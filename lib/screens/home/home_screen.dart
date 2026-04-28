import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../devices/add_device_screen.dart';
import '../devices/my_offers_screen.dart';
import '../reservations/my_reservations_screen.dart';
import '../reservations/owner_reservations_screen.dart';

/// Simpel HomeScreen om te testen of login werkt.
/// Toont: Welkom + email van ingelogde gebruiker.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const Color primaryGreen = Color(0xFF2E7D32);

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE3EAE4)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: primaryGreen.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: primaryGreen),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.black38),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    /// Huidige ingelogde user ophalen
    final User? user = FirebaseAuth.instance.currentUser;

    /// Naam tonen als displayName bestaat,
    /// anders email tonen.
    final String userName = user?.displayName ?? user?.email ?? "Gebruiker";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("RentBy"),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welkom $userName",
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: primaryGreen,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Wat wil je vandaag doen?",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 22),
              _buildActionCard(
                title: "Toestel aanbieden",
                subtitle: "Voeg een toestel toe met prijs en beschikbaarheid",
                icon: Icons.add_circle_outline,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddDeviceScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),
              _buildActionCard(
                title: "Mijn aanbiedingen",
                subtitle: "Bekijk en beheer je toestellen",
                icon: Icons.inventory_2_outlined,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyOffersScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),
              _buildActionCard(
                title: "Mijn reservaties",
                subtitle: "Overzicht van je reserveringen als huurder",
                icon: Icons.event_available_outlined,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyReservationsScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),
              _buildActionCard(
                title: "Mijn reservaties (verhuurder)",
                subtitle: "Bekijk reserveringen voor je eigen toestellen",
                icon: Icons.assignment_outlined,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OwnerReservationsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
