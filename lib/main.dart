import 'package:flutter/material.dart';
import 'page_home.dart';
import 'page_match.dart';
import 'page_empty.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/empty': (context) => EmptyPage(),
        '/match': (context) => MatchPage(),
      },
    );
  }
}
