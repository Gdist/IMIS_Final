import 'package:flutter/material.dart';
import 'page_home.dart';
import 'page_login.dart';
import 'pages/about.dart';
import 'page_empty.dart';

import '../pages/page_match.dart';
import 'pages/findme.dart';
import '../pages/page_forward.dart';
import '../pages/page_backward.dart';
import 'pages/bill.dart';
import 'pages/link.dart';

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
        '/login': (context) => LoginPage(),
        '/about': (context) => AboutPage(),
        '/match': (context) => MatchPage(),
        '/findme': (context) => FindMePage(),
        '/forward': (context) => ForwardPage(),
        '/backward': (context) => BackwardPage(),

        '/bill': (context) => BillPage(),
        '/link': (context) => LinkPage(),
      },
    );
  }
}
