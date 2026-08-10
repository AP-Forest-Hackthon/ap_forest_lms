// ─────────────────────────────────────────────────────────────────────────────
// lib/core/services/auth_service.dart
// Firebase Authentication service — Admin, Faculty (with approval flow), Student.
// Default Admin: apforest@email.com / apforest123
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

  // ── Google Sign-In (Students / Trainees) ──────────────────────────────────

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

      final docRef = _db.collection(AppConstants.colUsers).doc(user.uid);
      final docSnap = await docRef.get();

      if (!docSnap.exists) {
        final newUser = UserModel(
          uid: user.uid,
          name: user.displayName ?? 'Student',
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

  // ── Unified Email / User ID Sign-In ───────────────────────────────────────

  /// Supports logging in using Email OR Student User ID (e.g. APSFA2026001).
  Future<UserModel?> signIn({
    required String identifier, // Email or User ID
    required String password,
    UserRole? expectedRole,
  }) async {
    final trimmedIdentifier = identifier.trim();

    // Check if logging in as Default Admin
    if (trimmedIdentifier.toLowerCase() == 'apforest@email.com' && password == 'apforest123') {
      return await _loginOrCreateDefaultAdmin();
    }

    String emailToUse = trimmedIdentifier;

    // If identifier is not an email address, treat it as Student User ID
    if (!trimmedIdentifier.contains('@')) {
      final userQuery = await _db
          .collection(AppConstants.colUsers)
          .where('studentId', isEqualTo: trimmedIdentifier)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        final fallbackQuery = await _db
            .collection(AppConstants.colUsers)
            .where('userId', isEqualTo: trimmedIdentifier)
            .limit(1)
            .get();
        if (fallbackQuery.docs.isEmpty) {
          throw Exception('This User ID is not registered.');
        }
        emailToUse = fallbackQuery.docs.first.data()['email'] ?? '';
      } else {
        emailToUse = userQuery.docs.first.data()['email'] ?? '';
      }
    }

    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: emailToUse,
        password: password,
      );

      final User? user = result.user;
      if (user == null) throw Exception('Authentication failed.');

      final docSnap =
          await _db.collection(AppConstants.colUsers).doc(user.uid).get();

      if (!docSnap.exists) {
        await _auth.signOut();
        throw Exception('Account record not found. Please contact administrator.');
      }

      final userModel = UserModel.fromFirestore(docSnap);

      // Verify Role if expected
      if (expectedRole != null && userModel.role != expectedRole) {
        await _auth.signOut();
        throw Exception('Access denied. Please log in using the correct role section.');
      }

      // Check Status
      if (userModel.status == 'pending') {
        await _auth.signOut();
        throw Exception(
          'Your faculty account is awaiting administrator approval.\n\n'
          'You will be able to log in after your account has been approved by the administrator.',
        );
      }

      if (userModel.status == 'rejected') {
        await _auth.signOut();
        throw Exception(
          'Your faculty registration request has been rejected.\n'
          'Please contact the administrator.',
        );
      }

      if (userModel.status == 'inactive') {
        await _auth.signOut();
        throw Exception('Account is deactivated. Contact administrator.');
      }

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    }
  }

  // ── Default Admin Helper ──────────────────────────────────────────────────

  Future<UserModel> _loginOrCreateDefaultAdmin() async {
    const adminEmail = 'apforest@email.com';
    const adminPass = 'apforest123';

    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: adminEmail,
        password: adminPass,
      );
      final user = result.user!;
      final docSnap = await _db.collection(AppConstants.colUsers).doc(user.uid).get();

      if (!docSnap.exists) {
        final adminModel = UserModel(
          uid: user.uid,
          name: 'System Administrator',
          email: adminEmail,
          role: UserRole.admin,
          status: AppConstants.statusActive,
          createdAt: DateTime.now(),
        );
        await _db.collection(AppConstants.colUsers).doc(user.uid).set(adminModel.toFirestore());
        return adminModel;
      }

      return UserModel.fromFirestore(docSnap);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        // Create default admin account in Auth + Firestore
        final result = await _auth.createUserWithEmailAndPassword(
          email: adminEmail,
          password: adminPass,
        );
        final user = result.user!;
        final adminModel = UserModel(
          uid: user.uid,
          name: 'System Administrator',
          email: adminEmail,
          role: UserRole.admin,
          status: AppConstants.statusActive,
          createdAt: DateTime.now(),
        );
        await _db.collection(AppConstants.colUsers).doc(user.uid).set(adminModel.toFirestore());
        return adminModel;
      }
      rethrow;
    }
  }

  // ── Faculty Self-Registration ─────────────────────────────────────────────

  Future<void> registerFaculty({
    required String name,
    required String subject,
    required String email,
    required String password,
  }) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = result.user;
      if (user == null) throw Exception('Registration failed.');

      final facultyModel = UserModel(
        uid: user.uid,
        name: name.trim(),
        email: email.trim(),
        role: UserRole.faculty,
        subject: subject.trim(),
        status: 'pending', // Awaiting admin approval
        createdAt: DateTime.now(),
      );

      await _db.collection(AppConstants.colUsers).doc(user.uid).set(facultyModel.toFirestore());

      // Immediately sign out so pending faculty cannot stay authenticated
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    }
  }

  // ── Student Self-Registration ─────────────────────────────────────────────

  Future<UserModel> registerStudent({
    required String studentId,
    required String name,
    required String email,
    required String password,
  }) async {
    final cleanId = studentId.trim();

    // Check unique Student ID
    final existingId = await _db
        .collection(AppConstants.colUsers)
        .where('studentId', isEqualTo: cleanId)
        .get();

    if (existingId.docs.isNotEmpty) {
      throw Exception('This User ID is already registered. Please choose another User ID.');
    }

    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = result.user;
      if (user == null) throw Exception('Registration failed.');

      final studentModel = UserModel(
        uid: user.uid,
        name: name.trim(),
        email: email.trim(),
        role: UserRole.trainee,
        studentId: cleanId,
        status: 'active',
        createdAt: DateTime.now(),
      );

      await _db.collection(AppConstants.colUsers).doc(user.uid).set(studentModel.toFirestore());
      return studentModel;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    }
  }

  // ── Current User Profile ──────────────────────────────────────────────────

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

  // ── Error Handler ─────────────────────────────────────────────────────────

  Exception _handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('Invalid email or password.');
      case 'wrong-password':
      case 'invalid-credential':
        return Exception('Invalid email or password.');
      case 'invalid-email':
        return Exception('Invalid email address.');
      case 'user-disabled':
        return Exception('Account has been disabled.');
      case 'too-many-requests':
        return Exception('Too many attempts. Please try again later.');
      case 'email-already-in-use':
        return Exception('An account with this email already exists.');
      case 'weak-password':
        return Exception('Password must be at least 6 characters.');
      default:
        return Exception(e.message ?? 'Authentication error occurred.');
    }
  }
}
