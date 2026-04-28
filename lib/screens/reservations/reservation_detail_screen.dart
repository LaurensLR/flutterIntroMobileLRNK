import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReservationDetailScreen extends StatelessWidget {
  const ReservationDetailScreen({
    super.key,
    required this.reservation,
  });

  final Map<String, dynamic> reservation;

  static const Color primaryGreen = Color(0xFF2E7D32);

  DateTime? _readDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    return null;
  }

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

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Onbekend';
    }
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.black54),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final title =
        (reservation['deviceTitle'] ?? reservation['title'] ?? 'Toestel')
            .toString();
    final category =
        (reservation['deviceCategory'] ?? reservation['category'] ?? '')
            .toString();
    final status = (reservation['status'] ?? 'gereserveerd').toString();
    final location = (reservation['location'] ?? '').toString();
    final ownerId = (reservation['ownerId'] ?? '').toString();
    final renterId = (reservation['renterId'] ?? '').toString();
    final price = _readPrice(reservation['pricePerDay']);
    final startDate = _readDate(reservation['startDate']);
    final endDate = _readDate(reservation['endDate']);

    final periodLabel =
        '${_formatDate(startDate)} - ${_formatDate(endDate)}';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Reservatie'),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                category.isEmpty ? 'Categorie onbekend' : category,
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: primaryGreen.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                      color: primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFE3EAE4)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildInfoRow('Periode', periodLabel),
                      const Divider(height: 24),
                      _buildInfoRow(
                        'Prijs per dag',
                        price == null
                            ? 'Onbekend'
                            : '${price.toStringAsFixed(2)} EUR',
                      ),
                      if (location.isNotEmpty) ...[
                        const Divider(height: 24),
                        _buildInfoRow('Locatie', location),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFE3EAE4)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        'Verhuurder',
                        ownerId.isEmpty ? 'Onbekend' : ownerId,
                      ),
                      const Divider(height: 24),
                      _buildInfoRow(
                        'Huurder',
                        renterId.isEmpty ? 'Onbekend' : renterId,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
