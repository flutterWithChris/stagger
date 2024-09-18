import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:buoy/features/auth/domain/repositories/auth_repository.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class AuthRepositoryImpl extends AuthRepository {
  final supabase.SupabaseClient _supabase = supabase.Supabase.instance.client;

  @override
  Future<(supabase.AuthResponse, String? firstName, String? lastName)?>
      signInWithGoogle() async {
    try {
      /// Web Client ID that you registered with Google Cloud.
      String? webClientId = dotenv.env['GOOGLE_OAUTH_ID'];

      String? androidClientId = dotenv.env['GOOGLE_ANDROID_OAUTH_CLIENT_ID'];

      ///
      /// iOS Client ID that you registered with Google Cloud.
      String? iosClientId = dotenv.env['GOOGLE_IOS_OAUTH_CLIENT_ID'];

      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: Platform.isAndroid ? null : iosClientId,
        serverClientId: webClientId,
      );
      final googleUser = await googleSignIn.signIn();
      final googleAuth = await googleUser!.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null) {
        throw 'No Access Token found.';
      }
      if (idToken == null) {
        throw 'No ID Token found.';
      }

      String? firstName = googleUser.displayName != null
          ? googleUser.displayName!.split(' ')[0]
          : null;
      String? lastName = googleUser.displayName != null
          ? googleUser.displayName!.split(' ')[1]
          : null;

      return (
        await _supabase.auth.signInWithIdToken(
          provider: supabase.OAuthProvider.google,
          idToken: idToken,
          accessToken: accessToken,
        ),
        firstName,
        lastName
      );
    } catch (e, stackTrace) {
      print(e);
      print(stackTrace);
      // scaffoldKey.currentState?.showSnackBar(
      //   getErrorSnackBar('Failed to sign in. Please try again.'),
      // );
      // await Sentry.captureException(
      //   e,
      //   stackTrace: stackTrace,
      // );
      return null;
    }
  }

  @override
  Stream<supabase.AuthState> get authStateChanges =>
      _supabase.auth.onAuthStateChange.asBroadcastStream();

  @override
  Future<(supabase.AuthResponse, String? firstName, String? lastName)?>
      signInWithApple() async {
    try {
      // Generate a random nonce for security purposes
      final rawNonce = _generateNonce();
      final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

      // Request Apple ID credential with email and full name scopes
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      // Extract the ID token from the credential
      final idToken = credential.identityToken;
      if (idToken == null) {
        throw const supabase.AuthException(
            'Could not find ID Token from generated credential.');
      }

      // Extract first name and last name from the Apple credential
      final String? firstName = credential.givenName;
      final String? lastName = credential.familyName;

      // Sign in to Supabase with the ID token and the original raw nonce
      return (
        await _supabase.auth.signInWithIdToken(
          provider: supabase.OAuthProvider.apple,
          idToken: idToken,
          nonce: rawNonce,
        ),
        firstName,
        lastName
      );
    } catch (e, stackTrace) {
      // scaffoldKey.currentState?.showSnackBar(
      //   getErrorSnackBar('Failed to sign in. Please try again.'),
      // );
      // await Sentry.captureException(
      //   e,
      //   stackTrace: stackTrace,
      // );
      return null;
    }
  }

// Helper function to generate a random nonce
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  @override
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e, stackTrace) {
      // scaffoldKey.currentState?.showSnackBar(
      //   getErrorSnackBar('Failed to sign out. Please try again.'),
      // );
      // await Sentry.captureException(
      //   e,
      //   stackTrace: stackTrace,
      // );
      return;
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      print('Deleting account: ${_supabase.auth.currentUser!.id}');
      await _supabase.auth.admin.deleteUser(_supabase.auth.currentUser!.id);
    } catch (e, stackTrace) {
      print(e);
      rethrow;
    }
  }
}
