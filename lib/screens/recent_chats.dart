import 'package:chat_application/models/Conversation.dart';
import 'package:chat_application/models/message.dart';
import 'package:chat_application/providers/auth_provider.dart';
import 'package:chat_application/screens/conversation_page.dart';
import 'package:chat_application/services/db_service.dart';
import 'package:chat_application/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class RecentChats extends StatelessWidget {
  final double height;
  final double width;
  AuthProvider _auth;
  RecentChats({this.height, this.width});
  @override
  Widget build(BuildContext context) {
    return Container(
        // padding: EdgeInsets.all(20),
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
          child: Builder(builder: (ctx) {
            _auth = Provider.of<AuthProvider>(ctx);
            return _recentConversationListview();
          }),
        ));
  }

  Widget _recentConversationListview() {
    return StreamBuilder<List<Conversation>>(
        stream: DBService.instance.getUserConversations(_auth.user.uid),
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            snapshot.data.removeWhere((data)=>data.timestamp==null);
            return snapshot.data.length >= 0
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                        itemBuilder: (ctx, index) {
                          return ListTile(
                            onTap: () {
                              // print(snapshot.data[index].conversationID);
                              NavigationService.instance.pushToRoute(MaterialPageRoute(builder: (context){
                                return ConversationPage(
                                  conversationID: snapshot.data[index].conversationID,
                                  id: snapshot.data[index].id,
                                  image: snapshot.data[index].image,
                                  name: snapshot.data[index].name,
                                );
                              }));
                            },
                            title: Text(snapshot.data[index].name),
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(
                                    snapshot.data[index].image,
                                  ),
                                ),
                              ),
                            ),
                            subtitle: Text(
                              snapshot.data[index].type==MessageType.Text ?
                              snapshot.data[index].lastMessage: 'Attachment: Image'),
                            trailing: _trailingWidget(snapshot.data[index]),
                          );
                        },
                        itemCount: snapshot.data.length),
                  )
                : Align(
                    alignment: Alignment.center,
                    child: Text(
                      'No Conversations Yet!',
                      style: TextStyle(
                        color: Colors.white30,
                        fontSize: 15.0,
                      ),
                    ),
                  );
          } else {
            return SpinKitWanderingCubes(
              color: Colors.blue,
              size: 50.0,
            );
          }
        });
  }

  Widget _trailingWidget(Conversation data) {
    // var _timedifference = data.timestamp.toDate().difference(DateTime.now());
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text(
          'Last Message',
          style: TextStyle(fontSize: 15),
        ),
        Text(
          timeago.format(data.timestamp.toDate()),
          style: TextStyle(fontSize: 15),
        ),
      ],
    );
  }
}
