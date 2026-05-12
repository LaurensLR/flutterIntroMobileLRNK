import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/geo.dart';
import '../devices/map_picker_screen.dart';
import '../../services/device_service.dart';

/// ======================================================
/// SEARCH SCREEN + FIREBASE
/// Devices laden uit Firestore
/// ======================================================

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const Color primaryGreen = Color(0xFF2E7D32);

  final searchController = TextEditingController();

  // Filters
  String selectedCategory = 'Alle';
  double maxPrice = 100.0;
  double radiusKm = 10.0;
  double? centerLat;
  double? centerLng;
  DateTimeRange? desiredRange;

  @override
  void initState() {
    super.initState();
    searchController.addListener(_handleSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_handleSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  void _handleSearchChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Zoeken",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// Zoekveld
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: "Zoek toestellen...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Filters card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filters',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  // Category placeholder - static categories for now
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedCategory,
                          items:
                              [
                                    'Alle',
                                    'Stofzuiger',
                                    'Grasmaaier',
                                    'Keukenmachine',
                                    'Gereedschap',
                                    'Tuin',
                                    'Overig',
                                  ]
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() {
                              selectedCategory = v;
                            });
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Radius / map picker
                      ElevatedButton.icon(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MapPickerScreen(),
                            ),
                          );
                          if (result != null && result is Map) {
                            setState(() {
                              centerLat = (result['lat'] as num).toDouble();
                              centerLng = (result['lng'] as num).toDouble();
                            });
                          }
                        },
                        icon: const Icon(Icons.map_outlined),
                        label: const Text('Kies centrum'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Text('Radius (km): '),
                      Expanded(
                        child: Slider(
                          value: radiusKm,
                          min: 1,
                          max: 100,
                          divisions: 20,
                          label: "${radiusKm.toStringAsFixed(0)} km",
                          onChanged: (v) => setState(() {
                            radiusKm = v;
                          }),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Max prijs: €${maxPrice.toStringAsFixed(0)}',
                        ),
                      ),
                      SizedBox(
                        width: 140,
                        child: Slider(
                          value: maxPrice,
                          min: 0,
                          max: 500,
                          divisions: 50,
                          onChanged: (v) => setState(() {
                            maxPrice = v;
                          }),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          final now = DateTime.now();
                          final picked = await showDateRangePicker(
                            context: context,
                            firstDate: now,
                            lastDate: DateTime(now.year + 2),
                          );
                          if (picked != null)
                            setState(() {
                              desiredRange = picked;
                            });
                        },
                        icon: const Icon(Icons.date_range),
                        label: const Text('Beschikbaarheid kiezen'),
                      ),

                      const SizedBox(width: 12),

                      if (desiredRange != null)
                        Text(
                          '${desiredRange!.start.day}/${desiredRange!.start.month} - ${desiredRange!.end.day}/${desiredRange!.end.month}',
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          /// Titel
          const Text(
            "Suggesties uit de buurt",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 14),

          // Devices stream and filtered list
          SizedBox(
            height: 260,
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: DeviceService().streamAllDevices(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("Geen toestellen gevonden"));
                }

                final docs = snapshot.data!.docs;

                // Apply client-side filters
                final q = searchController.text.trim().toLowerCase();

                final filtered = docs.where((doc) {
                  final data = doc.data();

                  final title = (data['title'] ?? '').toString().toLowerCase();
                  final desc = (data['description'] ?? '')
                      .toString()
                      .toLowerCase();
                  final category = (data['category'] ?? '').toString();
                  final price = (data['pricePerDay'] ?? 0).toDouble();

                  // Text search
                  if (q.isNotEmpty &&
                      !(title.contains(q) ||
                          desc.contains(q) ||
                          category.toLowerCase().contains(q))) {
                    return false;
                  }

                  // Category filter
                  if (selectedCategory != 'Alle' &&
                      category != selectedCategory)
                    return false;

                  // Price filter
                  if (price > maxPrice) return false;

                  // Availability filter
                  if (desiredRange != null) {
                    final from = (data['availableFrom']);
                    final to = (data['availableTo']);
                    DateTime? availFrom;
                    DateTime? availTo;
                    if (from != null && from is Timestamp)
                      availFrom = from.toDate();
                    if (to != null && to is Timestamp) availTo = to.toDate();

                    if (availFrom != null &&
                        availTo != null &&
                        desiredRange != null) {
                      // require overlap
                      if (availTo.isBefore(desiredRange!.start) ||
                          availFrom.isAfter(desiredRange!.end))
                        return false;
                    }
                  }

                  // Radius filter
                  if (centerLat != null && centerLng != null) {
                    final lat = (data['locationLat'] as num?)?.toDouble();
                    final lng = (data['locationLng'] as num?)?.toDouble();
                    if (lat == null || lng == null) return false;

                    final d = distanceKm(centerLat!, centerLng!, lat, lng);
                    if (d > radiusKm) return false;
                  }

                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text('Geen toestellen gevonden met deze filters'),
                  );
                }

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final data = filtered[index].data();

                    return _deviceCard(
                      title: data["title"],
                      city: data["location"] ?? '',
                      price: "€${data["pricePerDay"]}/dag",
                      category: data["category"],
                      imageUrl: (data["imageUrl"] ?? '').toString(),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// ==========================
  /// DEVICE CARD
  /// ==========================
  Widget _deviceCard({
    required String title,
    required String city,
    required String price,
    required String category,
    required String imageUrl,
  }) {
    Widget imageWidget;

    if (imageUrl.isEmpty) {
      imageWidget = Container(
        height: 90,
        decoration: BoxDecoration(
          color: primaryGreen.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Icon(
            Icons.inventory_2_outlined,
            size: 42,
            color: primaryGreen,
          ),
        ),
      );
    } else {
      final isAsset = imageUrl.startsWith('assets/');

      imageWidget = ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: isAsset
            ? Image.asset(
                imageUrl,
                height: 90,
                width: double.infinity,
                fit: BoxFit.cover,
              )
            : Image.network(
                imageUrl,
                height: 90,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 90,
                    decoration: BoxDecoration(
                      color: primaryGreen.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        size: 34,
                        color: primaryGreen,
                      ),
                    ),
                  );
                },
              ),
      );
    }

    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          imageWidget,

          const SizedBox(height: 12),

          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),

          const SizedBox(height: 4),

          Text(category, style: TextStyle(color: Colors.grey.shade600)),

          const SizedBox(height: 4),

          Text(city, style: TextStyle(color: Colors.grey.shade600)),

          const Spacer(),

          Text(
            price,
            style: const TextStyle(
              color: primaryGreen,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
