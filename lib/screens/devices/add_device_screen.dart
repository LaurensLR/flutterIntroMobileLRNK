import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../firebase/device_service.dart';

class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({super.key});

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const List<String> _categories = [
    'Stofzuiger',
    'Grasmaaier',
    'Keukenmachine',
    'Gereedschap',
    'Tuin',
    'Overig',
  ];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  String _selectedCategory = _categories.first;
  DateTimeRange? _availabilityRange;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon == null ? null : Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primaryGreen, width: 2),
      ),
    );
  }

  bool _isAssetPath(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty || trimmed.startsWith('assets/');
  }

  Widget _buildAssetPreview(String assetPath) {
    if (assetPath.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        assetPath.trim(),
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

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  String _availabilityLabel() {
    final range = _availabilityRange;
    if (range == null) {
      return 'Kies periode';
    }
    return '${_formatDate(range.start)} - ${_formatDate(range.end)}';
  }

  Future<void> _pickAvailability() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year, now.month, now.day);
    final lastDate = DateTime(now.year + 2, 12, 31);

    final picked = await showDateRangePicker(
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDateRange: _availabilityRange,
      helpText: 'Kies beschikbaarheid',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: primaryGreen),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (picked != null) {
      setState(() {
        _availabilityRange = picked;
      });
    }
  }

  Future<void> _submit() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Je moet ingelogd zijn om een toestel toe te voegen'),
        ),
      );
      return;
    }

    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }

    if (_availabilityRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kies een beschikbaarheidsperiode')),
      );
      return;
    }

    final rawPrice = _priceController.text.trim().replaceAll(',', '.');
    final price = double.tryParse(rawPrice);
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vul een geldige prijs in')));
      return;
    }

    if (!_isAssetPath(_imageUrlController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gebruik een pad uit assets/, bv assets/images/foto.jpg'),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await DeviceService().addDevice(
        ownerId: user.uid,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        pricePerDay: price,
        location: _locationController.text.trim(),
        imageUrl: _imageUrlController.text.trim(),
        availableFrom: _availabilityRange!.start,
        availableTo: _availabilityRange!.end,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Toestel toegevoegd')));

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Fout bij opslaan')));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Toestel aanbieden'),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Vul de info van je toestel in',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _titleController,
                      decoration: _inputDecoration(
                        'Toestel naam',
                        icon: Icons.devices_outlined,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vul een naam in';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: _inputDecoration(
                        'Beschrijving',
                        icon: Icons.description_outlined,
                      ),
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vul een beschrijving in';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: _inputDecoration(
                        'Categorie',
                        icon: Icons.category_outlined,
                      ),
                      items: _categories
                          .map(
                            (category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: _inputDecoration(
                        'Prijs per dag (EUR)',
                        icon: Icons.euro_symbol,
                      ),
                      validator: (value) {
                        final raw = value?.trim().replaceAll(',', '.') ?? '';
                        if (raw.isEmpty) {
                          return 'Vul een prijs in';
                        }
                        final price = double.tryParse(raw);
                        if (price == null || price <= 0) {
                          return 'Vul een geldige prijs in';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _locationController,
                      decoration: _inputDecoration(
                        'Locatie (stad of postcode)',
                        icon: Icons.place_outlined,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vul een locatie in';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _imageUrlController,
                      decoration: _inputDecoration(
                        'Foto asset pad (optioneel)',
                        icon: Icons.image_outlined,
                      ).copyWith(
                        helperText: 'Voorbeeld: assets/images/mijnfoto.jpg',
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _buildAssetPreview(_imageUrlController.text),
                    ),
                    const SizedBox(height: 18),
                    InkWell(
                      onTap: _pickAvailability,
                      child: InputDecorator(
                        decoration: _inputDecoration(
                          'Beschikbaarheid',
                          icon: Icons.date_range,
                        ),
                        child: Text(
                          _availabilityLabel(),
                          style: TextStyle(
                            color: _availabilityRange == null
                                ? Colors.black54
                                : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Toestel toevoegen',
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
          ),
        ),
      ),
    );
  }
}
