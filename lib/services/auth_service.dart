import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class AuthService {
  final SupabaseClient supabase = SupabaseService.client;

  /// Sign up a new user
  Future<AuthResponse?> signUp(String email, String password) async {
    try {
      final response = await supabase.auth.signUp(email: email, password: password);
      return response;
    } catch (error) {
      print("🔥 SignUp Error: $error");
      return null; // Return null if an error occurs
    }
  }

  /// Sign in an existing user
  Future<AuthResponse?> signIn(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(email: email, password: password);
      return response;
    } catch (error) {
      print("⚠️ SignIn Error: $error");
      return null; // Return null if sign-in fails
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
      print("✅ User signed out successfully.");
    } catch (error) {
      print("❌ SignOut Error: $error");
    }
  }

  /// Get the current authenticated user
  User? getCurrentUser() {
    try {
      return supabase.auth.currentUser;
    } catch (error) {
      print("⚠️ GetUser Error: $error");
      return null;
    }
  }

  /// Check if user is logged in
  bool isUserLoggedIn() {
    return getCurrentUser() != null;
  }

  /// Send password reset email
  Future<bool> resetPassword(String email) async {
    try {
      await supabase.auth.resetPasswordForEmail(email);
      print("📩 Password reset email sent to $email.");
      return true;
    } catch (error) {
      print("❌ Reset Password Error: $error");
      return false;
    }
  }

  /// Listen to authentication state changes
  void listenToAuthChanges(Function(User?) callback) {
    supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      callback(session?.user);
    });
  }
}
