import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  /// Get Current User
  Future<User?> getCurrentUser() async {
    return _supabaseClient.auth.currentUser;
  }

  /// Sign In with Google
  Future<void> signInWithGoogle() async {
    try {
      // GoogleSignIn googleSignIn = GoogleSignIn(
      //   //serverClientId: dotenv.get('GOOGLE_OAUTH_ID'),
      //   scopes: [
      //     'email',
      //     'https://www.googleapis.com/auth/userinfo.profile',
      //   ],
      // );
      // print('Signing in with google');
      // final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      // if (googleUser == null) {
      //   // User canceled sign-in, return null
      //   return null;
      // }

      // // Get the ID token to authenticate with your backend:
      // final GoogleSignInAuthentication googleAuth =
      //     await googleUser.authentication;
      // final String googleToken = googleAuth.idToken!;

      // // Get user's name:
      // final String userName = googleUser.displayName ?? '';

      // Now you can send googleToken to your Supabase server
      bool response = await _supabaseClient.auth.signInWithOAuth(
          Provider.google,
          redirectTo: 'io.supabase.flutterquickstart://login-callback/',
          scopes: 'email https://www.googleapis.com/auth/userinfo.profile');
      print('Supabase response: ${response}');

      // if (response  != null) {
      //   print('Error during Supabase authentication: ${response.error!.message}');
      //   return null;
      // }
    } catch (e) {
      // TODO: Handle Error
      print(e);
      throw e;
    }
    return null;
  }
  // Future<GoogleSignInAccount?> signInWithGoogle() async {
  //   try {
  //     GoogleSignIn googleSignIn = GoogleSignIn(
  //       //serverClientId: dotenv.get('GOOGLE_OAUTH_ID'),
  //       scopes: [
  //         'email',
  //         'https://www.googleapis.com/auth/userinfo.profile',
  //       ],
  //     );
  //     print('Signing in with google');
  //     final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
  //     if (googleUser == null) {
  //       // User canceled sign-in, return null
  //       return null;
  //     }

  //     // Get the ID token to authenticate with your backend:
  //     final GoogleSignInAuthentication googleAuth =
  //         await googleUser.authentication;
  //     final String googleToken = googleAuth.idToken!;

  //     // Get user's name:
  //     final String userName = googleUser.displayName ?? '';

  //     // Now you can send googleToken to your Supabase server
  //     AuthResponse response = await _supabaseClient.auth
  //         .signInWithIdToken(provider: Provider.google, idToken: googleToken);
  //     print('Supabase response: ${response}');

  //     // if (response  != null) {
  //     //   print('Error during Supabase authentication: ${response.error!.message}');
  //     //   return null;
  //     // }

  //     return googleUser;
  //   } catch (e) {
  //     // TODO: Handle Error
  //     print(e);
  //     throw e;
  //   }
  //   return null;
  // }

  /// Sign In With Apple
  Future<AuthResponse> signInWithApple() async {
    final response = await _supabaseClient.auth.signInWithApple();
    return response;
  }

  /// Listen to Auth State Changes
  Stream<AuthState> getAuthStateStrean() {
    return _supabaseClient.auth.onAuthStateChange;
  }
}
