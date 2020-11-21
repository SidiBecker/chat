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

  TextEditingController controllerEmail = TextEditingController();

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

  createtAlertDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Insira o e-mail'),
            content: TextField(
              keyboardType: TextInputType.emailAddress,
              controller: controllerEmail,
              autofocus: true,
            ),
            actions: [
              MaterialButton(
                elevation: 0.5,
                onPressed: () {
                  Navigator.of(context).pop(controllerEmail.text.toString());
                },
                child: Text('OK'),
              )
            ],
          );
        });
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
                    googleSignIn.disconnect();

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
                stream: Firestore.instance.collection('chats').orderBy('lastMessage').snapshots(),
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
                                  .where((user) =>
                                      user["uid"] == _currentUser.uid ||
                                      user["email"] == _currentUser.email)
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
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            createtAlertDialog(context).then((value) => {
                  print(value),
                  _createChat(value),
                  controllerEmail.clear(),
                });
          },
          child: Icon(Icons.add)),
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

  void _createChat(String email) {
    if (email != _currentUser.email) {
      Map myUser = {
        'email': _currentUser.email,
        'uid': _currentUser.uid,
        'photoUrl': _currentUser.photoUrl,
        'name': _currentUser.displayName
      };

      Map anotherUser = {
        'email': email,
        'uid': null,
        'photoUrl': null,
        'name': null
      };

      List<Map> users = [myUser, anotherUser];
      DocumentReference documentChat =
          Firestore.instance.collection('chats').document();
      documentChat.setData({'users': users, 'id': documentChat.documentID});
    }
  }
}
