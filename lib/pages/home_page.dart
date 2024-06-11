import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/firestore.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();

}
class _HomePageState extends State<HomePage> {
  final FirestoreService firestoreService = FirestoreService();
  final TextEditingController controller = TextEditingController();

  // sign user out method
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }
  void openNoteBox({
    String? UId,
    int? line,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Image'),
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
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Text(
          "Logged in as",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey[900],
        actions: [
          IconButton(
            onPressed: signUserOut,
            icon: Icon(Icons.logout),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Something went wrong!');
            } else if (!snapshot.hasData) {
              return Text('User not logged in!');
            } else {
              final user = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.fromLTRB(30.0, 40.0, 30.0, 0.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: CircleAvatar(
                        backgroundImage: AssetImage('lib/assets/images/Seaborn.png'),
                        radius: 80.0,
                        child: (user.photoURL!="")?
                        Image.network('https://arknights.wiki.gg/images/1/11/Skadi%27s_Seaborn.png'):
                        Image.network(user.photoURL!),
                      ),
                    ),
                    Divider(
                        height: 90.0,
                        color: Colors.grey[800]
                    ),
                    Icon(
                      Icons.email,
                      color: Colors.grey,
                    ),
                    Text(
                      user.email!,
                      style: TextStyle(
                        color: Colors.black,
                        letterSpacing: 2.0,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
