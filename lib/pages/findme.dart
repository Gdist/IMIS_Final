import 'package:flutter/material.dart';
import 'dart:async';

import 'package:imis_final/components/scoreboard.dart';
import 'package:imis_final/components/countdownbar.dart';
import 'package:imis_final/utils/game_findme.dart';
import 'package:imis_final/utils/flutter_tts.dart';
import 'package:imis_final/utils/writer.dart';

enum GameState { IDLE, MEMORY, RECALL, END }

class FindMePage extends StatefulWidget {
  const FindMePage({Key? key}) : super(key: key);

  @override
  _FindMePageState createState() => _FindMePageState();
}

class _FindMePageState extends State<FindMePage> {
  // stroage & upload
  InfoStorage storage = InfoStorage();
  String _account = "";

  // direction Text
  String directionText = "請你記住一開始出現的圖卡\n並在以任意順序選出它們！";

  // setting text style
  TextStyle whiteText = TextStyle(color: Colors.white);

  // game status
  FindMeGame _game = FindMeGame();
  GameState _gamestatus = GameState.IDLE;
  bool hideText = false;
  String btnText = "開始遊戲";
  Icon btnIcon = Icon(Icons.send);

  int _gameTargetNum = 3;
  int _gameAllNum = 9;

  // game stats
  int click = 0;
  int tries = 0;
  int correct = 0;
  int score = 0; // score = correct * 100 - tries * 10
  int curAns = 0; // reset if answer all

  void resetGameStats() {
    _gameTargetNum = 3;
    _gameAllNum = 9;
    click = 0;
    tries = 0;
    correct = 0;
    score = 0; // score = correct * 100 - tries * 10
    curAns = 0; // reset if answer all
  }

  @override
  void initState() {
    super.initState();
    _game.initGame(_gameTargetNum, _gameAllNum);
    startTimer(999);
    storage.readAccount().then((value) {
      setState(() {
        _account = value;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Begin Timer ///
  Timer? _timer;
  final int timerNum = 60;
  int countdownCurrent = 0;
  int countdownRemain = 60;
  int countdownTotal = 60;
  bool isTimerRunning = false;

  void startTimer(int endSeconds) {
    _timer = new Timer.periodic(Duration(seconds: 1), (timer) {
      if (timer.tick > endSeconds) {
        stopTimer();
        setState(() {
          _gamestatus = GameState.END;
          setBtnText();
          storage.Upload(_account, '11', score); //Upload
        });
      } else {
        setState(() {
          countdownCurrent = timer.tick;
          countdownRemain = endSeconds - countdownCurrent;
          isTimerRunning = true;
        });
      }
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
        title: Text('東尋西覓'),
      ),
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (_gamestatus == GameState.IDLE || _gamestatus == GameState.END)
            Center(
              child: Text(
                _gamestatus == GameState.IDLE ? "東尋西覓" : "遊戲結束",
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
                scoreBoard("Score", "$score"),
              ],
            ),
          if (_gamestatus != GameState.IDLE && _gamestatus != GameState.END)
            SizedBox(
                height: MediaQuery.of(context).size.width,
                width: MediaQuery.of(context).size.width,
                child: GridView.builder(
                    itemCount: _game.gameImages!.length,
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
                            setState(() {
                              //incrementing the clicks
                              click++;
                              _game.matchCheck
                                  .add({index: _game.gameImages![index]});
                            });
                            // Start check
                            print(_game.matchCheck);
                            if (_game.matchCheck.length > 0) {
                              bool isCorrect = true;
                              for (var i = 0; i < _game.matchCheck.length; i++) {
                                print(_game.matchCheck[i].values.first);
                                if (!_game.gameTargets!.contains(_game.matchCheck[i].values.first)){
                                  isCorrect = false;
                                  break;
                                }
                              }

                              print(isCorrect);

                              if (isCorrect) {
                                for (var i = 0;
                                    i < _game.matchCheck.length;
                                    i++) {
                                  _game.gameImages![_game.matchCheck[i].keys
                                      .first] = _game.correctCardPath;
                                }

                                if (_game.matchCheck.length >= _gameTargetNum) {
                                  correct++;
                                  tries++;
                                  _game.matchCheck.clear();
                                  Future.delayed(Duration(milliseconds: 50),
                                      () {
                                    if (correct == 4 || correct == 10){
                                      _gameTargetNum++;
                                    }
                                    _game.initGame(_gameTargetNum, _gameAllNum);
                                    _gamestatus = GameState.MEMORY;
                                  });
                                  curAns = 0;
                                  btnText = "我記住了";
                                }
                              } else {
                                _game.gameImages![_game
                                    .matchCheck[_game.matchCheck.length - 1]
                                    .keys
                                    .first] = _game.falseCardPath;
                                Future.delayed(Duration(milliseconds: 200), () {
                                  for (var i = 0;
                                      i < _game.matchCheck.length;
                                      i++) {
                                    _game.gameImages![
                                            _game.matchCheck[i].keys.first] =
                                        _game.matchCheck[i].values.first;
                                  }
                                  _game.matchCheck.clear();
                                });
                                tries++;
                              }
                              score = correct * 110 - tries * 10;
                            }
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.yellow[200],
                            borderRadius: BorderRadius.circular(8.0),
                            image: DecorationImage(
                              image: AssetImage(_game.gameImages![index]),
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
                    fontSize: 20,
                  ),
                ),
                onPressed: () {
                  setState(() {
                    if (_gamestatus == GameState.IDLE) {
                      _gamestatus = GameState.MEMORY; // Next State
                      resetTimer(timerNum);
                    } else if (_gamestatus == GameState.MEMORY) {
                      _gamestatus = GameState.RECALL;
                      _game.shuffleCard(_gameTargetNum, _gameAllNum);
                    } else if (_gamestatus == GameState.RECALL) {
                      _gamestatus = GameState.MEMORY;
                      _game.initGame(_gameTargetNum, _gameAllNum);
                      curAns = 0;
                    } else {
                      _gamestatus = GameState.MEMORY;
                      _game.initGame(_gameTargetNum, _gameAllNum);
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
    else if (_gamestatus == GameState.END) btnText = "重新開始";
  }
}
