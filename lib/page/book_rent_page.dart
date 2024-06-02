import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/firestore.dart';

class BookRentPage extends StatefulWidget {
  final String bookId;
  final int line;
  const BookRentPage({
    super.key,
    required this.bookId,
    required this.line,
  });

  @override
  State<BookRentPage> createState() => _BookRentPageState();
}

class _BookRentPageState extends State<BookRentPage> {
  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController controller = TextEditingController();
  bool isdocIdNull = true;

  //open dialog box to edit
  void openNoteBox({
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
                firestoreService.updateBook(docId!, opt!, controller.text);
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
        title: Text('Book Detail'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('books')
            .doc(widget.bookId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          var bookData = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  bookData['image'],
                  fit: BoxFit.cover,
                ),
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () =>
                      openNoteBox(docId: widget.bookId, opt: 'image'),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      bookData['name'],
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () =>
                          openNoteBox(docId: widget.bookId, opt: 'name'),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  bookData['description'],
                  style: TextStyle(fontSize: 16),
                ),
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () =>
                      openNoteBox(docId: widget.bookId, opt: 'description'),
                ),
                SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}
