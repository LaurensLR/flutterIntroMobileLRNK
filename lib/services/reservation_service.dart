import 'package:cloud_firestore/cloud_firestore.dart';

class ReservationService {
  final CollectionReference<Map<String, dynamic>> _reservations =
  FirebaseFirestore.instance.collection('reservations');

  // ── Bestaande methodes ──────────────────────────────

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

  // ── Nieuw: reservering aanmaken ─────────────────────

  Future<void> createReservation({
    required String deviceId,
    required String renterId,
    required String ownerId,
    required DateTime fromDate,
    required DateTime toDate,
    required int pickupHour,
    required int pickupMinute,
    required int returnHour,
    required int returnMinute,
    required double totalPrice,
  }) async {
    await _reservations.add({
      'deviceId': deviceId,
      'renterId': renterId,
      'ownerId': ownerId,
      'fromDate': Timestamp.fromDate(fromDate),
      'toDate': Timestamp.fromDate(toDate),
      'pickupTime': '$pickupHour:${pickupMinute.toString().padLeft(2, '0')}',
      'returnTime': '$returnHour:${returnMinute.toString().padLeft(2, '0')}',
      'totalPrice': totalPrice,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Status updaten ──────────────────────────────────

  Future<void> updateStatus(String reservationId, String status) async {
    await _reservations.doc(reservationId).update({'status': status});
  }

  Future<void> approveReservation(String reservationId) async {
    await updateStatus(reservationId, 'approved');
  }

  Future<void> rejectReservation(String reservationId) async {
    await updateStatus(reservationId, 'rejected');
  }

  Future<void> cancelReservation(String reservationId) async {
    await updateStatus(reservationId, 'cancelled');
  }
}