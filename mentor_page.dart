import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import ajouté pour currentUser
import 'profile_mentor_page.dart';

class MentorPage extends StatelessWidget {
  const MentorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nos Mentors"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'mentor')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Aucun mentor trouvé"));
          }

          final mentors = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: mentors.length,
            itemBuilder: (context, index) {
              final doc = mentors[index]; 
              final data = doc.data() as Map<String, dynamic>;

              // 🔑 Injection UID mentor (ID du document)
              data['uid'] = doc.id;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileMentorPage(mentorData: data),
                    ),
                  );
                },
                child: Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.blue.shade50,
                            child: const Icon(
                              Icons.person,
                              size: 35,
                              color: Colors.blueAccent,
                            ),
                          ),
                          title: Text(
                            data['name'] ?? 'Mentor',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Text(data['email'] ?? ''),
                          trailing: const Icon(
                            Icons.verified,
                            color: Colors.green,
                          ),
                        ),
                        const Divider(),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // 🚀 Appel de la nouvelle fonction avec mentorName et mentorId
                              _showChoiceDialog(
                                context,
                                data['name'] ?? 'Mentor',
                                doc.id, 
                              );
                            },
                            icon: const Icon(
                              Icons.check_circle_outline,
                              color: Colors.white,
                            ),
                            label: const Text(
                              "Choose Mentor",
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // --- NOUVELLE FONCTION DE DIALOGUE ET ENREGISTREMENT ---
  void _showChoiceDialog(BuildContext context, String mentorName, String mentorId) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      try {
        await FirebaseFirestore.instance.collection('mentorships').add({
          'studentId': currentUser.uid,
          'mentorId': mentorId,
          'mentorName': mentorName,
          'studentName': currentUser.displayName ?? "Un élève",
          'createdAt': FieldValue.serverTimestamp(),
          'status': 'pending', // Pour une future validation par le mentor
        });

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Demande envoyée à $mentorName !")),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erreur lors de l'envoi : $e")),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vous devez être connecté pour choisir un mentor.")),
      );
    }
  }
}