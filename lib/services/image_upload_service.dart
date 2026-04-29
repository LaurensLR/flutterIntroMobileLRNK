import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

class ImageUploadService {

  // --------------------------------------------------
  // Upload afbeelding
  //
  // folder voorbeelden:
  // devices / profiles / chats
  // --------------------------------------------------

  Future<String> uploadImageBytes({
    required Uint8List bytes,
    required String folder,
    required String userId,
  }) async {
    try {
      final String fileName = DateTime.now().millisecondsSinceEpoch.toString();

      final Reference ref = FirebaseStorage.instance
          .ref()
          .child(folder)
          .child(userId)
          .child("$fileName.jpg");

      await ref.putData(bytes, SettableMetadata(contentType: "image/jpeg"));

      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception("Upload mislukt: $e");
    }
  }

  Future<String> uploadImage({
    required File file,
    required String folder,
    required String userId,
  }) async {
    try {
      final String fileName = DateTime.now().millisecondsSinceEpoch.toString();

      final Reference ref = FirebaseStorage.instance
          .ref()
          .child(folder)
          .child(userId)
          .child("$fileName.jpg");

      final UploadTask uploadTask = ref.putFile(file);
      await uploadTask.whenComplete(() {});

      final String url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      throw Exception("Upload mislukt: $e");
    }
  }

  // --------------------------------------------------
  // Afbeelding verwijderen
  // --------------------------------------------------

  Future<void> deleteImage(String imageUrl) async {
    try {
      final Reference ref = FirebaseStorage.instance.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw Exception("Verwijderen mislukt: $e");
    }
  }
}