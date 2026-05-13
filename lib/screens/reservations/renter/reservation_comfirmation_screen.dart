import 'dart:async';
import 'package:flutter/material.dart';

class ReservationConfirmationScreen extends StatefulWidget {
  const ReservationConfirmationScreen({super.key});

  @override
  State<ReservationConfirmationScreen> createState() =>
      _ReservationConfirmationScreenState();
}

class _ReservationConfirmationScreenState
    extends State<ReservationConfirmationScreen> {

  @override
  void initState() {
    super.initState();

    // Na 5 seconden terug naar home
    Timer(const Duration(seconds: 5), () {
      if (!mounted) return;

      Navigator.popUntil(
        context,
            (route) => route.isFirst,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF2E7D32);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Success icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: primaryGreen.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    size: 80,
                    color: primaryGreen,
                  ),
                ),

                const SizedBox(height: 32),

                const Text(
                  "Toestel gereserveerd!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 14),

                Text(
                  "Je reservatie werd succesvol verzonden naar de verhuurder.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 40),

                const CircularProgressIndicator(
                  color: primaryGreen,
                ),

                const SizedBox(height: 18),

                Text(
                  "Je wordt automatisch doorgestuurd...",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}