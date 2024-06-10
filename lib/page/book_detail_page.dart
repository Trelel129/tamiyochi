import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookDetailPage extends StatelessWidget {
  final String bookId;
  final Timestamp returnDate;

  BookDetailPage({required this.bookId, required this.returnDate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Detail'),
      ),


      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('books')
            .doc(bookId)
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
                SizedBox(height: 8),
                Text(
                  'Return Date: ${returnDate.toDate().toString().split(' ')[0].split('-').reversed.join('/')}',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection('books_user')
                        .where('book_id', isEqualTo: bookId)
                        .get()
                        .then((querySnapshot) {
                      querySnapshot.docs.forEach((doc) {
                        doc.reference.delete();
                      });
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text('Batalkan Peminjaman'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                  int? daysToAdd = await showDialog<int>(
                    context: context,
                    builder: (BuildContext context) {
                    int selectedDays = 0;
                    return AlertDialog(
                      title: Text('Tambahkan Jumlah Hari'),
                      content: TextField(
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        selectedDays = int.tryParse(value) ?? 0;
                      },
                      ),
                      actions: [
                      TextButton(
                        onPressed: () {
                        Navigator.of(context).pop(selectedDays);
                        },
                        child: Text('OK'),
                      ),
                      ],
                    );
                    },
                  );

                  if (daysToAdd != null && daysToAdd > 0) {
                    DateTime newReturnDate = returnDate.toDate().add(Duration(days: daysToAdd));
                    await FirebaseFirestore.instance
                      .collection('books_user')
                      .where('book_id', isEqualTo: bookId)
                      .get()
                      .then((querySnapshot) {
                    querySnapshot.docs.forEach((doc) {
                      doc.reference.update({'return_date': newReturnDate});
                    });
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Perpanjangan waktu berhasil'),
                    ),
                    );
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Jumlah hari harus lebih dari 0 atau berupa angka'),
                    ),
                    );
                  }
                  },
                  child: Text('Perpanjangan'),
                  style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}