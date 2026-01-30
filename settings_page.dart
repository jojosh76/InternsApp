import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDarkMode = false;
  bool notificationsEnabled = true;
  String selectedLanguage = "Français";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Paramètres"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ================== COMPTE ==================
          const Text(
            "Compte",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Mon profil"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Naviguer vers la page profil si elle existe
            },
          ),

          const Divider(height: 32),

          // ================== PREFERENCES ==================
          const Text(
            "Préférences",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          SwitchListTile(
            title: const Text("Mode sombre"),
            value: isDarkMode,
            secondary: const Icon(Icons.dark_mode),
            onChanged: (value) {
              setState(() => isDarkMode = value);
              // TODO: connecter à un ThemeProvider si besoin
            },
          ),

          SwitchListTile(
            title: const Text("Notifications"),
            value: notificationsEnabled,
            secondary: const Icon(Icons.notifications),
            onChanged: (value) {
              setState(() => notificationsEnabled = value);
            },
          ),

          const Divider(height: 32),

          // ================== SECURITE ==================
          const Text(
            "Sécurité",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text("Changer le mot de passe"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Page reset password
            },
          ),

          const Divider(height: 32),

          // ================== LOGOUT ==================
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text(
              "Se déconnecter",
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: _handleLogout,
          ),
        ],
      ),
    );
  }

  // ================== LOGOUT LOGIC ==================
  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Déconnexion"),
        content: const Text("Voulez-vous vraiment vous déconnecter ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Déconnexion"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false,
    );
  }
}
