import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/device_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../reservations/reservation_comfirmation_screen.dart';


/// ======================================================
/// DEVICE DETAIL SCREEN
/// Marktplaats-geïnspireerde stijl
/// ======================================================

class DeviceDetailScreen extends StatefulWidget {
  final DeviceModel device;

  const DeviceDetailScreen({super.key, required this.device});

  @override
  State<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen> {
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color accentBlue = Color(0xFF0064D2);

  bool isFavorite = false;
  bool isReserving = false;
  DateTimeRange? reservationRange;

  TimeOfDay pickupTime = const TimeOfDay(hour: 0, minute: 0);
  TimeOfDay returnTime = const TimeOfDay(hour: 0, minute: 0);

  final List<TimeOfDay> allowedTimes = List.generate(
    25,
        (index) {
      final totalMinutes = (8 * 60) + (index * 30);

      return TimeOfDay(
        hour: totalMinutes ~/ 60,
        minute: totalMinutes % 60,
      );
    },
  );

  String formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  int get totalDays {
    if (reservationRange == null) return 0;
    return reservationRange!.end.difference(reservationRange!.start).inDays + 1;
  }

  double get totalPrice => totalDays * widget.device.pricePerDay;

  Future<bool> isPeriodAvailable({
    required DateTime newStart,
    required DateTime newEnd,
  }) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('reservations')
        .where('deviceId', isEqualTo: widget.device.id)
        .get();

    for (final doc in snapshot.docs) {
      final data = doc.data();

      final status =
      (data['status'] ?? '')
          .toString()
          .toLowerCase();

      // geannuleerde reservaties negeren
      if (status == 'geannuleerd') {
        continue;
      }

      // skip oude reservaties zonder datetime velden
      if (data['fromDateTime'] == null ||
          data['toDateTime'] == null) {
        continue;
      }

      final existingStart =
      (data['fromDateTime'] as Timestamp).toDate();

      // +2 uur buffer
      final existingEnd =
      (data['toDateTime'] as Timestamp)
          .toDate()
          .add(const Duration(hours: 2));

      debugPrint("BESTAANDE:");
      debugPrint(existingStart.toString());
      debugPrint(existingEnd.toString());

      debugPrint("NIEUWE:");
      debugPrint(newStart.toString());
      debugPrint(newEnd.toString());

      final overlaps =
          newStart.isBefore(existingEnd) &&
              newEnd.isAfter(existingStart);

      if (overlaps) {
        return false;
      }
    }

    return true;
  }

  Future<bool> isDayFullyUnavailable(
      DateTime selectedDay,
      ) async {

    final snapshot = await FirebaseFirestore.instance
        .collection('reservations')
        .where('deviceId', isEqualTo: widget.device.id)
        .get();

    // alle mogelijke startmomenten testen
    for (final startTime in allowedTimes) {

      final testStart = DateTime(
        selectedDay.year,
        selectedDay.month,
        selectedDay.day,
        startTime.hour,
        startTime.minute,
      );

      // minimum 24u huur
      final testEnd = testStart.add(
        const Duration(hours: 24),
      );

      bool overlaps = false;

      for (final doc in snapshot.docs) {

        final data = doc.data();

        if (data['fromDateTime'] == null ||
            data['toDateTime'] == null) {
          continue;
        }

        final existingStart =
        (data['fromDateTime'] as Timestamp)
            .toDate();

        final existingEnd =
        (data['toDateTime'] as Timestamp)
            .toDate()
            .add(const Duration(hours: 2));

        final conflict =
            testStart.isBefore(existingEnd) &&
                testEnd.isAfter(existingStart);

        if (conflict) {
          overlaps = true;
          break;
        }
      }

      // minstens 1 geldig 24u-slot gevonden
      if (!overlaps) {
        return false;
      }
    }

    return true;
  }

  Future<void> pickTime({required bool isPickup}) async {
    if (reservationRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Kies eerst een huurperiode"),
        ),
      );
      return;
    }

    // ── Bezettingen ophalen ─────────────────────────────
    final Set<String> unavailableTimes = {};

    final snapshot = await FirebaseFirestore.instance
        .collection('reservations')
        .where('deviceId', isEqualTo: widget.device.id)
        .get();

    for (final doc in snapshot.docs) {
      final data = doc.data();

      // Oude reservaties skippen
      if (data['fromDateTime'] == null ||
          data['toDateTime'] == null) {
        continue;
      }

      final start =
      (data['fromDateTime'] as Timestamp).toDate();

      final end =
      (data['toDateTime'] as Timestamp)
          .toDate()
          .add(const Duration(hours: 2));

      DateTime current = start;

      // Elke 30 min overlopen
      while (
      current.isBefore(end) ||
          current.isAtSameMomentAs(end)
      ) {

        // Enkel geselecteerde dag
        if (
        current.year == reservationRange!.start.year &&
            current.month == reservationRange!.start.month &&
            current.day == reservationRange!.start.day
        ) {

          final key =
              "${current.hour.toString().padLeft(2, '0')}:"
              "${current.minute.toString().padLeft(2, '0')}";

          unavailableTimes.add(key);
        }

        current = current.add(
          const Duration(minutes: 30),
        );
      }
    }

    // ── Time picker bottom sheet ────────────────────────
    final selected = await showModalBottomSheet<TimeOfDay>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return SizedBox(
          height: 420,
          child: ListView.builder(
            itemCount: allowedTimes.length,
            itemBuilder: (context, index) {

              final time = allowedTimes[index];

              final hour =
              time.hour.toString().padLeft(2, '0');

              final minute =
              time.minute.toString().padLeft(2, '0');

              final timeKey = "$hour:$minute";

              final isUnavailable =
              unavailableTimes.contains(timeKey);

              return Opacity(
                opacity: isUnavailable ? 0.4 : 1,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 4,
                  ),

                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isUnavailable
                          ? Colors.grey.shade200
                          : primaryGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.access_time_rounded,
                      color: isUnavailable
                          ? Colors.grey
                          : primaryGreen,
                    ),
                  ),

                  title: Text(
                    timeKey,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isUnavailable
                          ? Colors.grey
                          : Colors.black,
                    ),
                  ),

                  trailing: isUnavailable
                      ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Bezet",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                      : null,

                  onTap: isUnavailable
                      ? null
                      : () {
                    Navigator.pop(context, time);
                  },
                ),
              );
            },
          ),
        );
      },
    );

    if (selected == null) return;

    // ── Tijd opslaan ────────────────────────────────────
    setState(() {
      if (isPickup) {
        pickupTime = selected;
      } else {
        returnTime = selected;
      }
    });
  }

  Future<void> pickReservationDates() async {

    final now = DateTime.now();

    // volledig onbeschikbare dagen
    final Set<DateTime> unavailableDays = {};

    final firstDate =
        widget.device.availableFrom ?? now;

    final lastDate =
        widget.device.availableTo ??
            DateTime(now.year + 2);

    // elke dag controleren
    DateTime current = DateTime(
      firstDate.year,
      firstDate.month,
      firstDate.day,
    );

    while (
    current.isBefore(lastDate) ||
        current.isAtSameMomentAs(lastDate)
    ) {

      final fullyUnavailable =
      await isDayFullyUnavailable(current);

      if (fullyUnavailable) {

        unavailableDays.add(
          DateTime(
            current.year,
            current.month,
            current.day,
          ),
        );
      }

      current = current.add(
        const Duration(days: 1),
      );
    }

    final picked = await showDateRangePicker(
      context: context,

      firstDate: firstDate,

      lastDate: lastDate,

      initialDateRange: reservationRange,

      helpText: "Kies huurperiode",

      selectableDayPredicate: (
          DateTime day,
          DateTime? start,
          DateTime? end,
          ) {

        final normalized = DateTime(
          day.year,
          day.month,
          day.day,
        );

        return !unavailableDays.contains(
          normalized,
        );
      },

      builder: (context, child) {

        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryGreen,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;

    setState(() {
      reservationRange = picked;
    });
  }

  Future<void> makeReservation() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Je moet ingelogd zijn"),
        ),
      );
      return;
    }

    if (reservationRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Kies eerst een huurperiode"),
        ),
      );
      return;
    }

    // volledige datetime maken
    final pickupDateTime = DateTime(
      reservationRange!.start.year,
      reservationRange!.start.month,
      reservationRange!.start.day,
      pickupTime.hour,
      pickupTime.minute,
    );

    final returnDateTime = DateTime(
      reservationRange!.end.year,
      reservationRange!.end.month,
      reservationRange!.end.day,
      returnTime.hour,
      returnTime.minute,
    );

    // ophalen moet vóór terugbrengen zijn
    if (!pickupDateTime.isBefore(returnDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Terugbrengen moet later zijn dan ophalen",
          ),
        ),
      );
      return;
    }

    setState(() => isReserving = true);

    try {
      // controleren op overlap
      final available = await isPeriodAvailable(
        newStart: pickupDateTime,
        newEnd: returnDateTime,
      );

      if (!available) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Deze periode is niet beschikbaar",
            ),
          ),
        );

        setState(() => isReserving = false);
        return;
      }

      // reservatie opslaan
      await FirebaseFirestore.instance
          .collection('reservations')
          .add({
        'deviceId': widget.device.id,
        'renterId': user.uid,
        'ownerId': widget.device.ownerId,

        // oude velden
        'fromDate': Timestamp.fromDate(reservationRange!.start),
        'toDate': Timestamp.fromDate(reservationRange!.end),

        // NIEUWE datetime velden
        'fromDateTime': Timestamp.fromDate(pickupDateTime),
        'toDateTime': Timestamp.fromDate(returnDateTime),

        'pickupHour': pickupTime.hour,
        'pickupMinute': pickupTime.minute,
        'returnHour': returnTime.hour,
        'returnMinute': returnTime.minute,

        'totalPrice': totalPrice,
        'status': 'Bevestigd',

        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Reservering aangevraagd!"),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const ReservationConfirmationScreen(),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Fout: $e"),
        ),
      );
    }

    if (mounted) {
      setState(() => isReserving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final device = widget.device;

    return Scaffold(
      backgroundColor: Colors.white,

      // ── App bar ──────────────────────────────────────
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : Colors.black,
            ),
            onPressed: () => setState(() => isFavorite = !isFavorite),
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          ),
        ],
      ),

      // ── Bottom bar met reserveer-knop ─────────────────
      bottomNavigationBar: _buildBottomBar(),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Grote foto ──────────────────────────────
            _buildImageSection(device),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Titel ───────────────────────────────
                  Text(
                    device.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ── Prijs ───────────────────────────────
                  Text(
                    "€ ${device.pricePerDay.toStringAsFixed(2)} / dag",
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Categorie chip ──────────────────────
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      device.category,
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey.shade700),
                    ),
                  ),

                  const Divider(height: 28),

                  // ── Info rijen ──────────────────────────
                  _infoRow(Icons.place_outlined, device.location),
                  const SizedBox(height: 10),
                  _infoRow(
                    Icons.date_range_outlined,
                    device.availableFrom != null && device.availableTo != null
                        ? "Beschikbaar: ${formatDate(device.availableFrom!)} – ${formatDate(device.availableTo!)}"
                        : "Beschikbaarheid onbekend",
                  ),
                  const SizedBox(height: 10),
                  _infoRow(Icons.person_outline, "Aangeboden door verhuurder"),

                  const Divider(height: 28),

                  // ── Beschrijving ────────────────────────
                  const Text(
                    "Omschrijving",
                    style: TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    device.description.isNotEmpty
                        ? device.description
                        : "Geen beschrijving opgegeven.",
                    style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade800,
                        height: 1.5),
                  ),

                  const Divider(height: 28),

                  // ── Huurperiode kiezen ──────────────────────────────
                  const Text(
                    "Huurperiode",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  // Datumkiezer
                  InkWell(
                    onTap: pickReservationDates,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, color: primaryGreen),
                          const SizedBox(width: 12),
                          Text(
                            reservationRange == null
                                ? "Kies je huurperiode"
                                : "${formatDate(reservationRange!.start)}  →  ${formatDate(reservationRange!.end)}",
                            style: TextStyle(
                              fontSize: 15,
                              color: reservationRange == null ? Colors.grey : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _timePickerTile(
                          label: "Ophalen om",
                          time: pickupTime,
                          onTap: () => pickTime(isPickup: true),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _timePickerTile(
                          label: "Terugbrengen om",
                          time: returnTime,
                          onTap: () => pickTime(isPickup: false),
                        ),
                      ),
                    ],
                  ),

                  // Totaalprijs preview (stond er al)
                  if (reservationRange != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      // ...
                    ),
                  ],


                  // ── Totaalprijs preview ─────────────────
                  if (reservationRange != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F7F0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "$totalDays dag${totalDays == 1 ? '' : 'en'} × €${device.pricePerDay.toStringAsFixed(2)}",
                            style: const TextStyle(fontSize: 14),
                          ),
                          Text(
                            "€ ${totalPrice.toStringAsFixed(2)}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: primaryGreen),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 80), // ruimte voor bottom bar
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Foto sectie ────────────────────────────────────────
  Widget _buildImageSection(DeviceModel device) {
    return Stack(
      children: [
        SizedBox(
          height: 300,
          width: double.infinity,
          child: device.imageUrl.isNotEmpty
              ? Image.network(
            device.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _imagePlaceholder(),
          )
              : _imagePlaceholder(),
        ),
        // Categorie badge bovenaan
        Positioned(
          top: 12,
          left: 12,
          child: Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              device.category,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(Icons.devices, size: 60, color: Colors.grey),
      ),
    );
  }

  // ── Info rij ───────────────────────────────────────────
  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
        ),
      ],
    );
  }

  // ── Bottom reserveer-knop ──────────────────────────────
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          // Bel-knop
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              side: BorderSide(color: Colors.grey.shade400),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            child: const Icon(Icons.chat_bubble_outline, color: Colors.black),
          ),

          const SizedBox(width: 12),

          // Reserveer-knop
          Expanded(
            child: ElevatedButton(
              onPressed: isReserving ? null : makeReservation,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: isReserving
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
                  : const Text(
                "Reserveer nu",
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _timePickerTile({
    required String label,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                primaryGreen.withValues(alpha: 0.08),
                primaryGreen.withValues(alpha: 0.02),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: primaryGreen.withValues(alpha: 0.15),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.access_time_rounded,
                  color: primaryGreen,
                  size: 20,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      "$hour:$minute",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

