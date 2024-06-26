import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/firestore.dart';
import '../user_book.dart';

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
  final user = FirebaseAuth.instance.currentUser!;
  final TextEditingController controller = TextEditingController();

  final CollectionReference rentals = FirebaseFirestore.instance.collection('books_user');

  Future<void> addRental(String bookId, String userId) async {
    DateTime? returnDate = await showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Return Date'),
          content: DatePickerDialog(
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime(2100),
          ),
        );
      },
    );

    if (returnDate != null) {
      await rentals.add({
        'book_id': bookId,
        'user_id': userId,
        'return_date': returnDate,
      });

      Navigator.pop(context);
    }
  }
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
        actions: <Widget>[
          IconButton(
            icon: Icon((user.email=="admin@admin.adm")?Icons.delete:null),
            onPressed: () {
              firestoreService.deleteBook(widget.bookId);
              Navigator.of(context).pop();
            },
          ),
        ],
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
                  icon: Icon((user.email=="admin@admin.adm")?Icons.edit:null),
                  onPressed: () =>
                      openNoteBox(docId: widget.bookId, opt: 'image'),
                ),
                SizedBox(height: 16),
                Text(
                  bookData['name'],
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon((user.email=="admin@admin.adm")?Icons.edit:null),
                  onPressed: () =>
                      openNoteBox(docId: widget.bookId, opt: 'name'),
                ),
                SizedBox(height: 8),
                Text(
                  bookData['description'],
                  style: TextStyle(fontSize: 16),
                ),
                IconButton(
                  icon: Icon((user.email=="admin@admin.adm")?Icons.edit:null),
                  onPressed: () =>
                      openNoteBox(docId: widget.bookId, opt: 'description'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                    onPressed: () async {
                      String bookId = widget.bookId;
                      String userId = FirebaseAuth.instance.currentUser!.uid;
                      
                      // Check if rental already exists
                      QuerySnapshot rentalSnapshot = await rentals
                          .where('book_id', isEqualTo: bookId)
                          .where('user_id', isEqualTo: userId)
                          .get();

                      if (rentalSnapshot.docs.isNotEmpty) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Error'),
                              content: RichText(
                                text: TextSpan(
                                  text: 'Anda sudah melakukan peminjaman, jika ingin memperpanjang bisa pada halaman ',
                                  style: DefaultTextStyle.of(context).style,
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: 'My Book',
                                      style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                                      recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        // Navigate to the My Book page
                                        // Navigate to the UserBookPage
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => UserBook()),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      } else {
                        addRental(bookId, userId);
                      }
                    },
                  child: Text('Rental'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
