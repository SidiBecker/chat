import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatCard extends StatelessWidget {
  ChatCard(this.data, this.currentUser, this.lastMessage);

  final Map<String, dynamic> data;

  final FirebaseUser currentUser;

  final Map lastMessage;

  @override
  Widget build(BuildContext context) {
    Map user =
        data["users"].firstWhere((user) => user["uid"] != currentUser.uid);

    print(lastMessage["time"].toDate());

    String formatTimestamp(DateTime date, String format) {
      //TODO: FORMATAR DATA

      // var format = new DateFormat('d/MM/yy - hh:mm');
      return new DateFormat(format).format(date);
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundImage: NetworkImage(user["photoUrl"]),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['name'],
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
                Text(
                  lastMessage["text"],
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w300),
                ),
              ],
            ),
          ),
          Padding(
              padding: EdgeInsets.only(right: 16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatTimestamp(lastMessage["time"].toDate(), 'hh:mm'),
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w300),
                    ),
                    Text(
                      formatTimestamp(lastMessage["time"].toDate(), 'd/MM/yy'),
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w300),
                    )
                  ])),
        ],
      ),
    );
  }
}
