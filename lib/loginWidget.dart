import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'randomWordsWidget.dart';
import 'newAccWidget.dart';

class LoginWidget extends StatefulWidget {
  final RouteObserver<PageRoute> routeObserver;
  LoginState createState() => LoginState(routeObserver: routeObserver);
  LoginWidget({this.routeObserver});
}

class LoginState extends State<LoginWidget> with RouteAware {
  final RouteObserver<PageRoute> routeObserver;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser _user;
  String email = '';
  String password = '';
  bool _autovalidate = false;
  final _formKey = GlobalKey<FormState>();

  LoginState({this.routeObserver});

  @override
  void initState() {
    super.initState();
    _auth.currentUser().then((user) => _user = user);
    if (_user != null) {
      Navigator.of(context).push(getRandomWordsRoute());
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void didPopNext() {
    _auth.currentUser().then((user) => _user = user);
    if (_user != null) {
      Future.delayed(Duration.zero, () {
        Navigator.of(context).push(getRandomWordsRoute());
      });
    }
  }

  MaterialPageRoute getRandomWordsRoute() {
    return MaterialPageRoute(builder: (context) => RandomWords());
  }

  Future<FirebaseUser> checkLogin(BuildContext context) async {
    if (!_formKey.currentState.validate()) {
      return null;
    }
    _formKey.currentState.save();
    await _auth
        .signInWithEmailAndPassword(email: email, password: password)
        .then((auth) => _user = auth.user)
        .catchError((e) => print(e));
    if (_user != null) {
      Navigator.of(context).push(getRandomWordsRoute());
      print("signed in " + _user.email);
    } else {
      setState(() {
        _autovalidate = true;
      });
    }
    return _user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Login'),
        ),
        body: Container(
            margin: EdgeInsets.all(15.0),
            child: Form(
              key: _formKey,
              autovalidate: _autovalidate,
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
                    onPressed: () => checkLogin(context),
                  ),
                  FlatButton(
                    child: Text('Create Account'),
                    onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => NewAccWidget())),
                  ),
                  //Text((_user != null) ? _user.toString():"null"),
                ],
              ),
            )));
  }
}
