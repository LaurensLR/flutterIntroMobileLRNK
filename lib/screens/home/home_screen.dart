import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Simpel HomeScreen om te testen of login werkt.
/// Toont: Welkom + email van ingelogde gebruiker.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    /// Huidige ingelogde user ophalen
    final User? user = FirebaseAuth.instance.currentUser;

    /// Naam tonen als displayName bestaat,
    /// anders email tonen.
    final String userName =
        user?.displayName ??
        user?.email ??
        "Gebruiker";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("RentBy"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),

      body: Center(
        child: Text(
          "Welkom $userName",
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ),
    );
  }
}