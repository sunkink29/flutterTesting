import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Startup Name Generator',
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      home: loginWidget(),
    );
  }
}

FirebaseUser _user;

class loginWidget extends StatelessWidget {
  String email = '';
  String password = '';
  final _formKey = GlobalKey<FormState>();
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
              autovalidate: false,
              child: ListView(
                children: <Widget>[
                  TextFormField(
                    onSaved: (text) => email = text,
                    decoration: InputDecoration(
                      labelText: 'Email',
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  TextFormField(
                    onSaved: (text) => password = text,
                    decoration: InputDecoration(
                      labelText: 'Password',
                    ),
                  ),
                  FlatButton(
                    child: Text('Submit'),
                    onPressed: () => checkLogin(context)
                        .then((FirebaseUser user) => {})
                        .catchError((e) => print(e)),
                  )
                ],
              ),
            )));
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<FirebaseUser> checkLogin(BuildContext context) async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      final AuthCredential credential =
          EmailAuthProvider.getCredential(email: email, password: password);

      final FirebaseUser user =
          (await _auth.signInWithCredential(credential)).user;
      if (user != null) {
        _user = user;
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => RandomWords()));
        print("signed in " + user.email);
      } else {
        print("error");
      }
      return user;
    }
    return null;
  }
}

class NamedPair {
  String createrName;
  String createrEmail;
  WordPair pair;
  NamedPair(String email, WordPair pair) {
    // this.createrName = name;
    this.createrEmail = email;
    this.pair = pair;
  }
}

class RandomWordsState extends State<RandomWords> {
  final _suggestions = <WordPair>[];
  final _saved = Set<WordPair>();
  final _savedNamed = Set<NamedPair>();
  final _biggerFont = const TextStyle(fontSize: 18.0);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Startup Name Generator'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.list), onPressed: _pushSaved),
        ],
      ),
      body: _buildSuggestions(),
    );
  }

  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          final Iterable<ListTile> tiles = _savedNamed.map(
            (NamedPair pair) {
              return ListTile(
                title: Text(
                  pair.pair.asPascalCase,
                  style: _biggerFont,
                ),
                subtitle: Text(pair.createrEmail),
              );
            },
          );
          final List<Widget> divided = ListTile.divideTiles(
            context: context,
            tiles: tiles,
          ).toList();
          return Scaffold(
            appBar: AppBar(
              title: Text('Saved Suggestions'),
            ),
            body: ListView(children: divided),
          );
        },
      ),
    );
  }

  Widget _buildSuggestions() {
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (context, i) {
          if (i.isOdd) return Divider();

          final index = i ~/ 2;
          if (index >= _suggestions.length) {
            _suggestions.addAll(generateWordPairs().take(10)); /*4*/
          }
          return _buildRow(_suggestions[index]);
        });
  }

  Widget _buildRow(WordPair pair) {
    final bool alreadySaved = _saved.contains(pair);
    return ListTile(
      title: Text(
        pair.asPascalCase,
        style: _biggerFont,
      ),
      trailing: Icon(
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
      ),
      onTap: () {
        setState(() {
          if (alreadySaved) {
            _saved.remove(pair);
          } else {
            if (_user != null) {
              _saved.add(pair);
              _savedNamed.add(NamedPair(_user.email, pair));
            }
          }
        });
      },
    );
  }
}

class RandomWords extends StatefulWidget {
  @override
  RandomWordsState createState() => RandomWordsState();
}
