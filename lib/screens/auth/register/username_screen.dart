import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'welcome_screen.dart';

/// Scherm waar nieuwe gebruikers een gebruikersnaam kiezen tijdens de registratie.
///
/// Na bevestiging wordt de gebruikersnaam opgeslagen in Firestore en wordt
/// de gebruiker doorgestuurd naar het welkomstscherm.
class UsernameScreen extends StatefulWidget {
  /// Voornaam van de gebruiker, getoond in de begroeting.
  final String firstName;

  /// Achternaam van de gebruiker.
  final String lastName;

  const UsernameScreen({
    super.key,
    required this.firstName,
    required this.lastName,
  });

  @override
  State<UsernameScreen> createState() => _UsernameScreenState();
}

class _UsernameScreenState extends State<UsernameScreen> {
  /// Primaire merkkleur van RentBy, gebruikt doorheen het scherm.
  static const Color primaryGreen = Color(0xFF2E7D32);

  /// Controller voor het tekstveld waar de gebruiker zijn gebruikersnaam invoert.
  final TextEditingController _usernameController = TextEditingController();

  @override
  void dispose() {
    // Controller vrijgeven om geheugenlekken te vermijden.
    _usernameController.dispose();
    super.dispose();
  }

  /// Slaat de gekozen gebruikersnaam op in Firestore voor de ingelogde gebruiker.
  ///
  /// Valideert eerst of het veld niet leeg is. Bij succes wordt de gebruiker
  /// doorgestuurd naar [WelcomeToRentByScreen] en wordt de navigatiestack gewist.
  ///
  /// Keert stil terug als [FirebaseAuth.instance.currentUser] null is.
  Future<void> _saveUsername() async {
    final username = _usernameController.text.trim().toLowerCase();

    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kies een gebruikersnaam")),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Sla de gebruikersnaam op in het Firestore-document van de gebruiker.
    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .update({"username": username});

    // Navigeer naar het welkomstscherm en verwijder alle vorige routes.
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeToRentByScreen()),
          (route) => false,
    );
  }

  /// Bouwt het volledige scherm met:
  /// - RentBy-logo en welkomsttekst
  /// - Tekstveld voor de gebruikersnaam (met @-prefix)
  /// - Bevestigingsknop om de gebruikersnaam op te slaan
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App-titel
                const Text(
                  "RentBy",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: primaryGreen,
                  ),
                ),

                const SizedBox(height: 14),

                // Persoonlijke begroeting
                Text(
                  "Welkom ${widget.firstName} ${widget.lastName} 👋",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Kies een gebruikersnaam",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 30),

                // Invoerveld voor de gebruikersnaam
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: "Gebruikersnaam",
                    prefixText: "@",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: primaryGreen,
                        width: 2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Bevestigingsknop
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _saveUsername,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "Registreer",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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