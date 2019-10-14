import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'randomWordsWidget.dart';
import 'newAccWidget.dart';
import 'validators.dart';

class LoginWidget extends StatefulWidget {
  final RouteObserver<PageRoute> routeObserver;
  LoginState createState() => LoginState(routeObserver: routeObserver);
  LoginWidget({this.routeObserver});
}

class LoginState extends State<LoginWidget> with RouteAware {
  final RouteObserver<PageRoute> routeObserver;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  FirebaseUser _user;
  String _email = '';
  String _password = '';
  String _errorMessage = '';
  bool _autovalidate = false;

  LoginState({this.routeObserver});

  @override
  void initState() {
    super.initState();
    _auth.currentUser().then((user) => _user = user);
    if (_user != null) {
      pushNextWidget();
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
    _auth.currentUser().then((user) {
      _user = user;
      if (_user != null) {
        Future.delayed(Duration.zero, () {
          pushNextWidget();
        });
      }
    });
  }

  void pushNextWidget() {
    setState(() {
      _errorMessage = '';
      _autovalidate = false;
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => RandomWords()));
    });
  }

  Future<FirebaseUser> checkLogin(BuildContext context) async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      await _auth
          .signInWithEmailAndPassword(email: _email, password: _password)
          .then((auth) => _user = auth.user)
          .catchError((e) {
        setState(() {
          if (e is PlatformException) {
            switch (e.code) {
              case 'ERROR_WRONG_PASSWORD':
              case 'ERROR_USER_NOT_FOUND':
                _errorMessage = 'Invalid email or password';
                break;
              default:
                _errorMessage = e.code;
            }
          }
          // _errorMessage = e.toString();
        });
      });
      if (_user != null) {
        Future.delayed(Duration.zero, () {
          pushNextWidget();
        });
        print("signed in " + _user.email);
      }
      return _user;
    }
    setState(() {
      _autovalidate = true;
    });
    return null;
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
                physics: NeverScrollableScrollPhysics(),
                children: [
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
                    margin: EdgeInsets.symmetric(horizontal: 30.0),
                    child: RaisedButton(
                      child: Text('Login'),
                      clipBehavior: Clip.antiAlias,
                      onPressed: () => checkLogin(context),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 80),
                    child: RaisedButton(
                      child: Text('Create Account'),
                      clipBehavior: Clip.antiAlias,
                      onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => NewAccWidget())),
                    ),
                  ),
                  Text(_errorMessage),
                  //Text((_user != null) ? _user.toString():"null"),
                ],
              )),
        ));
  }
}
