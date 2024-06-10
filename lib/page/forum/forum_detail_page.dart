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
                  docId!,
                  opt!,
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

  // Method to delete a reply
  void deleteReply(String commentId, String replyId) {
    firestoreForumService.deleteReply(widget.forumId, commentId, replyId);
  }

  // Method to open dialog box to edit a reply
  void openReplyBox({
    required String commentId,
    required String replyId,
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
                firestoreForumService.updateReply(
                  widget.forumId,
                  commentId,
                  replyId,
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

  // Reply to a comment
  void replyToComment(String parentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reply to Comment'),
          content: TextField(
            maxLines: 3,
            controller: commentController,
            decoration: const InputDecoration(
              hintText: 'Enter your reply...',
            ),
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
                addReplyToComment(parentId);
                Navigator.pop(context);
              },
              child: const Text('Reply'),
            ),
          ],
        );
      },
    );
  }

  // Add a reply to a comment
  void addReplyToComment(String parentId) {
    if (commentController.text.trim().isNotEmpty) {
      FirebaseFirestore.instance
          .collection('forum')
          .doc(widget.forumId)
          .collection('comments')
          .doc(parentId)
          .collection('replies')
          .add({
        'text': commentController.text.trim(),
        'user': user.email,
        'timestamp': FieldValue.serverTimestamp(),
      });
      commentController.clear();
    }
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
                  // Post content
                  Text(
                    forumData['title'],
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (forumData['image'] != null &&
                      forumData['image'].isNotEmpty)
                    Center(
                      child: Image.network(
                        forumData['image'],
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Post content
                  Text(
                    forumData['text'],
                    style: const TextStyle(
                      fontSize: 18,
                    ),
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

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                contentPadding: const EdgeInsets.all(0),
                                title: Text(comment['text'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                subtitle: Row(
                                  children: [
                                    Text(
                                      commentUserEmail,
                                    ),
                                    if (user.email == commentUserEmail)
                                      Row(
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
                                      ),
                                  ],
                                ),
                                // Add reply button
                                onTap: () {
                                  replyToComment(commentId);
                                },
                              ),
                              // Display replies
                              StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('forum')
                                    .doc(widget.forumId)
                                    .collection('comments')
                                    .doc(
                                        commentId) // Get replies for this comment
                                    .collection('replies')
                                    .orderBy('timestamp', descending: true)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const SizedBox();
                                  }

                                  var replies = snapshot.data!.docs;

                                  return ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: replies.length,
                                    itemBuilder: (context, index) {
                                      var reply = replies[index].data()
                                          as Map<String, dynamic>;
                                      var replyId = replies[index].id;
                                      var replyUserEmail = reply['user'];

                                      return ListTile(
                                        contentPadding:
                                            const EdgeInsets.only(left: 16),
                                        title: Text(
                                          reply['text'],
                                        ),
                                        subtitle: Row(
                                          children: [
                                            Text(replyUserEmail),
                                            if (user.email == replyUserEmail)
                                              Row(
                                                children: [
                                                  IconButton(
                                                    icon:
                                                        const Icon(Icons.edit),
                                                    onPressed: () =>
                                                        openReplyBox(
                                                      commentId: commentId,
                                                      replyId: replyId,
                                                      opt: 'text',
                                                      initialValue:
                                                          reply['text'],
                                                    ),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                        Icons.delete),
                                                    onPressed: () =>
                                                        deleteReply(
                                                            commentId, replyId),
                                                  ),
                                                ],
                                              ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
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
