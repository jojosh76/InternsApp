import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class CoursePage extends StatefulWidget {
  final String courseId;     
  final String courseTitle;  

  const CoursePage({
    super.key,
    required this.courseId,
    required this.courseTitle,
  });

  @override
  State<CoursePage> createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  String? userRole;
  bool loadingRole = true;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  // 🔐 Charger le rôle pour la sécurité
  Future<void> _loadUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => loadingRole = false);
      return;
    }
    
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (mounted) {
        setState(() {
          userRole = doc.data()?['role'] ?? 'student';
          loadingRole = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => loadingRole = false);
    }
  }

  // 🎥 Google Meet
  Future<void> _startGoogleMeet() async {
    final uri = Uri.parse("https://meet.google.com/new");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // 🔗 Ouvrir URL Drive
  Future<void> _openDocumentUrl(String urlString) async {
    if (urlString.isEmpty) return;
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // ➕ BLOC DE SAUVEGARDE DANS FIRESTORE
  void _openAddContentDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final urlCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Ajouter à ${widget.courseTitle}"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: "Nom du document")),
              TextField(controller: descCtrl, decoration: const InputDecoration(labelText: "Description")),
              TextField(controller: urlCtrl, decoration: const InputDecoration(labelText: "Lien Drive/URL")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () async {
              if (urlCtrl.text.isNotEmpty && titleCtrl.text.isNotEmpty) {
                // SAUVEGARDE ICI
                await FirebaseFirestore.instance
                    .collection('courses')
                    .doc(widget.courseId)
                    .collection('documents')
                    .add({
                  'title': titleCtrl.text.trim(),
                  'description': descCtrl.text.trim(),
                  'url': urlCtrl.text.trim(),
                  'createdAt': FieldValue.serverTimestamp(),
                });
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text("Sauvegarder"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.courseTitle),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.video_call), onPressed: _startGoogleMeet),
          if (!loadingRole && (userRole == 'mentor' || userRole == 'admin'))
            IconButton(icon: const Icon(Icons.add_link), onPressed: _openAddContentDialog),
        ],
      ),
      body: loadingRole 
        ? const Center(child: CircularProgressIndicator())
        : StreamBuilder<QuerySnapshot>(
            // RÉCUPÉRATION DES DONNÉES EN TEMPS RÉEL
            stream: FirebaseFirestore.instance
                .collection('courses')
                .doc(widget.courseId)
                .collection('documents')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              
              final docs = snapshot.data!.docs;

              if (docs.isEmpty) {
                return const Center(child: Text("Aucun document enregistré"));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  final docId = docs[index].id;

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: const Icon(Icons.link, color: Colors.blueAccent),
                      title: Text(data['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(data['description'] ?? ''),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (userRole == 'admin' || userRole == 'mentor')
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => FirebaseFirestore.instance
                                  .collection('courses')
                                  .doc(widget.courseId)
                                  .collection('documents')
                                  .doc(docId)
                                  .delete(),
                            ),
                          IconButton(
                            icon: const Icon(Icons.open_in_new, color: Colors.blue),
                            onPressed: () => _openDocumentUrl(data['url'] ?? ''),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
    );
  }
}