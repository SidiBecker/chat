import 'package:chat_app/firebase_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatCard extends StatefulWidget {
  ChatCard(this.data, this.currentUser, this.chatId);

  final Map<String, dynamic> data;

  final FirebaseUser currentUser;

  final String chatId;

  @override
  _ChatCardState createState() => _ChatCardState();
}

class _ChatCardState extends State<ChatCard> {
  Map lastMessageObj;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Map user = widget.data["users"]
        .firstWhere((user) => user["uid"] != widget.currentUser.uid);

    Firestore.instance
        .collection('chats/${widget.chatId}/messages')
        .orderBy("time", descending: true)
        .limit(1)
        .getDocuments()
        .then((value) => {
              if (this.mounted && value.documentChanges != null)
                {
                  if (value.documentChanges.toList().isNotEmpty)
                    {
                      setState(() {
                        lastMessageObj =
                            value.documentChanges.first.document.data;
                      })
                    }
                }
            });

    String formatTimestamp(DateTime date, String format) {
      return new DateFormat(format).format(date);
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: user["photoUrl"] != null
                ? CircleAvatar(
                    backgroundImage: NetworkImage(user["photoUrl"]),
                  )
                : CircleAvatar(
                    child: Icon(Icons.person),
                  ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name'] ?? user['email'],
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
                lastMessageObj != null
                    ? Text(
                        lastMessageObj["text"],
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w300),
                      )
                    : Container(),
              ],
            ),
          ),
          lastMessageObj != null
              ? Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          formatTimestamp(
                              lastMessageObj["time"].toDate().toLocal(),
                              'hh:mm'),
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w300),
                        ),
                        Text(
                          formatTimestamp(
                              lastMessageObj["time"].toDate().toLocal(),
                              'd/MM/yy'),
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w300),
                        )
                      ]))
              : Container(),
        ],
      ),
    );
  }
}
