import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart'; // voor kIsWeb
import 'dart:io';

import '../auth/login_screen.dart';
// import '../rating/rate_screen.dart';
import '../rating/ratings_screen.dart';
import 'profile_settings_screen.dart';
import '../devices/my_offers_screen.dart';
import '../reservations/my_reservations_screen.dart';
import '../reservations/owner_reservations_screen.dart';

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

  final User? user =
      FirebaseAuth.instance.currentUser;

  String userName = "Gebruiker";
  String email = "";
  String? photoUrl;

  bool isLoading = true;
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  /// 🔗 LOAD PROFILE
  Future<void> loadProfile() async {
    if (user == null) return;

    final doc = await FirebaseFirestore
        .instance
        .collection("users")
        .doc(user!.uid)
        .get();

    if (doc.exists) {
      final data = doc.data()!;

      setState(() {
        userName =
            "${data["firstName"] ?? ""} ${data["lastName"] ?? ""}".trim();
        if (userName.isEmpty) {
          userName = "Gebruiker";
        }

        email = user?.email ?? "";
        photoUrl = data["photoUrl"];
        isLoading = false;
      });
    } else {
      setState(() {
        email = user?.email ?? "";
        isLoading = false;
      });
    }
  }

  /// 📷 PICK + UPLOAD IMAGE
  Future<void> pickAndUploadImage() async {
    final picker = ImagePicker();

    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (picked == null) return;

    setState(() => isUploading = true);

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child("profile_images/${user!.uid}.jpg");

      if (kIsWeb) {
        /// 🌐 WEB
        final bytes = await picked.readAsBytes();
        await ref.putData(bytes);
      } else {
        /// 📱 MOBILE
        final file = File(picked.path);
        await ref.putFile(file);
      }

      final url = await ref.getDownloadURL();

      print("DOWNLOAD URL: $url");

      await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .update({
        "photoUrl": url,
      });

      setState(() {
        photoUrl = url;
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Fout: $e")),
      );
    }

    setState(() => isUploading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
            child: CircularProgressIndicator()),
      );
    }



    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Text(
                "Profiel",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              const SizedBox(height: 28),

              /// HEADER
              Container(
                padding:
                const EdgeInsets.all(22),
                decoration:
                BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.circular(28),
                ),
                child: Row(
                  children: [

                    /// 📷 AVATAR
                    GestureDetector(
                      onTap: pickAndUploadImage,
                      child: Stack(
                        children: [
                          Container(
                            width: 82,
                            height: 82,
                            decoration:
                            BoxDecoration(
                              shape: BoxShape.circle,
                              color: primaryGreen.withValues(alpha: 0.12),
                              image: photoUrl !=
                                  null
                                  ? DecorationImage(
                                image:
                                NetworkImage(
                                    photoUrl!),
                                fit: BoxFit
                                    .cover,
                              )
                                  : null,
                            ),
                            child: photoUrl ==
                                null
                                ? const Icon(
                              Icons.person,
                              size: 42,
                              color:
                              primaryGreen,
                            )
                                : null,
                          ),

                          /// ✏️ EDIT ICON
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding:
                              const EdgeInsets
                                  .all(4),
                              decoration:
                              const BoxDecoration(
                                color: Colors.green,
                                shape:
                                BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.edit,
                                size: 14,
                                color:
                                Colors.white,
                              ),
                            ),
                          ),

                          if (isUploading)
                            const Positioned.fill(
                              child: Center(
                                child:
                                CircularProgressIndicator(),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 18),

                    /// INFO
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                        children: [
                          Text(
                            userName,
                            style:
                            const TextStyle(
                              fontSize: 24,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                              height: 6),
                          Text(
                            email,
                            style: TextStyle(
                              color: Colors
                                  .grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              /// ACCOUNT
              buildSectionTitle("Account"),
              buildCard(children: [

                buildTile(
                  context: context,
                  icon: Icons.settings,
                  title: "Profielinstellingen",
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

                divider(),

                buildTile(
                  context: context,
                  icon: Icons.star,
                  title: "Mijn beoordelingen",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            RatingsScreen(
                              userId: user!.uid,
                            ),
                      ),
                    );
                  },
                ),
              ]),

              /*
              buildTile(
                context: context,
                icon: Icons.star,
                title: "Beoordeel",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RateScreen(),
                    ),
                  );
                },
              ),
*/
              const SizedBox(height: 24),

              /// ACTIVITEIT
              buildSectionTitle(
                  "Mijn activiteit"),
              buildCard(children: [

                buildTile(
                  context: context,
                  icon: Icons.sell,
                  title: "Mijn aanbiedingen",
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
                  context: context,
                  icon: Icons.sync_alt,
                  title:
                  "Lopende verhuringen",
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
                  context: context,
                  icon: Icons.shopping_bag,
                  title:
                  "Mijn reservaties",
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
              ]),

              const SizedBox(height: 30),

              /// LOGOUT
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    await FirebaseAuth
                        .instance
                        .signOut();

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                        const LoginScreen(),
                      ),
                          (route) => false,
                    );
                  },
                  style:
                  ElevatedButton.styleFrom(
                    backgroundColor:
                    primaryGreen,
                    foregroundColor:
                    Colors.white,
                  ),
                  child:
                  const Text("Uitloggen"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// COMPONENTS
  Widget buildSectionTitle(String title) {
    return Padding(
      padding:
      const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color:
          Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget buildCard({
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(24),
      ),
      child: Column(children: children),
    );
  }

  Widget buildTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding:
        const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(icon,
                color: primaryGreen),
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
      color: Colors.grey.shade200,
      height: 1,
    );
  }
}