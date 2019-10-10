import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'randomWordsWidget.dart';

class NewAccWidget extends StatefulWidget {
  NewAccState createState() => NewAccState();
}

FirebaseUser _user;

class NewAccState extends State<NewAccWidget> {
  String email = '';
  String password = '';
  final _formKey = GlobalKey<FormState>();

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
                    onPressed: () => checkCreation(context)
                        .then((FirebaseUser user) => {})
                        .catchError((e) => print(e)),
                  ),
                ],
              ),
            )));
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<FirebaseUser> checkCreation(BuildContext context) async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      final FirebaseUser user = (await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    ))
        .user;
      if (user != null) {
        _user = user;
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => RandomWords(user: _user)));
        print("signed in " + user.email);
      } else {
        print("error");
      }
      return user;
    }
    return null;
  }
}
