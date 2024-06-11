import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tamiyochi/page/all_comics.dart';

void notesMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const NotesMainApp());
}

class NotesMainApp extends StatelessWidget {
  static String title = 'Notes SQLite';

  const NotesMainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: title,
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.blueGrey.shade900,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      home: const MoviePage(),
    );
  }
}
