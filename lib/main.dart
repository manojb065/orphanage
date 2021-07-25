//@dart=2.9
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:orphanage/book/bookRequestList.dart';
import 'package:orphanage/cloth/clothRequestList.dart';
import 'package:orphanage/screenRoute.dart';
import './global/global.dart';
import './food/foodRequestList.dart';
import 'package:badges/badges.dart';
import 'package:focused_menu/focused_menu.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  runApp(MaterialApp(
    theme: ThemeData.dark(),
    initialRoute: "/log",
    onGenerateRoute: screenRoute.routeScreen,
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int fchange = 0, bchange = 0, cchange = 0;

  @override
  Widget build(BuildContext context) {
    Badge foodCount() {
      UserCredential usr = appDataGet("usr");
      FirebaseFirestore.instance
          .collection("foodrequest")
          .where("aname", isEqualTo: usr.user.displayName)
          .snapshots()
          .listen((event) {
        if (event.docChanges.length != fchange)
          setState(() {
            fchange = event.docChanges.length;
          });
      });

      return Badge(
        badgeContent: Text(fchange.toString()),
        child: Icon(
          Icons.food_bank,
        ),
      );
    }

    Badge bookCount() {
      UserCredential usr = appDataGet("usr");
      FirebaseFirestore.instance
          .collection("bookrequest")
          .where("aname", isEqualTo: usr.user.displayName)
          .snapshots()
          .listen((event) {
        if (event.docChanges.length != bchange)
          setState(() {
            bchange = event.docChanges.length;
          });
      });

      return Badge(
        badgeContent: Text(bchange.toString()),
        child: Icon(
          Icons.book,
        ),
      );
    }

    Badge clothCount() {
      UserCredential usr = appDataGet("usr");
      FirebaseFirestore.instance
          .collection("clothrequest")
          .where("aname", isEqualTo: usr.user.displayName)
          .snapshots()
          .listen((event) {
        if (event.docChanges.length != cchange)
          setState(() {
            cchange = event.docChanges.length;
          });
      });

      return Badge(
        badgeContent: Text(cchange.toString()),
        child: Icon(
          Icons.shopping_bag,
        ),
      );
    }

    final _TabPages = <Widget>[
      DonationList.listBuild(),
      ClothDonationList.listBuild(),
      BookDonationList.listBuild(),
      // Center(
      //   child: Icon(Icons.money),
      // ),
    ];
    final _Tabs = <Badge>[
      foodCount(),
      clothCount(),
      bookCount(),
      // Badge(
      //   badgeContent: Text("2"),
      //   child: Icon(Icons.money),
      // ),
    ];
    return DefaultTabController(
      length: _Tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Orphange"),
          actions: [
            IconButton(
                onPressed: () async {
                  UserCredential usr = appDataGet("usr");
                  var db = FirebaseDatabase.instance
                      .reference()
                      .child("Ashram/Ashraminfo")
                      .child(usr.user.displayName);
                  appDataSet("db", db);

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
