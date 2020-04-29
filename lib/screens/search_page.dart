import 'package:chat_application/models/contact.dart';
import 'package:chat_application/providers/auth_provider.dart';
import 'package:chat_application/screens/conversation_page.dart';
import 'package:chat_application/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../services/db_service.dart';
import 'package:timeago/timeago.dart' as timeago;

class SearchPage extends StatefulWidget {
  final double width;
  final double height;

  SearchPage({this.width, this.height});
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _searchText;
  TextEditingController _controller = TextEditingController();
  _SearchPageState() {
    _searchText = '';
  }
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        height: this.widget.height,
        width: this.widget.width,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              _searchBar(),
              _userListView(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _searchBar() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: this.widget.height * 0.02),
      height: this.widget.height * 0.08,
      width: this.widget.width,
      child: TextField(
        controller: _controller,
        autocorrect: false,
        onChanged: (input) {
          setState(() {
            _searchText = input;
          });
        },
        onSubmitted: (input) {
          setState(() {
            _searchText = input;
          });
        },
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.search,
            color: Colors.white,
          ),
          labelText: 'Search',
          labelStyle: TextStyle(color: Colors.white),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _userListView() {
    return SingleChildScrollView(
      child: StreamBuilder<List<Contact>>(
          stream: DBService.instance.getUsers(_searchText),
          builder: (context, snapshot) {
            var _userData = snapshot.data;
            var _auth = Provider.of<AuthProvider>(context);
            if (_userData != null) {
              _userData.removeWhere((contact) => contact.id == _auth.user.uid);
            }
            return snapshot.hasData
                ? Container(
                    height: this.widget.height * 0.74,
                    width: this.widget.width,
                    child: ListView.builder(
                        padding: EdgeInsets.symmetric(
                            vertical: this.widget.height * 0.02),
                        itemCount: _userData.length,
                        itemBuilder: (ctx, index) {
                          return ListTile(
                            onTap: () {
                              DBService.instance.createOrGetConversations(
                                  _auth.user.uid, _userData[index].id,
                                  (String _conversationID) {
                                NavigationService.instance.pushToRoute(
                                    MaterialPageRoute(builder: (ctx) {
                                  return ConversationPage(
                                    conversationID: _conversationID,
                                    id: _userData[index].id,
                                    image: _userData[index].image,
                                    name: _userData[index].name,
                                  );
                                }));
                              });
                            },
                            title: Text(_userData[index].name,
                                style: TextStyle(color: Colors.white)),
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(
                                    _userData[index].image,
                                  ),
                                ),
                              ),
                            ),
                            trailing: _trailingWidget(_userData[index]),
                          );
                        }),
                  )
                : Align(
                    child: SpinKitWanderingCubes(
                      color: Colors.blue,
                      size: 50.0,
                    ),
                  );
          }),
    );
  }

  Widget _trailingWidget(Contact data) {
    String _activeStatus = data.lastSeen
            .toDate()
            .isBefore(DateTime.now().subtract(Duration(hours: 1)))
        ? 'LastSeen'
        : 'Active Now';
    Widget _lastSeenTimeStamp = _activeStatus == "Active Now"
        ? Container(
            height: 12,
            width: 12,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(100),
            ),
          )
        : Text(
            timeago.format(data.lastSeen.toDate()),
            style: TextStyle(fontSize: 15),
          );
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text(
          _activeStatus,
          style: TextStyle(fontSize: 15),
        ),
        _lastSeenTimeStamp
      ],
    );
  }
}
