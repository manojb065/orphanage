import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import '../screenRoute.dart';
import '../global/global.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  GlobalKey<FormBuilderState> _formkey = new GlobalKey<FormBuilderState>();
  String err = "Successfully logged in";

  bool _showPassword = true;

  void toggle() {
    setState(() {
      _showPassword = !_showPassword;
    });
  }

  void _sigin(Map<String, dynamic> data) async {
    try {
      UserCredential usr = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: data["email"], password: data['password']);
      FirebaseFirestore.instance
          .collection("AshramUser")
          .where("uid", isEqualTo: usr.user!.uid)
          .get()
          .then((value) {
        if (value.docs.isNotEmpty) {
          appDataSet("usr", usr);
          // Navigator.of(context).pop();
          Navigator.of(context).popAndPushNamed("/home");
        } else {
          FirebaseAuth.instance.signOut();
        }
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        err = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        err = 'Wrong password provided for that user.';
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(err),
      duration: Duration(seconds: 5),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateRoute: screenRoute.routeScreen,
      home: Scaffold(
        appBar: AppBar(
          title: Text("Delight to Server"),
        ),
        body: FormBuilder(
          key: _formkey,
          child: Column(
            children: [
              FormBuilderTextField(
                name: "email",
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  labelText: "Email *",
                  prefixIcon: Icon(Icons.account_box_outlined),
                  hintText: "example@gmail.com",
                ),
                mouseCursor: MouseCursor.defer,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.email(context),
                  FormBuilderValidators.required(context)
                ]),
              ),
              FormBuilderTextField(
                name: "password",
                keyboardType: TextInputType.text,
                obscureText: _showPassword,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                    labelText: "Password *",
                    prefixIcon: Icon(Icons.lock),
                    hintText: "****",
                    suffixIcon: !_showPassword
                        ? IconButton(
                            onPressed: () {
                              toggle();
                            },
                            icon: Icon(Icons.visibility_off))
                        : IconButton(
                            onPressed: () => toggle(),
                            icon: Icon(Icons.visibility))),
                validator: FormBuilderValidators.required(context,
                    errorText: "Required"),
              ),
              ElevatedButton.icon(
                  onPressed: () {
                    if (_formkey.currentState!.validate()) {
                      _formkey.currentState!.save();
                    }
                    _sigin(Map<String, dynamic>.from(
                        _formkey.currentState!.value));
                  },
                  icon: Icon(Icons.send),
                  label: Text("Login")),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).popAndPushNamed("/reg");
                  },
                  child: Text("click here ? signup"))
            ],
          ),
          autovalidateMode: AutovalidateMode.disabled,
        ),
      ),
    );
  }
}
