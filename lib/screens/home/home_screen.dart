import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../search/search_screen.dart';
import '../profile/profile_screen.dart';
import '../devices/add_device_screen.dart';
import '../devices/my_offers_screen.dart';
import '../reservations/my_reservations_screen.dart';
import '../reservations/owner_reservations_screen.dart';

/// ======================================================
/// HOME SCREEN
/// Bottom navigation:
/// - Home
/// - Zoeken
/// - Profiel
/// ======================================================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends State<HomeScreen> {

  static const Color primaryGreen =
  Color(0xFF2E7D32);

  /// Actieve tab
  int _selectedIndex = 0;

  /// Firebase user
  final User? user =
      FirebaseAuth.instance.currentUser;

  /// Firestore data
  DocumentSnapshot? _userDoc;

  @override
  void initState() {
    super.initState();
    _loadUserDoc();
  }

  /// ======================================================
  /// USER DATA OPHALEN
  /// ======================================================

  Future<void> _loadUserDoc() async {
    if (user == null) return;

    final doc =
    await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get();

    if (doc.exists) {
      setState(() {
        _userDoc = doc;
      });
    }
  }

  /// ======================================================
  /// TAB WISSELEN
  /// ======================================================

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /// ======================================================
  /// GEBRUIKERSNAAM
  /// ======================================================

  String get userName {
    if (_userDoc == null) {
      return user?.displayName ??
          user?.email ??
          "Gebruiker";
    }

    final data =
    _userDoc!.data()
    as Map<String, dynamic>;

    final isBusiness =
        data["isBusiness"] ?? false;

    if (isBusiness) {
      return data["companyName"] ??
          "Gebruiker";
    }

    final first =
        data["firstName"] ?? "";

    final last =
        data["lastName"] ?? "";

    final fullName =
    "$first $last".trim();

    return fullName.isNotEmpty
        ? fullName
        : "Gebruiker";
  }

  @override
  Widget build(BuildContext context) {

    /// Pagina's tabs
    final List<Widget> pages = [
      _buildHomeContent(),
      const SearchScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,

      /// Actieve pagina
      body: pages[_selectedIndex],

      /// Bottom navigation
      bottomNavigationBar:
      BottomNavigationBar(
        currentIndex:
        _selectedIndex,
        selectedItemColor:
        primaryGreen,
        unselectedItemColor:
        Colors.grey,
        backgroundColor:
        Colors.white,
        type:
        BottomNavigationBarType
            .fixed,
        onTap: _onItemTapped,

        items: const [

          BottomNavigationBarItem(
            icon: Icon(
                Icons.home_outlined),
            activeIcon:
            Icon(Icons.home),
            label: "Home",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon:
            Icon(Icons.search),
            label: "Zoeken",
          ),

          BottomNavigationBarItem(
            icon: Icon(
                Icons.person_outline),
            activeIcon:
            Icon(Icons.person),
            label: "Profiel",
          ),
        ],
      ),
    );
  }

  /// ======================================================
  /// HOME PAGINA
  /// ======================================================

  Widget _buildHomeContent() {
    return Scaffold(
      appBar: AppBar(
        title: const Text("RentBy"),
        backgroundColor:
        primaryGreen,
        foregroundColor:
        Colors.white,
        centerTitle: true,
      ),

      body: SafeArea(
        child:
        SingleChildScrollView(
          padding:
          const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment
                .start,

            children: [

              /// Welkom
              Text(
                "Welkom $userName",
                style:
                const TextStyle(
                  fontSize: 26,
                  fontWeight:
                  FontWeight.bold,
                  color:
                  primaryGreen,
                ),
              ),

              const SizedBox(
                  height: 6),

              const Text(
                "Wat wil je vandaag doen?",
                style: TextStyle(
                  fontSize: 16,
                  color:
                  Colors.black54,
                ),
              ),

              const SizedBox(
                  height: 22),

              /// Toestel aanbieden
              _buildActionCard(
                title:
                "Toestel aanbieden",
                subtitle:
                "Voeg een toestel toe met prijs en beschikbaarheid",
                icon: Icons
                    .add_circle_outline,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                      const AddDeviceScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(
                  height: 14),

              /// Mijn aanbiedingen
              _buildActionCard(
                title:
                "Mijn aanbiedingen",
                subtitle:
                "Bekijk en beheer je toestellen",
                icon: Icons
                    .inventory_2_outlined,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                      const MyOffersScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(
                  height: 14),

              /// Mijn reservaties
              _buildActionCard(
                title:
                "Mijn reservaties",
                subtitle:
                "Overzicht van je reserveringen als huurder",
                icon: Icons
                    .event_available_outlined,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                      const MyReservationsScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(
                  height: 14),

              /// Reservaties verhuurder
              _buildActionCard(
                title:
                "Mijn reservaties (verhuurder)",
                subtitle:
                "Bekijk reserveringen voor je eigen toestellen",
                icon: Icons
                    .assignment_outlined,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                      const OwnerReservationsScreen(),
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

  /// ======================================================
  /// ACTION CARD
  /// ======================================================

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,

      shape:
      RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(
            16),
        side: const BorderSide(
          color:
          Color(0xFFE3EAE4),
        ),
      ),

      child: InkWell(
        borderRadius:
        BorderRadius.circular(
            16),
        onTap: onTap,

        child: Padding(
          padding:
          const EdgeInsets.all(
              16),

          child: Row(
            children: [

              Container(
                width: 48,
                height: 48,
                decoration:
                BoxDecoration(
                  color: primaryGreen
                      .withValues(
                      alpha:
                      0.12),
                  borderRadius:
                  BorderRadius.circular(
                      12),
                ),
                child: Icon(
                  icon,
                  color:
                  primaryGreen,
                ),
              ),

              const SizedBox(
                  width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [

                    Text(
                      title,
                      style:
                      const TextStyle(
                        fontSize:
                        16,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),

                    const SizedBox(
                        height:
                        4),

                    Text(
                      subtitle,
                      style:
                      const TextStyle(
                        color: Colors
                            .black54,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right,
                color:
                Colors.black38,
              ),
            ],
          ),
        ),
      ),
    );
  }
}