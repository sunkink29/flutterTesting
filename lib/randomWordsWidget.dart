import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:english_words/english_words.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final _saved =
      Map<String, String>(); // a map of documentIDs with the pair as the key
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
        builder: (BuildContext context) => StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance.collection('wordPairs').snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
            Iterable<ListTile> tiles;
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Scaffold(
                  appBar: AppBar(
                    title: Text('Saved Suggestions'),
                  ),
                  body: Text('Loading...'),
                );
                break;
              default:
                tiles = snapshot.data.documents.map(
                  (DocumentSnapshot document) {
                    return ListTile(
                      title: Text(
                        document['wordPair'].toString(),
                        style: _biggerFont,
                      ),
                      subtitle: Text(document['email']),
                      onTap: () async {
                        _saved.remove(document['wordPair'].toString());
                        await Firestore.instance
                            .collection('wordPairs')
                            .document(document.documentID)
                            .delete()
                            .catchError((e) => print(e.toString()));
                      },
                    );
                  },
                );
            }
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
            _suggestions.addAll(generateWordPairs().take(10));
          }
          return _buildRow(_suggestions[index]);
        });
  }

  Widget _buildRow(WordPair pair) {
    String docID;
    // Firestore.instance
    //     .collection('wordPairs')
    //     .where('wordPair', isEqualTo: pair.asPascalCase)
    //     .snapshots()
    //     .first
    //     .catchError((e) {})
    //     .then((val) => this.setState(() {
    //           _saved[pair.asPascalCase] =
    //               val.documents.isNotEmpty ? val.documents[0].documentID : null;
    //         }));
    final bool alreadySaved = _saved.keys.contains(pair.asPascalCase);
    if (alreadySaved) {
      docID = _saved[pair.asPascalCase];
    }
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
            Firestore.instance.collection('wordPairs').document(docID).delete();
            _saved.remove(pair.asPascalCase);
          } else {
            if (_user != null) {
              DocumentReference doc =
                  Firestore.instance.collection('wordPairs').document();
              _saved[pair.asPascalCase] = doc.documentID;
              doc.setData({
                'email': _user.email,
                'uid': _user.uid,
                'wordPair': pair.asPascalCase
              });
            }
          }
        });
      },
    );
  }
}
