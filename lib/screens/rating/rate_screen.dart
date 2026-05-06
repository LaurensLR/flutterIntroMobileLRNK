import 'package:flutter/material.dart';

class RateScreen extends StatefulWidget {
  const RateScreen({super.key});

  @override
  State<RateScreen> createState() => _RateScreenState();
}

class _RateScreenState extends State<RateScreen> {
  int rating = 0;
  final TextEditingController commentController =
  TextEditingController();

  static const Color accent = Color(0xFF2E7D32);

  /// ⭐ STAR
  Widget buildStar(int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          rating = index;
        });
      },
      child: AnimatedScale(
        scale: index <= rating ? 1.2 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Icon(
          index <= rating
              ? Icons.star
              : Icons.star_border,
          size: 36,
          color: Color(0xFFFFD60A), // ⭐
        ),
      ),
    );
  }

  /// 🚀 POST
  void onPost() {
    final comment =
    commentController.text.trim();

    if (rating == 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text("Selecteer een rating"),
        ),
      );
      return;
    }

    print("Rating: $rating");
    print("Comment: $comment");

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text("Beoordeling"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding:
        const EdgeInsets.symmetric(
            horizontal: 24),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.center,
          children: [

            const SizedBox(height: 30),

            /// TITLE
            const Text(
              "Hoe was je ervaring?",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight:
                FontWeight.w600,
                letterSpacing: -0.5,
              ),
            ),

            const SizedBox(height: 30),

            /// ⭐ STARS
            Row(
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: List.generate(
                5,
                    (index) =>
                    buildStar(index + 1),
              ),
            ),

            const SizedBox(height: 40),

            /// 📝 COMMENT BOX
            Container(
              padding:
              const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.circular(20),
              ),
              child: TextField(
                controller:
                commentController,
                maxLines: 4,
                decoration:
                const InputDecoration(
                  hintText:
                  "Schrijf een korte beschrijving...",
                  border: InputBorder.none,
                ),
              ),
            ),

            const Spacer(),

            /// 🚀 BUTTON
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: onPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent, // jouw groen
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Post",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                    FontWeight.w500,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}