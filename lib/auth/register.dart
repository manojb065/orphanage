import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import '../screenRoute.dart';
import 'package:geocoding/geocoding.dart';

class Signup extends StatefulWidget {
  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  GlobalKey<FormBuilderState> _formkey = new GlobalKey<FormBuilderState>();
  String err = "successfully created account";
  bool _showPassword = true;

  void _sigup(Map<String, dynamic> data) async {
    try {
      UserCredential usr = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: data['email'], password: data['password']);

      usr.user!.updateDisplayName(data['aname']);
      // usr.additionalUserInfo!.profile!.addAll({"ashram": true});
      print(usr.additionalUserInfo!.profile);
      FirebaseFirestore.instance
          .collection("AshramUser")
          .doc(usr.user!.uid)
          .set({"name": data["aname"], "uid": usr.user!.uid});
      data.remove('password');
      data.remove("email");
      String loc = data["location"];
      List<Location> locations = await locationFromAddress(loc);

      data.update(
          "location",
          (value) => {
                "lat": locations[0].latitude,
                "long": locations[0].longitude,
                "location": loc
              });
      await FirebaseDatabase.instance
          .reference()
          .child("Ashram/Ashraminfo")
          .child(data['aname'])
          .set(data);
      Navigator.of(context).popAndPushNamed("/home");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    } catch (e) {
      err = e.toString();
      print(err);
    }
  }

  void toggle() {
    setState(() {
      _showPassword = !_showPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      onGenerateRoute: screenRoute.routeScreen,
      home: Scaffold(
        appBar: AppBar(
          title: Text("Orphange"),
        ),
        body: Stack(children: [
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Colors.black, Colors.blue],
                    end: Alignment.topCenter,
                    begin: Alignment.bottomCenter)),
          ),
          SingleChildScrollView(
            child: FormBuilder(
              key: _formkey,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FormBuilderTextField(
                      name: "aname",
                      keyboardType: TextInputType.name,
                      maxLength: 13,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        enabled: true,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(60)),
                        labelText: "Orphanage Name *",
                        prefixIcon: Icon(Icons.account_box_outlined),
                        hintText: "Orphanage name",
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
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FormBuilderTextField(
                      name: "phone",
                      // maxLength: 13,
                      keyboardType: TextInputType.number,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        enabled: true,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(60)),
                        labelText: "Phone *",
                        prefixIcon: Icon(Icons.account_box_outlined),
                        hintText: "xxx-xxx-xxxx",
                      ),
                      validator: FormBuilderValidators.compose([
                        (val) {
                          if (val!.length != 10) {
                            return "enter valid phone number";
                          }
                        },
                        FormBuilderValidators.required(context)
                      ]),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FormBuilderTextField(
                      name: "location",
                      // maxLength: 13,
                      maxLines: 5,
                      keyboardType: TextInputType.multiline,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        enabled: true,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15)),
                        labelText: "location *",
                        prefixIcon: Icon(Icons.account_box_outlined),
                        // hintText: "",
                      ),
                      validator: FormBuilderValidators.compose(
                          [FormBuilderValidators.required(context)]),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FormBuilderTextField(
                      name: "email",
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        enabled: true,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(60)),
                        labelText: "Email *",
                        prefixIcon: Icon(Icons.account_box_outlined),
                        hintText: "example@gmail.com",
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.email(context),
                        FormBuilderValidators.required(context)
                      ]),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FormBuilderTextField(
                      name: "password",
                      keyboardType: TextInputType.text,
                      obscureText: _showPassword,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                          enabled: true,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(60)),
                          labelText: "Password *",
                          prefixIcon: Icon(Icons.phone),
                          hintText: "****",
                          suffixIcon: _showPassword
                              ? IconButton(
                                  onPressed: () {
                                    toggle();
                                  },
                                  icon: Icon(Icons.visibility_off))
                              : IconButton(
                                  onPressed: () => toggle(),
                                  icon: Icon(Icons.visibility))),
                      validator: FormBuilderValidators.compose([
                        (val) {
                          if (!val!.contains(RegExp(r"\d+\w+"))) {
                            return "must contain 1 digit and 1 character";
                          }
                        },
                        FormBuilderValidators.required(context)
                      ]),
                    ),
                  ),
                  ElevatedButton.icon(
                      onPressed: () {
                        if (_formkey.currentState!.validate()) {
                          _formkey.currentState!.save();
                        }
                        _sigup(Map<String, dynamic>.from(
                            _formkey.currentState!.value));
                      },
                      icon: Icon(Icons.send),
                      label: Text("Register")),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).popAndPushNamed("/");
                      },
                      child: Text("have a account ? signin"))
                ],
              ),
              autovalidateMode: AutovalidateMode.disabled,
            ),
          ),
        ]),
      ),
    );
  }
}
