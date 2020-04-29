import 'package:chat_application/screens/homepage.dart';
import 'package:chat_application/screens/login_screen.dart';
import 'package:chat_application/services/navigation_service.dart';
import 'package:chat_application/services/snackbar_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/db_service.dart';

enum AuthStatus {
  Authenticating,
  NotAuthenticated,
  Authenticated,
  Error,
  UserNotFound,
}

class AuthProvider extends ChangeNotifier {
  FirebaseUser user;
  FirebaseAuth _auth;
  AuthStatus status;

  AuthProvider() {
    _auth = FirebaseAuth.instance;
    _checkCurrentUserAuthenticated();
  }

  Future<void> _tryAutoLogin() async {
    if (user != null) {
      await DBService.instance.updateLastSeen(user.uid);
      return NavigationService.instance.pushReplacement(HomePage.routeName);
    }
  }

  void _checkCurrentUserAuthenticated() async {
    user = await _auth.currentUser();
    if (user != null) {
      notifyListeners();
      await _tryAutoLogin();
    }
  }

  Future<void> loginWithEmailAndPassword(String email, String password) async {
    status = AuthStatus.Authenticating;
    notifyListeners();
    try {
      AuthResult _result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      user = _result.user;
      status = AuthStatus.Authenticated;
      SnackBarService.instance
          .showSnackbarloginStatus('Welcome, ${user.email}', status);
      await DBService.instance.updateLastSeen(user.uid);
      NavigationService.instance.pushReplacement(HomePage.routeName);
    } catch (e) {
      status = AuthStatus.Error;
      SnackBarService.instance.showSnackbarloginStatus('LogIn Failed!', status);
    }
    notifyListeners();
  }

  Future<void> createUserWithEmailAndPassword(
    String email,
    String password,
    Future<void> onSuccess(String uid),
  ) async {
    status = AuthStatus.Authenticating;
    notifyListeners();
    try {
      AuthResult result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      user = result.user;
      status = AuthStatus.Authenticated;
      await onSuccess(user.uid);
      SnackBarService.instance
          .showSnackbarloginStatus('User Registered Successfully', status);
      await DBService.instance.updateLastSeen(user.uid);
      NavigationService.instance.pushReplacement(HomePage.routeName);
    } catch (e) {
      status = AuthStatus.Error;
      user = null;
      SnackBarService.instance
          .showSnackbarloginStatus('User Not Registered!', status);
    }
    notifyListeners();
  }

  Future<void> logoutUser(Future<void> onSuccess()) async {
    try {
      await _auth.signOut();
      // user=null;
      status = AuthStatus.NotAuthenticated;
      await onSuccess();
      SnackBarService.instance
          .showSnackbarloginStatus('Logged out Successfully', status);
      NavigationService.instance.pushReplacement(LoginScreen.routeName);
      // SnackBarService.instance.showSnackbarloginStatus('Logged out Successfully', status);
    } catch (e) {
      status = AuthStatus.Error;
      SnackBarService.instance
          .showSnackbarloginStatus('Error in logout', status);
    }
    notifyListeners();
  }
}
