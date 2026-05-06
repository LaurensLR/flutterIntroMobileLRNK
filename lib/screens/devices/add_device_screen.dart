import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/device_service.dart';
import '../../services/image_upload_service.dart';
import '../../widgets/image_picker_card.dart';
import 'map_picker_screen.dart';

/// ======================================================
/// TOESTEL AANBIEDEN SCREEN
/// Apple / iOS geïnspireerde stijl
/// ======================================================

class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({super.key});

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  static const Color primaryGreen = Color(0xFF2E7D32);

  static const List<String> categories = [
    "Stofzuiger",
    "Grasmaaier",
    "Keukenmachine",
    "Gereedschap",
    "Tuin",
    "Overig",
  ];

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController titleController = TextEditingController();

  final TextEditingController descriptionController = TextEditingController();

  final TextEditingController priceController = TextEditingController();

  final TextEditingController locationController = TextEditingController();

  double? locationLat;
  double? locationLng;

  dynamic selectedImage;

  String selectedCategory = categories.first;

  DateTimeRange? availabilityRange;

  bool isSaving = false;

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    locationController.dispose();
    super.dispose();
  }

  /// --------------------------------------------------
  /// INPUT STYLING
  /// --------------------------------------------------

  InputDecoration inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: primaryGreen, width: 2),
      ),
    );
  }

  /// --------------------------------------------------
  /// DATUM FORMATTEREN
  /// --------------------------------------------------

  String formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');

    final month = date.month.toString().padLeft(2, '0');

    return "$day/$month/${date.year}";
  }

  String availabilityLabel() {
    if (availabilityRange == null) {
      return "Kies periode";
    }

    return "${formatDate(availabilityRange!.start)} - ${formatDate(availabilityRange!.end)}";
  }

  /// --------------------------------------------------
  /// PERIODE KIEZEN
  /// --------------------------------------------------

  Future<void> pickAvailability() async {
    final now = DateTime.now();

    final picked = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      initialDateRange: availabilityRange,
      helpText: "Beschikbaarheid",
    );

    if (picked != null) {
      setState(() {
        availabilityRange = picked;
      });
    }
  }

  /// --------------------------------------------------
  /// OPSLAAN
  /// --------------------------------------------------

  Future<void> submit() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    if (!formKey.currentState!.validate()) {
      return;
    }

    if (availabilityRange == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Kies beschikbaarheid")));
      return;
    }

    final price = double.tryParse(priceController.text.replaceAll(',', '.'));

    if (price == null || price <= 0) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      if (selectedImage == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Kies eerst een foto")));
        setState(() {
          isSaving = false;
        });
        return;
      }

      final bytes = await (selectedImage as dynamic).readAsBytes();
      final imageUrl = await ImageUploadService().uploadImageBytes(
        bytes: bytes,
        folder: "devices",
        userId: user.uid,
      );

      await DeviceService().addDevice(
        ownerId: user.uid,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        category: selectedCategory,
        pricePerDay: price,
        location: locationController.text.trim(),
        locationLat: locationLat,
        locationLng: locationLng,
        imageUrl: imageUrl,
        availableFrom: availabilityRange!.start,
        availableTo: availabilityRange!.end,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Toestel toegevoegd")));

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Fout: $e")));
    }

    setState(() {
      isSaving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF7F7F7),
        foregroundColor: Colors.black,
        title: const Text(
          "Toestel aanbieden",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Form(
          key: formKey,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,

            children: [
              Center(
                child: ImagePickerCard(
                  onImageSelected: (file) {
                    setState(() {
                      selectedImage = file;
                    });
                  },
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                "Vul de gegevens van je toestel in",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 24),

              TextFormField(
                controller: titleController,
                decoration: inputStyle("Naam toestel", Icons.devices_outlined),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? "Verplicht" : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: descriptionController,
                maxLines: 4,
                decoration: inputStyle(
                  "Beschrijving",
                  Icons.description_outlined,
                ),
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: selectedCategory,
                decoration: inputStyle("Categorie", Icons.category_outlined),
                items: categories
                    .map(
                      (item) =>
                          DropdownMenuItem(value: item, child: Text(item)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    selectedCategory = value;
                  });
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: inputStyle("Prijs per dag", Icons.euro_symbol),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: locationController,
                      decoration: inputStyle("Locatie", Icons.place_outlined),
                      readOnly: true,
                    ),
                  ),

                  const SizedBox(width: 12),

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
                          locationController.text = result['address'] ?? '';
                          locationLat = (result['lat'] as num).toDouble();
                          locationLng = (result['lng'] as num).toDouble();
                        });
                      }
                    },
                    icon: const Icon(Icons.map_outlined),
                    label: const Text('Kies op kaart'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              InkWell(
                onTap: pickAvailability,
                borderRadius: BorderRadius.circular(18),

                child: InputDecorator(
                  decoration: inputStyle("Beschikbaarheid", Icons.date_range),
                  child: Text(availabilityLabel()),
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                height: 56,

                child: ElevatedButton(
                  onPressed: isSaving ? null : submit,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),

                  child: isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Toestel toevoegen",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
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
