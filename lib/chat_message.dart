import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatMessage extends StatelessWidget {
  ChatMessage(this.data, this.user, this.ownMessage);

  final Map<String, dynamic> data;
  final Map<String, dynamic> user;
  final bool ownMessage;

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        children: [
          !ownMessage
              ? Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: user["photoUrl"] != null
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(user["photoUrl"]),
                        )
                      : CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                )
              : Container(),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: ownMessage
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(5),
                  width: MediaQuery.of(context).size.width * 0.7,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color:
                        ownMessage ? Colors.purple[300] : Colors.grey[800],
                  ),
                  child: data['imgUrl'] != null
                      ? Image.network(
                          data['imgUrl'],
                          width: 250,
                        )
                      : Text(
                          data['text'],
                          textAlign:
                              ownMessage ? TextAlign.end : TextAlign.start,
                          style: TextStyle(fontSize: 16, color: Colors.white)
                        ),
                ),
                Text(
                  new DateFormat('HH:mm')
                      .format(data['time'].toDate().toLocal()),
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w300),
                ),
              ],
            ),
          ),
          ownMessage
              ? Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: user["photoUrl"] != null
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(user["photoUrl"]),
                        )
                      : CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                )
              : Container(),
        ],
      ),
    );
  }
}
