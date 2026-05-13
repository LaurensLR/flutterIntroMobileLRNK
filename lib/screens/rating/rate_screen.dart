import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RateScreen extends StatefulWidget {
  final String reservationId;
  final String deviceId;
  final String ownerId;
  final String reviewerId;

  const RateScreen({
    super.key,
    required this.reservationId,
    required this.deviceId,
    required this.ownerId,
    required this.reviewerId,
  });

  @override
  State<RateScreen> createState() => _RateScreenState();
}

class _RateScreenState extends State<RateScreen> {
  int rating = 0;
  bool _isLoading = false;
  final TextEditingController commentController = TextEditingController();

  static const Color accent = Color(0xFF2E7D32);

  // ✅ FIX 1: dispose controller om memory leak te voorkomen
  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  Future<void> onPost() async {
    final comment = commentController.text.trim();

    if (rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecteer een rating")),
      );
      return;
    }

    // ✅ FIX 2: loading state activeren zodat dubbele submits geblokkeerd worden
    setState(() => _isLoading = true);

    try {
      // ✅ FIX 3: check of er al een review bestaat voor deze reservering
      final existing = await FirebaseFirestore.instance
          .collection('reservations')
          .doc(widget.reservationId)
          .collection('reviews')
          .where('reviewerId', isEqualTo: widget.reviewerId)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Je hebt deze reservering al beoordeeld.")),
        );
        return;
      }

      await FirebaseFirestore.instance
          .collection('reservations')
          .doc(widget.reservationId)
          .collection('reviews')
          .add({
        'deviceId': widget.deviceId,
        'ownerId': widget.ownerId,
        'reviewerId': widget.reviewerId,
        'rating': rating,
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Review geplaatst!")),
      );
      Navigator.pop(context);

    } catch (e) {
      // ✅ FIX 4: mounted check ook in de catch zodat er geen crash ontstaat
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Fout: $e")),
      );
    } finally {
      // ✅ FIX 5: loading state altijd resetten, ook bij een fout
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget buildStar(int index) {
    return GestureDetector(
      onTap: _isLoading ? null : () => setState(() => rating = index),
      child: AnimatedScale(
        scale: index <= rating ? 1.2 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Icon(
          index <= rating ? Icons.star : Icons.star_border,
          size: 36,
          color: const Color(0xFFFFD60A),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: const Text("Beoordeling"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),

            const Text(
              "Hoe was je ervaring?",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.5,
              ),
            ),

            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) => buildStar(index + 1)),
            ),

            // ✅ FIX 6: label toevoegen op basis van de gekozen rating
            const SizedBox(height: 12),
            Text(
              rating == 0
                  ? "Tik op een ster om te beoordelen"
                  : ["", "Slecht", "Matig", "Oké", "Goed", "Uitstekend!"][rating],
              style: TextStyle(
                color: rating == 0 ? Colors.grey : accent,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 28),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: commentController,
                maxLines: 4,
                enabled: !_isLoading,
                decoration: const InputDecoration(
                  hintText: "Schrijf een korte beschrijving...",
                  border: InputBorder.none,
                ),
              ),
            ),

            const Spacer(),

            // ✅ FIX 7: loading spinner in de knop
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : onPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
                    : const Text(
                  "Post",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
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