import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../config/app_config.dart';
import '../../services/google_maps_web_loader.dart'
  if (dart.library.html) '../../services/google_maps_web_loader_web.dart'
  if (dart.library.io) '../../services/google_maps_web_loader_stub.dart';

class MapPickerScreen extends StatefulWidget {
  final LatLng? initialLocation;

  const MapPickerScreen({super.key, this.initialLocation});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  late LatLng picked;
  bool isLoadingMaps = false;
  bool mapsFailedToLoad = false;
  GoogleMapController? _mapController;
  static const Color primaryGreen = Color(0xFF2E7D32);

  @override
  void initState() {
    super.initState();
    picked =
        widget.initialLocation ??
        const LatLng(52.370216, 4.895168); // Amsterdam
    _prepareMaps();
  }

  Future<void> _prepareMaps() async {
    final apiKey = AppConfig.googleMapsApiKey;
    final hasValidKey = apiKey.isNotEmpty && apiKey != 'YOUR_API_KEY_HERE';

    if (!kIsWeb || !hasValidKey) {
      return;
    }

    setState(() {
      isLoadingMaps = true;
    });

    try {
      final loaded = await loadGoogleMapsForWeb(apiKey);
      if (!mounted) {
        return;
      }

      setState(() {
        isLoadingMaps = false;
        mapsFailedToLoad = !loaded;
      });
    } catch (e) {
      debugPrint('Error loading Google Maps: $e');
      if (mounted) {
        setState(() {
          isLoadingMaps = false;
          mapsFailedToLoad = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final apiKey = AppConfig.googleMapsApiKey;
    final hasValidKey = apiKey.isNotEmpty && apiKey != 'YOUR_API_KEY_HERE';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kies locatie'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          if (hasValidKey)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context, {
                    'lat': picked.latitude,
                    'lng': picked.longitude,
                    'address':
                        'Lat: ${picked.latitude.toStringAsFixed(5)}, Lng: ${picked.longitude.toStringAsFixed(5)}',
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.check),
                label: const Text('Selecteer'),
              ),
            ),
        ],
      ),
      body: !hasValidKey
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Google Maps API Key niet ingesteld',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Voeg je Google Maps API key toe aan het .env bestand en start de app opnieuw.\nGOOGLE_MAPS_API_KEY=your_key_here',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Terug'),
                    ),
                  ],
                ),
              ),
            )
          : isLoadingMaps
              ? const Center(child: CircularProgressIndicator())
              : mapsFailedToLoad
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.cloud_off_outlined,
                              size: 48,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Google Maps kon niet worden geladen in Chrome',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Controleer of de Maps JavaScript API is ingeschakeld voor je API key en of de web origin is toegestaan.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Terug'),
                            ),
                          ],
                        ),
                      ),
                    )
          : _buildGoogleMap(),
    );
  }

  Widget _buildGoogleMap() {
    return GoogleMap(
      initialCameraPosition: CameraPosition(target: picked, zoom: 14),
      onMapCreated: _onMapCreated,
      onTap: (pos) {
        setState(() {
          picked = pos;
        });
      },
      markers: {
        Marker(markerId: const MarkerId('picked'), position: picked),
      },
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }
}
