import 'package:cloud_firestore/cloud_firestore.dart';

/// ======================================================
/// DEVICE MODEL
/// ======================================================

class DeviceModel {
  final String id;
  final String ownerId;
  final String title;
  final String description;
  final String category;
  final double pricePerDay;
  final String location;
  final double? locationLat;
  final double? locationLng;
  final String imageUrl;
  final DateTime? availableFrom;
  final DateTime? availableTo;
  final DateTime? createdAt;

  DeviceModel({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.category,
    required this.pricePerDay,
    required this.location,
    this.locationLat,
    this.locationLng,
    required this.imageUrl,
    this.availableFrom,
    this.availableTo,
    this.createdAt,
  });

  // ── Van Firestore naar model ────────────────────────
  // Werkt met DocumentSnapshot én QueryDocumentSnapshot
  factory DeviceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DeviceModel(
      id: doc.id,
      ownerId: data['ownerId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      pricePerDay: (data['pricePerDay'] as num?)?.toDouble() ?? 0.0,
      location: data['location'] ?? '',
      locationLat: (data['locationLat'] as num?)?.toDouble(),
      locationLng: (data['locationLng'] as num?)?.toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      availableFrom: (data['availableFrom'] as Timestamp?)?.toDate(),
      availableTo: (data['availableTo'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  // ── Van model naar Firestore ────────────────────────
  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'title': title,
      'description': description,
      'category': category,
      'pricePerDay': pricePerDay,
      'location': location,
      'locationLat': locationLat,
      'locationLng': locationLng,
      'imageUrl': imageUrl,
      'availableFrom':
      availableFrom != null ? Timestamp.fromDate(availableFrom!) : null,
      'availableTo':
      availableTo != null ? Timestamp.fromDate(availableTo!) : null,
      'createdAt':
      createdAt != null ? Timestamp.fromDate(createdAt!) : null,
    };
  }
}
