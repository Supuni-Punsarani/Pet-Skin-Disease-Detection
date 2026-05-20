import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _firebaseUser;
  String? _displayName;
  bool _isLoading = false;
  String? _errorMessage;

  // ─── Getters ────────────────────────────────────────────────────────────────
  bool get isLoggedIn => _firebaseUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get userName => _displayName ?? _firebaseUser?.email ?? 'User';
  String get userEmail => _firebaseUser?.email ?? '';
  String get uid => _firebaseUser?.uid ?? '';

  // ─── Initialise ─────────────────────────────────────────────────────────────
  /// Call once at startup. Listens to Firebase auth state so the app stays
  /// logged in after a hot restart or app kill.
  void init() {
    _auth.authStateChanges().listen((user) async {
      _firebaseUser = user;
      if (user != null) {
        // Load display name from Firestore profile
        final profile = await FirestoreService.getUserProfile(user.uid);
        _displayName = profile?['name'] as String?;
      }
      notifyListeners();
    });
  }

  // ─── Register ───────────────────────────────────────────────────────────────
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    String? dob,
    String? gender,
    required String petName,
    required String petBreed,
    required String petAge,
    required String petWeight,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Update display name in Firebase Auth
      await credential.user?.updateDisplayName(name);

      // Save full profile to Firestore
      await FirestoreService.saveUserProfile(
        uid: credential.user!.uid,
        name: name,
        email: email.trim(),
        phone: phone,
        dob: dob,
        gender: gender,
        petName: petName,
        petBreed: petBreed,
        petAge: petAge,
        petWeight: petWeight,
      );

      _displayName = name;
      _firebaseUser = credential.user;
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapAuthError(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ─── Sign In ─────────────────────────────────────────────────────────────────
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _firebaseUser = credential.user;

      // Load name from Firestore
      final profile = await FirestoreService.getUserProfile(credential.user!.uid);
      _displayName = profile?['name'] as String?;

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapAuthError(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ─── Google Sign In ────────────────────────────────────────────────────────
  /// Signs in with Google. If the user is new (has no Firestore profile),
  /// we create a basic profile for them (without pet data). Returns false if
  /// they cancel the dialog.
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
      if (gUser == null) {
        _isLoading = false;
        notifyListeners();
        return false; // User cancelled the sign-in flow
      }

      final GoogleSignInAuthentication gAuth = await gUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      final UserCredential userCred =
          await _auth.signInWithCredential(credential);

      // Check if user already has a Firestore profile
      final profile =
          await FirestoreService.getUserProfile(userCred.user!.uid);

      if (profile == null) {
        // First time signing in with Google! Create a barebones profile.
        // We will default the pet data to unknown since we can't get it from Google.
        await FirestoreService.saveUserProfile(
          uid: userCred.user!.uid,
          name: gUser.displayName ?? 'Google User',
          email: gUser.email,
          phone: '',
          petName: 'My Pet',
          petBreed: 'Unknown',
          petAge: '0',
          petWeight: '0',
        );
        _displayName = gUser.displayName ?? 'Google User';
      } else {
        _displayName = profile['name'] as String?;
      }

      _firebaseUser = userCred.user;
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapAuthError(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Google Sign-In failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ─── Sign Out ────────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    await _auth.signOut();
    _firebaseUser = null;
    _displayName = null;
    notifyListeners();
  }

  // ─── Password Reset ──────────────────────────────────────────────────────────
  Future<bool> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return true;
    } on FirebaseAuthException {
      return false;
    }
  }

  // ─── Helper ──────────────────────────────────────────────────────────────────
  String _mapAuthError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
