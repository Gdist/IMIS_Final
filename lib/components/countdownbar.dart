import 'package:flutter/material.dart';
import 'dart:async';

Widget CountdownBarWidget(int cursec, int total) {
  return Container(
      margin: EdgeInsets.all(12),
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 26.0),
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 10,
              child: LinearProgressIndicator(
                value: cursec / total, // percent filled
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                backgroundColor: Color(0xFFFFDAB8),
              ),
            ),
          ),
          Text('$cursec/$total', style: TextStyle(
            fontSize: 22,
          ),),
        ],
      )
  );
}

class CountdownBar extends StatefulWidget {
  const CountdownBar({Key? key}) : super(key: key);

  @override
  State<CountdownBar> createState() => _CountdownBarState();
}

class _CountdownBarState extends State<CountdownBar> {
  Timer? countdownTimer;
  int countdownSecond = 0;
  int countdownValue = 30;
  Duration myDuration = Duration(seconds: 10);

  @override
  void initState() {
    super.initState();
    start();
  }

  void start() {
    countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        countdownSecond = timer.tick;
        countdownValue  = 30 - countdownSecond;
      });
      if (countdownSecond + 1 > 30) {
        stopTimer();
      }
      print('Hello world, timer: $countdownSecond, $countdownValue');
    });
  }

  void startTimer() {
    countdownTimer =
        Timer.periodic(Duration(seconds: 1), (_) => setCountDown());
  }

  void stopTimer() {
    setState(() => countdownTimer!.cancel());
  }

  void resetTimer() {
    stopTimer();
    setState(() => myDuration = Duration(seconds: 1));
  }

  void setCountDown() {
    final reduceSecondsBy = 1;
    setState(() {
      final seconds = myDuration.inSeconds - reduceSecondsBy;
      if (seconds < 0) {
        countdownTimer!.cancel();
      } else {
        myDuration = Duration(seconds: seconds);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 10,
            child: LinearProgressIndicator(
              value: countdownValue / 30, // percent filled
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              backgroundColor: Color(0xFFFFDAB8),
            ),
          ),
        ),
        Text('$countdownValue/30', style: TextStyle(
          fontSize: 22,
        ),),
      ],
    );
  }
}
