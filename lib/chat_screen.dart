import 'dart:io';

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

class ChatScreen extends StatefulWidget {
  ChatScreen(this.chatData);

  final Map chatData;

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _title = "Olá";

  FirebaseUser _currentUser;
  bool _isLoading = false;

  List _messages = [];

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

    _messages = widget.chatData["messages"];
  }

  Future<FirebaseUser> _getUser() async {
    return _currentUser = await FireBaseUtil.getUser();
  }

  void _sendMessage({String text, PickedFile img}) async {
    final FirebaseUser user = await _getUser();

    if (user == null) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Não foi possível realizar login com o google."),
        backgroundColor: Colors.red,
      ));
    }

    Map<String, dynamic> data = {
      "senderUid": user.uid,
    };

    if (img != null) {
      StorageUploadTask task = FirebaseStorage.instance
          .ref()
          .child(_currentUser.uid +
              DateTime.now().millisecondsSinceEpoch.toString())
          .putFile(File(img.path));

      setState(() {
        _isLoading = true;
      });

      StorageTaskSnapshot taskSnapshot = await task.onComplete;
      String url = await taskSnapshot.ref.getDownloadURL();
      data['imgUrl'] = url;
    }

    if (text != null) {
      data['text'] = text;
    }

    data['time'] = Timestamp.now();
    setState(() {
      _isLoading = false;
    });

    //TODO: Se o documento ainda não existe
    // DocumentReference documentChat =
    //     Firestore.instance.collection('chats').document();
    // documentChat.setData({
    //   'users': widget.chatData["users"],
    //   'messages': [],
    //   'id': documentChat.documentID
    // });

    String id = widget.chatData["id"];


    Firestore.instance.collection('chats').document(id).updateData({'lastMessage': Timestamp.now()});

    Firestore.instance.collection('chats/$id/messages').add(data);
  }

  @override
  Widget build(BuildContext context) {
    String _chatId = widget.chatData["id"];

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
                stream: Firestore.instance
                    .collection('chats/$_chatId/messages')
                    .orderBy('time')
                    .snapshots(),
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

                      List<DocumentSnapshot> documents =
                          chatSnapshot.data.documents.reversed.toList();

                      return ListView.builder(
                          itemCount: documents.length,
                          reverse: true,
                          itemBuilder: (context, index) {
                            String senderUid = documents[index]["senderUid"];

                            Map user = widget.chatData["users"]
                                .firstWhere((user) => user["uid"] == senderUid);

                            return ChatMessage(documents[index].data, user,
                                (user["uid"] == _currentUser.uid));
                          });
                  }
                }),
          ),
          _isLoading ? LinearProgressIndicator() : Container(),
          _currentUser != null ? TextComposer(_sendMessage) : Container(),
        ],
      ),
    );
  }
}
