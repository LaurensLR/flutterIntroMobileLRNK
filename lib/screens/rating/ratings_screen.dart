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
    final userRef = FirebaseFirestore.instance
        .collection("users")
        .doc(userId);

    final ratingsRef = userRef
        .collection("ratings")
        .orderBy("createdAt", descending: true);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text("Beoordelingen"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [

          /// ⭐ HEADER
          FutureBuilder<DocumentSnapshot>(
            future: userRef.get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(30),
                  child: CircularProgressIndicator(),
                );
              }

              final data =
              snapshot.data!.data()
              as Map<String, dynamic>?;

              final avg =
              (data?["avgRating"] ?? 0)
                  .toDouble();
              final count =
                  data?["ratingCount"] ?? 0;

              return Padding(
                padding:
                const EdgeInsets.symmetric(
                    vertical: 30),
                child: Column(
                  children: [

                    /// ⭐ GEMIDDELDE
                    Text(
                      avg.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight:
                        FontWeight.w600,
                        letterSpacing: -1,
                      ),
                    ),

                    const SizedBox(height: 6),

                    /// ⭐ STARS
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment
                          .center,
                      children: List.generate(
                        5,
                            (index) => Icon(
                          index < avg.round()
                              ? Icons.star
                              : Icons.star_border,
                          size: 20,
                          color: Colors.black,
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "$count beoordelingen",
                      style: TextStyle(
                        color:
                        Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          /// 📝 LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: ratingsRef.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child:
                    CircularProgressIndicator(),
                  );
                }

                final docs =
                    snapshot.data!.docs;

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

                return ListView.builder(
                  padding:
                  const EdgeInsets.symmetric(
                      horizontal: 16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data =
                    docs[index].data()
                    as Map<String, dynamic>;

                    final rating =
                        data["rating"] ?? 0;
                    final comment =
                        data["comment"] ?? "";

                    return Container(
                      margin:
                      const EdgeInsets.only(
                          bottom: 14),
                      padding:
                      const EdgeInsets.all(16),
                      decoration:
                      BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                        BorderRadius.circular(
                            20),
                      ),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                        children: [

                          /// ⭐ STARS
                          Row(
                            children:
                            List.generate(
                              5,
                                  (i) => Icon(
                                i < rating
                                    ? Icons.star
                                    : Icons
                                    .star_border,
                                size: 16,
                                color: Colors.black,
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          /// 📝 COMMENT
                          Text(
                            comment.isEmpty
                                ? "Geen beschrijving"
                                : comment,
                            style:
                            const TextStyle(
                              fontSize: 15,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
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
}