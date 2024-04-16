import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:weather_app/screens/search_city.dart';

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
          primaryColor: Colors.white,
          useMaterial3: true,
        ),
        home: const SearchCity());
  }
}
