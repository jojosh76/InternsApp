import 'dart:html' as html;
import 'dart:js' as js;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DiscussionPage extends StatefulWidget {
  const DiscussionPage({super.key});

  @override
  State<DiscussionPage> createState() => _DiscussionPageState();
}

class _DiscussionPageState extends State<DiscussionPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final CollectionReference messagesRef =
      FirebaseFirestore.instance.collection('messages');

  bool _isRecording = false;
  dynamic _voiceListener;

  /// 🔒 Messages supprimés localement (supprimer pour moi)
  final Set<String> _hiddenMessages = {};

  @override
  void initState() {
    super.initState();

    if (kIsWeb) {
      _voiceListener = (event) async {
        final audioBase64 =
            (event as html.CustomEvent).detail as String;

        await messagesRef.add({
          'type': 'audio',
          'content': audioBase64,
          'sender': 'user',
          'createdAt': FieldValue.serverTimestamp(),
        });

        _scrollToBottom();
      };

      html.window.addEventListener('voiceMessage', _voiceListener);
    }
  }

  @override
  void dispose() {
    if (kIsWeb) {
      html.window.removeEventListener('voiceMessage', _voiceListener);
    }
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendText() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();

    await messagesRef.add({
      'type': 'text',
      'content': text,
      'sender': 'user',
      'createdAt': FieldValue.serverTimestamp(),
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// 🧹 Menu suppression (WhatsApp style)
  void _showDeleteOptions(BuildContext context, String messageId) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text("Supprimer pour moi"),
              onTap: () {
                setState(() {
                  _hiddenMessages.add(messageId);
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text("Supprimer pour tout le monde"),
              onTap: () async {
                await messagesRef.doc(messageId).delete();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      appBar: AppBar(
        title: const Text("Discussion"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessages()),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessages() {
    return StreamBuilder<QuerySnapshot>(
      stream: messagesRef
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          reverse: true,
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (_, i) {
            final doc = docs[i];
            if (_hiddenMessages.contains(doc.id)) {
              return const SizedBox();
            }

            final data = doc.data() as Map<String, dynamic>;
            final isUser = data['sender'] == 'user';

            return GestureDetector(
              onLongPress: () =>
                  _showDeleteOptions(context, doc.id),
              child: _buildMessageBubble(data, isUser),
            );
          },
        );
      },
    );
  }

  Widget _buildMessageBubble(
      Map<String, dynamic> msg, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: isUser ? Colors.blueAccent : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: msg['type'] == 'audio'
            ? IconButton(
                icon: const Icon(Icons.play_circle, size: 36),
                color: isUser ? Colors.white : Colors.black,
                onPressed: () {
                  html.AudioElement(msg['content']).play();
                },
              )
            : Text(
                msg['content'],
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.black87,
                ),
              ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withOpacity(0.08),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onLongPress: () {
              setState(() => _isRecording = true);
              js.context.callMethod("startVoice");
            },
            onLongPressUp: () {
              setState(() => _isRecording = false);
              js.context.callMethod("stopVoice");
            },
            child: CircleAvatar(
              backgroundColor:
                  _isRecording ? Colors.red : Colors.blueAccent,
              child: const Icon(Icons.mic, color: Colors.white),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Écrivez ici...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onSubmitted: (_) => _sendText(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blueAccent),
            onPressed: _sendText,
          ),
        ],
      ),
    );
  }
}
