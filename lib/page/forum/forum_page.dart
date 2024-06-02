import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:tamiyochi/db/movies_database.dart';
import 'package:tamiyochi/model/movie.dart';
import 'package:tamiyochi/page/forum/forum_detail_page.dart';
import 'package:tamiyochi/page/forum/forum_edit_page.dart';
import 'package:tamiyochi/page/movie_detail_page.dart';
import 'package:tamiyochi/widget/movie_card_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text(
            "Forums",
            style: TextStyle(fontSize: 24, color: Colors.black),
          ),
          actions: const [Icon(Icons.search), SizedBox(width: 12)],
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('forum').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final List books = snapshot.data!.docs;
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: books.length,
                itemBuilder: (context, index) {
                  // Get each individual document
                  final DocumentSnapshot document = books[index];
                  String docId = document.id;

                  // Get note from each document
                  Map<String, dynamic> data =
                      document.data() as Map<String, dynamic>;
                  String title = data['title'];
                  String image = data['image'];

                  // Display as ListTile
                  return GestureDetector(
                    onTap: () async {
                      await Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ForumDetailPage(
                            forumId: docId, title: title, image: image),
                      ));
                    },
                    child: SingleChildScrollView(
                      child: Card(
                        color: Colors.lightGreen.shade300,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(),
                                ],
                              ),
                              Center(
                                child: Column(
                                  children: [
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                            minWidth: 0,
                                            maxWidth: MediaQuery.of(context)
                                                .size
                                                .width),
                                        child: Text(
                                          title,
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.visible,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Image.network(
                                      image,
                                      fit: BoxFit.cover,
                                      height: 150,
                                      width: double.infinity,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),
              );
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.white38,
          child: const Icon(Icons.add),
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AddEditForumPage()),
            );

            refreshNotes();
          },
        ),
      );
  Widget buildNotes() => StaggeredGrid.count(
      crossAxisCount: 2,
      mainAxisSpacing: 2,
      crossAxisSpacing: 2,
      children: List.generate(
        notes.length,
        (index) {
          final note = notes[index];

          return StaggeredGridTile.fit(
            crossAxisCellCount: 1,
            child: GestureDetector(
              onTap: () async {
                await Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => NoteDetailPage(noteId: note.id!),
                ));

                refreshNotes();
              },
              child: NoteCardWidget(note: note, index: index),
            ),
          );
        },
      ));
}
