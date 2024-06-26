import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tamiyochi/db/movies_database.dart';
import 'package:tamiyochi/model/movie.dart';
import 'package:tamiyochi/page/forum/forum_detail_page.dart';
import 'package:tamiyochi/page/forum/forum_edit_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tamiyochi/services/forum/custom_search.dart';

class ForumPage extends StatefulWidget {
  const ForumPage({super.key});

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  late List<Movie> notes;
  bool isLoading = false;
  final user = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    super.initState();
    refreshNotes();
  }

  @override
  void dispose() {
    MovieDatabase.instance.close();
    super.dispose();
  }

  Future refreshNotes() async {
    setState(() => isLoading = true);
    notes = await MovieDatabase.instance.readAllMovie();
    setState(() => isLoading = false);
  }

  Future<int> fetchCommentCount(String docId) async {
    QuerySnapshot commentSnapshot = await FirebaseFirestore.instance
        .collection('forum')
        .doc(docId)
        .collection('comments')
        .get();

    int commentCount = commentSnapshot.docs.length;

    for (var commentDoc in commentSnapshot.docs) {
      QuerySnapshot replySnapshot = await FirebaseFirestore.instance
          .collection('forum')
          .doc(docId)
          .collection('comments')
          .doc(commentDoc.id)
          .collection('replies')
          .get();
      commentCount += replySnapshot.docs.length;
    }

    return commentCount;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text(
            "Forums",
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
          backgroundColor: Colors.green[800],
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () async {
                final snapshot =
                    await FirebaseFirestore.instance.collection('forum').get();

                final forumData = snapshot.docs
                    .map((doc) => doc.data()['title'].toString())
                    .toList();

                showSearch(
                  context: context,
                  delegate: CustomSearchDelegate(context, forumData),
                );
              },
            ),
            SizedBox(width: 12),
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('forum').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final List<DocumentSnapshot> forums = snapshot.data!.docs;
              return ListView.builder(
                itemCount: forums.length,
                itemBuilder: (context, index) {
                  final DocumentSnapshot document = forums[index];
                  String docId = document.id;
                  Map<String, dynamic> data =
                      document.data() as Map<String, dynamic>;

                  String title = data['title'] ?? 'No Title';
                  String image = data['image'] ?? '';
                  String userEmail = data['email'] ?? 'Unknown User';

                  return GestureDetector(
                    onTap: () async {
                      await Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ForumDetailPage(
                          forumId: docId,
                          title: title,
                          image: image,
                          email: userEmail,
                        ),
                      ));
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.grey.shade800,
                                  child: Text(userEmail[0].toUpperCase()),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  userEmail,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            image.isNotEmpty
                                ? Image.network(image, height: 500, width: 500)
                                : Container(),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.comment, color: Colors.grey),
                                    SizedBox(width: 4),
                                    FutureBuilder<int>(
                                      future: fetchCommentCount(docId),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Text('Loading...');
                                        } else {
                                          if (snapshot.hasData) {
                                            return Text(
                                                '${snapshot.data} Comment(s)');
                                          } else {
                                            return Text('Error');
                                          }
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              );
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.green[900],
          child: const Icon(Icons.add, color: Colors.white),
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AddEditForumPage()),
            );
            refreshNotes();
          },
        ),
      );
}
