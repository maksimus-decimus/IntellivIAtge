import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 1. Added Firebase Auth
import '../widgets/bouncy_button.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLogin;

  const LoginScreen({Key? key, required this.onLogin}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 2. Controllers to get the text from fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 3. The Firebase Login Logic
  Future<void> _signIn() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Success! The StreamBuilder in main.dart will handle the switch.
    } on FirebaseAuthException catch (e) {
      String message = 'Ocurrió un error';
      if (e.code == 'user-not-found')
        message = 'Usuario no encontrado.';
      else if (e.code == 'wrong-password') message = 'Contraseña incorrecta.';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
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

                  // 4. Email Input (Added Controller)
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _inputStyle('Correo electrónico'),
                  ),
                  const SizedBox(height: 16),

                  // 5. Password Input (Added Controller)
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: _inputStyle('Contraseña'),
                  ),
                  const SizedBox(height: 24),

                  // 6. Login Button (Connected to _signIn)
                  _isLoading
                      ? const CircularProgressIndicator()
                      : BouncyButton(
                          onPressed: _signIn,
                          fullWidth: true,
                          child: const Text('¡Vamos allá!'),
                        ),

                  const SizedBox(height: 32),
                  // ... Rest of your UI (Divider, Social Buttons) ...
                  Row(
                    children: const [
                      Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                      Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('O CONTINÚA CON',
                              style: TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12))),
                      Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                          child: BouncyButton(
                              onPressed: () {},
                              color: Colors.white,
                              child: const Text('Google',
                                  style: TextStyle(color: Color(0xFF334155))))),
                      const SizedBox(width: 16),
                      Expanded(
                          child: BouncyButton(
                              onPressed: () {},
                              color: Colors.white,
                              child: const Text('Apple',
                                  style: TextStyle(color: Color(0xFF334155))))),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper for consistent styling
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
