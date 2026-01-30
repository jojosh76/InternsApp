import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CourseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ==========================================
  // 📂 GESTION DES CONTENUS (PDF, SHEETS, ETC.)
  // ==========================================

  /// 📚 Récupérer les fichiers d'une thématique précise
  Stream<QuerySnapshot> getCourseContents(String courseId) {
    return _db
        .collection('courses')
        .doc(courseId)
        .collection('contents')
        .orderBy('createdAt', descending: true)
        .snapshots(); //
  }

  /// ➕ Ajouter une ressource (PDF, Lien, etc.)
  Future<void> uploadContent({
    required String courseId,
    required String title,
    required String description,
    required String url,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw "Utilisateur non connecté"; //

    final role = await getUserRole(); // Récupération sécurisée du rôle

    if (role != 'admin' && role != 'mentor') {
      throw "Accès refusé : rôle insuffisant"; //
    }

    await _db
        .collection('courses')
        .doc(courseId)
        .collection('contents')
        .add({
      'title': title,
      'description': description,
      'url': url,
      'uploaderId': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
    }); //
  }

  /// ❌ Supprimer un fichier spécifique
  Future<void> deleteContent(String courseId, String contentId) async {
    final role = await getUserRole();

    if (role != 'admin' && role != 'mentor') {
      throw "Seul un admin ou mentor peut supprimer un contenu"; //
    }

    await _db
        .collection('courses')
        .doc(courseId)
        .collection('contents')
        .doc(contentId)
        .delete(); //
  }

  // ==========================================
  // 🔐 LOGIQUE UTILISATEUR & RÔLES
  // ==========================================

  /// Récupère le rôle de l'utilisateur actuel depuis Firestore
  Future<String?> getUserRole() async {
    final user = _auth.currentUser;
    if (user == null) return null; //

    final userDoc = await _db.collection('users').doc(user.uid).get(); //
    
    if (!userDoc.exists) return 'student';
    return userDoc.data()?['role']; //
  }
}