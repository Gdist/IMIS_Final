import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:imis_final/utils/writer.dart';

enum LoginState { FAILED, SUCCESS, TIMEOUT }

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var _selectedIndex = 0;

  // stroage & upload
  InfoStorage storage = InfoStorage();

  LoginState _loginstatus = LoginState.FAILED;
  String _account = "";
  String _password = "";
  bool _isPasswordVisible = true;
  bool _isAuth = false;

  // Declare TextEditingController to get the value in TextField
  TextEditingController accountController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    storage.readAccount().then((value) {
      setState(() {
        _account = value;
        if (_account != "guest") {
          _loginstatus = LoginState.SUCCESS;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Text(
              "帳戶中心",
              style: TextStyle(
                fontSize: 40.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          if (_loginstatus != LoginState.SUCCESS)
            Text(
              "若需使用更多功能，請登入",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.black,
              ),
            ),
          if (_loginstatus == LoginState.SUCCESS)
            Text(
              "歡迎，$_account！\n以下是你的遊玩紀錄",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.black,
              ),
            ),
          if (_loginstatus == LoginState.SUCCESS)
            SizedBox(height: 10,),
          if (_loginstatus == LoginState.SUCCESS) // GameInfo
            FutureBuilder(
              future: InfoStorage.getData(_account),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final gamelogs = snapshot.data as List<GameLog>;
                  return ListView.builder(
                    //physics: ScrollPhysics(),
                    //scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: gamelogs.length + 1, // Add Title
                    itemBuilder: (BuildContext context, index) {
                      if (index == 0) {
                        return GameInfo(
                            index:index, time: "時間", gameid: "遊戲名稱", score: "分數");
                      } else {
                        return GameInfo(
                            index: index,
                            time: gamelogs.elementAt(index - 1).time,
                            gameid: gamelogs.elementAt(index - 1).gameid,
                            score: gamelogs.elementAt(index - 1).score);
                      }
                    },
                  );
                } else if (snapshot.hasError) {
                  print("${snapshot.error}");
                  return Text("${snapshot.error}");
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
          if (_loginstatus == LoginState.SUCCESS)
            SizedBox(
              height: 20.0,
            ),
          if (_loginstatus != LoginState.SUCCESS) buildAccountField(),
          if (_loginstatus != LoginState.SUCCESS) buildPasswordField(),
          if (_loginstatus != LoginState.SUCCESS)
            SizedBox(
              height: 20.0,
            ),
          SizedBox(
            width: MediaQuery.of(context).size.width - 48.0,
            height: 48.0,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                primary: _loginstatus != LoginState.SUCCESS
                    ? Colors.green
                    : Colors.red,
                onPrimary: Colors.white,
                shadowColor: Colors.greenAccent,
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32.0)),
                minimumSize: Size(300, 50), //////// HERE
              ),
              icon: _loginstatus != LoginState.SUCCESS
                  ? Icon(Icons.login)
                  : Icon(Icons.logout),
              label: Text(
                (_loginstatus != LoginState.SUCCESS) ? "登入／註冊" : "登出",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
              onPressed: () {
                if (_loginstatus == LoginState.SUCCESS) {
                  // Log out
                  accountController.text = _account;
                  passwordController.text = "";
                  storage.writeAccount("guest");
                  _loginstatus = LoginState.FAILED;
                  setState(() {
                    _account = accountController.text;
                    _password = passwordController.text;
                  });
                } else {
                  setState(() {
                    _account = accountController.text;
                    _password = passwordController.text;
                  });

                  /// Begin User Verify ///
                  bool isLogin = false;
                  Login(_account, _password).then((value) {
                    setState(() {
                      isLogin = value;
                      print('Login: $isLogin');
                      if (isLogin) {
                        _loginstatus = LoginState.SUCCESS;
                        storage.writeAccount(_account);
                      } else {
                        _loginstatus = LoginState.FAILED;
                        _showAlertDialog(context);
                      }
                    });
                  });

                  /// End User Verify ///
                }
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: '遊戲清單',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: '帳戶',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: '關於',
          ),
        ],
        currentIndex: 1,
        selectedItemColor: Colors.amber[800],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          if (_selectedIndex == 1)
            Navigator.of(context)
                .pushNamedAndRemoveUntil("/login", (Route route) => false);
          else if (_selectedIndex == 2)
            Navigator.of(context)
                .pushNamedAndRemoveUntil("/about", (Route route) => false);
          else
            Navigator.of(context)
                .pushNamedAndRemoveUntil("/", (Route route) => false);
        },
      ),
    );
  }

  Future<bool> Login(String account, String password) async {
    final headers = {
      "Connection": "Keep-Alive",
      "Keep-Alive": "timeout=5, max=1000"
    };
    String url =
        "https://imis.ncku.me/login?account=$account&password=$password";
    final res = await http.get(Uri.parse(url), headers: headers);
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      if (json['status'] == 'success') {
        return true;
      }
    } else {
      throw Exception('Failed to login: ${res.body}');
    }
    return false;
  }

  Widget buildAccountField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: TextFormField(
        controller: accountController, // 為了獲得TextField中的value
        decoration: InputDecoration(
          fillColor: Colors.white70,
          // 背景顏色，必須結合filled: true,才有效
          filled: true,
          // 重點，必須設定為true，fillColor才有效
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)), // 設定邊框圓角弧度
            borderSide: BorderSide(
              color: Colors.black87, // 設定邊框的顏色
              width: 2.0, // 設定邊框的粗細
            ),
          ),
          // when user choose the TextField
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(
            color: Colors.red, // 設定邊框的顏色
            width: 2, // 設定邊框的粗細
          )),

          // 提示文字
          prefixIcon: Icon(
            Icons.person, // Flutter 內建的搜尋 icon
            color: Colors.black54, // 設定 icon 顏色
          ),
          labelText: "帳號 *",
          hintText: "請在此輸入帳號",
        ),
      ),
    );
  }

  Widget buildPasswordField() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: TextFormField(
        controller: passwordController, // 為了獲得TextField中的value
        obscureText: _isPasswordVisible,
        decoration: InputDecoration(
          fillColor: Colors.white70,
          // 背景顏色，必須結合filled: true,才有效
          filled: true,
          // 重點，必須設定為true，fillColor才有效
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)), // 設定邊框圓角弧度
            borderSide: BorderSide(
              color: Colors.black87, // 設定邊框的顏色
              width: 2.0, // 設定邊框的粗細
            ),
          ),
          // when user choose the TextField
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(
            color: Colors.red, // 設定邊框的顏色
            width: 2, // 設定邊框的粗細
          )),

          prefixIcon: Icon(
            Icons.lock, // Flutter 內建的搜尋 icon
            color: Colors.black54, // 設定 icon 顏色
          ),
          suffixIcon: IconButton(
            icon: const Icon(
              Icons.remove_red_eye,
              color: Colors.black54,
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          ),
          labelText: "密碼 *",
          hintText: "請在此輸入密碼",
        ),
      ),
    );
  }

  Future<void> _showAlertDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('錯誤'),
          content: Container(
            height: 50,
            child: Column(
              children: [
                Text('密碼錯誤',
                    style: TextStyle(fontSize: 30.0, color: Colors.black)),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              //style: flatButtonStyle,
              //color: Colors.amber[200],
              child: Text('確定',
                  style: TextStyle(fontSize: 18.0, color: Colors.black)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
