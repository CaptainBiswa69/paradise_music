import 'package:flutter/material.dart';
import 'package:paradise_music/pages/homepage.dart';

import 'myTheme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo', theme: myTheme, home: const HomePage());
  }
}
