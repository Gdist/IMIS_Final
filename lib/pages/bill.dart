import 'package:flutter/material.dart';
import 'dart:async';

import 'package:imis_final/components/scoreboard.dart';
import 'package:imis_final/components/countdownbar.dart';
import 'package:imis_final/utils/game_bill.dart';
import 'package:imis_final/utils/writer.dart';

class BillPage extends StatefulWidget {
  const BillPage({Key? key}) : super(key: key);

  @override
  _BillPageState createState() => _BillPageState();
}

class _BillPageState extends State<BillPage>{
  // stroage & upload
  InfoStorage storage = InfoStorage();
  String _account = "";

  BillGame _game = BillGame();
  int correct = 0;
  int wrong = 0;
  int look = 0;
  int score = 0; // score = correct * 100 - tries * 10

  int state = 0;

  bool start = false;
  bool history_start = false;

  var main_btn_str = '開始';

  void scorecount(){
    score = correct * 100 - look * 10 - wrong * 20;
    if(score <= 0){
      score = 0;
      correct = 0;
      look = 0;
      wrong = 0;
    }
  }

  void resetscore(){
    _game.initGame();
    correct = 0;
    wrong = 0;
    look = 0;
    score = 0;
  }

  void setstate(int s){
    if(s == 1){
      state = 1;
      main_btn_str = '再看一次';
    }
    else if(s == 0){
      state = 0;
      main_btn_str = '準備好了';
    }
    else if(s == 2){
      state = 2;
      main_btn_str = '開始';
    }
    history_start = true;
  }

  @override
  void initState() {
    super.initState();
    resetscore();
    state = 0;
    history_start = false;
    startTimer(999);
    storage.readAccount().then((value) {
      setState(() {
        _account = value;
      });
    });
  }

  /// Begin Timer ///
  Timer? _timer;
  final int timerNum = 20;
  int countdownCurrent = 0;
  int countdownRemain = 20;
  int countdownTotal = 20;
  bool isTimerRunning = false;

  void startTimer(int endSeconds) {
    _timer = new Timer.periodic(Duration(seconds: 1), (timer) {
      if (timer.tick > endSeconds) {
        stopTimer();
        setState(() {
          setstate(2);
          start = false;
          storage.Upload(_account, '14', score); //Upload
        });
      } else {
        setState(() {
          countdownCurrent = timer.tick;
          countdownRemain = endSeconds - countdownCurrent;
          isTimerRunning = true;
        });
        //print('Hello world, timer: $countdownCurrent, $countdownRemain');
      }
      //print('Hello world, timer: $countdownCurrent, $countdownRemain');
    });
  }

  void stopTimer() {
    setState(() {
      _timer!.cancel();
      isTimerRunning = false;
      countdownRemain = timerNum;
    });
  }

  void resetTimer(int endSeconds) {
    stopTimer();
    startTimer(endSeconds);
    setState(() {
      isTimerRunning = true;
    });
  }

  /// End Timer ///

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('發票兌獎'),
      ),
      //backgroundColor: Color(0xFFE55870),
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if(!start)
            SizedBox(
              height: 50,
            ),
          if(!start && history_start)
            Text(
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 40,
                ),
              '遊戲結束'
            ),
          if(!history_start)
            Text(
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 40,
                ),
                '發票兌獎'
            ),
          if(start)
            CountdownBarWidget(countdownRemain, countdownTotal),
          if(history_start)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //scoreBoard("Tries", "$tries"),
                scoreBoard("Score", "$score"),
              ],
            ),
          if(start)
            Flexible(
              flex: 6,
              child: ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                itemCount: _game.numCount + 1,
                itemBuilder: (context, index) {
                  if(state == 0){
                    if(index == 1) return NumberCard(num : '中獎號碼:\n     ' + _game.award.toString().padLeft(3, '0'));
                    else return SizedBox(
                      height: 100,
                    );
                  }
                  else{
                    if(index == 0) return NumberCard(num : '你的號碼:');
                    else return NumberCard(num : _game.ques[index-1].toString().padLeft(3, '0'));
                  }
                },
              ),
            ),
          Flexible(
              flex: 2,
              child: Column(
                children: [
                  if(start)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if(state == 1)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.green,
                                  onPrimary: Colors.white,
                                  shadowColor: Colors.greenAccent,
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(32.0)),
                                  minimumSize: Size(180, 50),
                                ),
                                icon: Icon(Icons.send),
                                label: Text(
                                  '中獎!',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 20,
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    if(_game.ans){
                                      correct++;
                                      _game.initGame();
                                      setstate(0);
                                    }
                                    else{
                                      wrong++;
                                    }
                                    scorecount();
                                  });
                                },
                              )
                            ],
                          ),
                        SizedBox(
                          width: 10,
                        ),
                        if(state == 1)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  primary: Colors.green,
                                  onPrimary: Colors.white,
                                  shadowColor: Colors.greenAccent,
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(32.0)),
                                  minimumSize: Size(180, 50),
                                ),
                                icon: Icon(Icons.send),
                                label: Text(
                                  '沒中QQ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 20,
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    if(!_game.ans){
                                      correct++;
                                      _game.initGame();
                                      setstate(0);
                                    }
                                    else{
                                      wrong++;
                                    }
                                    scorecount();
                                  });
                                },
                              )
                            ],
                          ),
                      ],
                    ),
                  SizedBox(
                      height: 10,
                      child: Container()
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.green,
                          onPrimary: Colors.white,
                          shadowColor: Colors.greenAccent,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32.0)),
                          minimumSize: Size(180, 50), //////// HERE
                        ),
                        icon: Icon(Icons.send),
                        label: Text(
                          main_btn_str,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            if(state == 0 || state == 2){
                              if(!start) {
                                start = true;
                                setstate(0);
                                resetscore();
                                resetTimer(20);
                              }
                              else setstate(1);
                            }
                            else{
                              setstate(0);
                              look++;
                            }
                            scorecount();
                          });
                        },
                      )
                    ],
                  ),
                ],
              )

          ),
        ],
      ),
    );
  }
}

class NumberCard extends StatelessWidget{
  const NumberCard({
    Key? key,
    required this.num,
  }) : super(key: key);

  final String num;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      color: Colors.tealAccent,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 40,
              ),
              num
          ),
        ],
      ),
    );
  }
}