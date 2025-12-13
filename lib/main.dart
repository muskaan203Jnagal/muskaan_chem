import 'package:chem_revolutions/policy/policy.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '/homepage/homepage.dart';
import 'package:chem_revolutions/about/about.dart';
import 'package:chem_revolutions/contact/contact.dart';

import 'firebase_options.dart';

// Import Cookie Popup Wrapper
import '/policy/cookies.dart'; // <-- ADD THIS

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase initialization successful.");
  } catch (e) {
    print("WARNING: Firebase initialization failed: $e");
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
        fontFamily: 'Inter',
      ),

      // 🔥 Cookie Popup FIRST → then HomePage
      home: const CookieApp(),
     routes: {
  '/home': (context) => const HomePage(),
  '/about': (context) => const AboutPage(),
  '/policy': (context) => const PolicyPageB(),
  '/contact': (context) => const ContactPage(),
},
    );
  }
}
