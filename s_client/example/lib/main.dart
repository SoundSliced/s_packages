import 'package:flutter/material.dart';
import 'package:s_client_example/screens/home_screen.dart';

void main() {
  runApp(const SClientExampleApp());
}

class SClientExampleApp extends StatelessWidget {
  const SClientExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 's_client Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
