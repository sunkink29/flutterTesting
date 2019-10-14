import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:english_words/english_words.dart';

class NamedPair {
  String createrName;
  String createrEmail;
  WordPair pair;
  NamedPair(this.createrEmail, this.pair);
}

class RandomWords extends StatefulWidget {
  final RouteObserver<PageRoute> routeObserver;
  @override
  RandomWordsState createState() => RandomWordsState();
  RandomWords({this.routeObserver});
}

class RandomWordsState extends State<RandomWords> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser _user;
  final _suggestions = <WordPair>[];
  final _saved = Set<WordPair>();
  final _savedNamed = Set<NamedPair>();
  final _biggerFont = const TextStyle(fontSize: 18.0);

  RandomWordsState();

  @override
  void initState() {
    super.initState();
    _auth.currentUser().then((user) => _user = user);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Startup Name Generator'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.list), onPressed: _pushSaved),
        ],
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                _auth.signOut();
                Navigator.maybePop(context);
              },
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            );
          },
        ),
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
            _savedNamed.removeWhere((namedPair) => namedPair.pair == pair);
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
