import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isProcessing = false; // Pour gérer l'état de chargement

  // ================== LOGIQUE : RÉINITIALISER LE MOT DE PASSE ==================
  Future<void> _handleChangePassword() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null && user.email != null) {
      // Demander confirmation avant d'envoyer
      final bool? confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Réinitialisation"),
          content: Text("Envoyer un email de changement de mot de passe à ${user.email} ?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Annuler"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Envoyer"),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      setState(() => _isProcessing = true);

      try {
        // Envoie l'email de reset via Firebase
        await FirebaseAuth.instance.sendPasswordResetEmail(email: user.email!.trim());
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Lien de réinitialisation envoyé ! Vérifiez votre boîte mail (et spams)."),
            backgroundColor: Colors.green,
          ),
        );
      } on FirebaseAuthException catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur : ${e.message}"),
            backgroundColor: Colors.redAccent,
          ),
        );
      } finally {
        if (mounted) setState(() => _isProcessing = false);
      }
    }
  }

  // ================== LOGIQUE : DÉCONNEXION ==================
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
            child: const Text("Déconnexion", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    // Renvoi vers la page de login en effaçant l'historique
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Paramètres"),
        centerTitle: true,
        elevation: 0,
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ================== SECTION : COMPTE ==================
              const _SectionHeader(title: "COMPTE"),
              ListTile(
                leading: const Icon(Icons.person_outline, color: Colors.blueAccent),
                title: const Text("Mon profil"),
                subtitle: Text(FirebaseAuth.instance.currentUser?.email ?? ""),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // TODO: Naviguer vers ProfilPage
                },
              ),

              const Divider(height: 32),

              // ================== SECTION : SÉCURITÉ ==================
              const _SectionHeader(title: "SÉCURITÉ"),
              ListTile(
                leading: const Icon(Icons.lock_reset, color: Colors.orange),
                title: const Text("Changer le mot de passe"),
                subtitle: const Text("Recevoir un lien par email"),
                trailing: _isProcessing 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.send_rounded, size: 20),
                onTap: _isProcessing ? null : _handleChangePassword,
              ),

              const Divider(height: 48),

              // ================== SECTION : DÉCONNEXION ==================
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                tileColor: Colors.red.withOpacity(0.05),
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
          
          // Overlay de chargement global
          if (_isProcessing)
            Container(
              color: Colors.black12,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}