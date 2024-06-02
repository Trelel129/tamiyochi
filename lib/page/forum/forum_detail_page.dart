import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tamiyochi/services/forum/firestore_forum.dart';

class ForumDetailPage extends StatefulWidget {
  final String forumId;
  final String title;
  final String image;
  const ForumDetailPage({
    super.key,
    required this.forumId,
    required this.title,
    required this.image,
  });

  @override
  State<ForumDetailPage> createState() => _ForumDetailPageState();
}

class _ForumDetailPageState extends State<ForumDetailPage> {
  final FirestoreForumService firestoreForumService = FirestoreForumService();
  final TextEditingController controller = TextEditingController();
  bool isdocIdNull = true;

  //open dialog box to edit
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  forumData['image'],
                  fit: BoxFit.cover,
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () =>
                      openForumBox(docId: widget.forumId, opt: 'image'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      forumData['title'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () =>
                          openForumBox(docId: widget.forumId, opt: 'title'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  forumData['text'],
                  style: const TextStyle(fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () =>
                      openForumBox(docId: widget.forumId, opt: 'text'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}
