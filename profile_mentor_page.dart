import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/post_service.dart';

class ProfileMentorPage extends StatelessWidget {
  final Map<String, dynamic> mentorData;
  final PostService _postService = PostService();

  ProfileMentorPage({super.key, required this.mentorData});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final bool isMyProfile = currentUser?.uid == mentorData['uid'];

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: Text(mentorData['name'] ?? "Profile"),
        backgroundColor: Colors.blueAccent,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context)),
          
          if (isMyProfile)
            SliverToBoxAdapter(child: _buildCreatePostArea(context))
          else
            const SliverToBoxAdapter(child: SizedBox(height: 10)),

          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                "Publications & Compétences", 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
              ),
            ),
          ),

          StreamBuilder<QuerySnapshot>(
            stream: _postService.getMentorPosts(mentorData['uid'] ?? ''), 
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(child: LinearProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Text("Aucune publication pour le moment."),
                    ),
                  ),
                );
              }
              
              final postsDocs = snapshot.data!.docs;
              
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final doc = postsDocs[index];
                    final postData = doc.data() as Map<String, dynamic>;
                    // On passe l'ID du document et le flag isMyProfile
                    return _buildPostCard(context, postData, doc.id, isMyProfile);
                  },
                  childCount: postsDocs.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- COMPOSANTS WIDGETS ---

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 15), 
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Container(height: 120, color: Colors.blue.shade100),
              Positioned(
                top: 60,
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 50, 
                    backgroundColor: Colors.blue.shade800, 
                    child: const Icon(Icons.person, size: 50, color: Colors.white)
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 50),
          Text(mentorData['name'] ?? '', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(mentorData['email'] ?? '', style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildCreatePostArea(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          const CircleAvatar(radius: 20, child: Icon(Icons.person)),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () => _showPostDialog(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(20)
                ),
                child: const Text("Partagez une compétence ou un projet..."),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // MODIFIÉ : Ajout du bouton de suppression si isMyProfile est vrai
  Widget _buildPostCard(BuildContext context, Map<String, dynamic> post, String postId, bool canDelete) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const CircleAvatar(radius: 18, child: Icon(Icons.person, size: 20)),
                  const SizedBox(width: 10),
                  Text(mentorData['name'] ?? 'Mentor', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              // Bouton supprimer visible uniquement pour le propriétaire
              if (canDelete)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                  onPressed: () => _confirmDeletion(context, postId),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(post['content'] ?? ''),
          if (post['skill'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Chip(
                label: Text(post['skill']), 
                backgroundColor: Colors.blue.shade50,
                side: BorderSide.none,
              ),
            ),
        ],
      ),
    );
  }

  // Affiche une boîte de dialogue pour confirmer la suppression
  void _confirmDeletion(BuildContext context, String postId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Supprimer la publication"),
        content: const Text("Voulez-vous vraiment supprimer ce post ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () async {
              await _postService.deletePost(postId);
              if (context.mounted) Navigator.pop(context);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Publication supprimée")),
                );
              }
            },
            child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showPostDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Créer un post"),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(hintText: "Décrivez votre compétence..."),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await _postService.createPost(
                  authorId: mentorData['uid'],
                  content: controller.text.trim(),
                  skillTag: "Mentor", 
                );
                if (context.mounted) Navigator.pop(context);
              }
            }, 
            child: const Text("Publier")
          )
        ],
      ),
    );
  }
}