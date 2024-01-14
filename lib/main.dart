import 'package:boookbytes/splashpage.dart';
import 'package:flutter/material.dart';

//import 'mainpage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'BookByte',
      home: SplashPage(),
    );
  }
}
