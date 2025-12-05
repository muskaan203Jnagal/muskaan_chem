import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '/homepage/homepage.dart';
import 'firebase_options.dart'; // <-- Now importing your generated options

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // IMPORTANT: Initialize Firebase here. 
    // Uncomment and replace 'DefaultFirebaseOptions.currentPlatform' 
    // with your actual Firebase initialization code.
    await Firebase.initializeApp( // <-- Initialization is now active
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    print("Firebase initialization successful (assuming configuration is correct).");
  } catch (e) {
    // If you haven't set up Firebase yet, this will fail.
    // The app will still run but won't fetch real data.
    print("WARNING: Firebase initialization failed. Please ensure 'firebase_core' is configured. Error: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Commerce Catalog',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Inter', // Using a clean, modern font style
      ),
      // Call the HomePage
      home: const HomePage(),
    );
  }
}