import 'package:flutter/material.dart';
import '../auth/auth_service.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final AuthService _auth = AuthService();

  bool loading = false;
  bool _obscureText = true;

  // --- LOGIQUE DE CONNEXION ---
  Future<void> loginEmail() async {
    try {
      setState(() => loading = true);
      await _auth.signInWithEmail(_email.text.trim(), _password.text.trim());
      if (!mounted) return;
      setState(() => loading = false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.redAccent),
      );
      setState(() => loading = false);
    }
  }

  Future<void> loginGoogle() async {
    try {
      setState(() => loading = true);
      await _auth.signInWithGoogle();
      if (!mounted) return;
      setState(() => loading = false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
      setState(() => loading = false);
    }
  }

  // --- STYLE DES CHAMPS ---
  InputDecoration _inputStyle(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.blue.shade200, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.blue, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE9EEF2), 
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 25),
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  spreadRadius: 2,
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Login",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF2D3E50)),
                ),
                const SizedBox(height: 25),

                // Champ Email
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Email:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _email,
                  decoration: _inputStyle("Enter your email"),
                ),
                const SizedBox(height: 20),

                // Champ Password
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Password:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _password,
                  obscureText: _obscureText,
                  decoration: _inputStyle("Enter your password"),
                ),
                const SizedBox(height: 25),

                // Bouton Log In
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: loading ? null : loginEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A90E2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: loading 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text("Log In", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),

                const SizedBox(height: 15),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? ", style: TextStyle(fontSize: 13, color: Colors.grey)),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPage())),
                      child: const Text(
                        "Register here",
                        style: TextStyle(color: Color(0xFF4A90E2), fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text("OR", style: TextStyle(color: Colors.grey, fontSize: 12))),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 15),

                // Bouton Google (Version sans icône réseau problématique)
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: OutlinedButton(
                    onPressed: loading ? null : loginGoogle,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // On remplace l'image par une icône Flutter standard ou rien du tout pour l'instant
                        const Icon(Icons.login, color: Colors.black54, size: 18),
                        const SizedBox(width: 10),
                        const Text("Continue with Google", style: TextStyle(color: Colors.black87, fontSize: 14)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}