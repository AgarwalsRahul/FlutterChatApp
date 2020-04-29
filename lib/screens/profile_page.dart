import 'package:chat_application/models/contact.dart';
import 'package:chat_application/services/snackbar_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/db_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ProfilePage extends StatelessWidget {
  final double height;
  final double width;
  ProfilePage({this.height, this.width});
  @override
  Widget build(BuildContext context) {
    return Container(
      // set with mediaQuery
      margin: EdgeInsets.only(top: 20.0),
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
        child: _profilePageUI(),
      ),
    );
  }

  Widget _profilePageUI() {
    return Builder(builder: (BuildContext ctx) {
      var _auth = Provider.of<AuthProvider>(ctx);
      SnackBarService.instance.buildContext=ctx;
      return _auth.user.uid!=null ? StreamBuilder<Contact>(
          stream: DBService.instance.getUserData(_auth.user.uid),
          builder: (BuildContext ctx, snapshot) {
            return snapshot.hasData ? Align(
              alignment: Alignment.center,
              child: SizedBox(
                height: height * 0.50,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    _userImage(snapshot.data.image),
                    _userName(snapshot.data.name),
                    _userEmail(snapshot.data.email),
                    _logOutButton(_auth),
                  ],
                ),
              ),
            ) : SpinKitWanderingCubes(
              color: Colors.blue,
              size: 50.0,
            );
          }):SpinKitWanderingCubes(
              color: Colors.blue,
              size: 50.0,
            );
    });
  }

  Widget _userImage(String _image) {
    return Container(
      height: height * 0.20,
      width: height * 0.20,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height * 0.20),
        image: DecorationImage(
          image: NetworkImage(_image),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _userName(name) {
    return Container(
      height: height * 0.05,
      width: width,
      child: Text(
        name,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 30,
        ),
      ),
    );
  }

  Widget _userEmail(email) {
    return Container(
      height: height * 0.03,
      width: width,
      child: Text(
        email,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white24,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _logOutButton(AuthProvider auth) {
    return Container(
        height: height * 0.06,
        width: width * 0.80,
        child: MaterialButton(
          onPressed: () {
            auth.logoutUser(()async{
              await DBService.instance.updateLastSeen(auth.user.uid);
            });
          },
          color: Colors.red,
          child: Text(
            'LOGOUT',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ));
  }
}
