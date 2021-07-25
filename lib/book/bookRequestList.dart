//@dart=2.9
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:orphanage/global/global.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:slimy_card/slimy_card.dart';
import 'package:intl/intl.dart';

class BookDonationList {
  static Widget topCard(
      BuildContext build, Map<String, dynamic> data, String id) {
    var d = DateTime.fromMicrosecondsSinceEpoch(
        data['time'].microsecondsSinceEpoch);

    String Date = DateFormat('yyyy-MM-dd').format(d);

    return Padding(
      padding: EdgeInsetsDirectional.only(top: 5),
      child: SlimyCard(
        color: data["status"] ? Colors.green : Colors.red,
        width: MediaQuery.of(build).size.width - 30,
        topCardHeight: 200,
        bottomCardHeight: 100,
        borderRadius: 20,
        topCardWidget: Column(
          children: [
            Text(
              "${data['name']}",
              style: TextStyle(fontSize: 20),
            ),
            Text(
              "${data['phone']}",
              style: TextStyle(fontSize: 20),
            ),
            Text(
              "$Date",
              style: TextStyle(fontSize: 20),
            ),
            Text(
              "${data['address']}",
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
        bottomCardWidget: ButtonBar(
          alignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection("bookrequest")
                      .doc(id)
                      .update({"status": true});
                },
                icon: Icon(Icons.thumb_up)),
            IconButton(
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection("bookrequest")
                      .doc(id)
                      .delete();
                },
                icon: Icon(Icons.thumb_down)),
          ],
        ),
        slimeEnabled: true,
      ),
    );
  }

  static Widget listBuild() {
    UserCredential usr = appDataGet("usr");
    print(usr.user.displayName);
    final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance
        .collection("bookrequest")
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
            // print(element.data().runtimeType);
          });
          // print(snapshot.data.docs.runtimeType);
          return ListView.builder(
              itemCount: d.length,
              itemBuilder: (build, ind) {
                return topCard(build, d[ind], id[ind]);
              });
        });
  }
}
