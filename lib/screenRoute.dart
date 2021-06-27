import 'package:firebase_database/firebase_database.dart';
import 'package:orphanage/auth/user.dart';

import './auth/login.dart';
import './auth/register.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'package:firebase_auth/firebase_auth.dart';

class screenRoute {
  static Route<dynamic> routeScreen(RouteSettings set) {
    var arg = set.arguments;

    // if (set.name == "/home") {
    //   return MaterialPageRoute(builder: (build) => Home());
    // }
    switch (set.name) {
      case "/home":
        return MaterialPageRoute(builder: (build) => Home());
      case "/reg":
        return MaterialPageRoute(builder: (_) => Signup());
      case "/profile":
        return MaterialPageRoute(builder: (_) => UserProfile());
      default:
        return MaterialPageRoute(builder: (build) => Login());
    }
  }

  static Route<dynamic> _error() {
    return MaterialPageRoute(
        builder: (builder) => Scaffold(
              body: Text("page not found"),
            ));
  }
}
