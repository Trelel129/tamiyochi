import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:tamiyochi/db/movies_database.dart';
import 'package:tamiyochi/model/movie.dart';
import 'package:tamiyochi/page/movie_edit_page.dart';
import 'package:tamiyochi/page/movie_detail_page.dart';
import 'package:tamiyochi/widget/movie_card_widget.dart';

import '../services/firestore.dart';
import 'book_rent_page.dart';

class MoviePage extends StatefulWidget {
  const MoviePage({super.key});

  @override
  State<MoviePage> createState() => _MoviePageState();
}

class _MoviePageState extends State<MoviePage> {
  late List<Movie> notes;
  bool isLoading = false;
  final user = FirebaseAuth.instance.currentUser!;
  final FirestoreService firestoreService = FirestoreService();

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
      backgroundColor: Colors.green[800],
      title: Text(
        "All Comics",
        style: TextStyle(fontSize: 24, color: Colors.white),
      ),
      actions: const [Icon(Icons.search, color: Colors.greenAccent), SizedBox(width: 12)],
    ),
    backgroundColor: Colors.white,
    body: StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('books').snapshots(),
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
              Map<String, dynamic> data = document.data() as Map<String, dynamic>;
              String bookName = data['name'];
              String bookImage = data['image'];

              // Display as ListTile
              return GestureDetector(
                onTap: () async {
                  await Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => BookRentPage(
                      bookId: docId,
                      line: 2,
                    ),
                  ));
                },
                child: SingleChildScrollView(
                  child: Card(
                    color: Colors.grey[400],
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(), // This empty container is used to push the delete icon to the right
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => firestoreService.deleteNote(docId),
                              ),
                            ],
                          ),
                          Center(
                            child: Column(
                              children: [
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(minWidth: 0, maxWidth: MediaQuery.of(context).size.width),
                                    child: Text(
                                      bookName,
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
                                  bookImage,
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
      backgroundColor: Colors.green[900],
      child: const Icon(Icons.add, color: Colors.white),
      onPressed: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const AddEditNotePage()),
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

        return GestureDetector(
          onTap: () async {
            await Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => NoteDetailPage(noteId: note.id!),
            ));

            refreshNotes();
          },
          child: NoteCardWidget(note: note, index: index),
        );
      },
    ),
  );
}
