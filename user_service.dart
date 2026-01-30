import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// 🔐 Détermine le rôle selon le domaine email
  String _resolveRoleFromEmail(String email) {
    if (email.toLowerCase().endsWith("@ict.cm")) {
      return "mentor"; 
    }
    return "student";
  }

  /// Crée ou met à jour le profil utilisateur dans Firestore
  Future<void> saveUser(
    User user, {
    Map<String, dynamic>? additionalData,
  }) async {
    final ref = _db.collection('users').doc(user.uid);
    final snap = await ref.get();

    final email = user.email ?? "";

    Map<String, dynamic> userData = {
      'uid': user.uid,
      'email': email,
      'lastLogin': FieldValue.serverTimestamp(),
    };

    // 👇 PREMIÈRE CONNEXION UNIQUEMENT
    if (!snap.exists) {
      userData['createdAt'] = FieldValue.serverTimestamp();
      userData['role'] = _resolveRoleFromEmail(email);
    }

    // Ajout des données supplémentaires (nom, provider, etc.)
    if (additionalData != null) {
      userData.addAll(additionalData);
    }

    // Fusion des données pour ne pas écraser l'existant
    await ref.set(userData, SetOptions(merge: true));
  }
}