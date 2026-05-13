import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../rating/rate_screen.dart';

class OwnerReservationDetailScreen extends StatefulWidget {

  const OwnerReservationDetailScreen({
    super.key,
    required this.reservation,
  });

  final Map<String, dynamic> reservation;

  @override
  State<OwnerReservationDetailScreen> createState() =>
      _OwnerReservationDetailScreenState();
}

class _OwnerReservationDetailScreenState
    extends State<OwnerReservationDetailScreen> {

  static const Color primaryGreen =
  Color(0xFF2E7D32);

  bool alreadyReviewed = false;

  // ======================================================
  // REVIEW CHECK
  // ======================================================

  Future<bool> hasReviewed() async {

    final snapshot =
    await FirebaseFirestore.instance
        .collection('reservations')
        .doc(widget.reservation['id'])
        .collection('reviews')
        .where(
      'reviewerId',
      isEqualTo:
      widget.reservation['ownerId'],
    )
        .get();

    return snapshot.docs.isNotEmpty;
  }

  Future<void> loadReviewStatus() async {

    final reviewed =
    await hasReviewed();

    if (mounted) {
      setState(() {
        alreadyReviewed = reviewed;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadReviewStatus();
  }

  // ======================================================
  // HELPERS
  // ======================================================

  DateTime? _readDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    return null;
  }

  double _readPrice(dynamic value) {
    if (value is int) {
      return value.toDouble();
    }

    if (value is double) {
      return value;
    }

    if (value is num) {
      return value.toDouble();
    }

    return 0;
  }

  String _twoDigits(int value) {
    return value.toString().padLeft(2, '0');
  }

  String _formatDate(DateTime? date) {

    if (date == null) {
      return "Onbekend";
    }

    return "${_twoDigits(date.day)}/"
        "${_twoDigits(date.month)}/"
        "${date.year}";
  }

  String _formatTime(DateTime? date) {

    if (date == null) {
      return "--:--";
    }

    return "${_twoDigits(date.hour)}:"
        "${_twoDigits(date.minute)}";
  }

  Widget _infoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {

    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [

        Container(
          padding:
          const EdgeInsets.all(10),

          decoration: BoxDecoration(
            color: primaryGreen.withValues(
              alpha: 0.1,
            ),

            borderRadius:
            BorderRadius.circular(12),
          ),

          child: Icon(
            icon,
            color: primaryGreen,
            size: 20,
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [

              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color:
                  Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight:
                  FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ======================================================
  // UI
  // ======================================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
      const Color(0xFFF7F7F7),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,

        title: const Text(
          "Verhuring details",
        ),
      ),

      body: FutureBuilder<DocumentSnapshot>(

        // DEVICE
        future: FirebaseFirestore.instance
            .collection('devices')
            .doc(
          widget.reservation['deviceId'],
        )
            .get(),

        builder:
            (context, deviceSnapshot) {

          if (deviceSnapshot.connectionState ==
              ConnectionState.waiting) {

            return const Center(
              child:
              CircularProgressIndicator(),
            );
          }

          if (!deviceSnapshot.hasData ||
              !deviceSnapshot.data!.exists) {

            return const Center(
              child: Text(
                "Toestel niet gevonden",
              ),
            );
          }

          final deviceData =
          deviceSnapshot.data!.data()
          as Map<String, dynamic>;

          return FutureBuilder<DocumentSnapshot>(

            // RENTER
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(
              widget.reservation['renterId'],
            )
                .get(),

            builder:
                (context, renterSnapshot) {

              if (renterSnapshot.connectionState ==
                  ConnectionState.waiting) {

                return const Center(
                  child:
                  CircularProgressIndicator(),
                );
              }

              final renterData =
              renterSnapshot.data?.data()
              as Map<String, dynamic>?;

              // DEVICE
              final title =
                  deviceData['title'] ??
                      'Toestel';

              final category =
                  deviceData['category'] ??
                      '';

              final imageUrl =
                  deviceData['imageUrl'] ??
                      '';

              // RENTER
              final renterName =
                  "${renterData?['firstName'] ?? ''} "
                  "${renterData?['lastName'] ?? ''}";

              final renterUsername =
                  renterData?['username'] ??
                      '';

              final renterEmail =
                  renterData?['email'] ??
                      '';

              final renterPhoto =
                  renterData?['photoUrl'] ??
                      '';

              // RESERVATION
              final status =
                  widget.reservation['status'] ??
                      '';

              final totalPrice =
              _readPrice(
                widget.reservation['totalPrice'],
              );

              final fromDateTime =
              _readDate(
                widget.reservation['fromDateTime'],
              );

              final toDateTime =
              _readDate(
                widget.reservation['toDateTime'],
              );

              return SafeArea(
                child:
                SingleChildScrollView(

                  padding:
                  const EdgeInsets.all(18),

                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: [

                      // IMAGE
                      ClipRRect(
                        borderRadius:
                        BorderRadius.circular(22),

                        child: Image.network(
                          imageUrl,
                          height: 240,
                          width: double.infinity,
                          fit: BoxFit.cover,

                          errorBuilder:
                              (_, _, _) {

                            return Container(
                              height: 240,
                              color:
                              Colors.grey.shade200,

                              child:
                              const Center(
                                child: Icon(
                                  Icons.devices,
                                  size: 60,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 20),

                      // TITLE
                      Text(
                        title,
                        style:
                        const TextStyle(
                          fontSize: 28,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        category,
                        style: TextStyle(
                          fontSize: 15,
                          color:
                          Colors.grey.shade600,
                        ),
                      ),

                      const SizedBox(height: 18),

                      // STATUS
                      Container(
                        padding:
                        const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),

                        decoration:
                        BoxDecoration(
                          color:
                          primaryGreen.withValues(
                            alpha: 0.12,
                          ),

                          borderRadius:
                          BorderRadius.circular(30),
                        ),

                        child: Text(
                          status,

                          style:
                          const TextStyle(
                            fontWeight:
                            FontWeight.bold,
                            color: primaryGreen,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // INFO CARD
                      Container(
                        padding:
                        const EdgeInsets.all(20),

                        decoration:
                        BoxDecoration(
                          color: Colors.white,

                          borderRadius:
                          BorderRadius.circular(22),
                        ),

                        child: Column(
                          children: [

                            _infoTile(
                              icon:
                              Icons.login_rounded,

                              title:
                              "Start datum",

                              value:
                              "${_formatDate(fromDateTime)} om ${_formatTime(fromDateTime)}",
                            ),

                            const SizedBox(height: 20),

                            _infoTile(
                              icon:
                              Icons.logout_rounded,

                              title:
                              "Eind datum",

                              value:
                              "${_formatDate(toDateTime)} om ${_formatTime(toDateTime)}",
                            ),

                            const SizedBox(height: 20),

                            _infoTile(
                              icon:
                              Icons.euro_rounded,

                              title:
                              "Verdiensten",

                              value:
                              "€ ${totalPrice.toStringAsFixed(2)}",
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // RENTER CARD
                      Container(
                        padding:
                        const EdgeInsets.all(20),

                        decoration:
                        BoxDecoration(
                          color: Colors.white,

                          borderRadius:
                          BorderRadius.circular(22),
                        ),

                        child: Row(
                          children: [

                            CircleAvatar(
                              radius: 28,
                              backgroundColor:
                              Colors.grey.shade200,

                              child: ClipOval(
                                child:
                                renterPhoto.isNotEmpty
                                    ? Image.network(
                                  renterPhoto,
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                )
                                    : const Icon(
                                  Icons.person,
                                  size: 28,
                                ),
                              ),
                            ),

                            const SizedBox(width: 16),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,

                                children: [

                                  const Text(
                                    "Renter",
                                    style: TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    renterName,

                                    style:
                                    const TextStyle(
                                      fontSize: 17,
                                      fontWeight:
                                      FontWeight.bold,
                                    ),
                                  ),

                                  if (renterUsername.isNotEmpty)
                                    Text(
                                      "@$renterUsername",
                                    ),

                                  if (renterEmail.isNotEmpty)
                                    Text(
                                      renterEmail,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // REVIEW BUTTON
                      SizedBox(
                        width: double.infinity,

                        child:
                        ElevatedButton.icon(

                          icon: const Icon(
                            Icons.star_rounded,
                          ),

                          label: Text(
                            alreadyReviewed
                                ? "Review geschreven"
                                : "Schrijf review",
                          ),

                          onPressed:
                          status.toString().toLowerCase() ==
                              "voltooid" &&
                              !alreadyReviewed
                              ? () async {

                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    RateScreen(

                                      reservationId:
                                      widget.reservation['id'],

                                      deviceId:
                                      widget.reservation['deviceId'],

                                      ownerId:
                                      widget.reservation['ownerId'],

                                      reviewerId:
                                      widget.reservation['ownerId'],
                                    ),
                              ),
                            );

                            if (mounted) {
                              loadReviewStatus();
                            }
                          }
                              : null,

                          style:
                          ElevatedButton.styleFrom(
                            backgroundColor:
                            primaryGreen,

                            foregroundColor:
                            Colors.white,

                            disabledBackgroundColor:
                            Colors.grey.shade300,

                            padding:
                            const EdgeInsets.symmetric(
                              vertical: 16,
                            ),

                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      SizedBox(
                        width: double.infinity,

                        child: OutlinedButton.icon(

                          icon: const Icon(
                            Icons.cancel_rounded,
                          ),

                          label: const Text(
                            "Annuleer reservatie",
                          ),

                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,

                            side: const BorderSide(
                              color: Colors.red,
                            ),

                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                            ),

                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(16),
                            ),
                          ),

                          onPressed: () async {

                            final reasons = [

                              "Toestel werkt niet",

                              "Toestel heeft herstelling nodig",

                              "Toestel heeft onderhoud nodig",

                              "Toestel is niet beschikbaar",

                              "Dubbele reservatie",

                              "Onvoorziene omstandigheden",

                              "Probleem met batterij",

                              "Probleem met software",

                              "Beschadigd toestel",

                              "Andere reden",
                            ];

                            String? selectedReason;

                            final controller =
                            TextEditingController();

                            final confirm =
                            await showDialog<bool>(

                              context: context,

                              builder: (context) {

                                return StatefulBuilder(

                                  builder:
                                      (context, setStateDialog) {

                                    return AlertDialog(

                                      title: const Text(
                                        "Reservatie annuleren",
                                      ),

                                      content:
                                      SingleChildScrollView(

                                        child: Column(
                                          mainAxisSize:
                                          MainAxisSize.min,

                                          children: [

                                            DropdownButtonFormField<String>(

                                              initialValue: selectedReason,

                                              decoration:
                                              const InputDecoration(
                                                labelText:
                                                "Reden",
                                              ),

                                              items: reasons.map((r) {

                                                return DropdownMenuItem(
                                                  value: r,
                                                  child: Text(r),
                                                );
                                              }).toList(),

                                              onChanged: (value) {

                                                setStateDialog(() {
                                                  selectedReason =
                                                      value;
                                                });
                                              },
                                            ),

                                            const SizedBox(
                                              height: 14,
                                            ),

                                            TextField(
                                              controller:
                                              controller,

                                              maxLines: 3,

                                              decoration:
                                              const InputDecoration(
                                                hintText:
                                                "Extra uitleg...",
                                                border:
                                                OutlineInputBorder(),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      actions: [

                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(
                                              context,
                                              false,
                                            );
                                          },

                                          child: const Text(
                                            "Terug",
                                          ),
                                        ),

                                        ElevatedButton(
                                          onPressed:
                                          selectedReason == null
                                              ? null
                                              : () {
                                            Navigator.pop(
                                              context,
                                              true,
                                            );
                                          },

                                          style:
                                          ElevatedButton.styleFrom(
                                            backgroundColor:
                                            Colors.red,
                                          ),

                                          child: const Text(
                                            "Annuleren",
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            );

                            if (confirm != true) {
                              return;
                            }

                            await FirebaseFirestore.instance
                                .collection('reservations')
                                .doc(widget.reservation['id'])
                                .update({

                              'status': 'Geannuleerd',

                              'cancelledBy': 'owner',

                              'cancelReason':
                              selectedReason,

                              'cancelExtraInfo':
                              controller.text.trim(),

                              'cancelledAt':
                              FieldValue.serverTimestamp(),
                            });

                            if (!context.mounted) {
                              return;
                            }

                            ScaffoldMessenger.of(context)
                                .showSnackBar(

                              const SnackBar(
                                content: Text(
                                  "Reservatie geannuleerd",
                                ),
                              ),
                            );

                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}