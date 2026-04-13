import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  late final FirebaseAuth _auth;

  FirebaseService._internal();

  factory FirebaseService() {
    return _instance;
  }

  FirebaseAuth get auth => _auth;

  void initialize() {
    _auth = FirebaseAuth.instance;
    print('✅ Firebase Auth inicializado correctamente');
  }

  // Login con email y contraseña
  Future<bool> signIn(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      
      if (userCredential.user != null) {
        print('✅ Login exitoso: ${userCredential.user!.email}');
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('❌ Usuario no encontrado');
      } else if (e.code == 'wrong-password') {
        print('❌ Contraseña incorrecta');
      } else {
        print('❌ Error al iniciar sesión: ${e.message}');
      }
      return false;
    } catch (e) {
      print('❌ Error inesperado: $e');
      return false;
    }
  }

  // Sign Up
  Future<bool> signUp(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      
      if (userCredential.user != null) {
        print('✅ Registro exitoso: ${userCredential.user!.email}');
        return true;
      }
      return false;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        print('❌ Email ya está en uso');
      } else if (e.code == 'weak-password') {
        print('❌ Contraseña muy débil');
      } else {
        print('❌ Error al registrarse: ${e.message}');
      }
      return false;
    } catch (e) {
      print('❌ Error inesperado: $e');
      return false;
    }
  }

  // Logout
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      print('✅ Logout exitoso');
    } catch (e) {
      print('❌ Error al cerrar sesión: $e');
    }
  }

  // Obtener usuario actual
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Verificar si está logueado
  bool isLoggedIn() {
    return getCurrentUser() != null;
  }

  // Escuchar cambios de autenticación
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }
}
