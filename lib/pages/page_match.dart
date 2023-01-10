import 'package:flutter/material.dart';
import 'dart:async';

import 'package:imis_final/components/scoreboard.dart';
import 'package:imis_final/components/countdownbar.dart';
import 'package:imis_final/utils/game_match.dart';
import 'package:imis_final/utils/flutter_tts.dart';
import 'package:imis_final/utils/writer.dart';

enum GameState { IDLE, MEMORY, RECALL, END }

class MatchPage extends StatefulWidget {
  const MatchPage({Key? key}) : super(key: key);

  @override
  _MatchPageState createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {
  // stroage & upload
  InfoStorage storage = InfoStorage();
  String _account = "";

  // direction Text
  String directionText = "請你記住圖卡的位置\n並選出一樣的將其配對";

  // setting text style
  TextStyle whiteText = TextStyle(color: Colors.white);

  // game status
  MatchGame _game = MatchGame();
  GameState _gamestatus = GameState.IDLE;
  bool hideText = false;
  String btnText = "開始遊戲";
  Icon btnIcon = Icon(Icons.send);

  // game stats
  int click = 0;
  int tries = 0;
  int correct = 0;
  int score = 0; // score = correct * 100 - tries * 10
  int curAns = 0; // reset if answer all

  void resetGameStats() {
    click = 0;
    tries = 0;
    correct = 0;
    score = 0; // score = correct * 100 - tries * 10
    curAns = 0; // reset if answer all
  }

  @override
  void initState() {
    super.initState();
    _game.initGame();
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
      if (timer.tick  > endSeconds) {
        stopTimer();
        setState(() {
          _gamestatus = GameState.END;
          setBtnText();
          storage.Upload(_account, '10', score); //Upload
        });
      } else {
        setState(() {
          countdownCurrent = timer.tick;
          countdownRemain = endSeconds - countdownCurrent;
          isTimerRunning = true;
        });
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
        title: Text('配對遊戲'),
      ),
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (_gamestatus == GameState.IDLE || _gamestatus == GameState.END)
            Center(
              child: Text(
                _gamestatus == GameState.IDLE ? "配對遊戲" : "遊戲結束",
                style: TextStyle(
                  fontSize: 48.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          SizedBox(
            height: 16.0,
          ),
          if (_gamestatus == GameState.IDLE)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                primary: Colors.redAccent,
                onPrimary: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32.0)),
                minimumSize: Size(100, 50), //////// HERE
              ),
              icon: Icon(Icons.play_arrow),
              label: Text(
                "播放語音",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
              onPressed: () async {
                // connect to text2speech socket
                // await Text2Speech().connect(play, directionText, "chinese");
                await Text2SpeechFlutter().speak(directionText);
              },
            ),
          if (_gamestatus == GameState.IDLE)
            Center(
              child: Text(
                directionText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24.0,
                  color: Colors.black,
                ),
              ),
            ),
          if (_gamestatus != GameState.IDLE && _gamestatus != GameState.END)
            CountdownBarWidget(countdownRemain, countdownTotal),
          if (_gamestatus != GameState.IDLE)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //scoreBoard("Tries", "$tries"),
                scoreBoard("分數", "$score"),
              ],
            ),
          if (_gamestatus != GameState.IDLE && _gamestatus != GameState.END)
            SizedBox(
                height: MediaQuery.of(context).size.width,
                width: MediaQuery.of(context).size.width,
                child: GridView.builder(
                    itemCount: _game.gameImg!.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                    ),
                    padding: EdgeInsets.all(16.0),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          if (_gamestatus != GameState.IDLE &&
                              _gamestatus != GameState.MEMORY &&
                              isTimerRunning) {
                            print(_game.matchCheck);
                            setState(() {
                              //incrementing the clicks
                              click++;
                              tries = (click / 2).floor();
                              _game.gameImg![index] = _game.cards_list[index];
                              _game.matchCheck
                                  .add({index: _game.cards_list[index]});
                              print(_game.matchCheck.first);
                            });
                            if (_game.matchCheck.length == 2) {
                              if (_game.matchCheck[0].values.first ==
                                  _game.matchCheck[1].values.first) {
                                // true
                                print("true");
                                //incrementing correct
                                correct++;
                                curAns++;
                                if (curAns == 4) {
                                  _gamestatus = GameState.MEMORY;
                                  Future.delayed(Duration(milliseconds: 200),
                                      () {
                                    _game.initGame();

                                  });
                                  _gamestatus = GameState.MEMORY;
                                  curAns = 0;
                                  setBtnText();
                                }
                                _game.matchCheck.clear();
                              } else {
                                print("false");
                                Future.delayed(Duration(milliseconds: 200), () {
                                  setState(() {
                                    _game.gameImg![_game.matchCheck[0].keys
                                        .first] = _game.hiddenCardpath;
                                    _game.gameImg![_game.matchCheck[1].keys
                                        .first] = _game.hiddenCardpath;
                                    _game.matchCheck.clear();
                                  });
                                });
                              }
                              score = correct * 110 - tries * 10;
                            }
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(8.0),
                            image: DecorationImage(
                              image: AssetImage(_game.gameImg![index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    })),
          SizedBox(
            height: 16.0,
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
                  minimumSize: Size(300, 50), //////// HERE
                ),
                icon: btnIcon,
                label: Text(
                  btnText,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                  ),
                ),
                onPressed: () {
                  setState(() {
                    if (_gamestatus == GameState.IDLE) {
                      _gamestatus = GameState.MEMORY; // Next State
                      resetTimer(timerNum);
                    } else if (_gamestatus == GameState.MEMORY) {
                      _gamestatus = GameState.RECALL;
                      _game.hideCard();
                    } else if (_gamestatus == GameState.RECALL) {
                      _gamestatus = GameState.MEMORY;
                      _game.initGame();
                      curAns = 0;
                    } else {
                      _gamestatus = GameState.MEMORY;
                      _game.initGame();
                      resetGameStats();
                      resetTimer(timerNum);
                    }
                    setBtnText();
                  });
                },
              )
            ],
          ),
        ],
      ),
    );
  }

  void setBtnText() {
    if (_gamestatus == GameState.IDLE){
      btnText = "開始遊戲";
      btnIcon = Icon(Icons.send);
    }
    else if (_gamestatus == GameState.MEMORY){
      btnText = "我記住了";
      btnIcon = Icon(Icons.done);
    }
    else if (_gamestatus == GameState.RECALL){
      btnText = "我忘記了";
      btnIcon = Icon(Icons.refresh);
    }
    else if (_gamestatus == GameState.END){
      btnText = "重新開始";
      btnIcon = Icon(Icons.refresh);
    }
  }

}
