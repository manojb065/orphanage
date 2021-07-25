//@dart=2.9

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:orphanage/global/global.dart';
import 'package:intl/intl.dart';

class DonationList {
  static void _showDetail(
      BuildContext con, String name, String phone, String id) {
    Navigator.of(con).push(MaterialPageRoute(builder: (build) {
      return Scaffold(
        body: Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(60))),
          elevation: 20,
          shadowColor: Colors.transparent,
          child: Column(
            children: [
              Image.asset("assets/img/food.jpg"),
              ListTile(
                autofocus: true,
                title: Text(
                  name,
                  textAlign: TextAlign.center,
                ),
                subtitle: Text(
                  phone,
                  textAlign: TextAlign.center,
                ),
              ),
              ButtonBar(
                alignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      onPressed: () async {
                        print(id);
                        await FirebaseFirestore.instance
                            .collection("foodrequest")
                            .doc(id)
                            .update({"status": true});
                        Navigator.of(con).pop(true);
                      },
                      icon: Icon(Icons.thumb_up)),
                  IconButton(
                      onPressed: () async {
                        print(id);
                        await FirebaseFirestore.instance
                            .collection("foodrequest")
                            .doc(id)
                            .delete();
                        Navigator.of(con).pop(true);
                      },
                      icon: Icon(Icons.thumb_down)),
                ],
              ),
            ],
          ),
        ),
      );
    }));
  }

  static Widget topCard(
      BuildContext build, Map<String, dynamic> data, String id) {
    var d = DateTime.fromMicrosecondsSinceEpoch(
        data['time'].microsecondsSinceEpoch);

    String Date = DateFormat('yyyy-MM-dd').format(d);
    String Time = DateFormat("kk:mm").format(d);
    return GestureDetector(
      onTap: () => _showDetail(build, data["name"], data['phone'], id),
      child: Card(
        shadowColor: Colors.white24,
        elevation: 10,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(30))),
        child: ListTile(
          contentPadding: EdgeInsets.only(top: 10, bottom: 10, right: 20),
          // minVerticalPadding: 10,
          title: Text(
            "${data['name']}",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20),
          ),
          subtitle: Text(
            "${Date}",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20),
          ),
          trailing: data['status']
              ? Icon(
                  Icons.thumb_up,
                  color: Colors.green,
                )
              : CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.red,
                ),
        ),
      ),
    );
  }

  static Widget listBuild() {
    UserCredential usr = appDataGet("usr");
    final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance
        .collection("foodrequest")
        .where("aname", isEqualTo: usr.user.displayName)
        .snapshots();
    return StreamBuilder<QuerySnapshot>(
        stream: _usersStream,
        builder: (build, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(
              color: Colors.amber[700],
            );
          }
          ;

          List<Map<String, dynamic>> d =
              new List<Map<String, dynamic>>.empty(growable: true);
          List<String> id = new List<String>.empty(growable: true);

          snapshot.data.docs.forEach((element) {
            id.add(element.id);
            d.add(Map<String, dynamic>.from(element.data()));
          });
          return ListView.builder(
              itemCount: d.length,
              itemBuilder: (build, ind) {
                return topCard(build, d[ind], id[ind]);
              });
        });
  }
}
