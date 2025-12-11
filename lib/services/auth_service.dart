import 'package:firebase_auth/firebase_auth.dart';

/// A service class to handle all Firebase Authentication logic.
class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// Stream of authentication state changes.
  ///
  /// This can be used to listen for when a user signs in or out.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Gets the current signed-in user.
  User? get currentUser => _firebaseAuth.currentUser;

  /// Signs in a user with the given email and password.
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      // Re-throw the exception to be handled by the UI.
      throw Exception(e.message);
    }
  }

  /// Creates a new user with the given email and password.
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      // Re-throw the exception to be handled by the UI.
      throw Exception(e.message);
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
