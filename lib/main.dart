
import 'package:chat_application/screens/homepage.dart';
import 'package:chat_application/screens/login_screen.dart';
import 'package:chat_application/screens/registration_screen.dart';
import 'package:chat_application/services/navigation_service.dart';
import 'package:flutter/material.dart';
import './providers/auth_provider.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: AuthProvider(),
      child: MaterialApp(
        navigatorKey: NavigationService.instance.navigatorKey,
        title: 'Chat App',
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: Color.fromRGBO(47, 117, 188, 1),
          backgroundColor: Color.fromRGBO(15, 15, 15, 1),
          accentColor: Color.fromRGBO(64, 117, 188, 1),
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: LoginScreen.routeName,
        routes:{
          LoginScreen.routeName:(ctx)=>LoginScreen(),
          RegistrationScreen.routeName:(ctx)=>RegistrationScreen(),
          HomePage.routeName:(ctx)=>HomePage(),
        } ,
      ),
    );
  }
}
