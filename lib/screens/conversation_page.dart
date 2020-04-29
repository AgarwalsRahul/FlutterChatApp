import 'dart:async';

import 'package:chat_application/models/Conversation.dart';
import 'package:chat_application/models/message.dart';
import 'package:chat_application/providers/auth_provider.dart';
import 'package:chat_application/services/cloud_storage_service.dart';
import 'package:chat_application/services/db_service.dart';
import 'package:chat_application/services/media_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class ConversationPage extends StatefulWidget {
  final String name;
  final String id;
  final String image;
  final String conversationID;

  const ConversationPage({
    this.name,
    this.id,
    this.image,
    this.conversationID,
  });

  @override
  _ConversationPageState createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  double _deviceHeight;
  double _deviceWidth;
  ScrollController _scrollController = ScrollController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _messageText = '';
  AuthProvider _auth;
  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    _auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.name),
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: <Widget>[
          Container(
              height: _deviceHeight,
              decoration: BoxDecoration(
                color: Theme.of(context).backgroundColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25.0),
                  topRight: Radius.circular(25.0),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25.0),
                  topRight: Radius.circular(25.0),
                ),
                child: Container(),
              )),
          Column(
            children: <Widget>[
              Expanded(
                child: Container(
                  height: _deviceHeight,
                  decoration: BoxDecoration(
                    color: Theme.of(context).backgroundColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25.0),
                      topRight: Radius.circular(25.0),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25.0),
                      topRight: Radius.circular(25.0),
                    ),
                    child: _conversationPageBody(),
                  ),
                ),
              ),
              messageField(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _conversationPageBody() {
    return _conversationListView();
  }

  Widget _conversationListView() {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: StreamBuilder<Conversations>(
          stream: DBService.instance.getConversations(widget.conversationID),
          builder: (context, snapshot) {
            Timer(
                Duration(milliseconds: 50),
                () => {
                      if (_scrollController.hasClients)
                        _scrollController
                            .jumpTo(_scrollController.position.maxScrollExtent)
                    });
            var data = snapshot.data;
            if (data != null) {
              if (data.messages.length != 0) {
                return ListView.builder(
                    controller: _scrollController,
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                    itemCount: data.messages.length,
                    itemBuilder: (ctx, i) {
                      bool isMe = _auth.user.uid == data.messages[i].senderID;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: isMe
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: <Widget>[
                            isMe ? Container() : _imagebuilder(),
                            SizedBox(
                              width: _deviceWidth * 0.02,
                            ),
                            data.messages[i].type == MessageType.Text
                                ? _textMessageContainer(
                                    data.messages[i].content,
                                    isMe,
                                    data.messages[i].timestamp,
                                  )
                                : _imageMessageContainer(
                                    data.messages[i].content,
                                    isMe,
                                    data.messages[i].timestamp,
                                  ),
                          ],
                        ),
                      );
                    });
              } else {
                return Align(
                    alignment: Alignment.center,
                    child: Text("Let's start a conversation!"));
              }
            } else {
              return SpinKitWanderingCubes(
                color: Colors.blue,
                size: 50.0,
              );
            }
          }),
    );
  }

  Widget _textMessageContainer(String message, bool isMe, Timestamp timestamp) {
    List<Color> _colors = isMe
        ? [Colors.blue, Color.fromRGBO(42, 117, 188, 1)]
        : [Color.fromRGBO(40, 39, 39, 1), Color.fromRGBO(30, 30, 30, 1)];
    return Container(
      height: _deviceHeight * 0.08 + (message.length / 20 * 5.0),
      width: _deviceWidth * 0.75,
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        gradient: LinearGradient(
          colors: _colors,
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          stops: [
            0.30,
            0.70,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Text(message),
          Text(timeago.format(timestamp.toDate()),
              style: TextStyle(color: Colors.white54, fontSize: 15.0)),
        ],
      ),
    );
  }

  Widget _imagebuilder() {
    var _imageRadius = _deviceHeight * 0.05;
    return Container(
      width: _imageRadius,
      height: _imageRadius,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(500),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage(
            widget.image,
          ),
        ),
      ),
    );
  }

  Widget messageField(BuildContext context) {
    return Container(
      height: _deviceHeight * 0.08,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: Color.fromRGBO(23, 23, 23, 1),
      ),
      margin: EdgeInsets.only(
          left: _deviceWidth * 0.02,
          right: _deviceWidth * 0.02,
          bottom: _deviceHeight * 0.01,
          top: _deviceHeight * 0.02),
      child: Form(
        key: _formKey,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _messageTextField(),
            _sendMessageButton(),
            _imageButton()
          ],
        ),
      ),
    );
  }

  Widget _messageTextField() {
    return SizedBox(
      width: _deviceWidth * 0.55,
      child: TextFormField(
        autocorrect: false,
        validator: (input) {
          if (input.length == 0) {
            return 'Please enter a message';
          }
          return null;
        },
        decoration: InputDecoration(
          hintText: 'Type a message',
          border: InputBorder.none,
        ),
        onChanged: (_) {
          _formKey.currentState.save();
        },
        onSaved: (input) {
          setState(() {
            _messageText = input;
          });
        },
        cursorColor: Colors.white,
      ),
    );
  }

  Widget _sendMessageButton() {
    return Container(
      height: _deviceHeight * 0.05,
      width: _deviceHeight * 0.05,
      child: IconButton(
          icon: Icon(Icons.send),
          onPressed: () {
            if (_formKey.currentState.validate()) {
              _formKey.currentState.save();
              DBService.instance.sendMessage(
                  widget.conversationID,
                  Message(
                      content: _messageText,
                      senderID: _auth.user.uid,
                      timestamp: Timestamp.now(),
                      type: MessageType.Text));
              _formKey.currentState.reset();
            }
          }),
    );
  }

  Widget _imageButton() {
    return Container(
      height: _deviceHeight * 0.05,
      width: _deviceHeight * 0.05,
      child: FloatingActionButton(
          onPressed: () async {
            var _image = await MediaService.instance.getImage();
            if (_image != null) {
              var _result = await CloudStorageService.instance
                  .uploadMediaImage(_image, _auth.user.uid);
              String _imageUrl = await _result.ref.getDownloadURL();
              DBService.instance.sendMessage(
                  widget.conversationID,
                  Message(
                    content: _imageUrl,
                    senderID: _auth.user.uid,
                    timestamp: Timestamp.now(),
                    type: MessageType.Image,
                  ));
            }
          },
          child: Icon(
            Icons.camera_enhance,
          )),
    );
  }

  Widget _imageMessageContainer(
      String imageUrl, bool isMe, Timestamp timestamp) {
    List<Color> _colors = isMe
        ? [Colors.blue, Color.fromRGBO(42, 117, 188, 1)]
        : [Color.fromRGBO(40, 39, 39, 1), Color.fromRGBO(30, 30, 30, 1)];
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        gradient: LinearGradient(
          colors: _colors,
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          stops: [
            0.30,
            0.70,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Container(
            height: _deviceHeight * 0.30,
            width: _deviceWidth * 0.40,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                )),
          ),
          Text(timeago.format(timestamp.toDate()),
              style: TextStyle(color: Colors.white54, fontSize: 15.0)),
        ],
      ),
    );
  }
}
