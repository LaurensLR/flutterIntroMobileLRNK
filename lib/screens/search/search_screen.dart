import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// ======================================================
/// SEARCH SCREEN + FIREBASE
/// Devices laden uit Firestore
/// ======================================================

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const Color primaryGreen = Color(0xFF2E7D32);

  final searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Zoeken",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// Zoekveld
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: "Zoek toestellen...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 24),

          /// Titel
          const Text(
            "Suggesties uit de buurt",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 14),

          /// Firebase devices
          SizedBox(
            height: 260,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("devices")
                  .orderBy("createdAt", descending: true)
                  .limit(10)
                  .snapshots(),

              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("Geen toestellen gevonden"));
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index];

                    return _deviceCard(
                      title: data["title"],
                      city: data["location"],
                      price: "€${data["pricePerDay"]}/dag",
                      category: data["category"],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// ==========================
  /// DEVICE CARD
  /// ==========================
  Widget _deviceCard({
    required String title,
    required String city,
    required String price,
    required String category,
  }) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 90,
            decoration: BoxDecoration(
              color: primaryGreen.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Icon(
                Icons.inventory_2_outlined,
                size: 42,
                color: primaryGreen,
              ),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),

          const SizedBox(height: 4),

          Text(category, style: TextStyle(color: Colors.grey.shade600)),

          const SizedBox(height: 4),

          Text(city, style: TextStyle(color: Colors.grey.shade600)),

          const Spacer(),

          Text(
            price,
            style: const TextStyle(
              color: primaryGreen,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
