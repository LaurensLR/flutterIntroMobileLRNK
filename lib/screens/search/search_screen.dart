import 'package:flutter/material.dart';

/// ======================================================
/// SEARCH SCREEN
/// ------------------------------------------------------
/// Zoekpagina voor RentBy.
/// Later uitbreidbaar met:
/// - zoeken op producten
/// - zoeken op categorie
/// - locatie filter
/// - prijs filter
/// - beschikbaarheid
/// ======================================================

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() =>
      _SearchScreenState();
}

class _SearchScreenState
    extends State<SearchScreen> {

  /// Primaire kleur app
  static const Color primaryGreen =
  Color(0xFF2E7D32);

  /// Zoekcontroller
  final searchController =
  TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          "Zoeken",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            /// Zoekveld
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText:
                "Zoek producten of diensten...",
                prefixIcon:
                const Icon(Icons.search),
                filled: true,
                fillColor:
                Colors.grey.shade100,
                border:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(
                      16),
                  borderSide:
                  BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// Voorbeeld resultaten
            Expanded(
              child: ListView(
                children: [

                  _buildResultTile(
                    title:
                    "Boormachine Bosch",
                    location:
                    "Luik",
                    price:
                    "€15 / dag",
                  ),

                  _buildResultTile(
                    title:
                    "Aanhangwagen",
                    location:
                    "Brussel",
                    price:
                    "€35 / dag",
                  ),

                  _buildResultTile(
                    title:
                    "Ladder 6 meter",
                    location:
                    "Antwerpen",
                    price:
                    "€12 / dag",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ======================================================
  /// RESULTAAT ITEM
  /// ======================================================

  Widget _buildResultTile({
    required String title,
    required String location,
    required String price,
  }) {
    return Card(
      elevation: 1,
      margin:
      const EdgeInsets.only(
        bottom: 12,
      ),
      shape:
      RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(16),
      ),

      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
          primaryGreen.withValues(alpha: 0.12),
          child: const Icon(
            Icons.inventory_2_outlined,
            color: primaryGreen,
          ),
        ),

        title: Text(
          title,
          style: const TextStyle(
            fontWeight:
            FontWeight.bold,
          ),
        ),

        subtitle: Text(
          "$location • $price",
        ),

        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
        ),

        onTap: () {
          /// later detailpagina openen
        },
      ),
    );
  }
}