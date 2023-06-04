import 'package:flutter/material.dart';
import 'package:location_tracker/screens/loading_screen.dart';
import 'package:location_tracker/screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          appBarTheme: const AppBarTheme(
        color: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      )),
      home: const LoadingScreen(),

// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
