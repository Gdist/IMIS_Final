import 'dart:ffi';
import 'dart:math';

import 'package:flutter/material.dart';

class LinkGame {

  final int numCount = 5;
  List<String> cards_list = [
    "綠",
    "藍",
    "紅",
    "黑",
    "黃",
  ];

  List<Color> color_list = [
    Colors.green,
    Colors.blue,
    Colors.red,
    Colors.black,
    Colors.yellow,
  ];

  List<int> list = [
    0,0,0,0,0,
    0,0,0,0,0,
  ];

  List<int> fakecolor = [
    0,0,0,0,0,
  ];

  //methods
  void initGame() {
    for(int i=0; i<numCount; i++){
      list[i] = Random().nextInt(5);
      for(int j=0; j<i; j++){
        if(list[i] == list[j]){
          i--;
          break;
        }
      }
    }
    for(int i=numCount; i<numCount*2; i++){
      list[i] = Random().nextInt(5);
      for(int j=numCount; j<i; j++){
        if(list[i] == list[j]){
          i--;
          break;
        }
      }
      for(int i=0; i<numCount; i++){
        fakecolor[i] = Random().nextInt(5);
        for(int j=0; j<i; j++){
          if(fakecolor[i] == fakecolor[j]){
            i--;
            break;
          }
        }
      }
    }
  }

}