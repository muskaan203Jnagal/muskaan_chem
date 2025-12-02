// ============================================================================
// lib/admin/admin.dart
// ============================================================================

import 'package:flutter/material.dart';
import 'catalog.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../firebase_options.dart';
class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const CatalogPage(),
    const OrdersPage(),
    const CustomersPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar Navigation
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            backgroundColor: Colors.grey[900],
            selectedIconTheme: const IconThemeData(color: Colors.white),
            selectedLabelTextStyle: const TextStyle(color: Colors.white),
            unselectedIconTheme: IconThemeData(color: Colors.grey[400]),
            unselectedLabelTextStyle: TextStyle(color: Colors.grey[400]),
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[600],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.store, color: Colors.white, size: 32),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Admin',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.inventory),
                label: Text('Catalog'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.shopping_cart),
                label: Text('Orders'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people),
                label: Text('Customers'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // Main Content
          Expanded(
            child: _pages[_selectedIndex],
          ),
        ],
      ),
    );
  }
}

// Placeholder pages
class DashboardPage extends StatelessWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.dashboard, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Dashboard Coming Soon',
              style: TextStyle(fontSize: 24, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

class OrdersPage extends StatelessWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Orders'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Orders Management Coming Soon',
              style: TextStyle(fontSize: 24, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomersPage extends StatelessWidget {
  const CustomersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Customers'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Customer Management Coming Soon',
              style: TextStyle(fontSize: 24, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.settings, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Settings Coming Soon',
              style: TextStyle(fontSize: 24, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}



Future<void> main() async {
WidgetsFlutterBinding.ensureInitialized();


await Firebase.initializeApp(
options: DefaultFirebaseOptions.currentPlatform,
);


// OPTIONAL: disable persistence for admin accuracy
// FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: false);


runApp(const AdminApp());
}


class AdminApp extends StatelessWidget {
const AdminApp({Key? key}) : super(key: key);


@override
Widget build(BuildContext context) {
return MaterialApp(
debugShowCheckedModeBanner: false,
title: 'Admin Portal',
theme: ThemeData(
colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
useMaterial3: true,
),
home: const AdminPage(),
);
}
}

