import 'package:chat_app/chat_screen.dart';
import 'package:chat_app/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PageRouteBuilder _loginRoute = new PageRouteBuilder(
    pageBuilder: (BuildContext context, _, __) {
      return LoginScreen(false);
    },
  );

  PageRouteBuilder _chatRoute = new PageRouteBuilder(
    pageBuilder: (BuildContext context, _, __) {
      return ChatScreen();
    },
  );

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  @override
  initState() {
    super.initState();

    PageRouteBuilder route = _loginRoute;

    FirebaseAuth.instance.currentUser().then((user) => {
          if (user != null) {route = _chatRoute},
          _redirect(route)
        });

    super.initState();
  }

  void _redirect(PageRouteBuilder route) {
    Navigator.pushAndRemoveUntil(
      context,
      route,
      (Route<dynamic> r) => false,
    );
  }
}
