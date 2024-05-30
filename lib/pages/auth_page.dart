import 'dart:ffi';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tamiyochi/NotesMain.dart';
import 'package:tamiyochi/page/forum_page.dart';
import 'package:tamiyochi/pages/login_page.dart';
import 'package:tamiyochi/user_book.dart';
import 'home_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  int _selectedIndex = 0;

  static List<Widget> _pages = <Widget>[
    NotesMainApp(),
    UserBook(),
    ForumPage(),
    HomePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // user is logged in
          if (snapshot.hasData) {
            return Scaffold(
              body: Center(
                child: _pages.elementAt(_selectedIndex),
              ),
              bottomNavigationBar: BottomNavigationBar(
                items: <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.book,),
                    label: 'All Comics',
                    backgroundColor: _selectedIndex == 0 ? Colors.purple : Colors.grey,
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.library_books),
                    label: 'My Comics',
                    backgroundColor: _selectedIndex == 1 ? Colors.purple : Colors.grey[700],
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.chat_bubble),
                    label: 'Forums',
                    backgroundColor: _selectedIndex == 2 ? Colors.purple : Colors.grey,
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: 'Profile',
                    backgroundColor: _selectedIndex == 3 ? Colors.purple : Colors.grey,
                  ),

                ],
                currentIndex: _selectedIndex,
                selectedItemColor: Colors.amber[800],
                onTap: _onItemTapped,
              ),
            );
          }

          // user is NOT logged in
          else {
            return LoginPage();
          }
        },
      ),
    );
  }
}