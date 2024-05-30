import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tamiyochi/model/movie.dart';

import '../services/firestore.dart';

class BookRentPage extends StatefulWidget {
  final String bookId;
  BookRentPage({
    super.key,
    required this.bookId,
  });

  @override
  State<BookRentPage> createState() => _BookRentPageState();
}

class _BookRentPageState extends State<BookRentPage> {
  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController controller = TextEditingController();
  bool isdocIdNull = true;

  //open dialog box to edit
  void openNoteBox({String? docId}){
    if (docId != null) {
      isdocIdNull = false;
    } else {
      isdocIdNull = true;
    }
    showDialog(
      context: context,
      builder: (BuildContext context){

        return AlertDialog(
          title: isdocIdNull ? const Text('Add Note') : const Text('Edit Note'),
          content: TextField(
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
                // add new note to Firestore
                if (docId == null) {
                  firestoreService.addNote(controller.text as Movie);
                }
                // update note in Firestores
                else {
                  firestoreService.updateBook(docId, part, controller.text);
                }
                // Clear the text controller
                controller.clear();
                Navigator.pop(context);
              },
              child: isdocIdNull ? const Text('Add') : const Text('Update'),
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
                SizedBox(height: 16),
                Text(
                  bookData['name'],
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  bookData['description'],
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 16),
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => openNoteBox(docId: widget.bookId),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}