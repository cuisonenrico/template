import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import '../utils/app_logger.dart';

/// Firebase Authentication Service
/// Handles email/password and Google Sign-In authentication
class FirebaseAuthService {
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  factory FirebaseAuthService() => _instance;
  FirebaseAuthService._internal();

  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;

  // GoogleSignIn reads client ID from GoogleService-Info.plist (iOS)
  // and google-services.json (Android) automatically
  late final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  final _logger = AppLogger();

  /// Get current Firebase user
  firebase_auth.User? get currentUser => _firebaseAuth.currentUser;

  /// Get current user ID
  String? get currentUserId => _firebaseAuth.currentUser?.uid;

  /// Get current user email
  String? get currentUserEmail => _firebaseAuth.currentUser?.email;

  /// Check if user is signed in
  bool get isSignedIn => _firebaseAuth.currentUser != null;

  /// Stream of auth state changes
  Stream<firebase_auth.User?> get authStateChanges =>
      _firebaseAuth.authStateChanges();

  /// Sign in with email and password
  Future<FirebaseAuthResult> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      _logger.info('Attempting email/password sign in', {'email': email});

      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _logger.info('Email/password sign in successful', {
        'userId': userCredential.user?.uid,
        'email': userCredential.user?.email,
      });

      return FirebaseAuthResult(success: true, user: userCredential.user);
    } on firebase_auth.FirebaseAuthException catch (e, stackTrace) {
      _logger.error('Email/password sign in failed', e, stackTrace);
      return FirebaseAuthResult(
        success: false,
        errorMessage: _getAuthErrorMessage(e),
      );
    } catch (e, stackTrace) {
      _logger.error('Unexpected error during sign in', e, stackTrace);
      return FirebaseAuthResult(
        success: false,
        errorMessage: 'An unexpected error occurred',
      );
    }
  }

  /// Sign up with email and password
  Future<FirebaseAuthResult> signUpWithEmailPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      _logger.info('Attempting email/password sign up', {'email': email});

      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name if provided
      if (displayName != null && userCredential.user != null) {
        await userCredential.user!.updateDisplayName(displayName);
        await userCredential.user!.reload();
      }

      _logger.info('Email/password sign up successful', {
        'userId': userCredential.user?.uid,
        'email': userCredential.user?.email,
      });

      return FirebaseAuthResult(success: true, user: _firebaseAuth.currentUser);
    } on firebase_auth.FirebaseAuthException catch (e, stackTrace) {
      _logger.error('Email/password sign up failed', e, stackTrace);
      return FirebaseAuthResult(
        success: false,
        errorMessage: _getAuthErrorMessage(e),
      );
    } catch (e, stackTrace) {
      _logger.error('Unexpected error during sign up', e, stackTrace);
      return FirebaseAuthResult(
        success: false,
        errorMessage: 'An unexpected error occurred',
      );
    }
  }

  /// Sign in with Google
  Future<FirebaseAuthResult> signInWithGoogle() async {
    try {
      _logger.info('Attempting Google sign in');

      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        _logger.warning('Google sign in cancelled by user');
        return FirebaseAuthResult(
          success: false,
          errorMessage: 'Sign in cancelled',
        );
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      _logger.info('Google sign in successful', {
        'userId': userCredential.user?.uid,
        'email': userCredential.user?.email,
        'displayName': userCredential.user?.displayName,
      });

      return FirebaseAuthResult(success: true, user: userCredential.user);
    } on firebase_auth.FirebaseAuthException catch (e, stackTrace) {
      _logger.error('Google sign in failed', e, stackTrace);
      return FirebaseAuthResult(
        success: false,
        errorMessage: _getAuthErrorMessage(e),
      );
    } catch (e, stackTrace) {
      _logger.error('Unexpected error during Google sign in', e, stackTrace);
      return FirebaseAuthResult(
        success: false,
        errorMessage: 'An unexpected error occurred',
      );
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      _logger.info('Signing out user');
      await Future.wait([_firebaseAuth.signOut(), _googleSignIn.signOut()]);
      _logger.info('Sign out successful');
    } catch (e, stackTrace) {
      _logger.error('Error during sign out', e, stackTrace);
      rethrow;
    }
  }

  /// Send password reset email
  Future<FirebaseAuthResult> sendPasswordResetEmail(String email) async {
    try {
      _logger.info('Sending password reset email', {'email': email});
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      _logger.info('Password reset email sent');
      return FirebaseAuthResult(success: true);
    } on firebase_auth.FirebaseAuthException catch (e, stackTrace) {
      _logger.error('Failed to send password reset email', e, stackTrace);
      return FirebaseAuthResult(
        success: false,
        errorMessage: _getAuthErrorMessage(e),
      );
    }
  }

  /// Delete current user account
  Future<FirebaseAuthResult> deleteAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return FirebaseAuthResult(
          success: false,
          errorMessage: 'No user signed in',
        );
      }

      _logger.warning('Deleting user account', {'userId': user.uid});
      await user.delete();
      _logger.info('User account deleted');
      return FirebaseAuthResult(success: true);
    } on firebase_auth.FirebaseAuthException catch (e, stackTrace) {
      _logger.error('Failed to delete account', e, stackTrace);
      return FirebaseAuthResult(
        success: false,
        errorMessage: _getAuthErrorMessage(e),
      );
    }
  }

  /// Get Firebase ID token for API authentication
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;
      return await user.getIdToken(forceRefresh);
    } catch (e, stackTrace) {
      _logger.error('Failed to get ID token', e, stackTrace);
      return null;
    }
  }

  /// Convert Firebase error codes to user-friendly messages
  String _getAuthErrorMessage(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'invalid-email':
        return 'Invalid email address';
      case 'weak-password':
        return 'Password is too weak. Please use a stronger password';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled';
      case 'requires-recent-login':
        return 'Please sign in again to continue';
      case 'invalid-credential':
        return 'Invalid credentials provided';
      case 'account-exists-with-different-credential':
        return 'An account already exists with this email using a different sign-in method';
      default:
        return e.message ?? 'Authentication failed. Please try again';
    }
  }
}

/// Result class for Firebase authentication operations
class FirebaseAuthResult {
  final bool success;
  final firebase_auth.User? user;
  final String? errorMessage;

  FirebaseAuthResult({required this.success, this.user, this.errorMessage});

  String? get userId => user?.uid;
  String? get email => user?.email;
  String? get displayName => user?.displayName;
  String? get photoUrl => user?.photoURL;
}
