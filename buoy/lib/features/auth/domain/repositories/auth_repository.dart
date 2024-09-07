import 'package:supabase/supabase.dart' as supabase;

abstract class AuthRepository {
  Future<supabase.AuthResponse?> signInWithGoogle();
  Future<supabase.AuthResponse?> signInWithApple();
  Future<void> signOut();
  Future<void> deleteAccount();
  Stream<supabase.AuthState> get authStateChanges;
}
