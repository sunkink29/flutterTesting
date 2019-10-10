import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NewAccWidget extends StatefulWidget {
  NewAccState createState() => NewAccState();
}

class NewAccState extends State<NewAccWidget> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Create New Account'),
        ),
        body: Container(
            margin: EdgeInsets.all(15.0),
            child: Form(
              key: _formKey,
              autovalidate: false,
              child: ListView(
                children: <Widget>[
                  TextFormField(
                    onSaved: (text) => email = text,
                    validator: (text) => null, // add working validator
                    decoration: InputDecoration(
                      labelText: 'Email',
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  TextFormField(
                    onSaved: (text) => password = text,
                    validator: (text) => null, // add working validator
                    decoration: InputDecoration(
                      labelText: 'Password',
                    ),
                  ),
                  FlatButton(
                    child: Text('Submit'),
                    onPressed: () =>
                        checkCreation(context).catchError((e) => print(e)),
                  ),
                ],
              ),
            )));
  }

  Future<FirebaseUser> checkCreation(BuildContext context) async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      final FirebaseUser user = (await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      ))
          .user;
      Navigator.of(context).pop();
      return user;
    }
    return null;
  }
}
