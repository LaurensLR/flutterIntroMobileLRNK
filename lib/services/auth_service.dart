import 'package:firebase_auth/firebase_auth.dart';

/// Service class verantwoordelijk voor alle authenticatie-acties
/// via [Firebase Authentication].
///
/// Hier centraliseer je:
/// - Inloggen
/// - Registreren
/// - Uitloggen
///
/// Zo blijft je UI-code proper en overzichtelijk.
class AuthService {
  /// Referentie naar Firebase Authentication instance.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Logt een gebruiker in met e-mail en wachtwoord.
  ///
  /// Parameters:
  /// - [email]: e-mailadres van gebruiker
  /// - [password]: wachtwoord van gebruiker
  ///
  /// Return:
  /// - Geeft [User] terug als login succesvol is.
  /// - Geeft een fout als login mislukt.
  Future<User?> login(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return result.user;
  }

  /// Registreert een nieuwe gebruiker met e-mail en wachtwoord.
  ///
  /// Parameters:
  /// - [email]: nieuw e-mailadres
  /// - [password]: gekozen wachtwoord
  ///
  /// Return:
  /// - Geeft [User] terug wanneer account succesvol is aangemaakt.
  /// - Gooit fout bij ongeldig email of zwak wachtwoord.
  Future<User?> register(String email, String password) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    return result.user;
  }

  /// Logt de huidige gebruiker uit.
  ///
  /// Return:
  /// - Future voltooid wanneer uitloggen klaar is.
  Future<void> logout() async {
    await _auth.signOut();
  }
}
