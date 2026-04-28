import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../firebase/device_service.dart';
import 'add_device_screen.dart';

class MyOffersScreen extends StatelessWidget {
  const MyOffersScreen({super.key});

  static const Color primaryGreen = Color(0xFF2E7D32);

  double? _readPrice(dynamic value) {
    if (value is int) {
      return value.toDouble();
    }
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    return null;
  }

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
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: const Color(0xFFEAF3EB),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(
          Icons.image_outlined,
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
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 72,
                  height: 72,
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
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 72,
                  height: 72,
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

  Widget _buildDeviceCard(Map<String, dynamic> data) {
    final title = (data['title'] ?? 'Onbekend toestel').toString();
    final description = (data['description'] ?? '').toString();
    final category = (data['category'] ?? 'Onbekend').toString();
    final location = (data['location'] ?? '').toString();
    final imageUrl = (data['imageUrl'] ?? '').toString();
    final price = _readPrice(data['pricePerDay']);
    final availableFrom = _readDate(data['availableFrom']);
    final availableTo = _readDate(data['availableTo']);

    final availabilityLabel =
        '${_formatDate(availableFrom)} - ${_formatDate(availableTo)}';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE3EAE4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  const SizedBox(height: 4),
                  Text(
                    category,
                    style: const TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black87,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    'Beschikbaar: $availabilityLabel',
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                    ),
                  ),
                  if (location.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Locatie: $location',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    price == null
                        ? 'Prijs per dag: onbekend'
                        : 'Prijs per dag: ${price.toStringAsFixed(2)} EUR',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
          title: const Text('Mijn aanbiedingen'),
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        body: _buildStateMessage('Log in om je aanbiedingen te zien.'),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Mijn aanbiedingen'),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryGreen,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddDeviceScreen(),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: DeviceService().streamOwnerDevices(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: primaryGreen),
            );
          }

          if (snapshot.hasError) {
            return _buildStateMessage('Fout bij laden van aanbiedingen.');
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return _buildStateMessage('Nog geen aanbiedingen.');
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              return _buildDeviceCard(docs[index].data());
            },
          );
        },
      ),
    );
  }
}
