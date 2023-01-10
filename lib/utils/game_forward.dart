import 'package:flutter/material.dart';

class FindMeGame {
  List<String>? images;
  List<int>? allMap; // [2,1,0, 0,0,3, 0,0,0]
  List<int>? regularOrder; // [1,0,5]
  List<int>? reverseOrder; // [5,0,1]

  final String emptyCardPath = "assets/images/empty.png";
  final String targetCardPath = "assets/images/paw.png";

  final String correctCardPath = "assets/images/check.png";
  final String falseCardPath = "assets/images/cross.png";

  List<int> matchCheck = [];

  //methods
  void initGame(int targetCount, int cardCount) {
    images = List.generate(cardCount, (index) => emptyCardPath);
    allMap = List.generate(cardCount, (index) {
      if (index < targetCount) return index+1;
      else return -1;
    });
    allMap!.shuffle();
    regularOrder = List.generate(targetCount, (index) {
      for (var i = 0; i < cardCount; i++) {
        if ( allMap![i] == (index+1) ) return i;
      }
      return -1;
    });
    reverseOrder = regularOrder!.reversed.toList();
    matchCheck.clear();
    print(allMap);
    print(regularOrder);
    print(reverseOrder);
  }

}
