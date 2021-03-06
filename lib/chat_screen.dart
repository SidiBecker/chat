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

  Map chatData;

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _title = "Olá";

  FirebaseUser _currentUser;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    print('usuarios');
    print(widget.chatData["users"]);

    _getUser().then((value) => _getDataAnotherUser());

    _updateUsers();
  }

  Future<FirebaseUser> _getUser() async {
    return _currentUser = await FireBaseUtil.getUser();
  }

  Future<FirebaseUser> _getDataAnotherUser() async {
    Map anotherUser = widget.chatData["users"]
        .where((user) =>
            user['uid'] != _currentUser.uid &&
            user['email'] != _currentUser.email)
        .toList()
        .first;

    setState(() {
      _title = anotherUser['name'] ?? anotherUser['email'];
    });
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

    String id = widget.chatData["id"];

    DocumentReference chatObj =
        Firestore.instance.collection('chats').document(id);

    chatObj.updateData({'lastMessage': Timestamp.now()});

    Firestore.instance.collection('chats/$id/messages').add(data);
  }

  Future<void> _updateUsers() async {
    String id = widget.chatData["id"];

    DocumentReference chatObj =
        Firestore.instance.collection('chats').document(id);

    DocumentSnapshot document = await chatObj.get();

    List users = document.data["users"];

    Map userObj = users
        .where((user) =>
            user['uid'] == _currentUser.uid ||
            user['email'] == _currentUser.email)
        .toList()
        .first;

    if (userObj['needConfirmation']) {
      List usersId = document.data['usersId'];

      usersId.remove(_currentUser.email);
      usersId.add(_currentUser.uid);

      chatObj.updateData({'usersId': usersId});

      users.removeAt(users.indexOf(userObj));

      userObj['name'] = _currentUser.displayName;
      userObj['photoUrl'] = _currentUser.photoUrl;
      userObj['uid'] = _currentUser.uid;
      userObj['needConfirmation'] = false;

      List updatedUsers = [...users, userObj];

      chatObj.updateData({'users': updatedUsers});

      document = await chatObj.get();
      widget.chatData = document.data;
    }
  }

  @override
  Widget build(BuildContext context) {
    String _chatId = widget.chatData["id"];

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(_title),
        centerTitle: false,
        elevation: 0,
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
                            String senderUid =
                                documents[index].data["senderUid"];

                            Map user = widget.chatData["users"]
                                .where((user) => user["uid"] == senderUid)
                                .first;

                            return ChatMessage(documents[index].data, user,
                                user["uid"] == _currentUser.uid);
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
