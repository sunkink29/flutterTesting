import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:english_words/english_words.dart';

class NamedPair {
  String createrName;
  String createrEmail;
  WordPair pair;
  NamedPair(this.createrEmail, this.pair);
}

class RandomWordsState extends State<RandomWords> {
  final FirebaseUser user;
  final _suggestions = <WordPair>[];
  final _saved = Set<WordPair>();
  final _savedNamed = Set<NamedPair>();
  final _biggerFont = const TextStyle(fontSize: 18.0);

  RandomWordsState({this.user = null});

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
            _savedNamed.removeWhere((namedPair) => namedPair.pair == pair);
          } else {
            if (user != null) {
              _saved.add(pair);
              _savedNamed.add(NamedPair(user.email, pair));
            }
          }
        });
      },
    );
  }
}

class RandomWords extends StatefulWidget {
  final user;
  @override
  RandomWordsState createState() => RandomWordsState(user: user);
  RandomWords({this.user = null});
}
