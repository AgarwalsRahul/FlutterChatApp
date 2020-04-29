import 'dart:io';

import 'package:chat_application/models/user.dart';
import 'package:chat_application/screens/login_screen.dart';
import 'package:chat_application/services/cloud_storage_service.dart';
import 'package:chat_application/services/db_service.dart';
import 'package:chat_application/services/navigation_service.dart';
import 'package:chat_application/services/snackbar_service.dart';
import '../services/media_service.dart';
import 'package:flutter/material.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class RegistrationScreen extends StatefulWidget {
  static String routeName = "/register";
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  double _deviceHeight;
  double _deviceWidth;
  File _image;
  String _name;
  String _password;
  String _email;
  AuthProvider _auth;
  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Builder(builder: (BuildContext ctx) {
        SnackBarService.instance.buildContext = ctx;
        _auth = Provider.of<AuthProvider>(ctx);
        return Container(
          alignment: Alignment.center,
          child: _registerPageUI(),
        );
      }),
    );
  }

  Widget _registerPageUI() {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: _deviceWidth * 0.10),
        height: _deviceHeight * 0.75,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: [
            _heading(),
            _inputForm(),
            _registerButton(),
            _backToLogin(),
          ],
        ),
      ),
    );
  }

  Widget _heading() {
    return Container(
      alignment: Alignment.center,
      height: _deviceHeight * 0.12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Text(
            "Let's get going!",
            style: TextStyle(
              fontSize: 35,
              fontWeight: FontWeight.w700,
            ),
          ),
          FittedBox(
            fit: BoxFit.cover,
            child: Text(
              'Please enter your details.',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w200,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _inputForm() {
    return Container(
      height: _deviceHeight * 0.35,
      child: Form(
        key: _formKey,
        // onChanged: () {},
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            _imageSelector(),
            _nameTextField(),
            _emailTextField(),
            _passwordTextField(),
          ],
        ),
      ),
    );
  }

  Widget _imageSelector() {
    return Align(
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () async {
          File _imageFile = await MediaService.instance.getImage();
          setState(() {
            _image = _imageFile;
          });
        },
        child: Container(
          height: _deviceHeight * 0.12,
          width: _deviceHeight * 0.12,
          decoration: BoxDecoration(
              // color: Colors.transparent,
              borderRadius: BorderRadius.circular(500),
              image: DecorationImage(
                  image: _image == null
                      ? NetworkImage(
                          'https://cdn0.iconfinder.com/data/icons/occupation-002/64/programmer-programming-occupation-avatar-512.png')
                      : FileImage(
                          _image,
                        ),
                  fit: BoxFit.cover)),
        ),
      ),
    );
  }

  Widget _nameTextField() {
    return TextFormField(
      autocorrect: false,
      style: TextStyle(color: Colors.white),
      onSaved: (name) {
        setState(() {
          _name = name;
        });
      },
      validator: (email) {
        return email.length != 0 ? null : 'Please enter a name';
      },
      cursorColor: Colors.white,
      decoration: InputDecoration(
        hintText: 'Name',
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  Widget _emailTextField() {
    return TextFormField(
      autocorrect: false,
      style: TextStyle(color: Colors.white),
      onSaved: (email) {
        setState(() {
          _email = email;
        });
      },
      validator: (email) {
        return email.length != 0 && email.contains('@')
            ? null
            : 'Please enter a valid email';
      },
      cursorColor: Colors.white,
      decoration: InputDecoration(
        hintText: 'Email-Adress',
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  Widget _passwordTextField() {
    return TextFormField(
      autocorrect: false,
      obscureText: true,
      style: TextStyle(color: Colors.white),
      onSaved: (password) {
        setState(() {
          _password = password;
        });
      },
      validator: (email) {
        return email.length != 0 ? null : 'Please enter a password';
      },
      cursorColor: Colors.white,
      decoration: InputDecoration(
        hintText: 'Password',
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  Widget _registerButton() {
    return _auth.status == AuthStatus.Authenticating
        ? Align(
            alignment: Alignment.center,
            child: CircularProgressIndicator(),
          )
        : Container(
            height: _deviceHeight * 0.06,
            width: _deviceWidth,
            child: MaterialButton(
                onPressed: () {
                  if (_formKey.currentState.validate() && _image != null) {
                    FocusScope.of(context).unfocus();
                    _formKey.currentState.save();

                    _auth.createUserWithEmailAndPassword(_email, _password,
                        (String uid) async {
                      var result = await CloudStorageService.instance
                          .uploadImage(_image, uid);
                      var imageUrl = await result.ref.getDownloadURL();
                      final user = User(
                        email: _email,
                        id: uid,
                        name: _name,
                        imageUrl: imageUrl,
                      );
                      await DBService.instance.createUserInDatabase(user);
                    });

                    // NavigationService.instance.pushReplacement(LoginScreen.routeName);

                  }
                },
                color: Colors.blue,
                child: Text('REGISTER',
                    style: TextStyle(
                        fontSize: 18.0, fontWeight: FontWeight.w700))),
          );
  }

  Widget _backToLogin() {
    return GestureDetector(
      onTap: () {
        NavigationService.instance.pushReplacement(LoginScreen.routeName);
      },
      child: Container(
        alignment: Alignment.center,
        height: _deviceHeight * 0.10,
        width: _deviceWidth,
        child: Icon(
          Icons.arrow_back,
          size: 40,
        ),
      ),
    );
  }
}
