import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../widgets/bouncy_button.dart';
import '../services/user_service.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLogin;

  const LoginScreen({Key? key, required this.onLogin}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '616941545128-40jvtaasrp2u7mpapu4kn3ieqd07talr.apps.googleusercontent.com',
    scopes: [
      'email',
      'profile', // Incluye nombre y foto del perfil
    ],
  );
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Email/Password Sign In
  Future<void> _signIn() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      await UserService().createOrUpdateUserProfile();
      await UserService().setOnline();
    } on FirebaseAuthException catch (e) {
      String message = 'Ocurrió un error';
      if (e.code == 'user-not-found')
        message = 'Usuario no encontrado.';
      else if (e.code == 'wrong-password')
        message = 'Contraseña incorrecta.';
      else if (e.code == 'invalid-email')
        message = 'Correo electrónico inválido.';

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Email/Password Registration
  Future<void> _signUp() async {
    if (_emailController.text.trim().isEmpty || 
        _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, completa todos los campos'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    if (_passwordController.text.trim().length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La contraseña debe tener al menos 6 caracteres'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      await UserService().createOrUpdateUserProfile();
      await UserService().setOnline();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Cuenta creada con éxito! Bienvenido 🎉'),
            backgroundColor: Color(0xFF34D399),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Ocurrió un error al crear la cuenta';
      if (e.code == 'weak-password') {
        message = 'La contraseña es demasiado débil.';
      } else if (e.code == 'email-already-in-use') {
        message = 'Este correo ya está registrado.';
      } else if (e.code == 'invalid-email') {
        message = 'El correo electrónico no es válido.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Google Sign-In
  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      
      // Guardar nombre y foto del perfil de Google
      await UserService().createOrUpdateUserProfile(
        displayName: googleUser.displayName,
        photoUrl: googleUser.photoUrl,
      );
      await UserService().setOnline();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Bienvenido! 🎉'),
            backgroundColor: Color(0xFF34D399),
          ),
        );
      }
    } catch (e) {
      print('Error Google Sign-In: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al iniciar sesión con Google'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Password Reset
  Future<void> _resetPassword() async {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa tu correo electrónico primero'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Correo de recuperación enviado. Revisa tu bandeja de entrada 📧'),
            backgroundColor: Color(0xFF34D399),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al enviar correo de recuperación'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Decorative Circles (Kept from your original)
          Positioned(
            top: -50,
            left: -50,
            child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                    color: const Color(0xFF0EA5E9).withOpacity(0.2),
                    shape: BoxShape.circle)),
          ),
          Positioned(
            bottom: -20,
            right: -20,
            child: Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                    color: const Color(0xFFFBBF24).withOpacity(0.2),
                    shape: BoxShape.circle)),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo (Kept from your original)
                  Container(
                    width: 128,
                    height: 128,
                    decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xFFBAE6FD), width: 4)),
                    child: ClipOval(
                        child: Image.network(
                            'https://picsum.photos/seed/intelliviatge-logo/200/200',
                            fit: BoxFit.cover)),
                  ),
                  const SizedBox(height: 24),
                  const Text('IntellivIAtge',
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1E293B))),
                  const SizedBox(height: 8),
                  const Text('Tu compañero de aventuras en la ciudad condal.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B))),
                  const SizedBox(height: 48),

                  // Email Input
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _inputStyle('Correo electrónico'),
                  ),
                  const SizedBox(height: 16),

                  // Password Input with toggle visibility
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: _inputStyle('Contraseña').copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: const Color(0xFF94A3B8),
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                    ),
                  ),
                  
                  // Forgot Password Link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _resetPassword,
                      child: const Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(
                          color: Color(0xFF6366F1),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Login & Register Buttons
                  _isLoading
                      ? const CircularProgressIndicator()
                      : Column(
                          children: [
                            BouncyButton(
                              onPressed: _signIn,
                              fullWidth: true,
                              child: const Text('¡Vamos allá!'),
                            ),
                            const SizedBox(height: 12),
                            BouncyButton(
                              onPressed: _signUp,
                              fullWidth: true,
                              color: const Color(0xFF6366F1),
                              shadowColor: const Color(0xFF4338CA),
                              child: const Text('Crear cuenta nueva'),
                            ),
                          ],
                        ),

                  const SizedBox(height: 32),
                  
                  // Divider
                  Row(
                    children: const [
                      Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'O CONTINÚA CON',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Google Sign-In Button
                  BouncyButton(
                    onPressed: _signInWithGoogle,
                    fullWidth: true,
                    color: Colors.white,
                    child: const Text(
                      'Google',
                      style: TextStyle(
                        color: Color(0xFF334155),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Footer
                  const SizedBox(height: 32),
                  Text(
                    'Al continuar, aceptas nuestros Términos y Condiciones',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'v1.0.0',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[400],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputStyle(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 2)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF0EA5E9), width: 2)),
    );
  }
}
