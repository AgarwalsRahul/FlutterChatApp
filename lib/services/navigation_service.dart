import 'package:flutter/material.dart';
class NavigationService {
  GlobalKey<NavigatorState> navigatorKey=GlobalKey<NavigatorState>();

  static NavigationService instance = NavigationService();

  Future<dynamic> pushReplacement(String routeName){
    return navigatorKey.currentState.pushReplacementNamed(routeName);
  }
  
  Future<dynamic> pushNavigation(String routeName){
    return navigatorKey.currentState.pushNamed(routeName);
  }
  
  Future<dynamic> pushToRoute(MaterialPageRoute _route){
    return navigatorKey.currentState.push(_route);
  }

  bool backNavigation(){
    return navigatorKey.currentState.pop();
  }
}