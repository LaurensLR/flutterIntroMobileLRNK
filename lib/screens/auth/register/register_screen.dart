import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import  'personal_info_screen.dart';

/// Eerste registratie startscherm
/// Luxe iOS-stijl RentBy onboarding
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  static const Color primaryGreen = Color(0xFF2E7D32);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 18,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              /// hoofdicoon
              Center(
                child: Container(
                  width: 118,
                  height: 118,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F4F4),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border.all(
                      color: const Color(0xFFE8E8E8),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    CupertinoIcons.hammer_fill,
                    size: 52,
                    color: primaryGreen,
                  ),
                ),
              ),

              const SizedBox(height: 36),

              /// titel
              const Text(
                "Registreer je account",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 16),

              /// subtitel
              const Text(
                "Huur of verhuur huishoudelijke toestellen in jouw buurt.\nSnel, eenvoudig en veilig.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  height: 1.45,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 40),

              /// voordelen
              _benefitTile(
                icon: CupertinoIcons.check_mark_circled_solid,
                text: "Veilige registratie",
              ),

              _benefitTile(
                icon: CupertinoIcons.location_solid,
                text: "Toestellen dichtbij jou",
              ),

              _benefitTile(
                icon: CupertinoIcons.money_euro_circle_fill,
                text: "Verdien met je eigen toestellen",
              ),

              const Spacer(),

              /// registreer knop
              SizedBox(
                height: 58,
                child: CupertinoButton(
                  color: primaryGreen,
                  borderRadius: BorderRadius.circular(18),
                  onPressed: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => const PersonalInfoScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "Registreren",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              /// login onderaan
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Heb je al een account?",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 15,
                    ),
                  ),
                  CupertinoButton(
                    padding: const EdgeInsets.only(left: 6),
                    minimumSize: Size.zero,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Log in",
                      style: TextStyle(
                        color: primaryGreen,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _benefitTile({
    required IconData icon,
    required String text,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4), // iets donkerder
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFE8E8E8),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: primaryGreen,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}