import 'package:flutter/material.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  var _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Text(
              "關於我們",
              style: TextStyle(
                fontSize: 40.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          Text(
            "智慧型醫學資訊系統實作@NCKU\n\nG15：改善失智的認知學習App\nMentor：盧文祥 教授\n\n組員：\nF74116233 陳軒宇\nF74091205李育丞",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20.0,
              color: Colors.black,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: '遊戲清單',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: '帳戶',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: '關於',
          ),
        ],
        currentIndex: 2,
        selectedItemColor: Colors.amber[800],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          if (_selectedIndex == 1)
            Navigator.of(context)
                .pushNamedAndRemoveUntil("/login", (Route route) => false);
          else if (_selectedIndex == 2)
            Navigator.of(context)
                .pushNamedAndRemoveUntil("/about", (Route route) => false);
          else
            Navigator.of(context)
                .pushNamedAndRemoveUntil("/", (Route route) => false);
        },
      ),
    );
  }
}
