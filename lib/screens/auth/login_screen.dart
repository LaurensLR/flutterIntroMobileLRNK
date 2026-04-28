import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'register/register_screen.dart';
import '../../firebase/auth_service.dart';
import '../home/home_screen.dart';

/// RentBy Login Screen
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {
  final TextEditingController
  _loginController =
  TextEditingController();

  final TextEditingController
  _passwordController =
  TextEditingController();

  final AuthService _authService =
  AuthService();

  bool _obscurePassword = true;

  static const Color primaryGreen =
  Color(0xFF2E7D32);

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Login
  Future<void> _login() async {
    String login =
    _loginController.text.trim();

    final password =
    _passwordController.text.trim();

    if (login.isEmpty ||
        password.isEmpty) {
      _showSnack(
          "Vul alle velden in");
      return;
    }

    try {
      /// username -> email
      if (!login.contains("@")) {
        final query =
        await FirebaseFirestore
            .instance
            .collection(
            "users")
            .where(
          "username",
          isEqualTo: login
              .toLowerCase(),
        )
            .limit(1)
            .get();

        if (query.docs.isEmpty) {
          throw Exception();
        }

        login = query
            .docs.first["email"];
      }

      await _authService.login(
        login,
        password,
      );

      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(
          builder: (_) =>
          const HomeScreen(),
        ),
      );
    } catch (e) {
      _showSnack(
          "Login mislukt");
    }
  }

  void _showSnack(String text) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(text),
        behavior:
        SnackBarBehavior
            .floating,
      ),
    );
  }

  void _goToRegister() {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) =>
        const RegisterScreen(),
      ),
    );
  }

  Widget _input({
    required TextEditingController
    controller,
    required String label,
    bool obscure = false,
    Widget? suffix,
  }) {
    return Container(
      margin:
      const EdgeInsets.only(
          bottom: 16),
      decoration: BoxDecoration(
        color: const Color(
            0xFFF5F5F5),
        borderRadius:
        BorderRadius.circular(
            18),
        border: Border.all(
          color: const Color(
              0xFFE8E8E8),
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration:
        InputDecoration(
          hintText: label,
          border:
          InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18,
          ),
          suffixIcon: suffix,
        ),
      ),
    );
  }

  @override
  Widget build(
      BuildContext context) {
    return Scaffold(
      backgroundColor:
      Colors.white,

      body: SafeArea(
        child: Column(
          children: [
            /// FOTO HEADER
            SizedBox(
              height: 300,
              width:
              double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    "assets/images/login_header.png",
                    fit: BoxFit.cover,
                  ),

                  /// fade
                  Container(
                    decoration:
                    const BoxDecoration(
                      gradient:
                      LinearGradient(
                        begin: Alignment
                            .topCenter,
                        end: Alignment
                            .bottomCenter,
                        colors: [
                          Colors
                              .transparent,
                          Colors
                              .white,
                        ],
                        stops: [
                          0.55,
                          1
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// CONTENT
            Expanded(
              child: Center(
                child:
                SingleChildScrollView(
                  padding:
                  const EdgeInsets
                      .all(24),
                  child:
                  ConstrainedBox(
                    constraints:
                    const BoxConstraints(
                      maxWidth:
                      420,
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
                            36,
                            fontWeight:
                            FontWeight
                                .bold,
                          ),
                        ),

                        const SizedBox(
                            height:
                            8),

                        const Text(
                          "Welkom terug",
                          textAlign:
                          TextAlign
                              .center,
                          style:
                          TextStyle(
                            fontSize:
                            20,
                            color: Colors
                                .black54,
                          ),
                        ),

                        const SizedBox(
                            height:
                            34),

                        _input(
                          controller:
                          _loginController,
                          label:
                          "E-mail of username",
                        ),

                        _input(
                          controller:
                          _passwordController,
                          label:
                          "Wachtwoord",
                          obscure:
                          _obscurePassword,
                          suffix:
                          IconButton(
                            icon:
                            Icon(
                              _obscurePassword
                                  ? CupertinoIcons
                                  .eye_slash
                                  : CupertinoIcons
                                  .eye,
                            ),
                            onPressed:
                                () {
                              setState(
                                      () {
                                    _obscurePassword =
                                    !_obscurePassword;
                                  });
                            },
                          ),
                        ),

                        const SizedBox(
                            height:
                            10),

                        SizedBox(
                          height:
                          56,
                          child:
                          CupertinoButton(
                            color:
                            primaryGreen,
                            borderRadius:
                            BorderRadius.circular(
                                18),
                            onPressed:
                            _login,
                            child:
                            const Text(
                              "Inloggen",
                              style:
                              TextStyle(
                                color: Colors
                                    .white,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(
                            height:
                            22),

                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment
                              .center,
                          children: [
                            const Text(
                              "Nog geen account?",
                              style:
                              TextStyle(
                                color: Colors
                                    .black54,
                              ),
                            ),
                            CupertinoButton(
                              padding:
                              const EdgeInsets.only(
                                  left:
                                  6),
                              onPressed:
                              _goToRegister, minimumSize: Size(0, 0),
                              child:
                              const Text(
                                "Registreren",
                                style:
                                TextStyle(
                                  color:
                                  primaryGreen,
                                  fontWeight:
                                  FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}