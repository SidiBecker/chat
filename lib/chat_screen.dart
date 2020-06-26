import 'dart:io';

import 'package:chat_firebase/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  void _sendMessage({String text, PickedFile img}) async {
    Map<String, dynamic> data = {};

    if (img != null) {
      StorageUploadTask task = FirebaseStorage.instance
          .ref()
          .child(DateTime.now().millisecondsSinceEpoch.toString())
          .putFile(File(img.path));

      StorageTaskSnapshot taskSnapshot = await task.onComplete;
      String url = await taskSnapshot.ref.getDownloadURL();
      data['imgUrl'] = url;
    }

    if (text != null) {
      data['text'] = text;
    }

     data['time'] = Timestamp.now();

    Firestore.instance.collection('messages').add(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat"),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder(
                stream: Firestore.instance.collection('messages').orderBy('time').snapshots(),
                builder: (context, snapshot) {

                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    default:
                      List<DocumentSnapshot> document = snapshot.data.documents.reversed.toList();

                      return ListView.builder(
                        itemCount: document.length,
                        reverse: true,
                        itemBuilder: (context, index){
                          return ListTile(
                            title: Text(document[index].data['text']),
                          );
                        });
                      
                  }
                }),
          ),
          TextComposer(_sendMessage),
        ],
      ),
    );
  }
}
