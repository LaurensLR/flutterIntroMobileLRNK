import 'package:flutter/material.dart';

/// ======================================================
/// NOTIFICATION SCREEN
/// ------------------------------------------------------
/// Toont meldingen van gebruiker.
/// Later uitbreidbaar met:
/// - realtime notificaties
/// - reserveringen
/// - chat meldingen
/// - systeem updates
/// ======================================================

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() =>
      _NotificationScreenState();
}

class _NotificationScreenState
    extends State<NotificationScreen> {

  /// Primaire kleur app
  static const Color primaryGreen =
  Color(0xFF2E7D32);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          "Meldingen",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          /// Nieuwe reservatie
          _buildNotificationTile(
            icon: Icons.calendar_today,
            title: "Nieuwe reservatie",
            message:
            "Jan Peeters reserveerde jouw boormachine.",
            time: "2 min geleden",
            unread: true,
          ),

          /// Chat bericht
          _buildNotificationTile(
            icon: Icons.chat_bubble_outline,
            title: "Nieuw bericht",
            message:
            "Sofie stuurde je een bericht.",
            time: "10 min geleden",
            unread: true,
          ),

          /// Bevestiging
          _buildNotificationTile(
            icon: Icons.check_circle_outline,
            title: "Reservatie bevestigd",
            message:
            "Jouw reservatie werd goedgekeurd.",
            time: "Gisteren",
            unread: false,
          ),
        ],
      ),
    );
  }

  /// ======================================================
  /// NOTIFICATIE ITEM
  /// ======================================================

  Widget _buildNotificationTile({
    required IconData icon,
    required String title,
    required String message,
    required String time,
    required bool unread,
  }) {
    return ListTile(
      contentPadding:
      const EdgeInsets.symmetric(
        vertical: 6,
      ),

      leading: CircleAvatar(
        radius: 24,
        backgroundColor:
        primaryGreen.withValues(alpha: 0.12),
        child: Icon(
          icon,
          color: primaryGreen,
        ),
      ),

      title: Text(
        title,
        style: TextStyle(
          fontWeight: unread
              ? FontWeight.bold
              : FontWeight.w600,
        ),
      ),

      subtitle: Text(
        message,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),

      trailing: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          Text(
            time,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 6),

          if (unread)
            Container(
              width: 10,
              height: 10,
              decoration:
              const BoxDecoration(
                color: primaryGreen,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),

      onTap: () {
        /// later actie openen
      },
    );
  }
}