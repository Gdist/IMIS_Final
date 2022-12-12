import 'package:flutter/material.dart';
import 'package:imis_final/components/scoreboard.dart';
import 'package:imis_final/utils/game_match.dart';

class MatchPage extends StatefulWidget {
  const MatchPage({Key? key}) : super(key: key);

  @override
  _MatchPageState createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {
  //setting text style
  TextStyle whiteText = TextStyle(color: Colors.white);
  bool hideTest = false;
  MatchGame _game = MatchGame();

  //game stats
  int click = 0;
  int tries = 0;
  int correct = 0;
  int score = 0; // score = correct * 100 - tries * 10

  // game status
  int gameStatus = 0; //0: open, 1: close, 2: end
  String btnText = "我記住了";

  @override
  void initState() {
    super.initState();
    _game.initGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Match Game'),
      ),
      //backgroundColor: Color(0xFFE55870),
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /*Center(
            child: Text(
              "Match Game",
              style: TextStyle(
                fontSize: 48.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(
            height: 16.0,
          ),*/
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //scoreBoard("Tries", "$tries"),
              scoreBoard("Score", "$score"),
            ],
          ),
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
                        if(gameStatus > 0) {
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
                              print("true");
                              //incrementing correct
                              correct ++;
                              _game.matchCheck.clear();
                            } else {
                              print("false");

                              Future.delayed(Duration(milliseconds: 500), () {
                                setState(() {
                                  _game.gameImg![_game.matchCheck[0].keys
                                      .first] =
                                      _game.hiddenCardpath;
                                  _game.gameImg![_game.matchCheck[1].keys
                                      .first] =
                                      _game.hiddenCardpath;
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
                icon: Icon(Icons.send),
                label: Text(
                  btnText,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
                onPressed: () {
                  setState(() {
                    if (gameStatus == 0) {
                      _game.hideCard();
                      btnText = "重新開始";
                      gameStatus++;
                    } else {
                      _game.initGame();
                      btnText = "我記住了";
                      gameStatus = 0;
                    }
                  });
                },
              )
            ],
          ),
        ],
      ),
    );
  }
}
