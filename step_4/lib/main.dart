// Copyright 2016, the Flutter project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:math' show Random;

import 'package:flutter/material.dart';

void main() {
  runApp(new MaterialApp(
    title: "Firechat",
    theme: new ThemeData(
      primarySwatch: Colors.purple,
      accentColor: Colors.orangeAccent[400]
    ),
    home: new ChatScreen()
  ));
}

class ChatScreen extends StatefulWidget {
  @override
  State createState() => new ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  String _name = "Guest${new Random().nextInt(1000)}";
  Color _color = Colors.accents[new Random().nextInt(Colors.accents.length)][700];
  List<ChatMessage> _messages = <ChatMessage>[];
  InputValue _currentMessage = InputValue.empty;

  @override
  void dispose() {
    for (ChatMessage message in _messages)
      message.animationController.dispose();
    super.dispose();
  }

  void _handleMessageChanged(InputValue value) {
    setState(() {
      _currentMessage = value;
    });
  }

  void _handleMessageAdded(InputValue value) {
    setState(() {
      _currentMessage = InputValue.empty;
    });
    _addMessage(name: _name, color: _color, text: value.text);
  }

  void _addMessage({ String name, Color color, String text }) {
    AnimationController animationController = new AnimationController(
      duration: new Duration(milliseconds: 700)
    );
    ChatUser sender = new ChatUser(name: name, color: color);
    ChatMessage message = new ChatMessage(
      sender: sender,
      text: text,
      animationController: animationController
    );
    setState(() {
      _messages.add(message);
    });
    animationController.forward();
  }

  bool get _isComposing => _currentMessage.text.length > 0;

  Widget _buildTextComposer() {
    ThemeData themeData = Theme.of(context);
    return new Row(
      children: <Widget>[
        new Flexible(
          child: new Input(
            value: _currentMessage,
            hintText: 'Enter message',
            onSubmitted: _handleMessageAdded,
            onChanged: _handleMessageChanged
          )
        ),
        new Container(
          margin: new EdgeInsets.symmetric(horizontal: 4.0),
          child: new IconButton(
            icon: new Icon(Icons.send),
            onPressed: _isComposing ? () => _handleMessageAdded(_currentMessage) : null,
            color: themeData.accentColor
          )
        )
      ]
    );
  }

  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Chatting as $_name")
      ),
      body: new Column(
        children: <Widget>[
          new Flexible(
            child: new Block(
              padding: new EdgeInsets.symmetric(horizontal: 8.0),
              scrollAnchor: ViewportAnchor.end,
              children: _messages.map((m) => new ChatMessageListItem(m)).toList()
            )
          ),
          _buildTextComposer(),
        ]
      )
    );
  }
}

class ChatUser {
  ChatUser({ this.name, this.color });
  final String name;
  final Color color;
}

class ChatMessage {
  ChatMessage({ this.sender, this.text, this.animationController });
  final ChatUser sender;
  final String text;
  final AnimationController animationController;
}

class ChatMessageListItem extends StatelessWidget {
  ChatMessageListItem(this.message);

  final ChatMessage message;

  Widget build(BuildContext context) {
    return new SizeTransition(
      sizeFactor: new CurvedAnimation(
        parent: message.animationController,
        curve: Curves.easeOut
      ),
      axisAlignment: 0.0,
      child: new ListItem(
        dense: true,
        leading: new CircleAvatar(
          child: new Text(message.sender.name[0]),
          backgroundColor: message.sender.color
        ),
        title: new Text(message.sender.name),
        subtitle: new Text(message.text)
      )
    );
  }
}
