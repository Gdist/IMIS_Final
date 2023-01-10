import 'package:flutter/material.dart';
import 'dart:async';

import 'package:imis_final/components/scoreboard.dart';
import 'package:imis_final/components/countdownbar.dart';
import 'package:imis_final/utils/game_link.dart';
import 'package:imis_final/utils/writer.dart';

class LinkPage extends StatefulWidget {
  const LinkPage({Key? key}) : super(key: key);

  @override
  _LinkPageState createState() => _LinkPageState();
}

class _LinkPageState extends State<LinkPage>{
  // stroage & upload
  InfoStorage storage = InfoStorage();
  String _account = "";

  LinkGame _game = LinkGame();
  int correct = 0;
  int wrong = 0;
  int score = 0; // score = correct * 100 - tries * 10

  int state = 0;
  int select = 0;

  bool start = false;
  bool history_start = false;
  bool selected = false;
  bool fake = false;

  List<bool> paired = [
    false, false, false, false, false,
    false, false, false, false, false,
  ];

  var main_btn_str = '開始';

  void scorecount(){
    score = correct * 100 - wrong * 20;
    if(score <= 0){
      score = 0;
      correct = 0;
      wrong = 0;
    }

    if(score >= 1000){
      fake = true;
    }
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

  bool allclean(){
    for(int i=0; i<5; i++){
      if(!paired[i]){
        return false;
      }
    }

    return true;
  }

  void resetscore(){
    _game.initGame();
    correct = 0;
    wrong = 0;
    score = 0;
    selected = false;
    paired = [
      false, false, false, false, false,
      false, false, false, false, false,
    ];
  }

  @override
  void initState() {
    super.initState();
    resetscore();
    state = 0;
    fake = false;
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
  final int timerNum = 30;
  int countdownCurrent = 0;
  int countdownRemain = 30;
  int countdownTotal = 30;
  bool isTimerRunning = false;

  void startTimer(int endSeconds) {
    _timer = new Timer.periodic(Duration(seconds: 1), (timer) {
      if (timer.tick > endSeconds) {
        stopTimer();
        setState(() {
          setstate(2);
          start = false;
          storage.Upload(_account, '20', score); //Upload
        });
      } else {
        setState(() {
          countdownCurrent = timer.tick;
          countdownRemain = endSeconds - countdownCurrent;
          isTimerRunning = true;
        });
        //print('Hello world, timer: $countdownCurrent, $countdownRemain');
      }
      print('Hello world, timer: $countdownCurrent, $countdownRemain');
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
        title: Text('連連看'),
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
                '連連看'
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
            Column(
              children: [
                SizedBox(
                    height: 90,
                    width: MediaQuery.of(context).size.width,
                    child: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemCount: 5*2+1,
                        padding: EdgeInsets.all(16.0),
                        itemBuilder: (context, index) {
                          if(index % 2 == 1){
                            if(paired[(index / 2).toInt()]) return SizedBox(width: 60,);
                            else return GestureDetector(
                              onTap: () {
                                int i = (index / 2).toInt();
                                if(!paired[i]){
                                  if(selected){
                                    if(select < _game.numCount){
                                      select = i;
                                    }
                                    else{
                                      if(_game.list[select] == _game.list[i]){
                                        correct++;
                                        paired[i] = true;
                                        paired[select] = true;
                                        if(allclean()){
                                          paired = [
                                            false, false, false, false, false,
                                            false, false, false, false, false,
                                          ];
                                          _game.initGame();
                                        }
                                      }
                                      else{
                                        wrong++;
                                      }
                                      selected = false;
                                    }
                                  }
                                  else{
                                    select = i;
                                    selected = true;
                                  }
                                }
                                setState(() {
                                  scorecount();
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.all(30.0),
                                decoration: BoxDecoration(
                                  color: _game.color_list[_game.list[(index / 2).toInt()]],
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                            );
                          }
                          else{
                            return SizedBox(
                              width: 10,
                            );
                          }
                        }
                    )
                ),
                SizedBox(
                  height: 100,
                ),
                SizedBox(
                    height: 110,
                    width: MediaQuery.of(context).size.width,
                    child: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemCount: 5*2+1,
                        itemBuilder: (context, index) {
                          if(index % 2 == 1){
                            if(paired[(5 + (index/2)).toInt()]) return SizedBox(width: 50,);
                            else return SizedBox(
                              width: 50,
                              child: GestureDetector(
                                onTap: () {
                                  int i = (5 + (index/2)).toInt();
                                  if(!paired[i]){
                                    if(selected){
                                      if(select >= _game.numCount){
                                        select = i;
                                      }
                                      else{
                                        if(_game.list[select] == _game.list[i]){
                                          correct++;
                                          paired[i] = true;
                                          paired[select] = true;
                                          if(allclean()){
                                            paired = [
                                              false, false, false, false, false,
                                              false, false, false, false, false,
                                            ];
                                            _game.initGame();
                                          }
                                        }
                                        else{
                                          wrong++;
                                        }
                                        selected = false;
                                      }
                                    }
                                    else{
                                      select = i;
                                      selected = true;
                                    }
                                  }
                                  setState(() {
                                    scorecount();
                                  });
                                },
                                child: Text(
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 40,
                                    color: (!fake) ? _game.color_list[_game.list[(5 + (index/2)).toInt()]] : _game.color_list[_game.fakecolor[((index/2)).toInt()]],
                                  ),
                                  _game.cards_list[_game.list[(5 + (index/2)).toInt()]],
                                ),
                              ),
                            );
                          }
                          else{
                            return SizedBox(
                              width: 25,
                            );
                          }
                        }
                    )
                ),
              ],
            ),
          if(!start)
            Flexible(
                flex: 2,
                child: Column(
                  children: [
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
                              if(!start) {
                                start = true;
                                setstate(0);
                                resetscore();
                                resetTimer(20);
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

