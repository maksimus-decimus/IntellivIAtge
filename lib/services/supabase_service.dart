import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  late final SupabaseClient _client;

  SupabaseService._internal();

  factory SupabaseService() {
    return _instance;
  }

  Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://ceybtkyrvclavyctzuud.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNleWJ0a3lydmNsYXZ5Y3R6dXVkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzYwNzI4ODcsImV4cCI6MjA5MTY0ODg4N30.wjeBO2ftGnZyZj4xHQAJtbazTIwYfOQEFo3SxOp2-tk',
    );
    _client = Supabase.instance.client;
  }

  SupabaseClient get client => _client;

  // Login
  Future<bool> signIn(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.user != null;
    } catch (e) {
      print('Error al iniciar sesión: $e');
      return false;
    }
  }

  // Sign Up
  Future<bool> signUp(String email, String password) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      return response.user != null;
    } catch (e) {
      print('Error al registrarse: $e');
      return false;
    }
  }

  // Logout
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      print('Error al cerrar sesión: $e');
    }
  }

  // Get current user
  User? getCurrentUser() {
    return _client.auth.currentUser;
  }

  // Get session
  Session? getSession() {
    return _client.auth.currentSession;
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return getCurrentUser() != null;
  }
}
