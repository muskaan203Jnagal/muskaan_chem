// lib/widgets/top_banner_tabs.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// PAGES
import '../my-addresses.dart';
import '../my-orders.dart';
import '../my-wishlist.dart';
import '../account-settings.dart';

const Color _black = Colors.black;
const Color _white = Colors.white;
const Color _gold = Color(0xFFC9A34E);

const double _avatarSize = 90;
const double _maxWidth = 1000;

/// ------------------------------------------------------------------
/// ENUM — Active tab identifier
/// ------------------------------------------------------------------
enum AccountTab { orders, addresses, wishlist, settings }

/// ------------------------------------------------------------------
/// COMMON TOP BANNER + TABS WIDGET (sliver-ready)
/// Pixel-perfect replica of AccountSettingsPage UI
/// ------------------------------------------------------------------
class TopBannerTabs extends StatelessWidget {
  final AccountTab active;

  const TopBannerTabs({super.key, required this.active});

  // Navigation helper
  void _go(BuildContext context, AccountTab tab) {
    if (tab == active) return;

    switch (tab) {
      case AccountTab.orders:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MyOrdersPage()),
        );
        break;

      case AccountTab.addresses:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MyAddressesPage()),
        );
        break;

      case AccountTab.wishlist:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MyWishlistPage()),
        );
        break;

      case AccountTab.settings:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AccountSettingsPage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = FirebaseAuth.instance;
    final db = FirebaseFirestore.instance;

    return FutureBuilder<DocumentSnapshot>(
      future: auth.currentUser == null
          ? null
          : db.collection("users").doc(auth.currentUser!.uid).get(),
      builder: (context, snapshot) {
        String name = "User";
        String avatarLetter = "U";

        if (snapshot.hasData && snapshot.data!.data() != null) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final fullName = (data["name"] ?? "").toString().trim();
          if (fullName.isNotEmpty) name = fullName;

          avatarLetter = name.isNotEmpty ? name[0].toUpperCase() : "U";
        }

        return Column(
          children: [
            // -----------------------------------------------------------
            // BLACK BANNER (avatar + name)
            // -----------------------------------------------------------
            Container(
              width: double.infinity,
              color: _black,
              padding: const EdgeInsets.symmetric(vertical: 22),
              child: Column(
                children: [
                  Container(
                    width: _avatarSize,
                    height: _avatarSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _black,
                      border: Border.all(color: _gold, width: 3),
                    ),
                    child: Center(
                      child: Text(
                        avatarLetter,
                        style: GoogleFonts.montserrat(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: _white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    name,
                    style: GoogleFonts.montserrat(
                      color: _white,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),

            // -----------------------------------------------------------
            // TABS
            // -----------------------------------------------------------
            Container(
              color: _white,
              child: Column(
                children: [
                  const SizedBox(height: 6),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: _maxWidth),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _tabItem(context, "My Orders", AccountTab.orders),
                          const SizedBox(width: 36),
                          _tabItem(
                            context,
                            "My Addresses",
                            AccountTab.addresses,
                          ),
                          const SizedBox(width: 36),
                          _tabItem(context, "My Wishlist", AccountTab.wishlist),
                          const SizedBox(width: 36),
                          _tabItem(
                            context,
                            "Account Settings",
                            AccountTab.settings,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(height: 1, color: _black.withOpacity(0.15)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // ----------------------------------------------------------------------
  // Single TAB widget
  // ----------------------------------------------------------------------
  Widget _tabItem(BuildContext context, String label, AccountTab tab) {
    final bool isActive = (tab == active);

    return InkWell(
      onTap: () => _go(context, tab),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: _black,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 3,
            width: 60,
            decoration: BoxDecoration(
              color: isActive ? _gold : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
