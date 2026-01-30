import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'settings_page.dart';
import 'discussion_page.dart';
import 'ai_page.dart';
import 'mentor_page.dart';
import 'course_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),

      /* ======================
         ☰ MENU LATÉRAL
         ====================== */
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blueAccent),
              child: Center(
                child: Text(
                  "Menu Apprentissage",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            _drawerItem(context, Icons.chat, "Discussion", const DiscussionPage()),
            _drawerItem(context, Icons.smart_toy, "AI Assistant", const AIPage()),
            _drawerItem(context, Icons.people, "Trouver un Mentor", const MentorPage()),
            _drawerItem(context, Icons.settings, "Paramètres", const SettingsPage()),
          ],
        ),
      ),

      /* ======================
         📚 LISTE DES COURS
         ====================== */
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('courses')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "Aucun cours disponible pour le moment.",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 18,
              crossAxisSpacing: 18,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (_, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final String title = data['title'] ?? 'Sans titre';
              final String description =
                  data['description'] ?? 'Pas de description';

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    /// ✅ NAVIGATION CORRIGÉE
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CoursePage(
                          courseId: 'web_design',
                          courseTitle: 'Web Design',
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.menu_book_rounded,
                          size: 42,
                          color: Colors.blueAccent,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
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

  /* ======================
     🔹 ITEM DU DRAWER
     ====================== */
  Widget _drawerItem(
    BuildContext context,
    IconData icon,
    String title,
    Widget page,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
    );
  }
}
