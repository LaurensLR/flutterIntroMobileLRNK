import 'package:cloud_firestore/cloud_firestore.dart';

class ReservationService {
  final CollectionReference<Map<String, dynamic>> _reservations =
      FirebaseFirestore.instance.collection('reservations');

  Stream<QuerySnapshot<Map<String, dynamic>>> streamReservationsForRenter(
    String renterId,
  ) {
    return _reservations.where('renterId', isEqualTo: renterId).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamReservationsForOwner(
    String ownerId,
  ) {
    return _reservations.where('ownerId', isEqualTo: ownerId).snapshots();
  }
}
