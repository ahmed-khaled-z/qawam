import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../models/login_model.dart';

abstract class LoginRemoteDataSource {
  Future<UserModel> signInWithGoogle();
  Future<void> signOut();
}

class LoginRemoteDataSourceImpl implements LoginRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  bool _initialized = false;

  LoginRemoteDataSourceImpl({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      // serverClientId is auto-detected from google-services.json
      // (oauth_client with client_type: 3).
      await GoogleSignIn.instance.initialize(
        serverClientId:
            '983763878341-ptib7icii7bo23v0eh7fl1m22432j4r8.apps.googleusercontent.com',
      );
      _initialized = true;
      debugPrint('[GoogleSignIn] Initialized successfully');
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    await _ensureInitialized();

    try {
      // First attempt lightweight (silent / auto) sign-in
      debugPrint('[GoogleSignIn] Attempting lightweight authentication...');
      GoogleSignInAccount? account = await GoogleSignIn.instance
          .attemptLightweightAuthentication();

      if (account == null) {
        // No cached/lightweight credential, use full interactive flow
        debugPrint(
          '[GoogleSignIn] Lightweight failed, trying full authenticate...',
        );
        account = await GoogleSignIn.instance.authenticate();
      }

      debugPrint('[GoogleSignIn] Got account: ${account.email}');

      // Get the idToken from authentication data
      final GoogleSignInAuthentication auth = account.authentication;
      final String? idToken = auth.idToken;

      debugPrint('[GoogleSignIn] idToken present: ${idToken != null}');

      if (idToken == null) {
        throw Exception('Failed to obtain ID token from Google Sign-In');
      }

      // Create a Firebase credential with the Google ID token
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(credential);

      final User? user = userCredential.user;

      if (user == null) {
        throw Exception('Failed to sign in with Google');
      }

      debugPrint('[GoogleSignIn] Firebase sign-in success: ${user.uid}');

      return UserModel(
        uid: user.uid,
        displayName: user.displayName,
        email: user.email,
        photoUrl: user.photoURL,
      );
    } on GoogleSignInException catch (e) {
      debugPrint('[GoogleSignIn] GoogleSignInException:');
      debugPrint('  code: ${e.code}');
      debugPrint('  description: ${e.description}');
      rethrow;
    } catch (e) {
      debugPrint('[GoogleSignIn] Error: $e');
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await GoogleSignIn.instance.signOut();
  }
}
