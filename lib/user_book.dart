import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:tamiyochi/page/book_detail_page.dart';

class UserBook extends StatefulWidget {
  const UserBook({Key? key}) : super(key: key);

  @override
  State<UserBook> createState() => _UserBookState();
}

class _UserBookState extends State<UserBook> {
  @override
  Widget build(BuildContext context) {
    // Get the current user's UID
    final currentUserUID = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Book",
          style: TextStyle(fontSize: 24),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('books_user')
            .where('user_id', isEqualTo: currentUserUID) // Filter by current user's UID
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final booksUser = snapshot.data!.docs;
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: booksUser.length,
              itemBuilder: (context, index) {
                final bookId = booksUser[index].get('book_id');

                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('books')
                      .doc(bookId)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final bookData =
                          snapshot.data!.data() as Map<String, dynamic>;
                      final bookName = bookData['name'];
                      final bookImage = bookData['image'];

                      return StaggeredGridTile.fit(
                        crossAxisCellCount: 1,
                        child: GestureDetector(
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    BookDetailPage(bookId: bookId),
                              ),
                            );
                          },
                          child: SingleChildScrollView(
                            child: Card(
                              color: Colors.lightGreen.shade300,
                              child: Container(
                                constraints:
                                    const BoxConstraints(minHeight: 200),
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      bookName,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Image.network(bookImage),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      );
                    }
                  },
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
            );
          }
        },
      ),
    );
  }
}
