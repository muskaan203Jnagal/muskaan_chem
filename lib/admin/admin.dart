// ============================================================================
// lib/admin/admin.dart (UPDATED UI: Dark NavigationRail + Desktop Header)
// ============================================================================
import 'package:flutter/material.dart';

// your existing admin pages (ensure these files exist in same folder)
import 'catalog.dart';
import 'inbox.dart';
import 'users.dart';
import 'marketing.dart';
import 'reviews_moderation.dart';
import 'orders.dart';
import 'shipping.dart';
import 'verification_codes.dart';

// Dashboard (kept in lib/dashboard.dart)
import 'dashboard.dart';

// NEW: customer management page
import 'customers.dart';

import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

// --- UI CONSTANTS FOR THEME ---
const Color _primaryColor = Color(0xFF1F2937); // Dark Slate Grey for Rail background
const Color _accentColor = Colors.indigo; // Use original indigo for accents
const Color _desktopContentBg = Color(0xFFF9FAFB); // Very light grey for main page background

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _selectedIndex = 0;

  // central list of pages (order must match _navItems)
  final List<Widget> _pages = [
    const DashboardPage(), // Dashboard
    const CatalogPage(),        // Catalog
     const VerificationCodesPage(), //generate pages
    const InboxPage(),          // Inbox
    const UsersPage(),          // Users
    const MarketingPage(),      // Marketing
    const ReviewsModerationPage(), // Reviews
    const OrdersPage(),         // Orders
    const CustomerManagementPage(), // Customers (connected)
    const ShippingPage(),
    const SettingsPage(),       // Settings (keep your placeholder)
  ];

  // navigation definitions (icon + label)
  final List<_NavItem> _navItems = const [
    _NavItem(Icons.dashboard, 'Dashboard'),
    _NavItem(Icons.inventory, 'Catalog'),
    _NavItem(Icons.verified, 'Verification Codes'),
    _NavItem(Icons.inbox, 'Inbox'),
    _NavItem(Icons.people_alt, 'Users'),
    _NavItem(Icons.local_offer, 'Marketing'),
    _NavItem(Icons.star_rate, 'Reviews'),
    _NavItem(Icons.shopping_cart, 'Orders'),
    _NavItem(Icons.people, 'Customers'),
    _NavItem(Icons.local_shipping, 'Shipping'), // <-- ADD THIS
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
      backgroundColor: isDesktop ? _desktopContentBg : Colors.white, // Apply background color for desktop
      // On mobile/tablet show AppBar + Drawer, on desktop hide AppBar
      appBar: isDesktop
          ? null
          : AppBar(
              title: Text(title),
              backgroundColor: _accentColor,
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
              // Mobile Drawer uses the same styling as the desktop rail for consistency
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DrawerHeader(
                      decoration: const BoxDecoration(color: _primaryColor), // Use primary color
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Icon(Icons.store, color: Colors.white, size: 36),
                          SizedBox(height: 12),
                          Text('Admin Portal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
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
                            leading: Icon(item.icon, color: selected ? _accentColor : Colors.grey[700]),
                            title: Text(item.label, style: TextStyle(color: selected ? _accentColor : null, fontWeight: selected ? FontWeight.w600 : null)),
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
              backgroundColor: _primaryColor, // Use the dark color
              unselectedIconTheme: const IconThemeData(color: Colors.white70),
              selectedIconTheme: const IconThemeData(color: _accentColor),
              selectedLabelTextStyle: const TextStyle(color: _accentColor, fontWeight: FontWeight.bold),
              unselectedLabelTextStyle: const TextStyle(color: Colors.white),
              // Refined leading logo/text
              leading: Padding(
                padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                child: Column(
                  children: const [
                    Icon(Icons.store, color: Colors.white, size: 32),
                    SizedBox(height: 8),
                    Text('Admin', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
                  ],
                ),
              ),
              destinations: _navItems
                  .map((n) => NavigationRailDestination(icon: Icon(n.icon), label: Text(n.label)))
                  .toList(),
            ),

          // vertical divider between rail and content (desktop) - Removed for dark rail
          // if (isDesktop) const VerticalDivider(thickness: 1, width: 1),

          // Main content area (always shown)
          Expanded(
            child: Column(
              children: [
                // NEW: Desktop Top AppBar/Header
                if (isDesktop)
                  const _DesktopAppBar(), 
                
                // Main Page Content (expanded)
                Expanded(
                  child: _pages[_selectedIndex],
                ),
              ],
            ),
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

// NEW: Desktop Top AppBar/Header Widget
class _DesktopAppBar extends StatelessWidget {
  const _DesktopAppBar();

  @override
  Widget build(BuildContext context) {
    // Determine the current page title
    final _AdminPageState? adminState = context.findAncestorStateOfType<_AdminPageState>();
    final String title = adminState != null 
        ? adminState._navItems[adminState._selectedIndex].label 
        : 'Dashboard';

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Current Page Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 20, 
              fontWeight: FontWeight.bold, 
              color: Colors.black87
            ),
          ),
          
          Row(
            children: [
              // Search button
              IconButton(onPressed: () {}, icon: const Icon(Icons.search, color: Colors.grey)),
              const SizedBox(width: 10),
              // User profile icon
              const CircleAvatar(
                backgroundColor: _accentColor,
                radius: 16,
                child: Text('A', style: TextStyle(color: Colors.white, fontSize: 14)),
              ),
              const SizedBox(width: 5),
            ],
          ),
        ],
      ),
    );
  }
}

// Existing SettingsPage placeholder kept for compatibility:
class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Note: The desktop version will now use the background color from AdminPage
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.settings, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('Settings Coming Soon', style: TextStyle(fontSize: 24, color: Colors.grey[600])),
        ],
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
        // Set the overall app theme to use the accent color
        colorScheme: ColorScheme.fromSeed(seedColor: _accentColor),
        useMaterial3: true,
      ),
      home: const AdminPage(),
    );
  }
}