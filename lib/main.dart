import 'package:flutter/material.dart';
import 'loginWidget.dart';
// import 'randomWordsWidget.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Startup Name Generator',
      theme: ThemeData(
        primaryColor: Colors.blue,
      ),
      // home: RandomWords(),
      home: LoginWidget(
        routeObserver: routeObserver,
      ),
      navigatorObservers: [routeObserver],
    );
  }
}
