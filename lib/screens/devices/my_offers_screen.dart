import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/device_service.dart';
import 'add_device_screen.dart';

/// ======================================================
/// MIJN AANBIEDINGEN SCREEN
/// Apple / iOS geïnspireerde stijl
/// ======================================================

class MyOffersScreen extends StatelessWidget {
  const MyOffersScreen({super.key});

  static const Color primaryGreen =
  Color(0xFF2E7D32);

  /// --------------------------------------------------
  /// PRIJS LEZEN
  /// --------------------------------------------------

  double? _readPrice(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return null;
  }

  /// --------------------------------------------------
  /// DATUM LEZEN
  /// --------------------------------------------------

  DateTime? _readDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    return null;
  }

  /// --------------------------------------------------
  /// DATUM FORMATTEREN
  /// --------------------------------------------------

  String _formatDate(DateTime? date) {
    if (date == null) {
      return "Onbekend";
    }

    final day =
    date.day.toString().padLeft(2, '0');

    final month =
    date.month.toString().padLeft(2, '0');

    return "$day/$month/${date.year}";
  }

  /// --------------------------------------------------
  /// LEGE / FOUT STATUS
  /// --------------------------------------------------

  Widget _buildStateMessage(
      String message) {
    return Center(
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black54,
        ),
      ),
    );
  }

  /// --------------------------------------------------
  /// AFBEELDING TOESTEL
  /// --------------------------------------------------

  Widget _buildDeviceImage(
      String imageUrl) {
    if (imageUrl.isEmpty) {
      return Container(
        width: 74,
        height: 74,
        decoration: BoxDecoration(
          color:
          const Color(0xFFEAF3EB),
          borderRadius:
          BorderRadius.circular(
              18),
        ),
        child: const Icon(
          Icons.inventory_2_outlined,
          color: primaryGreen,
          size: 28,
        ),
      );
    }

    final isAsset =
    imageUrl.startsWith(
        "assets/");

    return ClipRRect(
      borderRadius:
      BorderRadius.circular(18),
      child: isAsset
          ? Image.asset(
        imageUrl,
        width: 74,
        height: 74,
        fit: BoxFit.cover,
      )
          : Image.network(
        imageUrl,
        width: 74,
        height: 74,
        fit: BoxFit.cover,
      ),
    );
  }

  /// --------------------------------------------------
  /// DEVICE CARD
  /// --------------------------------------------------

  Widget _buildDeviceCard(
      Map<String, dynamic> data) {
    final title =
    (data["title"] ??
        "Onbekend toestel")
        .toString();

    final description =
    (data["description"] ??
        "")
        .toString();

    final category =
    (data["category"] ??
        "Onbekend")
        .toString();

    final location =
    (data["location"] ?? "")
        .toString();

    final imageUrl =
    (data["imageUrl"] ?? "")
        .toString();

    final price =
    _readPrice(
        data["pricePerDay"]);

    final availableFrom =
    _readDate(
        data["availableFrom"]);

    final availableTo =
    _readDate(
        data["availableTo"]);

    final availability =
        "${_formatDate(availableFrom)} - ${_formatDate(availableTo)}";

    return Container(
      margin:
      const EdgeInsets.only(
        bottom: 14,
      ),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(
            24),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(
                alpha: 0.04),
            blurRadius: 18,
            offset:
            const Offset(0, 8),
          ),
        ],
      ),

      child: Padding(
        padding:
        const EdgeInsets.all(
            16),

        child: Row(
          crossAxisAlignment:
          CrossAxisAlignment
              .start,

          children: [

            _buildDeviceImage(
                imageUrl),

            const SizedBox(
                width: 14),

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
                      17,
                      fontWeight:
                      FontWeight
                          .bold,
                    ),
                  ),

                  const SizedBox(
                      height: 4),

                  Text(
                    category,
                    style:
                    const TextStyle(
                      color: Colors
                          .black54,
                    ),
                  ),

                  if (description
                      .isNotEmpty)
                    Padding(
                      padding:
                      const EdgeInsets.only(
                          top:
                          6),
                      child: Text(
                        description,
                        maxLines: 2,
                        overflow:
                        TextOverflow
                            .ellipsis,
                      ),
                    ),

                  const SizedBox(
                      height: 8),

                  Text(
                    "Beschikbaar: $availability",
                    style:
                    const TextStyle(
                      fontSize:
                      13,
                      color: Colors
                          .black54,
                    ),
                  ),

                  if (location
                      .isNotEmpty)
                    Padding(
                      padding:
                      const EdgeInsets.only(
                          top:
                          4),
                      child: Text(
                        "Locatie: $location",
                        style:
                        const TextStyle(
                          fontSize:
                          13,
                          color: Colors
                              .black54,
                        ),
                      ),
                    ),

                  const SizedBox(
                      height: 4),

                  Text(
                    price == null
                        ? "Prijs onbekend"
                        : "€ ${price.toStringAsFixed(2)} / dag",
                    style:
                    const TextStyle(
                      fontSize:
                      13,
                      color:
                      primaryGreen,
                      fontWeight:
                      FontWeight
                          .w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(
      BuildContext context) {
    final user =
        FirebaseAuth.instance
            .currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor:
        Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor:
          Colors.white,
          foregroundColor:
          Colors.black,
          title: const Text(
            "Mijn aanbiedingen",
          ),
        ),
        body: _buildStateMessage(
          "Log in om je aanbiedingen te zien.",
        ),
      );
    }

    return Scaffold(
      backgroundColor:
      const Color(0xFFF7F7F7),

      appBar: AppBar(
        elevation: 0,
        backgroundColor:
        const Color(0xFFF7F7F7),
        foregroundColor:
        Colors.black,
        title: const Text(
          "Mijn aanbiedingen",
          style: TextStyle(
            fontWeight:
            FontWeight.bold,
          ),
        ),
      ),

      floatingActionButton:
      FloatingActionButton(
        backgroundColor:
        primaryGreen,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
              const AddDeviceScreen(),
            ),
          );
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),

      body: StreamBuilder<
          QuerySnapshot<
              Map<String, dynamic>>>(
        stream: DeviceService()
            .streamOwnerDevices(
            user.uid),

        builder:
            (context, snapshot) {

          if (snapshot
              .connectionState ==
              ConnectionState
                  .waiting) {
            return const Center(
              child:
              CircularProgressIndicator(
                color:
                primaryGreen,
              ),
            );
          }

          if (snapshot.hasError) {
            return _buildStateMessage(
              "Fout bij laden van aanbiedingen.",
            );
          }

          final docs =
              snapshot.data?.docs ??
                  [];

          if (docs.isEmpty) {
            return _buildStateMessage(
              "Nog geen aanbiedingen.",
            );
          }

          return ListView.builder(
            padding:
            const EdgeInsets.all(
                20),
            itemCount:
            docs.length,
            itemBuilder:
                (context, index) {
              return _buildDeviceCard(
                docs[index].data(),
              );
            },
          );
        },
      ),
    );
  }
}