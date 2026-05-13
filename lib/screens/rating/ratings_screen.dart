import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RatingsScreen extends StatelessWidget {

  final String userId;

  const RatingsScreen({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
      const Color(0xFFF5F5F7),

      appBar: AppBar(
        title: const Text(
          "Beoordelingen",
        ),
        backgroundColor:
        Colors.transparent,
        elevation: 0,
        foregroundColor:
        Colors.black,
      ),

      body: StreamBuilder<QuerySnapshot>(

        stream: FirebaseFirestore
            .instance
            .collectionGroup('reviews')
            .where(
          'ownerId',
          isEqualTo: userId,
        )
            .orderBy(
          'createdAt',
          descending: true,
        )
            .snapshots(),

        builder: (context, snapshot) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
              CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding:
                const EdgeInsets.all(24),
                child: Text(
                  snapshot.error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                ),
              ),
            );
          }

          final docs =
              snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                "Nog geen beoordelingen",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            );
          }

          double total = 0;
          for (final doc in docs) {
            final data =
            doc.data()
            as Map<String, dynamic>;
            total +=
                (data['rating'] ?? 0)
                    .toDouble();
          }

          final avg =
              total / docs.length;

          return Column(
            children: [

              // HEADER
              Padding(
                padding:
                const EdgeInsets.symmetric(
                  vertical: 30,
                ),
                child: Column(
                  children: [

                    Text(
                      avg.toStringAsFixed(1),
                      style:
                      const TextStyle(
                        fontSize: 52,
                        fontWeight:
                        FontWeight.bold,
                        letterSpacing: -2,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment
                          .center,
                      children:
                      List.generate(
                        5,
                            (index) => Icon(
                          index < avg.round()
                              ? Icons.star_rounded
                              : Icons
                              .star_border_rounded,
                          color: Colors.orange,
                          size: 22,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "${docs.length} beoordelingen",
                      style: TextStyle(
                        color:
                        Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // LIST
              Expanded(
                child: ListView.builder(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  itemCount: docs.length,
                  itemBuilder:
                      (context, index) {

                    final data =
                    docs[index].data()
                    as Map<String, dynamic>;

                    final rating =
                        data['rating'] ?? 0;
                    final comment =
                        data['comment'] ?? '';
                    final reviewerName =
                        data['reviewerName']
                            ?? 'Anoniem';
                    final reviewerPhoto =
                        data['reviewerPhoto']
                            ?? '';

                    return Container(
                      margin:
                      const EdgeInsets.only(
                        bottom: 14,
                      ),
                      padding:
                      const EdgeInsets.all(
                        18,
                      ),
                      decoration:
                      BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                        BorderRadius.circular(
                          24,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withValues(
                              alpha: 0.03,
                            ),
                            blurRadius: 12,
                            offset:
                            const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                        children: [

                          // REVIEWER INFO
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundImage:
                                reviewerPhoto
                                    .isNotEmpty
                                    ? NetworkImage(
                                    reviewerPhoto)
                                    : null,
                                backgroundColor:
                                Colors
                                    .grey.shade200,
                                child: reviewerPhoto
                                    .isEmpty
                                    ? const Icon(
                                  Icons.person,
                                  color:
                                  Colors.grey,
                                )
                                    : null,
                              ),
                              const SizedBox(
                                  width: 10),
                              Text(
                                reviewerName,
                                style:
                                const TextStyle(
                                  fontWeight:
                                  FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(
                              height: 12),

                          // STERREN
                          Row(
                            children:
                            List.generate(
                              5,
                                  (i) => Icon(
                                i < rating
                                    ? Icons
                                    .star_rounded
                                    : Icons
                                    .star_border_rounded,
                                color:
                                Colors.orange,
                                size: 18,
                              ),
                            ),
                          ),

                          const SizedBox(
                              height: 10),

                          // COMMENT
                          Text(
                            comment.isEmpty
                                ? "Geen beschrijving"
                                : comment,
                            style:
                            const TextStyle(
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}