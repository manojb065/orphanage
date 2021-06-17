//@dart=2.9
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:orphanage/screenRoute.dart';
import './global/global.dart';
import './food/foodRequestList.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    initialRoute: "/log",
    onGenerateRoute: screenRoute.routeScreen,
  ));
}

class Home extends StatelessWidget {
  int _counter = 0;
  // UserCredential usr = appDataGet("usrinfo");
  @override
  Widget build(BuildContext context) {
    final _TabPages = <Widget>[
      DonationList.listBuild(),
      Center(
        child: Icon(Icons.shopping_bag),
      ),
      Center(
          child: Icon(
        Icons.book,
      )),
      Center(
        child: Icon(Icons.money),
      ),
    ];
    final _Tabs = <Tab>[
      Tab(
        icon: Icon(Icons.food_bank),
        text: "food",
      ),
      Tab(
        icon: Icon(Icons.shopping_bag),
        text: "cloth",
      ),
      Tab(
        icon: Icon(Icons.book),
        text: "food",
      ),
      Tab(
        icon: Icon(Icons.money),
        text: "food",
      )
    ];
    return DefaultTabController(
      length: _Tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text("mini me"),
          actions: [
            IconButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).popAndPushNamed("/log");
                },
                icon: Icon(
                  Icons.person,
                  color: Colors.black,
                ))
          ],
          bottom: TabBar(
            tabs: _Tabs,
          ),
        ),
        body: TabBarView(
          children: _TabPages,
        ),
      ),
    );
  }
}
