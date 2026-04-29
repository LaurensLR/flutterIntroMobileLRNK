import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth/login_screen.dart';
import 'profile_settings_screen.dart';
import '../devices/my_offers_screen.dart';
import '../reservations/my_reservations_screen.dart';
import '../reservations/owner_reservations_screen.dart';

/// ======================================================
/// PROFILE SCREEN
/// Profielfoto upload + Firestore opslaan
/// ======================================================
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState
    extends State<ProfileScreen> {
  static const Color primaryGreen =
  Color(0xFF2E7D32);

  final User? user = FirebaseAuth.instance.currentUser;
  String userName = "Gebruiker";
  String email = "";

  bool isLoading = true;

  /// ======================================================
  /// START
  /// ======================================================
  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  /// ======================================================
  /// FIRESTORE DATA LADEN
  /// ======================================================
  Future<void> loadProfile() async {
    if (user == null) return;

    final doc =
    await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get();

    if (doc.exists) {
      final data =
      doc.data()!;

      setState(() {
        userName = data["firstName"] + " " + data["lastName"] ?? "Gebruiker";
        email = user?.email ?? "";
        isLoading = false;
      });
    } else {
      setState(() {
        email =
            user?.email ??
                "";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(
      BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child:
          CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor:
      const Color(
          0xFFF7F7F7),

      body: SafeArea(
        child:
        SingleChildScrollView(
          padding:
          const EdgeInsets.all(
              20),

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment
                .start,
            children: [

              /// TITEL
              const Text(
                "Profiel",
                style:
                TextStyle(
                  fontSize: 36,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              const SizedBox(
                  height: 28),

              /// HEADER
              Container(
                padding:
                const EdgeInsets.all(
                    22),
                decoration:
                BoxDecoration(
                  color:
                  Colors.white,
                  borderRadius:
                  BorderRadius.circular(
                      28),
                ),

                child: Row(
                  children: [

                    /// FOTO PICKER
                    Container(
                      width: 82,
                      height: 82,
                      decoration: BoxDecoration(
                        color: primaryGreen.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 42,
                        color: primaryGreen,
                      ),
                    ),

                    const SizedBox(
                        width: 18),

                    /// INFO
                    Expanded(
                      child:
                      Column(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                        children: [

                          Text(
                            userName,
                            style:
                            const TextStyle(
                              fontSize:
                              24,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),

                          const SizedBox(
                              height:
                              6),

                          Text(
                            email,
                            style:
                            TextStyle(
                              color: Colors
                                  .grey
                                  .shade600,
                            ),
                          ),

                          const SizedBox(
                              height:
                              8),

                          Container(
                            padding:
                            const EdgeInsets.symmetric(
                              horizontal:
                              10,
                              vertical:
                              6,
                            ),
                            decoration:
                            BoxDecoration(
                              color:
                              const Color(
                                  0xFFF2F2F2),
                              borderRadius:
                              BorderRadius.circular(
                                  30),
                            ),
                            child:
                            const Text(
                              "Lid sinds 2026",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                  height: 28),

              /// ACCOUNT
              buildSectionTitle(
                  "Account"),

              buildCard(
                children: [
                  buildTile(
                    context:
                    context,
                    icon:
                    Icons.settings,
                    title:
                    "Profielinstellingen",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                          const ProfileSettingsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(
                  height: 24),

              /// ACTIVITEIT
              buildSectionTitle(
                  "Mijn activiteit"),

              buildCard(
                children: [

                  buildTile(
                    context:
                    context,
                    icon:
                    Icons.sell,
                    title:
                    "Mijn aanbiedingen",
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

                  divider(),

                  buildTile(
                    context:
                    context,
                    icon: Icons.sync_alt,
                    title: "Lopende verhuringen",
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

                  divider(),

                  buildTile(
                    context:
                    context,
                    icon: Icons.shopping_bag,
                    title: "Mijn reservaties",
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
                ],
              ),

              const SizedBox(
                  height: 30),

              /// LOGOUT
              SizedBox(
                width:
                double.infinity,
                height: 56,
                child:
                ElevatedButton(
                  onPressed:
                      () async {
                    await FirebaseAuth
                        .instance
                        .signOut();

                    Navigator.pushAndRemoveUntil(
                      context, MaterialPageRoute(
                        builder: (_) =>
                        const LoginScreen(),
                      ),
                          (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                  ),
                  child:
                  const Text(
                    "Uitloggen",
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ======================================================
  /// COMPONENTEN
  /// ======================================================

  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title, style:
        TextStyle(
          fontWeight:
          FontWeight.bold,
          color:
          Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget buildCard({
    required List<Widget>
    children,
  }) {
    return Container(
      decoration:
      BoxDecoration(
        color:
        Colors.white,
        borderRadius:
        BorderRadius.circular(24),
      ),
      child:
      Column(
        children:
        children,
      ),
    );
  }

  Widget buildTile({
    required BuildContext
    context,
    required IconData icon,
    required String title,
    required VoidCallback
    onTap,
  }) {
    return InkWell(
      onTap: onTap,
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      focusColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(icon, color: primaryGreen),
            const SizedBox(width: 14),
            Expanded(child: Text(title)),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  Widget divider() {
    return Divider(
      color: Colors
          .grey.shade200,
      height: 1,
    );
  }
}