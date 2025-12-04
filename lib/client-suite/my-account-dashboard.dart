// lib/client-suite/my_account_dashboard.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'account-settings.dart';
import 'my-addresses.dart';

class MyAccountDashboard extends StatelessWidget {
  const MyAccountDashboard({Key? key}) : super(key: key);

  static const Color _bg = Color(0xFFF2F2F2);
  static const Color _gold = Color(0xFFC9A34E);
  static const double _maxContentWidth = 900.0;
  static const double _avatarSize = 70.0;
  static const double _radius = 16.0;

  /// FETCH USER DATA FROM FIRESTORE
  Future<Map<String, dynamic>> _getUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return {};

    final snap = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    return snap.data() ?? {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double width = constraints.maxWidth;
            final bool isTwoColumn = width >= 760;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: _maxContentWidth),
                  child: FutureBuilder<Map<String, dynamic>>(
                    future: _getUserData(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.black),
                        );
                      }

                      final data = snapshot.data!;
                      final name = data["name"] ?? "User";
                      final email = data["email"] ?? "No Email";
                      final firstLetter = name.isNotEmpty
                          ? name.trim()[0].toUpperCase()
                          : "U";

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ---------------- PROFILE CARD ----------------
                          Container(
                            margin: const EdgeInsets.only(bottom: 40),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 18,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(_radius),
                              border: Border(
                                left: BorderSide(color: _gold, width: 4),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.18),
                                  blurRadius: 45,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),

                            child: Row(
                              children: [
                                // Avatar (Dynamic First Letter)
                                Container(
                                  width: _avatarSize,
                                  height: _avatarSize,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black,
                                    border: Border.all(color: _gold, width: 2),
                                  ),
                                  child: Center(
                                    child: Text(
                                      firstLetter,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 20),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF111111),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      email,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 14,
                                        color: Colors.black.withOpacity(0.8),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // ---------------- GRID CARDS ----------------
                          LayoutBuilder(
                            builder: (context, inner) {
                              const double gap = 25;
                              final double cardWidth = isTwoColumn
                                  ? (inner.maxWidth - gap) / 2
                                  : inner.maxWidth;

                              return Wrap(
                                spacing: gap,
                                runSpacing: gap,
                                children: [
                                  SizedBox(
                                    width: cardWidth,
                                    child: DashboardActionCard(
                                      title: 'My Orders',
                                      subtitle:
                                          'View your past orders & details',
                                      gold: _gold,
                                      radius: _radius,
                                    ),
                                  ),
                                  SizedBox(
                                    width: cardWidth,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const MyAddressesPage(),
                                          ),
                                        );
                                      },
                                      child: DashboardActionCard(
                                        title: 'My Addresses',
                                        subtitle:
                                            'Manage saved delivery addresses',
                                        gold: _gold,
                                        radius: _radius,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: cardWidth,
                                    child: DashboardActionCard(
                                      title: 'My Wishlist',
                                      subtitle: 'Your saved favourite products',
                                      gold: _gold,
                                      radius: _radius,
                                    ),
                                  ),
                                  SizedBox(
                                    width: cardWidth,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const AccountSettingsPage(),
                                          ),
                                        );
                                      },
                                      child: DashboardActionCard(
                                        title: 'My Account',
                                        subtitle:
                                            'Edit your personal details & password',
                                        gold: _gold,
                                        radius: _radius,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),

                          const SizedBox(height: 40),

                          // ---------------- SIGN OUT BUTTON ----------------
                          Align(
                            alignment: Alignment.center,
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () async {
                                  await FirebaseAuth.instance.signOut();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Signed out successfully.'),
                                    ),
                                  );
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: _gold),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.25),
                                        blurRadius: 40,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    'Sign out',
                                    style: GoogleFonts.montserrat(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),
                        ],
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

///////////////////////////////////////////////////////////////////////////
// CARD CLASS (NO CHANGE IN UI)
///////////////////////////////////////////////////////////////////////////

class DashboardActionCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final Color gold;
  final double radius;

  const DashboardActionCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.gold,
    required this.radius,
  }) : super(key: key);

  @override
  State<DashboardActionCard> createState() => _DashboardActionCardState();
}

class _DashboardActionCardState extends State<DashboardActionCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        transform: Matrix4.translationValues(0, _hover ? -4 : 0, 0),
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(widget.radius),
          border: Border.all(
            color: _hover ? widget.gold : Colors.transparent,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 40,
              offset: const Offset(0, 8),
            ),
          ],
        ),

        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: widget.gold, width: 3)),
              ),
              padding: const EdgeInsets.only(left: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.subtitle,
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
