import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../firebase/auth_service.dart';
import 'company_screen.dart';

/// Registratie scherm voor RentBy
class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final AuthService _authService = AuthService();

  /// Controllers
  final TextEditingController _firstNameController =
  TextEditingController();

  final TextEditingController _lastNameController =
  TextEditingController();

  final TextEditingController _emailController =
  TextEditingController();

  final TextEditingController _passwordController =
  TextEditingController();

  final TextEditingController
  _confirmPasswordController =
  TextEditingController();

  static const Color primaryGreen =
  Color(0xFF2E7D32);

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Eerste letter hoofdletter
  String capitalize(String text) {
    if (text.isEmpty) return text;

    return text[0].toUpperCase() +
        text.substring(1).toLowerCase();
  }

  /// Verder naar volgende stap
  Future<void> _nextStep() async {
    final firstName = capitalize(
      _firstNameController.text.trim(),
    );

    final lastName = capitalize(
      _lastNameController.text.trim(),
    );

    final email =
    _emailController.text.trim();

    final password =
    _passwordController.text.trim();

    final confirmPassword =
    _confirmPasswordController.text.trim();

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Vul alle velden in",
          ),
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Wachtwoorden komen niet overeen",
          ),
        ),
      );
      return;
    }

    try {
      /// Firebase account maken
      final user =
      await _authService.register(
        email,
        password,
      );

      /// Firestore basis data
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .set({
        "uid": user.uid,
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "createdAt":
        FieldValue.serverTimestamp(),
      });

      /// Naar company_screen.dart
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
          const CompanyRegScreen(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Fout: $e",
          ),
        ),
      );
    }
  }

  Widget _input({
    required TextEditingController controller,
    required String label,
    bool obscure = false,
    TextInputType type =
        TextInputType.text,
  }) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 16,
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          border:
          OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(
                14),
          ),
          focusedBorder:
          OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(
                14),
            borderSide:
            const BorderSide(
              color:
              primaryGreen,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      Colors.white,

      body: Center(
        child:
        SingleChildScrollView(
          padding:
          const EdgeInsets.all(
              24),
          child:
          ConstrainedBox(
            constraints:
            const BoxConstraints(
              maxWidth: 430,
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .stretch,
              children: [
                const Text(
                  "RentBy",
                  textAlign:
                  TextAlign
                      .center,
                  style:
                  TextStyle(
                    fontSize:
                    34,
                    fontWeight:
                    FontWeight
                        .bold,
                    color:
                    primaryGreen,
                  ),
                ),

                const SizedBox(
                    height: 10),

                const Text(
                  "Maak een account",
                  textAlign:
                  TextAlign
                      .center,
                  style:
                  TextStyle(
                    fontSize:
                    22,
                    fontWeight:
                    FontWeight
                        .w600,
                  ),
                ),

                const SizedBox(
                    height: 30),

                _input(
                  controller:
                  _firstNameController,
                  label:
                  "Voornaam",
                ),

                _input(
                  controller:
                  _lastNameController,
                  label:
                  "Achternaam",
                ),

                _input(
                  controller:
                  _emailController,
                  label:
                  "E-mail",
                  type:
                  TextInputType
                      .emailAddress,
                ),

                _input(
                  controller:
                  _passwordController,
                  label:
                  "Wachtwoord",
                  obscure:
                  true,
                ),

                _input(
                  controller:
                  _confirmPasswordController,
                  label:
                  "Bevestig wachtwoord",
                  obscure:
                  true,
                ),

                const SizedBox(
                    height: 20),

                SizedBox(
                  height: 54,
                  child:
                  ElevatedButton(
                    onPressed:
                    _nextStep,
                    style:
                    ElevatedButton
                        .styleFrom(
                      backgroundColor:
                      primaryGreen,
                      foregroundColor:
                      Colors
                          .white,
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(
                            14),
                      ),
                    ),
                    child:
                    const Text(
                      "Volgende",
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}