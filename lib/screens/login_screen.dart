import 'package:chat_application/screens/registration_screen.dart';
import 'package:chat_application/services/navigation_service.dart';
import 'package:chat_application/services/snackbar_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  static String routeName = "/login";
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  double _deviceHeight;
  double _deviceWidth;
  String _email;
  String _password;
  AuthProvider _auth;

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Widget _loginPageUI() {
    return Builder(builder: (BuildContext _context) {
      _auth = Provider.of<AuthProvider>(_context);
      return Container(
        height: _deviceHeight * 0.60,
        padding: EdgeInsets.symmetric(horizontal: _deviceWidth * 0.10),
        // color: Colors.red,
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            _heading(),
            _inputForm(),
            _loginButton(),
            _registerButton(),
          ],
        ),
      );
    });
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
            'Welcome back!',
            style: TextStyle(
              fontSize: 35,
              fontWeight: FontWeight.w700,
            ),
          ),
          FittedBox(
            fit: BoxFit.cover,
            child: Text(
              'Please login to your account',
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
      height: _deviceHeight * 0.20,
      child: Form(
        key: _formKey,
        // onChanged: () {},
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            _emailTextField(),
            _passwordTextField(),
          ],
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
        hintText: 'Email Address',
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
      validator: (password) {
        return password.length != 0 ? null : 'Please enter a password';
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

  Widget _loginButton() {
    return _auth.status == AuthStatus.Authenticating
        ? Align(
            alignment: Alignment.center,
            child: CircularProgressIndicator(),
          )
        : Container(
            height: _deviceHeight * 0.06,
            width: _deviceWidth,
            child: MaterialButton(
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    FocusScope.of(context).unfocus();
                    _formKey.currentState.save();
                    await _auth.loginWithEmailAndPassword(_email, _password);
                  }
                },
                color: Colors.blue,
                child: Text('LOGIN',
                    style: TextStyle(
                        fontSize: 18.0, fontWeight: FontWeight.w700))),
          );
  }

  Widget _registerButton() {
    return GestureDetector(
      onTap: _auth.status == AuthStatus.Authenticating
          ? null
          : () {
              NavigationService.instance
                  .pushReplacement(RegistrationScreen.routeName);
            },
      child: Container(
        alignment: Alignment.center,
        child: Text(
          "REGISTER",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white60,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Builder(
        builder: (_context) {
          SnackBarService.instance.buildContext = _context;
          return Align(alignment: Alignment.center, child: _loginPageUI());
        },
      ),
    );
  }
}
