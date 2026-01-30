import 'package:cloud_firestore/cloud_firestore.dart';

class PostService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 📝 Créer un nouveau post
  Future<void> createPost({
    required String authorId,
    required String content,
    String? skillTag,
  }) async {
    await _db.collection('posts').add({
      'authorId': authorId,
      'content': content,
      'skill': skillTag, // Optionnel : pour filtrer par compétence
      'createdAt': FieldValue.serverTimestamp(),
      'likes': [], // Liste des UIDs des gens qui aiment
    });
  }

  // 📥 Récupérer les posts d'un mentor spécifique
  Stream<QuerySnapshot> getMentorPosts(String mentorId) {
    return _db.collection('posts')
        .where('authorId', isEqualTo: mentorId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // 🗑️ Supprimer un post
  Future<void> deletePost(String postId) async {
    await _db.collection('posts').doc(postId).delete();
  }
}