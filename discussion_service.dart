import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DiscussionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;
  String get _name =>
      _auth.currentUser!.displayName ??
      _auth.currentUser!.email ??
      "Utilisateur";

  Stream<QuerySnapshot> getMessages(String discussionId) {
    return _db
        .collection('discussions')
        .doc(discussionId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots();
  }

  Future<void> sendTextMessage({
    required String discussionId,
    required String text,
  }) async {
    await _db
        .collection('discussions')
        .doc(discussionId)
        .collection('messages')
        .add({
      'senderId': _uid,
      'senderName': _name,
      'type': 'text',
      'content': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> sendAudioMessage({
    required String discussionId,
    required String audioUrl,
  }) async {
    await _db
        .collection('discussions')
        .doc(discussionId)
        .collection('messages')
        .add({
      'senderId': _uid,
      'senderName': _name,
      'type': 'audio',
      'content': audioUrl,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
