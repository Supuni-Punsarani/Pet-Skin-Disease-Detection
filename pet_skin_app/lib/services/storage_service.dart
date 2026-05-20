import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

/// Handles dog photo uploads to Firebase Storage.
class StorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads a dog photo and returns its public download URL.
  ///
  /// Stored at: dog_photos/{uid}/{timestamp}.jpg
  static Future<String> uploadDogPhoto({
    required String uid,
    required String localImagePath,
  }) async {
    final file = File(localImagePath);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final ref = _storage.ref().child('dog_photos/$uid/$timestamp.jpg');

    final uploadTask = await ref.putFile(
      file,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    return await uploadTask.ref.getDownloadURL();
  }
}
