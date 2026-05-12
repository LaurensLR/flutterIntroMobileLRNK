import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../rating/rate_screen.dart';

class ReservationDetailScreen extends StatelessWidget {
  const ReservationDetailScreen({
    super.key,
    required this.reservation,
  });

  final Map<String, dynamic> reservation;

  static const Color primaryGreen =
  Color(0xFF2E7D32);

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
          "Reservatie details",
        ),
      ),

      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore
            .instance
            .collection('devices')
            .doc(
          reservation['deviceId'],
        )
            .get(),

        builder:
            (context, deviceSnapshot) {

          if (deviceSnapshot
              .connectionState ==
              ConnectionState.waiting) {

            return const Center(
              child:
              CircularProgressIndicator(),
            );
          }

          if (!deviceSnapshot.hasData ||
              !deviceSnapshot
                  .data!.exists) {

            return const Center(
              child: Text(
                "Toestel niet gevonden",
              ),
            );
          }

          final deviceData =
          deviceSnapshot.data!.data()
          as Map<String, dynamic>;

          return FutureBuilder<
              DocumentSnapshot>(

            future: FirebaseFirestore
                .instance
                .collection('users')
                .doc(
              reservation['ownerId'],
            )
                .get(),

            builder:
                (context, ownerSnapshot) {

              if (ownerSnapshot
                  .connectionState ==
                  ConnectionState.waiting) {

                return const Center(
                  child:
                  CircularProgressIndicator(),
                );
              }

              final ownerData =
              ownerSnapshot.data
                  ?.data()
              as Map<String,
                  dynamic>?;

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

              final ownerUsername =
                  ownerData?['username'] ?? '';

              // OWNER
              final ownerName =
                  "${ownerData?['firstName'] ?? ''} "
                  "${ownerData?['lastName'] ?? ''}";

              final ownerEmail =
                  ownerData?['email'] ??
                      '';

              final ownerPhoto =
                  ownerData?['photoUrl'] ??
                      '';

              // RESERVATION
              final status =
                  reservation['status'] ??
                      'Pending';

              final totalPrice =
              _readPrice(
                reservation['totalPrice'],
              );

              final fromDateTime =
              _readDate(
                reservation[
                'fromDateTime'],
              );

              final toDateTime =
              _readDate(
                reservation[
                'toDateTime'],
              );

              final createdAt =
              _readDate(
                reservation['createdAt'],
              );

              return SafeArea(
                child:
                SingleChildScrollView(
                  padding:
                  const EdgeInsets.all(
                    18,
                  ),

                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                    children: [

                      // FOTO
                      ClipRRect(
                        borderRadius:
                        BorderRadius
                            .circular(
                          22,
                        ),

                        child: Image.network(
                          imageUrl,
                          height: 240,
                          width:
                          double.infinity,
                          fit: BoxFit.cover,

                          errorBuilder:
                              (_, _, _) {

                            return Container(
                              height: 240,
                              color: Colors
                                  .grey
                                  .shade200,

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

                      const SizedBox(
                        height: 20,
                      ),

                      // TITEL
                      Text(
                        title,
                        style:
                        const TextStyle(
                          fontSize: 28,
                          fontWeight:
                          FontWeight
                              .bold,
                        ),
                      ),

                      const SizedBox(
                        height: 6,
                      ),

                      Text(
                        category,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors
                              .grey
                              .shade600,
                        ),
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      // STATUS
                      Container(
                        padding:
                        const EdgeInsets
                            .symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),

                        decoration:
                        BoxDecoration(
                          color: status ==
                              "Bevestigd"
                              ? Colors.green
                              .withValues(
                              alpha:
                              0.12)
                              : status ==
                              "Geannuleerd"
                              ? Colors
                              .red
                              .withValues(
                              alpha:
                              0.12)
                              : Colors
                              .orange
                              .withValues(
                              alpha:
                              0.12),

                          borderRadius:
                          BorderRadius
                              .circular(
                            30,
                          ),
                        ),

                        child: Text(
                          status,

                          style:
                          TextStyle(
                            fontWeight:
                            FontWeight
                                .bold,

                            color: status ==
                                "Bevestigd"
                                ? Colors
                                .green
                                : status ==
                                "Geannuleerd"
                                ? Colors
                                .red
                                : Colors
                                .orange,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 24,
                      ),

                      // INFO CARD
                      Container(
                        padding:
                        const EdgeInsets
                            .all(20),

                        decoration:
                        BoxDecoration(
                          color: Colors.white,

                          borderRadius:
                          BorderRadius
                              .circular(
                            22,
                          ),

                          boxShadow: [
                            BoxShadow(
                              color: Colors
                                  .black
                                  .withValues(
                                alpha:
                                0.04,
                              ),

                              blurRadius:
                              14,

                              offset:
                              const Offset(
                                0,
                                5,
                              ),
                            ),
                          ],
                        ),

                        child: Column(
                          children: [

                            _infoTile(
                              icon: Icons
                                  .login_rounded,

                              title:
                              "Ophalen",

                              value:
                              "${_formatDate(fromDateTime)} om ${_formatTime(fromDateTime)}",
                            ),

                            const SizedBox(
                              height: 20,
                            ),

                            _infoTile(
                              icon: Icons
                                  .logout_rounded,

                              title:
                              "Terugbrengen",

                              value:
                              "${_formatDate(toDateTime)} om ${_formatTime(toDateTime)}",
                            ),

                            const SizedBox(
                              height: 20,
                            ),

                            _infoTile(
                              icon: Icons
                                  .euro_rounded,

                              title:
                              "Totaalprijs",

                              value:
                              "€ ${totalPrice.toStringAsFixed(2)}",
                            ),

                            const SizedBox(
                              height: 20,
                            ),

                            _infoTile(
                              icon: Icons
                                  .schedule_rounded,

                              title:
                              "Reservatie gemaakt",

                              value:
                              "${_formatDate(createdAt)} om ${_formatTime(createdAt)}",
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      // VERHUURDER
                      Container(
                        padding:
                        const EdgeInsets
                            .all(20),

                        decoration:
                        BoxDecoration(
                          color: Colors.white,

                          borderRadius:
                          BorderRadius
                              .circular(
                            22,
                          ),

                          boxShadow: [
                            BoxShadow(
                              color: Colors
                                  .black
                                  .withValues(
                                alpha:
                                0.04,
                              ),

                              blurRadius:
                              14,

                              offset:
                              const Offset(
                                0,
                                5,
                              ),
                            ),
                          ],
                        ),

                        child: Row(
                          children: [

                            CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.grey.shade200,

                              child: ClipOval(
                                child: ownerPhoto.isNotEmpty
                                    ? Image.network(
                                  ownerPhoto,
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,

                                  errorBuilder:
                                      (context, error, stackTrace) {

                                    return const Icon(
                                      Icons.person,
                                      size: 28,
                                    );
                                  },
                                )
                                    : const Icon(
                                  Icons.person,
                                  size: 28,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 16,
                            ),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                                children: [

                                  const Text(
                                    "Verhuurder",
                                    style:
                                    TextStyle(
                                      color:
                                      Colors.grey,
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 4,
                                  ),

                                  Text(
                                    ownerName,

                                    style:
                                    const TextStyle(
                                      fontSize:
                                      17,

                                      fontWeight:
                                      FontWeight
                                          .bold,
                                    ),
                                  ),

                                  if (ownerUsername.isNotEmpty)
                                    Text(
                                      "@$ownerUsername",
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),

                                  if (ownerEmail
                                      .isNotEmpty)
                                    Text(
                                      ownerEmail,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 28,
                      ),

                      // REVIEW BUTTON
                      SizedBox(
                        width:
                        double.infinity,

                        child:
                        ElevatedButton
                            .icon(

                          icon: const Icon(
                            Icons.star_rounded,
                          ),

                          label: const Text(
                            "Schrijf een recensie",
                          ),

                          onPressed: toDateTime != null &&
                              DateTime.now().isAfter(
                                toDateTime,
                              )
                              ? () {

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RateScreen(

                                  deviceId:
                                  reservation['deviceId'],

                                  ownerId:
                                  reservation['ownerId'],

                                  reviewerId:
                                  reservation['renterId'],

                                ),
                              ),
                            );
                          }
                          : null,

                          style:
                          ElevatedButton
                              .styleFrom(
                            backgroundColor:
                            primaryGreen,

                            foregroundColor:
                            Colors.white,

                            disabledBackgroundColor:
                            Colors.grey
                                .shade300,

                            padding:
                            const EdgeInsets
                                .symmetric(
                              vertical: 16,
                            ),

                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius
                                  .circular(
                                16,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 14,
                      ),

                      // CANCEL BUTTON
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(
                            Icons.close_rounded,
                          ),

                          label: Text(
                            status == "Geannuleerd"
                                ? "Reservatie geannuleerd"
                                : "Annuleer reservatie",
                          ),

                          onPressed: status == "Geannuleerd"
                              ? null
                              : () async {

                            final confirm =
                            await showDialog<bool>(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text(
                                    "Reservatie annuleren?",
                                  ),
                                  content: const Text(
                                    "Ben je zeker dat je deze reservatie wilt annuleren?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(
                                          context,
                                          false,
                                        );
                                      },
                                      child: const Text("Nee"),
                                    ),

                                    ElevatedButton(
                                      onPressed: () {
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

                            if (confirm != true) {
                              return;
                            }

                            await FirebaseFirestore
                                .instance
                                .collection('reservations')
                                .doc(reservation['id'])
                                .update({
                              'status': 'Geannuleerd',
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

                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,

                            disabledForegroundColor: Colors.grey,

                            side: BorderSide(
                              color: status == "Geannuleerd"
                                  ? Colors.grey
                                  : Colors.red,
                            ),

                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                            ),

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                16,
                              ),
                            ),
                          ),
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