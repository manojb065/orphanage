import 'package:firebase_database/firebase_database.dart';

import './auth/login.dart';
import './auth/register.dart';
import 'package:flutter/material.dart';
import 'main.dart';
import 'package:firebase_auth/firebase_auth.dart';

class screenRoute {
  static Route<dynamic> routeScreen(RouteSettings set) {
    var arg = set.arguments;
    print(set.name);
    FirebaseAuth usr = FirebaseAuth.instance;
    // UserCredential usr =  FirebaseAuth.instance.getRedirectResult();
    // print("entered");
    if (usr.currentUser != null) {
      print(usr.currentUser!.metadata);
      print(usr.tenantId);
    }

    if (set.name == "/home") {
      return MaterialPageRoute(builder: (build) => Home());
    }
    switch (set.name) {
      case "/reg":
        return MaterialPageRoute(builder: (_) => Signup());
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
