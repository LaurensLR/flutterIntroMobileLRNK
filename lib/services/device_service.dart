import 'package:cloud_firestore/cloud_firestore.dart';

class DeviceService {
  final CollectionReference<Map<String, dynamic>> _devices =
      FirebaseFirestore.instance.collection('devices');

  Future<DocumentReference<Map<String, dynamic>>> addDevice({
    required String ownerId,
    required String title,
    required String description,
    required String category,
    required double pricePerDay,
    required DateTime availableFrom,
    required DateTime availableTo,
    String? imageUrl,
    String? location,
    double? locationLat,
    double? locationLng,
  }) {
    return _devices.add({
      'ownerId': ownerId,
      'title': title,
      'description': description,
      'category': category,
      'pricePerDay': pricePerDay,
      'imageUrl': imageUrl ?? '',
      'location': location ?? '',
      'locationLat': locationLat,
      'locationLng': locationLng,
      'availableFrom': Timestamp.fromDate(availableFrom),
      'availableTo': Timestamp.fromDate(availableTo),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamOwnerDevices(
    String ownerId,
  ) {
    return _devices.where('ownerId', isEqualTo: ownerId).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamAllDevices() {
    return _devices.orderBy('createdAt', descending: true).snapshots();
  }
}
