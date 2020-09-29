import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  ChatMessage(this.data, this.ownMessage);

  final Map<String, dynamic> data;
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
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(data["senderPhoto"]),
                  ),
                )
              : Container(),
          Expanded(
            child: Column(
              crossAxisAlignment: ownMessage
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                data['imgUrl'] != null
                    ? Image.network(
                        data['imgUrl'],
                        width: 250,
                      )
                    : Text(
                        data['text'],
                        textAlign: ownMessage ? TextAlign.end : TextAlign.start,
                        style: TextStyle(fontSize: 16),
                      ),
                Text(
                  data['senderName'],
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          ownMessage
              ? Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(data["senderPhoto"]),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}
