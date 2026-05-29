import 'package:flutter/material.dart';
import 'screens/location_select_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SE Stock App',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: const LocationSelectScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}