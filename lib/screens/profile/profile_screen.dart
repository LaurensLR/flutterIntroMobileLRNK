import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_settings_screen.dart';

/// Profielpagina van RentBy.
///
/// Toont de gebruikersinfo (naam, e-mail, lid sinds), navigatieopties
/// voor account- en activiteitsinstellingen, en een uitlogknop.
/// Ondersteunt zowel particuliere als bedrijfsaccounts.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  /// Primaire merkkleur van RentBy.
  static const Color primaryGreen = Color(0xFF2E7D32);

  /// De huidig ingelogde Firebase-gebruiker.
  final User? user = FirebaseAuth.instance.currentUser;

  /// Firestore-document van de ingelogde gebruiker.
  DocumentSnapshot? _userDoc;

  @override
  void initState() {
    super.initState();
    _loadUserDoc();
  }

  /// Haalt het Firestore-document van de ingelogde gebruiker op.
  Future<void> _loadUserDoc() async {
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get();

    if (doc.exists) {
      setState(() => _userDoc = doc);
    }
  }

  /// Geeft de weergavenaam terug op basis van het accounttype.
  ///
  /// - Bedrijf → bedrijfsnaam
  /// - Particulier → voornaam + achternaam
  /// - Fallback → "Gebruiker"
  String get userName {
    if (_userDoc == null) return "Gebruiker";

    final data = _userDoc!.data() as Map<String, dynamic>;
    final isBusiness = data["isBusiness"] ?? false;

    if (isBusiness) {
      return data["companyName"] ?? "Gebruiker";
    }

    final first = data["firstName"] ?? "";
    final last = data["lastName"] ?? "";
    final fullName = "$first $last".trim();

    return fullName.isNotEmpty ? fullName : "Gebruiker";
  }

  @override
  Widget build(BuildContext context) {
    final String email = user?.email ?? "Geen e-mail";

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Paginatitel
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Profiel",
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Profielkaart met avatar, naam, e-mail en lidmaatschapsdatum
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Circulaire avatar
                    Container(
                      width: 74,
                      height: 74,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8F5E9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 38,
                        color: primaryGreen,
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Naam, e-mail en lidmaatschapsdatum
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            email,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey.shade600,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            "Lid sinds april 2026",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Sectie: Account
              buildSectionTitle("Account"),
              buildSectionCard(
                children: [
                  buildTile(
                    icon: Icons.settings,
                    title: "Profielinstellingen",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProfileSettingsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Sectie: Mijn activiteit
              buildSectionTitle("Mijn activiteit"),
              buildSectionCard(
                children: [
                  buildTile(
                    icon: Icons.sell,
                    title: "Mijn aanbiedingen",
                    onTap: () {},
                  ),
                  buildDivider(),
                  buildTile(
                    icon: Icons.sync_alt,
                    title: "Lopende verhuringen",
                    onTap: () {},
                  ),
                  buildDivider(),
                  buildTile(
                    icon: Icons.shopping_bag,
                    title: "Mijn reservaties",
                    onTap: () {},
                  ),
                  buildDivider(),
                  buildTile(
                    icon: Icons.history,
                    title: "Verhuurgeschiedenis",
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Uitlogknop — meldt de gebruiker af via Firebase en keert terug
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    "Uitloggen",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Bouwt een grijs sectielabel boven een [buildSectionCard].
  ///
  /// [title] — de weer te geven sectienaam.
  Widget buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  /// Bouwt een witte kaart met afgeronde hoeken en lichte schaduw
  /// als container voor een groep [buildTile]-items.
  ///
  /// [children] — de lijst van tiles en dividers binnen de kaart.
  Widget buildSectionCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  /// Bouwt een dunne scheidingslijn tussen tiles in een [buildSectionCard].
  Widget buildDivider() {
    return Divider(
      height: 1,
      indent: 56,
      color: Colors.grey.shade200,
    );
  }

  /// Bouwt een aanklikbare rij met een icoon, titel en pijl-indicator.
  ///
  /// [icon] — het icoon aan de linkerkant.
  /// [title] — de weergegeven tekst.
  /// [onTap] — callback die wordt uitgevoerd bij aantikken.
  Widget buildTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 2,
      ),
      leading: Icon(icon, color: primaryGreen),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
    );
  }
}