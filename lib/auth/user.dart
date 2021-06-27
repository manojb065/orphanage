import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:orphanage/global/global.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UserProfile extends StatelessWidget {
  UserCredential usr = appDataGet("usr");
  late var db = appDataGet("db");

  GlobalKey<FormBuilderState> _formkey = new GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    // fetchData();
    return Scaffold(
      appBar: AppBar(
        title: Text("Delight to Server"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                ImagePicker()
                    .getImage(source: ImageSource.gallery)
                    .then((value) {
                  var path = FirebaseStorage.instance
                      .ref()
                      .child("Auser/profile/${appDataGet("usr").user.uid}")
                      .putFile(File(value!.path));
                  path.then((value) {
                    value.ref.getDownloadURL().then((value) {
                      appDataGet("usr").user.updatePhotoURL(value);
                    });
                  });
                });
              },
              child: Center(
                child: appDataGet("usr").user.photoURL == null
                    ? CircleAvatar(
                        radius: 50.0,
                        child: Icon(Icons.photo_camera),
                      )
                    : CircleAvatar(
                        radius: 50.0,
                        backgroundImage:
                            NetworkImage(appDataGet("usr").user.photoURL),
                      ),
              ),
            ),
            FormBuilder(
              key: _formkey,
              child: Column(
                children: [
                  FormBuilderTextField(
                    name: "username",
                    initialValue: usr.user!.displayName,
                    maxLength: 13,
                    onSubmitted: (val) {
                      usr.user!.updateDisplayName(val);
                      // saveUpdate();
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: InputDecoration(
                      labelText: "useranme *",
                      prefixIcon: Icon(Icons.account_box_outlined),
                      hintText: "user name",
                    ),
                    validator: FormBuilderValidators.compose([
                      (val) {
                        if (val!.contains(RegExp(r"[@#%]"))) {
                          return "should not contain special charcter";
                        }
                      },
                      FormBuilderValidators.required(context)
                    ]),
                  ),
                  FormBuilderTextField(
                    name: "email",
                    initialValue: usr.user!.email,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: "Email *",
                      prefixIcon: Icon(Icons.account_box_outlined),
                      hintText: "example@gmail.com",
                    ),
                  ),
                  FormBuilderTextField(
                    name: "address",
                    initialValue: appDataGet("loc"),
                    readOnly: true,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: "address",
                      prefixIcon: Icon(Icons.location_city),
                    ),
                  ),
                  FormBuilderTextField(
                    name: "phone",
                    initialValue: appDataGet("phone"),
                    maxLength: 10,
                    onSubmitted: (val) {
                      appDataGet("db").update({"phone": val});
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: InputDecoration(
                      labelText: "phone",
                      prefixIcon: Icon(Icons.account_box_outlined),
                      hintText: "xxx-xxx-xxxx",
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (val) {
                      if (val!.length != 10) {
                        return "enter valid number";
                      }
                    },
                  ),
                  ElevatedButton(
                      onPressed: () {
                        FirebaseAuth.instance.sendPasswordResetEmail(
                            email: usr.user!.email as String);
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text("Password reset email sent"),
                            content: Text("check your email inbox"),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  FirebaseAuth.instance.signOut();
                                  Navigator.of(ctx).popAndPushNamed("/");
                                },
                                child: Text("okay"),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Text("reset")),
                  ElevatedButton.icon(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.of(context).popAndPushNamed("/");
                      },
                      icon: Icon(Icons.send),
                      label: Text("Log out")),
                ],
              ),
              autovalidateMode: AutovalidateMode.disabled,
            ),
          ],
        ),
      ),
    );
  }
}
