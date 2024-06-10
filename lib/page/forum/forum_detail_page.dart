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
  final TextEditingController commentController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser!;

  // Open dialog box to edit forum
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

  // Add a new comment
  void addComment() {
    if (commentController.text.trim().isNotEmpty) {
      FirebaseFirestore.instance
          .collection('forum')
          .doc(widget.forumId)
          .collection('comments')
          .add({
        'text': commentController.text.trim(),
        'user': user.email,
        'timestamp': FieldValue.serverTimestamp(),
      });
      commentController.clear();
    }
  }

  // Open dialog box to edit comment
  void openCommentBox({
    required String commentId,
    required String opt,
    required String initialValue,
  }) {
    controller.text = initialValue;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit $opt'),
          content: TextField(
            maxLines: 3,
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
                firestoreForumService.updateComment(
                  widget.forumId,
                  commentId,
                  opt,
                  controller.text,
                );
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

  // Delete comment
  void deleteComment(String commentId) {
    firestoreForumService.deleteComment(widget.forumId, commentId);
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

                  // Comment input
                  TextField(
                    controller: commentController,
                    decoration: InputDecoration(
                      labelText: 'Add a comment',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: addComment,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Display comments
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('forum')
                        .doc(widget.forumId)
                        .collection('comments')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      var comments = snapshot.data!.docs;

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          var comment =
                              comments[index].data() as Map<String, dynamic>;
                          var commentId = comments[index].id;
                          var commentUserEmail = comment['user'];

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.grey.shade800,
                              child: Text(commentUserEmail[0].toUpperCase()),
                            ),
                            title: Text(comment['text']),
                            subtitle: Text(commentUserEmail),
                            trailing: user.email == commentUserEmail
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () => openCommentBox(
                                          commentId: commentId,
                                          opt: 'text',
                                          initialValue: comment['text'],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () =>
                                            deleteComment(commentId),
                                      ),
                                    ],
                                  )
                                : null,
                          );
                        },
                      );
                    },
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
