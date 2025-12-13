// /lib/client-suite/my-account-dashboard.dart

import 'package:chem_revolutions/client-suite/my-orders.dart';
import 'package:chem_revolutions/client-suite/my-wishlist.dart';
import 'package:chem_revolutions/client-suite/account-settings.dart';
import 'package:chem_revolutions/client-suite/my-addresses.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Header + Footer
import '/header.dart'; // AppScaffold
import '/footer.dart'; // Footer, FooterLogo, FooterColumn, FooterItem, SocialLink
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MyAccountDashboard extends StatelessWidget {
  const MyAccountDashboard({Key? key}) : super(key: key);

  static const Color _gold = Color(0xFFC9A34E);
  static const double _maxContentWidth = 900.0;
  static const double _avatarSize = 70.0;
  static const double _radius = 16.0;

  Future<void> _syncEmailBeforeDashboardLoad() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await user.reload();
    final refreshed = FirebaseAuth.instance.currentUser;
    if (refreshed == null || refreshed.email == null) return;

    final doc = FirebaseFirestore.instance
        .collection("users")
        .doc(refreshed.uid);

    final snap = await doc.get();
    final firestoreEmail = snap.data()?['email'];

    if (firestoreEmail != refreshed.email) {
      await doc.set({
        "email": refreshed.email,
        "updatedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  Future<Map<String, dynamic>> _getUserData() async {
    await _syncEmailBeforeDashboardLoad();

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
    return AppScaffold(
      currentPage: 'PROFILE',
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),
              LayoutBuilder(
                builder: (context, constraints) {
                  final double width = constraints.maxWidth;
                  final bool isTwoColumn = width >= 760;

                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: _maxContentWidth,
                      ),
                      child: FutureBuilder<Map<String, dynamic>>(
                        future: _getUserData(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Colors.black,
                              ),
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
                                    Container(
                                      width: _avatarSize,
                                      height: _avatarSize,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.black,
                                        border: Border.all(
                                          color: _gold,
                                          width: 2,
                                        ),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                            color: Colors.black.withOpacity(
                                              0.8,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // ---------------- DASHBOARD CARDS --------------
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
                                      _buildCard(
                                        context,
                                        width: cardWidth,
                                        title: "My Orders",
                                        subtitle:
                                            "View your past orders & details",
                                        page: const MyOrdersPage(),
                                      ),
                                      _buildCard(
                                        context,
                                        width: cardWidth,
                                        title: "My Addresses",
                                        subtitle:
                                            "Manage saved delivery addresses",
                                        page: const MyAddressesPage(),
                                      ),
                                      _buildCard(
                                        context,
                                        width: cardWidth,
                                        title: "My Wishlist",
                                        subtitle:
                                            "Your saved favourite products",
                                        page: const MyWishlistPage(),
                                      ),
                                      _buildCard(
                                        context,
                                        width: cardWidth,
                                        title: "Account Settings",
                                        subtitle:
                                            "Edit your personal details & password",
                                        page: const AccountSettingsPage(),
                                      ),
                                    ],
                                  );
                                },
                              ),

                              const SizedBox(height: 40),

                              // ---------------- SIGN OUT ---------------------
                              Align(
                                alignment: Alignment.center,
                                child: GestureDetector(
                                  onTap: () async {
                                    await FirebaseAuth.instance.signOut();
                                    if (!context.mounted) return;
                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/',
                                    );
                                  },
                                  child: Container(
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
                                      "Logout",
                                      style: GoogleFonts.montserrat(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 50),
                            ],
                          );
                        },
                      ),
                    ),
                  );
                },
              ),

              // ------------------- FOOTER (CORRECT WAY) -------------------
              _buildDashboardFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardFooter() {
    final social = [
      SocialLink(
        icon: FontAwesomeIcons.instagram,
        url: 'https://instagram.com',
      ),
      SocialLink(icon: FontAwesomeIcons.facebookF, url: 'https://facebook.com'),
      SocialLink(icon: FontAwesomeIcons.twitter, url: 'https://twitter.com'),
    ];

    final columns = [
      FooterColumn(
        title: 'QUICK LINKS',
        items: [
          FooterItem(label: 'Home', url: "/"),
          FooterItem(label: 'Categories'),
          FooterItem(label: 'Product Detail'),
          FooterItem(label: 'Contact Us'),
        ],
      ),
      FooterColumn(
        title: 'CUSTOMER SERVICE',
        items: [
          FooterItem(label: 'My Account'),
          FooterItem(label: 'Order Status'),
          FooterItem(label: 'Wishlist'),
        ],
      ),
      FooterColumn(
        title: 'INFORMATION',
        items: [
          FooterItem(label: 'About Us'),
          FooterItem(label: 'Privacy Policy'),
          FooterItem(label: 'Data Collection'),
        ],
      ),
      FooterColumn(
        title: 'POLICIES',
        items: [
          FooterItem(label: 'Privacy Policy'),
          FooterItem(label: 'Data Collection'),
          FooterItem(label: 'Terms & Conditions'),
        ],
      ),
    ];

    return ColoredBox(
      color: const Color.fromARGB(255, 8, 8, 8),
      child: Footer(
        logo: FooterLogo(
          image: Image.asset('assets/icons/chemo.png', fit: BoxFit.contain),
          onTapUrl: "https://chemrevolutions.com",
        ),
        socialLinks: social,
        columns: columns,
        copyright: "© 2025 ChemRevolutions.com. All rights reserved.",
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required double width,
    required String title,
    required String subtitle,
    required Widget page,
  }) {
    return SizedBox(
      width: width,
      child: GestureDetector(
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => page),
          );
        },
        child: DashboardActionCard(
          title: title,
          subtitle: subtitle,
          gold: _gold,
          radius: _radius,
        ),
      ),
    );
  }
}

// ---------------- CARD DESIGN ----------------
class DashboardActionCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final Color gold;
  final double radius;

  const DashboardActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.gold,
    required this.radius,
  });

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
