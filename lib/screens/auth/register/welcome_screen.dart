import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../home/home_screen.dart';

/// Welkomstscherm dat kort getoond wordt na een succesvolle registratie.
///
/// Haalt de gebruikersnaam op uit Firestore en navigeert na 5 seconden
/// automatisch naar [HomeScreen]. De navigatiestack wordt volledig gewist
/// zodat de gebruiker niet kan terugkeren naar het registratieproces.
class WelcomeToRentByScreen extends StatefulWidget {
  const WelcomeToRentByScreen({super.key});

  @override
  State<WelcomeToRentByScreen> createState() => _WelcomeToRentByScreenState();
}

class _WelcomeToRentByScreenState extends State<WelcomeToRentByScreen> {
  /// Primaire merkkleur van RentBy, gebruikt doorheen het scherm.
  static const Color primaryGreen = Color(0xFF2E7D32);

  /// Gebruikersnaam opgehaald uit Firestore. Standaard "Gebruiker" als fallback.
  String username = "Gebruiker";

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _goToHome();
  }

  /// Haalt de gebruikersnaam van de ingelogde gebruiker op uit Firestore.
  ///
  /// Keert stil terug als er geen ingelogde gebruiker is of als het document
  /// niet bestaat. Gebruikt "Gebruiker" als fallback wanneer het veld ontbreekt.
  Future<void> _loadUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    if (doc.exists) {
      setState(() {
        username = doc["username"] ?? "Gebruiker";
      });
    }
  }

  /// Start een timer van 5 seconden waarna de gebruiker naar [HomeScreen] wordt gestuurd.
  ///
  /// Controleert [mounted] voor de navigatie om fouten te vermijden wanneer
  /// het scherm vroegtijdig wordt verlaten.
  void _goToHome() {
    Timer(const Duration(seconds: 5), () {
      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
      );
    });
  }

  /// Bouwt het welkomstscherm met:
  /// - Circulair icoontje met handshake-icoon
  /// - RentBy-logo en persoonlijke begroeting met gebruikersnaam
  /// - Beschrijvende ondertitel
  /// - Laadanimatie die de automatische navigatie visueel aanduidt
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Circulair icoontje
              Container(
                width: 110,
                height: 110,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.handshake,
                  size: 55,
                  color: primaryGreen,
                ),
              ),

              const SizedBox(height: 30),

              // App-titel
              const Text(
                "RentBy",
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: primaryGreen,
                ),
              ),

              const SizedBox(height: 18),

              // Persoonlijke begroeting met gebruikersnaam
              Text(
                "Welkom bij RentBy $username 👋",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 12),

              // Beschrijvende ondertitel
              const Text(
                "Jouw account is klaar om toestellen te huren en verhuren.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),

              const SizedBox(height: 40),

              // Laadanimatie als visuele indicator voor de automatische navigatie
              const CircularProgressIndicator(color: primaryGreen),
            ],
          ),
        ),
      ),
    );
  }
}