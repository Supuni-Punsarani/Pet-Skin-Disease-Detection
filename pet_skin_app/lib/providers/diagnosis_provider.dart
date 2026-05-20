import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/symptom_answer.dart';
import '../models/disease_result.dart';
import '../data/disease_data.dart';
import '../services/api_service.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class DiagnosisProvider extends ChangeNotifier {
  String _selectedPet = 'Dog';
  SymptomAnswers _answers = SymptomAnswers();
  DiseaseResult? _result;
  List<String> _imagePaths = [];
  String? _errorMessage;

  String get selectedPet => _selectedPet;
  SymptomAnswers get answers => _answers;
  DiseaseResult? get result => _result;
  List<String> get imagePaths => _imagePaths;
  String? get errorMessage => _errorMessage;
  String? get primaryImagePath =>
      _imagePaths.isNotEmpty ? _imagePaths.first : null;

  void selectPet(String pet) {
    _selectedPet = pet;
    notifyListeners();
  }

  void addImage(String path) {
    _imagePaths.add(path);
    notifyListeners();
  }

  void clearImages() {
    _imagePaths.clear();
    notifyListeners();
  }

  /// Sets the answer (A/B/C/D/E) for any of the 6 symptom questions.
  void setAnswer(int questionNum, String answerCode) {
    switch (questionNum) {
      case 1:
        _answers = _answers.copyWith(q1Duration: answerCode);
      case 2:
        _answers = _answers.copyWith(q2Scratching: answerCode);
      case 3:
        _answers = _answers.copyWith(q3SkinLook: answerCode);
      case 4:
        _answers = _answers.copyWith(q4Smell: answerCode);
      case 5:
        _answers = _answers.copyWith(q5Environment: answerCode);
      case 6:
        _answers = _answers.copyWith(q6Behavior: answerCode);
    }
    notifyListeners();
  }

  /// Runs diagnosis:
  ///   1. Calls FastAPI backend for AI prediction
  ///   2. Uploads dog photo to Firebase Storage
  ///   3. Saves the full scan record to Firestore
  Future<void> runDiagnosis() async {
    _errorMessage = null;

    // ── Step 1: Get prediction from FastAPI ──────────────────────────────────
    if (_imagePaths.isNotEmpty) {
      try {
        _result = await ApiService.diagnose(
          imagePath: _imagePaths.first,
          answers: _answers,
          petType: _selectedPet,
        );
      } on ApiException catch (e) {
        _errorMessage = e.message;
        debugPrint('⚠ API failed, using local fallback: ${e.message}');
      } catch (e) {
        _errorMessage = e.toString();
        debugPrint('⚠ Unexpected error: $e');
      }
    }

    // ── Fallback: local rule-based diagnosis ─────────────────────────────────
    if (_result == null) {
      await Future.delayed(const Duration(seconds: 1));
      _result = DiseaseDatabase.diagnose(_answers, _selectedPet);
    }

    notifyListeners();

    // ── Step 2+3: Upload photo + save to Firestore ───────────────────────────
    // Runs in background — does NOT block the result screen from showing.
    _saveToFirebase();
  }

  /// Uploads the dog photo to Firebase Storage and saves the full scan
  /// record to Firestore. Runs after the result is already shown to the user.
  Future<void> _saveToFirebase() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || _result == null) return;

    try {
      // Upload photo (if one was selected)
      String imageUrl = '';
      if (_imagePaths.isNotEmpty) {
        imageUrl = await StorageService.uploadDogPhoto(
          uid: uid,
          localImagePath: _imagePaths.first,
        );
      }

      // Save full scan record to Firestore
      await FirestoreService.saveScan(
        uid: uid,
        petType: _selectedPet,
        imageUrl: imageUrl,
        diagnosis: _result!.diseaseName,
        confidence: _result!.confidence,
        severity: _result!.severity,
        urgency: _result!.urgency,
        description: _result!.description,
        treatments: _result!.treatments,
        matchedSymptoms: _result!.matchedSymptoms,
        answers: {
          'q1': _answers.q1Duration ?? 'E',
          'q2': _answers.q2Scratching ?? 'A',
          'q3': _answers.q3SkinLook ?? 'D',
          'q4': _answers.q4Smell ?? 'A',
          'q5': _answers.q5Environment ?? 'A',
          'q6': _answers.q6Behavior ?? 'A',
        },
      );
      debugPrint('✅ Scan saved to Firestore successfully.');
    } catch (e) {
      // Non-critical — don't disrupt the user experience
      debugPrint('⚠ Failed to save scan to Firebase: $e');
    }
  }

  void reset() {
    _answers = SymptomAnswers();
    _result = null;
    _imagePaths = [];
    _errorMessage = null;
    notifyListeners();
  }
}
