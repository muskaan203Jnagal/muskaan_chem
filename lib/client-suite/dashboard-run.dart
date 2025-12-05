// lib/client-suite/dashboard-run.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Import the page you want to test
import 'my-account-dashboard.dart';

void main() {
  runApp(const DashboardRunner());
}

class DashboardRunner extends StatelessWidget {
  const DashboardRunner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Dashboard Runner",
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.montserratTextTheme(),
      ),

      // 👇 Change this to test any page
      home: const MyAccountDashboard(),
    );
  }
}
