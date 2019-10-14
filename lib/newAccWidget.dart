import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'validators.dart';

class NewAccWidget extends StatefulWidget {
  NewAccState createState() => NewAccState();
}

class NewAccState extends State<NewAccWidget> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  var _email = '';
  var _password = '';
  var _autoValidate = false;
  var _errorMessage = '';

  Future<FirebaseUser> checkCreation(BuildContext context) async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      FirebaseUser _user;
      await _auth
          .createUserWithEmailAndPassword(
            email: _email,
            password: _password,
          )
          .then((auth) => _user = auth.user)
          .catchError((e) {
        setState(() {
          if (e is PlatformException) {
            switch (e.code) {
              case 'ERROR_EMAIL_ALREADY_IN_USE':
                _errorMessage = 'Email is already used';
                break;
              default:
                _errorMessage = e.code;
            }
          }
        });
      });
      if (_user != null) {
        Navigator.of(context).pop();
      }
      return _user;
    }
    setState(() {
      _autoValidate = true;
    });
    return null;
  }

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
              autovalidate: _autoValidate,
              child: ListView(
                children: <Widget>[
                  TextFormField(
                    onSaved: (text) => _email = text,
                    validator: validateEmail,
                    decoration: InputDecoration(
                      labelText: 'Email',
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  TextFormField(
                    onSaved: (text) => _password = text,
                    validator: validatePassword,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 30),
                    child: RaisedButton(
                      child: Text('Create Account'),
                      clipBehavior: Clip.antiAlias,
                      onPressed: () => checkCreation(context),
                    ),
                  ),
                  Text(_errorMessage),
                ],
              ),
            )));
  }
}
