import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../search/search_screen.dart';
import '../profile/profile_screen.dart';

/// ======================================================
/// HOME SCREEN
/// Bottom navigation met:
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

  /// Primaire kleur app
  static const Color primaryGreen =
  Color(0xFF2E7D32);

  /// Actieve tab index
  int _selectedIndex = 0;

  /// Firebase gebruiker
  final User? user =
      FirebaseAuth.instance.currentUser;

  /// Firestore user document
  DocumentSnapshot? _userDoc;

  @override
  void initState() {
    super.initState();
    _loadUserDoc();
  }

  /// Wissel tab
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /// Haal gebruiker op
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

  /// Naam gebruiker tonen
  String get userName {
    if (_userDoc == null) {
      return "Gebruiker";
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

    /// Pagina's gekoppeld aan tabs
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

          /// HOME
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home_outlined,
            ),
            activeIcon:
            Icon(Icons.home),
            label: "Home",
          ),

          /// ZOEKEN
          BottomNavigationBarItem(
            icon: Icon(
              Icons.search_outlined,
            ),
            activeIcon:
            Icon(Icons.search),
            label: "Zoeken",
          ),

          /// PROFIEL
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person_outline,
            ),
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
    return SafeArea(
      child: Padding(
        padding:
        const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment
              .start,
          children: [

            /// Logo
            const Text(
              "RentBy",
              style: TextStyle(
                fontSize: 30,
                fontWeight:
                FontWeight.bold,
                color:
                primaryGreen,
              ),
            ),

            const SizedBox(
                height: 8),

            /// Welkom tekst
            Text(
              "Welkom terug, $userName 👋",
              style:
              const TextStyle(
                fontSize: 22,
                fontWeight:
                FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}