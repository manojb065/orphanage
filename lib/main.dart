//@dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:orphanage/screenRoute.dart';
import './global/global.dart';
import './food/foodRequestList.dart';
import 'package:badges/badges.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  runApp(MaterialApp(
    initialRoute: "/log",
    onGenerateRoute: screenRoute.routeScreen,
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _counter = 0;
  int change = 0;

  @override
  Widget build(BuildContext context) {
    Badge foodCount() {
      UserCredential usr = appDataGet("usr");
      FirebaseFirestore.instance
          .collection("foodrequest")
          .where("aname", isEqualTo: usr.user.displayName)
          .snapshots()
          .listen((event) {
        if (event.docChanges.last.type == DocumentChangeType.added &&
            _counter != change) {
          setState(() {
            change = event.docChanges.length;
            _counter = change;
          });
        }
      });

      return Badge(
        badgeContent: Text(change.toString()),
        child: Icon(
          Icons.food_bank,
        ),
      );
    }

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
    final _Tabs = <Badge>[
      foodCount(),
      Badge(
        badgeContent: Text("2"),
        child: Icon(Icons.shopping_bag),
      ),
      Badge(
        badgeContent: Text("2"),
        child: Icon(Icons.book),
      ),
      Badge(
        badgeContent: Text("2"),
        child: Icon(Icons.money),
      ),
    ];
    return DefaultTabController(
      length: _Tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text("mini me"),
          actions: [
            IconButton(
                onPressed: () async {
                  var db = FirebaseDatabase.instance
                      .reference()
                      .child("Ashram/Ashraminfo")
                      .child("Ashram1");
                  appDataSet("db", db);
                  print(appDataGet("db") == null);

                  db.get().then((value) {
                    var d = Map.from(value.value);

                    appDataSet("phone", d["phone"].toString());
                    appDataSet("loc", d["location"]["loaction"]);
                  });
                  // await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushNamed("/profile");
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
