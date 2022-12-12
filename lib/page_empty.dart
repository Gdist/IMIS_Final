import 'package:flutter/material.dart';

class EmptyPage extends StatelessWidget {
  const EmptyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Empty'),
      ),
      body: Center(
          child: Text(
        'Hello',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 50,
        ),
      )),
    );
  }
}
