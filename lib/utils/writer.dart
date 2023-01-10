import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'package:imis_final/data.dart' as gameData;

class InfoStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/account.txt');
  }

  Future<String> readAccount() async {
    try {
      final file = await _localFile;

      // Read the file
      final contents = await file.readAsString();
      return contents;
    } catch (e) {
      // If encountering an error, return 0
      return "guest";
    }
  }

  Future<File> writeAccount(String contents) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString(contents);
  }

  Future<void> Upload(String account, String gamdid, int score) async {
    final headers = {
      "Connection": "Keep-Alive",
      "Keep-Alive": "timeout=5, max=1000"
    };
    String url =
        'https://imis.ncku.me/upload?account=$account&gameid=$gamdid&score=$score';
    print(url);
    final res = await http.get(Uri.parse(url), headers: headers);
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      print(json);
      if (json['status'] == 'success') {
        print('Upload: $account/$gamdid/$score');
      }
    } else {
      throw Exception('Failed to login: ${res.body}');
    }
  }

  static Future<List<GameLog>> getData(String account) async {
    final headers = {
      "Connection": "Keep-Alive",
      "Keep-Alive": "timeout=5, max=1000"
    };
    String url = 'https://imis.ncku.me/get_data?account=$account&num=10';
    print(url);
    final res = await http.get(Uri.parse(url), headers: headers);
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      final datas = json['data'];
      final logs =
          datas.map<GameLog>((results) => GameLog.fromJson(results)).toList();
      return logs;
    } else {
      throw Exception('Failed to load game record: ${res.body}');
    }
  }
}

class GameLog {
  String account;
  String gameid;
  String score;
  String time;

  GameLog({
    required this.account,
    required this.gameid,
    required this.score,
    required this.time,
  });

  factory GameLog.fromJson(Map<String, dynamic> json) {
    return GameLog(
      account: json['account'],
      gameid: json['gameid'],
      score: json['score'],
      time: json['time'],
    );
  }
}

class GameInfo extends StatelessWidget {
  const GameInfo({
    Key? key,
    required this.index,
    required this.time,
    required this.gameid,
    required this.score,
  }) : super(key: key);

  final int index;
  final String time;
  final String gameid;
  final String score;

  @override
  Widget build(BuildContext context) {
    String gameName = gameid;
    if (gameid != "遊戲名稱"){
      var gameId = int.parse(gameid);
      gameName = gameData.gameNames[gameId~/10-1][gameId%10];
    }

    return Expanded(child: Row(
      children: [
        Expanded(
          flex: 5,
          child: Center(child: Text(time, style: TextStyle(
            fontSize: index!=0? 20: 24,
            fontWeight: index!=0? FontWeight.normal: FontWeight.bold,
            color: Colors.black,
          )),),
        ),
        Expanded(
          flex: 3,
          child: Center(child: Text(gameName, style: TextStyle(
            fontSize: index!=0? 20: 24,
            fontWeight: index!=0? FontWeight.normal: FontWeight.bold,
            color: Colors.black,
          )),),
        ),
        Expanded(
          flex: 2,
          child: Center(child: Text(score, style: TextStyle(
            fontSize: index!=0? 20: 24,
            fontWeight: index!=0? FontWeight.normal: FontWeight.bold,
            color: Colors.black,
          )),),
        ),
      ],
    ));
  }
}
