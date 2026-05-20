import 'package:cloud_firestore/cloud_firestore.dart';

/// Handles all reads and writes to Cloud Firestore.
class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── User Profile ─────────────────────────────────────────────────────────

  /// Creates or overwrites the user profile document at users/{uid}.
  static Future<void> saveUserProfile({
    required String uid,
    required String name,
    required String email,
    required String phone,
    String? dob,
    String? gender,
    required String petName,
    required String petBreed,
    required String petAge,
    required String petWeight,
  }) async {
    // 1. Save User Profile
    await _db.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'phone': phone,
      if (dob != null) 'dob': dob,
      if (gender != null) 'gender': gender,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 2. Save Initial Pet Profile to a sub-collection
    await _db.collection('users').doc(uid).collection('pets').add({
      'name': petName,
      'breed': petBreed,
      'age': petAge,
      'weight': petWeight,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Fetches the user profile once.
  static Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data();
  }

  // ─── Scan History ─────────────────────────────────────────────────────────

  /// Saves a completed diagnosis scan to users/{uid}/scans/.
  /// Returns the generated scanId.
  static Future<String> saveScan({
    required String uid,
    required String petType,
    required String imageUrl,
    required String diagnosis,
    required double confidence,
    required String severity,
    required String urgency,
    required String description,
    required List<String> treatments,
    required List<String> matchedSymptoms,
    required Map<String, String> answers,
  }) async {
    final ref = await _db
        .collection('users')
        .doc(uid)
        .collection('scans')
        .add({
      'petType': petType,
      'imageUrl': imageUrl,
      'diagnosis': diagnosis,
      'confidence': confidence,
      'severity': severity,
      'urgency': urgency,
      'description': description,
      'treatments': treatments,
      'matchedSymptoms': matchedSymptoms,
      'answers': answers,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  /// Real-time stream of a user's scan history, newest first.
  static Stream<QuerySnapshot<Map<String, dynamic>>> scanHistoryStream(
      String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('scans')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
