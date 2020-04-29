import 'package:chat_application/providers/auth_provider.dart';
import 'package:flutter/material.dart';

class SnackBarService {
  BuildContext _buildContext;

  static SnackBarService instance = SnackBarService();

  set buildContext(BuildContext context){
    _buildContext = context;
  }
  
   void showSnackbarloginStatus(
      String message, AuthStatus status) {
    Scaffold.of(_buildContext).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w300,
          ),
        ),
        backgroundColor:
            (status == AuthStatus.Authenticated || status==AuthStatus.NotAuthenticated) ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      ),
    );
  }
}
