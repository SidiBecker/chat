import 'package:flutter/material.dart';

class TextComposer extends StatefulWidget {
  @override
  _TextComposerState createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {
  bool _isWriting = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const  EdgeInsets.symmetric(horizontal: 7.0),
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.photo_camera),
            onPressed: () {},
          ),
          Expanded(
            child: TextField(
              decoration:
                  InputDecoration.collapsed(hintText: "Enviar uma mensagem"),
              onChanged: (text) {
                setState(() {
                  _isWriting = text.isNotEmpty;
                });
              },
              onSubmitted: (text) {},
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: _isWriting ? () {} : null,
          )
        ],
      ),
    );
  }
}
