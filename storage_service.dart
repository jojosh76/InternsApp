import 'dart:convert';
import 'dart:typed_data';
import 'dart:html' as html;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final _storage = FirebaseStorage.instance;
  final _auth = FirebaseAuth.instance;

  Future<String> uploadAudioBase64(String base64Audio) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Utilisateur non connecté");

    final pureBase64 = base64Audio.split(',').last;
    final bytes = base64Decode(pureBase64);

    final blob = html.Blob(
      [Uint8List.fromList(bytes)],
      'audio/webm',
    );

    final ref = _storage.ref(
      'voice_messages/${user.uid}/${DateTime.now().millisecondsSinceEpoch}.webm',
    );

    final snapshot = await ref.putBlob(blob);
    return await snapshot.ref.getDownloadURL();
  }
}
