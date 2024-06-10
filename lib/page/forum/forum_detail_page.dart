import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tamiyochi/services/forum/firestore_forum.dart';

class ForumDetailPage extends StatefulWidget {
  final String forumId;
  final String title;
  final String image;
  final String email;
  const ForumDetailPage({
    super.key,
    required this.forumId,
    required this.title,
    required this.image,
    required this.email,
  });

  @override
  State<ForumDetailPage> createState() => _ForumDetailPageState();
}

class _ForumDetailPageState extends State<ForumDetailPage> {
  final FirestoreForumService firestoreForumService = FirestoreForumService();
  final TextEditingController controller = TextEditingController();
  final user = FirebaseAuth.instance.currentUser!;

  // Open dialog box to edit
  void openForumBox({
    String? docId,
    String? opt,
    int? line,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit $opt'),
          content: TextField(
            maxLines: line,
            controller: controller,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                firestoreForumService.updateForumPerPart(
                    docId!, opt!, controller.text);
                // Clear the text controller
                controller.clear();
                Navigator.pop(context);
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Forum Detail'),
        actions: <Widget>[
          if (user.email == widget.email)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                firestoreForumService.deleteForum(widget.forumId);
                Navigator.pop(context);
              },
            )
          else
            const SizedBox(), // Empty widget if the user is not the owner
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('forum')
            .doc(widget.forumId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          var forumData = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Post header
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.grey.shade800,
                        child: Text(widget.email[0].toUpperCase()),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.email,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Post title
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          forumData['title'],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (user.email == widget.email)
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () =>
                              openForumBox(docId: widget.forumId, opt: 'title'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Post image
                  if (forumData['image'] != null &&
                      forumData['image'].isNotEmpty)
                    Center(
                      child: Image.network(
                        forumData['image'],
                        fit: BoxFit.contain,
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Post content
                  Text(
                    forumData['text'],
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  if (user.email == widget.email)
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () =>
                          openForumBox(docId: widget.forumId, opt: 'text'),
                    ),
                  const SizedBox(height: 16),

                  // Post actions
                  Row(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.comment, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text('123'), // Replace with actual comment count
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
