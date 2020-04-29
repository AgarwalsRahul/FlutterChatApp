import 'package:chat_application/screens/profile_page.dart';
import 'package:chat_application/screens/recent_chats.dart';
import 'package:chat_application/screens/search_page.dart';
import 'package:flutter/material.dart';
// import 'package:gradient_app_bar/gradient_app_bar.dart';

class HomePage extends StatefulWidget {
  static String routeName = '/home';
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  double _height;
  double _width;
  _HomePageState() {
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
  }
  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    return Stack(
      children: <Widget>[
        // Container(
        //     height: _height,
        //     width: _width,
        //     child: Image(
        //       image: AssetImage('assets/images/background.png'),
        //       fit: BoxFit.cover,
        //     )),
        Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: Text(
              'Chats',
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
            elevation: 0.0,
            bottom: TabBar(
              indicatorColor: Colors.blue,
              indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(color: Colors.blue)),
              controller: _tabController,
              unselectedLabelColor: Theme.of(context).backgroundColor,
              tabs: <Widget>[
                Tab(
                  icon: Icon(
                    Icons.people_outline,
                    size: 30,
                  ),
                ),
                Tab(
                  icon: Icon(
                    Icons.chat_bubble_outline,
                    size: 30,
                  ),
                ),
                Tab(
                  icon: Icon(
                    Icons.person_outline,
                    size: 30,
                  ),
                )
              ],
            ),
          ),
          body: _tabBarPages(),
        ),
      ],
    );
  }

  Widget _tabBarPages() {
    return TabBarView(controller: _tabController, children: <Widget>[
      SearchPage(
        height: _height,
        width: _width,
      ),
      RecentChats(
        height: _height,
        width: _width,
      ),
      ProfilePage(
        height: _height,
        width: _width,
      ),
    ]);
  }
}
