import 'package:flutter/material.dart';

/// ======================================================
/// CHAT SCREEN
/// ------------------------------------------------------
/// Toont overzicht van gesprekken van gebruiker.
/// Later uitbreidbaar met:
/// - realtime chats
/// - unread badges
/// - zoeken in gesprekken
/// - berichten sturen
/// ======================================================

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() =>
      _ChatScreenState();
}

class _ChatScreenState
    extends State<ChatScreen> {

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
          "Chats",
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

          /// Voorbeeld chat item
          _buildChatTile(
            name: "Jan Peeters",
            lastMessage:
            "Is deze boormachine nog beschikbaar?",
            time: "14:22",
            unread: true,
          ),

          _buildChatTile(
            name: "Sofie BV",
            lastMessage:
            "Bedankt voor je reservatie.",
            time: "Gisteren",
            unread: false,
          ),
        ],
      ),
    );
  }

  /// ======================================================
  /// CHAT ITEM
  /// ======================================================

  Widget _buildChatTile({
    required String name,
    required String lastMessage,
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
        child: Text(
          name[0],
          style: const TextStyle(
            color: primaryGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      title: Text(
        name,
        style: TextStyle(
          fontWeight: unread
              ? FontWeight.bold
              : FontWeight.w600,
        ),
      ),

      subtitle: Text(
        lastMessage,
        maxLines: 1,
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
        /// later openen chatgesprek
      },
    );
  }
}