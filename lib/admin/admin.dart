// ============================================================================
// lib/admin/admin.dart (RESPONSIVE — Desktop NavigationRail + Mobile Drawer)
// ============================================================================
import 'package:flutter/material.dart';

// your existing admin pages (ensure these files exist in same folder)
import 'catalog.dart';
import 'inbox.dart';
import 'users.dart';
import 'marketing.dart';
import 'reviews_moderation.dart';
import 'orders.dart';

// Dashboard (kept in lib/dashboard.dart)
import 'dashboard.dart';

// NEW: customer management page (the one you pasted earlier)
import 'customers.dart';

import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _selectedIndex = 0;

  // central list of pages (order must match _navItems)
  final List<Widget> _pages = [
    const AdminDashboardPage(), // Dashboard
    const CatalogPage(),        // Catalog
    const InboxPage(),          // Inbox
    const UsersPage(),          // Users
    const MarketingPage(),      // Marketing
    const ReviewsModerationPage(), // Reviews
    const OrdersPage(),         // Orders
    const CustomerManagementPage(), // Customers (connected)
    const SettingsPage(),       // Settings (keep your placeholder)
  ];

  // navigation definitions (icon + label)
  final List<_NavItem> _navItems = const [
    _NavItem(Icons.dashboard, 'Dashboard'),
    _NavItem(Icons.inventory, 'Catalog'),
    _NavItem(Icons.inbox, 'Inbox'),
    _NavItem(Icons.people_alt, 'Users'),
    _NavItem(Icons.local_offer, 'Marketing'),
    _NavItem(Icons.star_rate, 'Reviews'),
    _NavItem(Icons.shopping_cart, 'Orders'),
    _NavItem(Icons.people, 'Customers'),
    _NavItem(Icons.settings, 'Settings'),
  ];

  // helper to open drawer programmatically on mobile
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    // responsive breakpoints
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1000;
    final isTablet = width >= 700 && width < 1000;
    final isMobile = width < 700;

    // Page title for AppBar on mobile/tablet
    final title = _navItems[_selectedIndex].label;

    return Scaffold(
      key: _scaffoldKey,
      // On mobile/tablet show AppBar + Drawer, on desktop hide AppBar (content provides its own)
      appBar: isDesktop
          ? null
          : AppBar(
              title: Text(title),
              backgroundColor: Colors.indigo,
              elevation: 0,
              leading: isMobile
                  ? IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                    )
                  : null,
            ),
      drawer: isDesktop
          ? null
          : Drawer(
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DrawerHeader(
                      decoration: BoxDecoration(color: Colors.grey[900]),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Icon(Icons.store, color: Colors.white, size: 36),
                          SizedBox(height: 12),
                          Text('Admin', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _navItems.length,
                        itemBuilder: (context, i) {
                          final item = _navItems[i];
                          final selected = i == _selectedIndex;
                          return ListTile(
                            leading: Icon(item.icon, color: selected ? Colors.indigo : Colors.grey[700]),
                            title: Text(item.label, style: TextStyle(color: selected ? Colors.indigo : null, fontWeight: selected ? FontWeight.w600 : null)),
                            selected: selected,
                            onTap: () {
                              setState(() {
                                _selectedIndex = i;
                              });
                              Navigator.of(context).pop(); // close drawer
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
      body: Row(
        children: [
          // Desktop: left NavigationRail
          if (isDesktop)
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) => setState(() => _selectedIndex = index),
              labelType: NavigationRailLabelType.all,
              backgroundColor: const Color.fromARGB(255, 168, 157, 157),
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.blue[600], borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.store, color: Colors.white, size: 28),
                    ),
                    const SizedBox(height: 10),
                    const Text('Admin', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              destinations: _navItems
                  .map((n) => NavigationRailDestination(icon: Icon(n.icon), label: Text(n.label)))
                  .toList(),
            ),

          // vertical divider between rail and content (desktop)
          if (isDesktop) const VerticalDivider(thickness: 1, width: 1),

          // Main content area (always shown)
          Expanded(
            child: _pages[_selectedIndex],
          ),
        ],
      ),
    );
  }
}

// small helper class for nav items
class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}

// Existing SettingsPage placeholder kept for compatibility:
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
            Text('Settings Coming Soon', style: TextStyle(fontSize: 24, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}

// MAIN: ensure firebase initialization remains (no change)
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
