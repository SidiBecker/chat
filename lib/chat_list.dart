import 'dart:io';

import 'package:chat_app/chat_card.dart';
import 'package:chat_app/firebase_util.dart';
import 'package:chat_app/login_screen.dart';
import 'package:chat_app/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

import 'chat_message.dart';

class ChatList extends StatefulWidget {
  @override
  ChatListState createState() => ChatListState();
}

class ChatListState extends State<ChatList> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _title = "Olá";

  FirebaseUser _currentUser;

  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.onAuthStateChanged.listen((user) {
      _currentUser = user;

      if (!mounted) return;

      setState(() {
        _title = _currentUser != null
            ? "Olá, " + user.displayName + "!"
            : "Chat App";
      });
    });
  }

  Future<FirebaseUser> _getUser() async {
    return _currentUser = await FireBaseUtil.getUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(_title),
        centerTitle: true,
        elevation: 0,
        actions: [
          _currentUser != null
              ? IconButton(
                  icon: Icon(Icons.exit_to_app),
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    googleSignIn.signOut();

                    PageRouteBuilder _loginRoute = new PageRouteBuilder(
                      pageBuilder: (BuildContext context, _, __) {
                        return LoginScreen(true);
                      },
                    );

                    Navigator.pushAndRemoveUntil(
                      context,
                      _loginRoute,
                      (Route<dynamic> r) => false,
                    );
                  },
                )
              : IconButton(
                  icon: Icon(Icons.person),
                  onPressed: () {
                    _getUser();
                  },
                )
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder(
                stream: Firestore.instance.collection('chats').snapshots(),
                builder: (context, chatSnapshot) {
                  switch (chatSnapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    default:
                      if (_currentUser == null) {
                        return Container();
                      }

                      print('Usuário logado: ' + _currentUser.uid);

                      List<DocumentSnapshot> document =
                          chatSnapshot.data.documents.reversed.toList();

                      List<DocumentSnapshot> messages = document
                          .where((element) =>
                              element["users"]
                                  .where(
                                      (user) => user["uid"] == _currentUser.uid)
                                  .length >
                              0)
                          .toList();

                      print('QTDE: ' + messages.length.toString());

                      return ListView.builder(
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            print(messages[index].data);

                            Map lastMessage =
                                messages[index].data["messages"].last;

                            return ChatCard(messages[index].data, _currentUser,
                                lastMessage);
                          });
                  }
                }),
          ),
        ],
      ),
    );
  }
}
