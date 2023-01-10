import 'dart:ffi';
import 'dart:math';

import 'package:flutter/material.dart';

class BillGame {

  final int numCount = 5;
  int award = 0;
  List<int> ques = [
    0, 0, 0, 0, 0
  ];

  bool ans = false;

  //methods
  void initGame() {
    award = Random().nextInt(1000);
    int place = Random().nextInt(1000) % numCount;
    int r = Random().nextInt(2);
    if(r == 1) ans = true;
    else ans = false;
    for(int i=0; i<numCount; i++){
      if(ans && i == place) ques[i] = award;
      else{
        ques[i] = Random().nextInt(1000);
        if(ques[i] == award && !ans){
          i--;
          continue;
        }
        for(int j=0; j<i; j++){
          if(ques[i] == ques[j]){
            i--;
            break;
          }
        }
      }
    }
  }

}