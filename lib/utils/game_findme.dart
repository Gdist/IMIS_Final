import 'package:flutter/material.dart';

class FindMeGame {
  List<String>? gameImages;
  List<String>? gameTargets;
  final String hiddenCardPath = "assets/images/hidden.png";
  final String correctCardPath = "assets/images/check.png";
  final String falseCardPath = "assets/images/cross.png";
  final int cardCount = 8;
  //List<Map<int, String>> matchCheck = [];
  List<Map<int, String>> matchCheck = [];

  List<String> target_list = [
    "assets/images/apple.png",
    "assets/images/banana.png",
    "assets/images/cherries.png",
    "assets/images/grapes.png",
    "assets/images/lemon.png",
    "assets/images/strawberry.png",
    "assets/images/sugarcane.png",
    "assets/images/cake.png",
    "assets/images/icecream.png",
    "assets/images/cat.png",
    "assets/images/paws.png",
    "assets/images/star.png",
    "assets/images/peach.png",
  ];

  //methods
  void initGame(int targetCount, int cardCount) {
    target_list.shuffle();
    gameTargets = List.generate(targetCount, (index) => target_list[index]);
    gameImages = List.generate(cardCount, (index) {
      if (index < targetCount) return target_list[index];
      else return hiddenCardPath;
    });
    print(gameImages);
    print(gameTargets);
  }

  void shuffleCard(int targetCount, int cardCount){
    gameImages = List.generate(cardCount, (index) => hiddenCardPath);
    gameImages = List.generate(cardCount, (index) {
      if (index < target_list.length) return target_list[index];
      else return target_list[((index + targetCount) % target_list.length)];
    });
    gameImages!.shuffle();
  }
}
