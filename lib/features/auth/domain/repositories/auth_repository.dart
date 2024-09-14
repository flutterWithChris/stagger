import 'package:supabase/supabase.dart' as supabase;

abstract class AuthRepository {
  Future<(supabase.AuthResponse, String? firstName, String? lastName)?>
      signInWithGoogle();
  Future<(supabase.AuthResponse, String? firstName, String? lastName)?>
      signInWithApple();
  Future<void> signOut();
  Future<void> deleteAccount();
  Stream<supabase.AuthState> get authStateChanges;
}
