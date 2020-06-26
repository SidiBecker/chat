import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TextComposer extends StatefulWidget {
  TextComposer(this.sendMessage);

  Function({String text, PickedFile img}) sendMessage;

  @override
  _TextComposerState createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {
  bool _isWriting = false;
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 7.0),
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.photo_camera),
            onPressed: () async {
              ImagePicker imagePicker = ImagePicker();
              PickedFile imgFile = await imagePicker.getImage(source: ImageSource.camera);
              if(imgFile == null) return;

              widget.sendMessage(img: imgFile);
            },
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
              onSubmitted: (value) {
                widget.sendMessage(text: value);
                reset();
              },
              controller: _controller,
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: _isWriting
                ? () {
                    widget.sendMessage(text: _controller.text);
                    reset();
                  }
                : null,
          )
        ],
      ),
    );
  }

  reset() {
    setState(() {
      _controller.clear();
      _isWriting = false;
    });
  }
}
