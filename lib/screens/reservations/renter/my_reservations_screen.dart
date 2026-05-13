import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/reservation_service.dart';
import 'reservation_detail_screen.dart';

class MyReservationsScreen extends StatelessWidget {
  const MyReservationsScreen({super.key});

  static const Color primaryGreen =
  Color(0xFF2E7D32);

  /// --------------------------------------------------
  /// Datum converteren
  /// --------------------------------------------------

  DateTime? _readDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    return null;
  }

  /// --------------------------------------------------
  /// Datum formatteren
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
  /// Lege / fout state
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
  /// Afbeelding toestel
  /// --------------------------------------------------

  Widget _buildDeviceImage(
      String imageUrl) {
    if (imageUrl.isEmpty) {
      return Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color:
          const Color(0xFFEAF3EB),
          borderRadius:
          BorderRadius.circular(
              18),
        ),
        child: const Icon(
          Icons.event_note_outlined,
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
        width: 70,
        height: 70,
        fit: BoxFit.cover,
      )
          : Image.network(
        imageUrl,
        width: 70,
        height: 70,
        fit: BoxFit.cover,
      ),
    );
  }

  /// --------------------------------------------------
  /// Reservatie kaart
  /// --------------------------------------------------

  Widget _buildReservationCard(
      BuildContext context,
      Map<String, dynamic> data,
      ) {

    final deviceId =
    (data["deviceId"] ?? "")
        .toString();

    final ownerId =
    (data["ownerId"] ?? "")
        .toString();

    final status =
    (data["status"] ?? "")
        .toString();

    final startDate =
    _readDate(
      data["fromDateTime"],
    );

    final endDate =
    _readDate(
      data["toDateTime"],
    );

    final period =
        "${_formatDate(startDate)} - "
        "${_formatDate(endDate)}";

    return FutureBuilder<DocumentSnapshot>(

      future: FirebaseFirestore
          .instance
          .collection('devices')
          .doc(deviceId)
          .get(),

      builder: (context, deviceSnapshot) {

        if (!deviceSnapshot.hasData) {
          return const SizedBox();
        }

        final deviceData =
        deviceSnapshot.data!.data()
        as Map<String, dynamic>?;

        final title =
            deviceData?['title'] ??
                "Toestel";

        final category =
            deviceData?['category'] ??
                "";

        final imageUrl =
            deviceData?['imageUrl'] ??
                "";

        return Container(
          margin:
          const EdgeInsets.only(
            bottom: 14,
          ),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius:
            BorderRadius.circular(
              24,
            ),

            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withValues(
                  alpha: 0.04,
                ),

                blurRadius: 18,

                offset:
                const Offset(0, 8),
              ),
            ],
          ),

          child: InkWell(

            borderRadius:
            BorderRadius.circular(
              24,
            ),

            onTap: () {

              Navigator.push(
                context,

                MaterialPageRoute(
                  builder: (_) =>
                      ReservationDetailScreen(
                        reservation: data,
                      ),
                ),
              );
            },

            child: Padding(

              padding:
              const EdgeInsets.all(
                16,
              ),

              child: Row(
                children: [

                  _buildDeviceImage(
                    imageUrl,
                  ),

                  const SizedBox(
                    width: 14,
                  ),

                  Expanded(
                    child: Column(

                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                      children: [

                        Text(
                          title,

                          maxLines: 1,

                          overflow:
                          TextOverflow
                              .ellipsis,

                          style:
                          const TextStyle(
                            fontSize: 17,

                            fontWeight:
                            FontWeight
                                .bold,
                          ),
                        ),

                        if (category
                            .isNotEmpty)

                          Padding(
                            padding:
                            const EdgeInsets
                                .only(
                              top: 4,
                            ),

                            child: Text(
                              category,

                              style:
                              const TextStyle(
                                color: Colors
                                    .black54,
                              ),
                            ),
                          ),

                        const SizedBox(
                          height: 8,
                        ),

                        Text(
                          "Periode: $period",

                          style:
                          const TextStyle(
                            fontSize: 13,

                            color: Colors
                                .black54,
                          ),
                        ),

                        const SizedBox(
                          height: 4,
                        ),

                        Text(
                          "Status: $status",

                          style:
                          const TextStyle(
                            fontSize: 13,

                            color:
                            primaryGreen,

                            fontWeight:
                            FontWeight
                                .w600,
                          ),
                        ),

                        if (ownerId
                            .isNotEmpty)

                          FutureBuilder<
                              DocumentSnapshot>(

                            future:
                            FirebaseFirestore
                                .instance
                                .collection(
                                'users')
                                .doc(ownerId)
                                .get(),

                            builder:
                                (context,
                                ownerSnapshot) {

                              if (!ownerSnapshot
                                  .hasData) {

                                return const SizedBox();
                              }

                              final ownerData =
                              ownerSnapshot
                                  .data!
                                  .data()
                              as Map<String,
                                  dynamic>?;

                              final ownerName =
                                  "${ownerData?['firstName'] ?? ''} "
                                  "${ownerData?['lastName'] ?? ''}";

                              return Padding(

                                padding:
                                const EdgeInsets
                                    .only(
                                  top: 4,
                                ),

                                child: Text(
                                  "Verhuurder: $ownerName",

                                  style:
                                  const TextStyle(
                                    fontSize: 12,

                                    color: Colors
                                        .black45,
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),

                  const Icon(
                    Icons.chevron_right,
                    color: Colors.black38,
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
            "Mijn reservaties",
          ),
        ),
        body: _buildStateMessage(
          "Log in om je reservaties te zien.",
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
          "Mijn reservaties",
          style: TextStyle(
            fontWeight:
            FontWeight.bold,
          ),
        ),
      ),

      body: StreamBuilder<
          QuerySnapshot<
              Map<String, dynamic>>>(
        stream: ReservationService()
            .streamReservationsForRenter(
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
              "Fout bij laden van reservaties.",
            );
          }

          final docs =
              snapshot.data?.docs ??
                  [];

          if (docs.isEmpty) {
            return _buildStateMessage(
              "Nog geen reservaties.",
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
              final doc = docs[index];
              final reservation =
              doc.data();
              reservation['id'] = doc.id;
              return _buildReservationCard(
                context,
                reservation,
              );
            },
          );
        },
      ),
    );
  }
}