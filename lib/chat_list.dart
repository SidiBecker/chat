import 'dart:io';
import 'package:chat_app/chat_card.dart';
import 'package:chat_app/chat_screen.dart';
import 'package:chat_app/firebase_util.dart';
import 'package:chat_app/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

                      List<DocumentSnapshot> chats = document
                          .where((element) =>
                              element["users"]
                                  .where(
                                      (user) => user["uid"] == _currentUser.uid)
                                  .length >
                              0)
                          .toList();

                      print('QTDE MSG: ' + chats.length.toString());

                      return ListView.builder(
                          itemCount: chats.length,
                          itemBuilder: (context, index) {
                            String chatId = chats[index].data["id"];

                            print('chatId: ' + chatId);
                            
                            return InkWell(
                              child: ChatCard(
                                  chats[index].data, _currentUser, chatId),
                              onTap: () => {_goToChat(chats[index].data)},
                              onLongPress: () => {print('onLongPress')},
                            );
                          });
                  }
                }),
          ),
        ],
      ),
    );
  }

  void _goToChat(chatData) {
    print('tap');

    PageRouteBuilder chatRoute = new PageRouteBuilder(
      pageBuilder: (BuildContext context, _, __) {
        return ChatScreen(chatData);
      },
    );

    Navigator.push(context, chatRoute);
  }

  Future<QuerySnapshot> _getLastMessage(chatId) async {
    Firestore rootRef = Firestore.instance;

    Query query =
        rootRef.collection('chats/$chatId/messages').orderBy("time").limit(1);

    return await query.getDocuments();
  }
}
