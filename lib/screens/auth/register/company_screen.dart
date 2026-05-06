import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'username_screen.dart';

/// Bedrijfsregistratie scherm voor RentBy
class CompanyRegScreen extends StatefulWidget {
  const CompanyRegScreen({super.key});

  @override
  State<CompanyRegScreen> createState() =>
      _CompanyRegScreenState();
}

class _CompanyRegScreenState
    extends State<CompanyRegScreen> {
  static const Color primaryGreen =
  Color(0xFF2E7D32);

  bool _isBusiness = false;

  final TextEditingController
  _companyNameController =
  TextEditingController();

  final TextEditingController
  _vatNumberController =
  TextEditingController();

  @override
  void dispose() {
    _companyNameController.dispose();
    _vatNumberController.dispose();
    super.dispose();
  }

  /// Alles correct ingevuld?
  bool get isValid {
    if (!_isBusiness) return true;

    return _companyNameController
        .text
        .trim()
        .isNotEmpty &&
        _vatNumberController
            .text
            .trim()
            .isNotEmpty;
  }

  /// Verder naar username_screen.dart
  Future<void> _next() async {
    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) return;

    Map<String, dynamic> data = {
      "isBusiness": _isBusiness,
    };

    if (_isBusiness) {
      data["companyName"] =
          _companyNameController.text.trim();

      data["vatNumber"] =
          _vatNumberController.text.trim();
    }

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .update(data);

    /// user data ophalen voor username screen
    final doc =
    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    final firstName =
        doc["firstName"] ?? "";

    final lastName =
        doc["lastName"] ?? "";

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UsernameScreen(
          firstName: firstName,
          lastName: lastName,
        ),
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String label,
    TextInputType type =
        TextInputType.text,
    String? hint,
  }) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 16,
      ),
      child: TextField(
        controller: controller,
        keyboardType: type,
        onChanged: (_) {
          setState(() {});
        },
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
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
                  "Type account",
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
                    height: 8),

                const Text(
                  "Wil je registreren als particulier of bedrijf?",
                  textAlign:
                  TextAlign
                      .center,
                  style:
                  TextStyle(
                    color:
                    Colors.grey,
                  ),
                ),

                const SizedBox(
                    height: 30),

                Container(
                  padding:
                  const EdgeInsets.all(
                      14),
                  decoration:
                  BoxDecoration(
                    border:
                    Border.all(
                      color: const Color(
                          0xFFE0E0E0),
                    ),
                    borderRadius:
                    BorderRadius.circular(
                        14),
                  ),
                  child:
                  SwitchListTile(
                    contentPadding:
                    EdgeInsets.zero,
                    title:
                    const Text(
                      "Bedrijfsaccount",
                      style:
                      TextStyle(
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                    subtitle:
                    const Text(
                      "Ideaal voor winkels, verhuurbedrijven of zelfstandigen",
                    ),
                    value:
                    _isBusiness,
                    activeThumbColor:
                    primaryGreen,
                    onChanged:
                        (value) {
                      setState(() {
                        _isBusiness =
                            value;
                      });
                    },
                  ),
                ),

                const SizedBox(
                    height: 24),

                if (_isBusiness) ...[
                  _input(
                    controller:
                    _companyNameController,
                    label:
                    "Bedrijfsnaam",
                    hint:
                    "Bijv. Rent Solutions BV",
                  ),

                  _input(
                    controller:
                    _vatNumberController,
                    label:
                    "BTW nummer",
                    hint:
                    "BE0123456789",
                  ),

                  Container(
                    padding:
                    const EdgeInsets.all(
                        14),
                    decoration:
                    BoxDecoration(
                      color: const Color(
                          0xFFF5F5F5),
                      borderRadius:
                      BorderRadius.circular(
                          14),
                    ),
                    child:
                    const Text(
                      "Je bedrijfsgegevens worden enkel gebruikt voor vertrouwen en facturatie.",
                      style:
                      TextStyle(
                        color:
                        Colors.black87,
                      ),
                    ),
                  ),

                  const SizedBox(
                      height: 16),
                ],

                SizedBox(
                  height: 54,
                  child:
                  ElevatedButton(
                    onPressed:
                    isValid
                        ? _next
                        : null,
                    style:
                    ElevatedButton
                        .styleFrom(
                      backgroundColor:
                      primaryGreen,
                      foregroundColor:
                      Colors
                          .white,
                      disabledBackgroundColor:
                      Colors
                          .grey
                          .shade300,
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