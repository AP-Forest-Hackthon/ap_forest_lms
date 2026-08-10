// ─────────────────────────────────────────────────────────────────────────────
// lib/core/services/auth_service.dart
// Firebase Authentication service — trainee Google Sign-In, faculty email/password.
// Role is ALWAYS read from Firestore (never trusted from client).
// ─────────────────────────────────────────────────────────────────────────────

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../models/user_model.dart';
import '../constants/app_constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // ── Stream ────────────────────────────────────────────────────────────────

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  // ── Google Sign-In (Trainees) ─────────────────────────────────────────────

  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // user cancelled

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential result = await _auth.signInWithCredential(credential);
      final User? user = result.user;
      if (user == null) return null;

      // Check if profile exists in Firestore
      final docRef = _db.collection(AppConstants.colUsers).doc(user.uid);
      final docSnap = await docRef.get();

      if (!docSnap.exists) {
        // First-time login → create trainee profile
        final newUser = UserModel(
          uid: user.uid,
          name: user.displayName ?? 'Officer Trainee',
          email: user.email ?? '',
          photoUrl: user.photoURL,
          role: UserRole.trainee,
          status: AppConstants.statusActive,
          createdAt: DateTime.now(),
        );
        await docRef.set(newUser.toFirestore());
        return newUser;
      }

      return UserModel.fromFirestore(docSnap);
    } catch (e) {
      rethrow;
    }
  }

  // ── Faculty / Admin Email+Password Sign-In ────────────────────────────────

  Future<UserModel?> signInWithEmail(String email, String password) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final User? user = result.user;
      if (user == null) return null;

      // Read role from Firestore — NEVER trust client-side role claims
      final docSnap =
          await _db.collection(AppConstants.colUsers).doc(user.uid).get();

      if (!docSnap.exists) {
        await _auth.signOut();
        throw Exception('Account not found. Contact administrator.');
      }

      final userModel = UserModel.fromFirestore(docSnap);

      if (userModel.status == AppConstants.statusInactive) {
        await _auth.signOut();
        throw Exception('Account is deactivated. Contact administrator.');
      }

      if (userModel.status == AppConstants.statusPending) {
        await _auth.signOut();
        throw Exception('Account is pending approval. Contact administrator.');
      }

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    }
  }

  // ── Get Current User Profile from Firestore ───────────────────────────────

  Future<UserModel?> getCurrentUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final docSnap =
        await _db.collection(AppConstants.colUsers).doc(user.uid).get();

    if (!docSnap.exists) return null;
    return UserModel.fromFirestore(docSnap);
  }

  // ── Sign Out ──────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  // ── Admin: Create Faculty Account (called from Admin panel) ───────────────

  /// Creates a faculty Firebase Auth account + Firestore profile.
  /// Only callable by authenticated admin users.
  Future<String> createFacultyAccount({
    required String email,
    required String password,
    required String name,
    required String designation,
    required String department,
    String? specialization,
    String? phone,
  }) async {
    // NOTE: In production, this should be a Cloud Function or Admin SDK call
    // so the calling admin doesn't get signed out. For MVP, we note this limitation.
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final User? user = result.user;
      if (user == null) throw Exception('Failed to create user');

      final facultyModel = UserModel(
        uid: user.uid,
        name: name,
        email: email,
        role: UserRole.faculty,
        designation: designation,
        department: department,
        specialization: specialization,
        status: AppConstants.statusActive,
        createdAt: DateTime.now(),
      );

      await _db
          .collection(AppConstants.colUsers)
          .doc(user.uid)
          .set(facultyModel.toFirestore());

      return user.uid;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    }
  }

  // ── Error Handler ─────────────────────────────────────────────────────────

  Exception _handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('No account found with this email.');
      case 'wrong-password':
        return Exception('Incorrect password.');
      case 'invalid-email':
        return Exception('Invalid email address.');
      case 'user-disabled':
        return Exception('Account has been disabled.');
      case 'too-many-requests':
        return Exception('Too many attempts. Please try again later.');
      case 'email-already-in-use':
        return Exception('Email is already in use.');
      case 'weak-password':
        return Exception('Password must be at least 6 characters.');
      case 'network-request-failed':
        return Exception('Network error. Check your internet connection.');
      default:
        return Exception(e.message ?? 'Authentication error occurred.');
    }
  }
}
