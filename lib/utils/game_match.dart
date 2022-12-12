import 'package:flutter/material.dart';

class MatchGame {
  final Color hiddenCardColor = Colors.red;
  List<Color>? gameColors;
  List<String>? gameImg;
  List<Color> cards = [
    Colors.green,
    Colors.yellow,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.blue
  ];
  final String hiddenCardpath = "assets/images/hidden.png";
  List<String> cards_list = [
    "assets/images/apple.png",
    "assets/images/apple.png",
    "assets/images/cat.png",
    "assets/images/cat.png",
    "assets/images/paw.png",
    "assets/images/paw.png",
    "assets/images/star.png",
    "assets/images/star.png",
  ];
  final int cardCount = 8;
  List<Map<int, String>> matchCheck = [];

  //methods
  void initGame() {
    cards_list.shuffle();
    gameColors = List.generate(cardCount, (index) => hiddenCardColor);
    gameImg = List.generate(cardCount, (index) => cards_list[index]);
  }

  void hideCard(){

    gameImg = List.generate(cardCount, (index) => hiddenCardpath);
  }
}
