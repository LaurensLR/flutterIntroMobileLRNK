import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../firebase/reservation_service.dart';
import 'reservation_detail_screen.dart';

class OwnerReservationsScreen extends StatelessWidget {
  const OwnerReservationsScreen({super.key});

  static const Color primaryGreen = Color(0xFF2E7D32);

  DateTime? _readDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    return null;
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Onbekend';
    }
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  Widget _buildStateMessage(String message) {
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

  Widget _buildImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: const Color(0xFFEAF3EB),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(
          Icons.assignment_outlined,
          color: primaryGreen,
        ),
      );
    }

    final isAsset = imageUrl.trim().startsWith('assets/');

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: isAsset
          ? Image.asset(
              imageUrl,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 64,
                  height: 64,
                  color: const Color(0xFFEAF3EB),
                  child: const Icon(
                    Icons.broken_image_outlined,
                    color: primaryGreen,
                  ),
                );
              },
            )
          : Image.network(
              imageUrl,
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 64,
                  height: 64,
                  color: const Color(0xFFEAF3EB),
                  child: const Icon(
                    Icons.broken_image_outlined,
                    color: primaryGreen,
                  ),
                );
              },
            ),
    );
  }

  Widget _buildReservationCard(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    final title =
        (data['deviceTitle'] ?? data['title'] ?? 'Toestel').toString();
    final category = (data['deviceCategory'] ?? data['category'] ?? '').toString();
    final status = (data['status'] ?? 'gereserveerd').toString();
    final renterId = (data['renterId'] ?? '').toString();
    final imageUrl =
        (data['deviceImageUrl'] ?? data['imageUrl'] ?? '').toString();

    final startDate = _readDate(data['startDate']);
    final endDate = _readDate(data['endDate']);
    final periodLabel =
        '${_formatDate(startDate)} - ${_formatDate(endDate)}';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE3EAE4)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReservationDetailScreen(
                reservation: data,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              _buildImage(imageUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (category.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        category,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      'Periode: $periodLabel',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Status: $status',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 13,
                      ),
                    ),
                    if (renterId.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Huurder: $renterId',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.black38),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Mijn reservaties (verhuurder)'),
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        body: _buildStateMessage('Log in om je reservaties te zien.'),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Mijn reservaties (verhuurder)'),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: ReservationService().streamReservationsForOwner(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: primaryGreen),
            );
          }

          if (snapshot.hasError) {
            return _buildStateMessage('Fout bij laden van reservaties.');
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return _buildStateMessage('Nog geen reservaties.');
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              return _buildReservationCard(context, doc.data());
            },
          );
        },
      ),
    );
  }
}
