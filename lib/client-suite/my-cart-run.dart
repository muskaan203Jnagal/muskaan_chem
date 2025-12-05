import 'package:flutter/material.dart';
import 'my-cart.dart'; // <-- Make sure this path matches your project

void main() {
  runApp(const TempRunnerApp());
}

class TempRunnerApp extends StatelessWidget {
  const TempRunnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Cart Page Test",
      home: const MyCartPage(),
    );
  }
}
