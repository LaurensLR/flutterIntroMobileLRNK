// ======================================================
// IMAGE_PICKER_CARD.DART
// Herbruikbare foto picker met preview
// ======================================================

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart'; // 👈 voor kIsWeb
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerCard extends StatefulWidget {
  final Function(dynamic file) onImageSelected; // 👈 dynamic ipv File
  final String imageUrl;

  const ImagePickerCard({
    super.key,
    required this.onImageSelected,
    this.imageUrl = "",
  });

  @override
  State<ImagePickerCard> createState() => _ImagePickerCardState();
}

class _ImagePickerCardState extends State<ImagePickerCard> {
  static const Color primaryGreen = Color(0xFF2E7D32);
  final ImagePicker picker = ImagePicker();

  File? selectedImage;        // mobiel
  Uint8List? selectedBytes;   // web

  Future<void> pickImage() async {
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );

    if (image == null) return;

    if (kIsWeb) {
      final bytes = await image.readAsBytes();
      setState(() => selectedBytes = bytes);
      widget.onImageSelected(image); // XFile doorgeven op web
    } else {
      final file = File(image.path);
      setState(() => selectedImage = file);
      widget.onImageSelected(file);  // File doorgeven op mobiel
    }

    final file = File(image.path);

    setState(() {
      selectedImage = file;
    });

    widget.onImageSelected(file);
  }

  // --------------------------------------------------
  // FOTO VERWIJDEREN
  // --------------------------------------------------

  void removeImage() {
    setState(() {
      selectedImage = null;
    });
  }

  // --------------------------------------------------
  // UI
  // --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: pickImage,
      child: Stack(
        children: [

          /// RONDE FOTO
          CircleAvatar(
            radius: 44,
            backgroundImage: kIsWeb
                ? (selectedBytes != null
                ? MemoryImage(selectedBytes!) as ImageProvider
                : widget.imageUrl.isNotEmpty
                ? NetworkImage(widget.imageUrl)
                : null)
                : (selectedImage != null
                ? FileImage(selectedImage!) as ImageProvider
                : widget.imageUrl.isNotEmpty
                ? NetworkImage(widget.imageUrl)
                : null),
          ),

          /// CAMERA ICOONTJE
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: primaryGreen,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}