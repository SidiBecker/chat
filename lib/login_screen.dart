import 'package:chat_app/chat_list.dart';
import 'package:chat_app/chat_screen-old.dart';
import 'package:chat_app/firebase_util.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();

  bool logout = false;

  LoginScreen(this.logout);
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  final PageRouteBuilder _chatRoute = new PageRouteBuilder(
    pageBuilder: (BuildContext context, _, __) {
      return ChatScreen();
    },
  );

  final PageRouteBuilder _chatListRoute = new PageRouteBuilder(
    pageBuilder: (BuildContext context, _, __) {
      return ChatList();
    },
  );

  void _login() async {

    Navigator.pushAndRemoveUntil(
        context, _chatListRoute, (Route<dynamic> r) => false);
  }

  @override
  Future<void> initState() {
    super.initState();

    FirebaseAuth.instance.currentUser().then((user) => {
          if (user != null)
            {
              Navigator.pushAndRemoveUntil(
                  context, _chatRoute, (Route<dynamic> r) => false)
            }
        });

    if (widget.logout) {
      WidgetsBinding.instance.addPostFrameCallback(
          (_) => _scaffoldKey.currentState.showSnackBar(SnackBar(
                content: Text('Você saiu com sucesso!'),
              )));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.green,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Vem com a galera!",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Calibri',
                            letterSpacing: 3),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 30),
                  ),
                  RaisedButton(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(Icons.account_circle),
                          Container(
                            child: Text('Entrar'),
                            margin: EdgeInsets.only(left: 10),
                          ),
                        ],
                      ),
                      onPressed: _login)
                ],
              ),
            ),
            Padding(
              child: Text(
                'Powered by SidiBecker',
                style: TextStyle(color: Colors.white),
              ),
              padding: EdgeInsets.only(bottom: 10),
            )
          ],
        ));
  }
}
