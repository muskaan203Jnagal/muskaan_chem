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

/// Desktop max width
const double _maxWidth = 1000;

/// ------------------------------------------------------------------
/// ENUM — Active tab identifier
/// ------------------------------------------------------------------
enum AccountTab { orders, addresses, wishlist, settings }

/// ------------------------------------------------------------------
/// RESPONSIVE TOP BANNER + TABS
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

    final width = MediaQuery.of(context).size.width;

    // RESPONSIVE avatar sizes
    final double avatarSize = width < 500
        ? 60
        : width < 900
        ? 75
        : 90;

    final double nameFont = width < 500
        ? 16
        : width < 900
        ? 18
        : 20;

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
            // RESPONSIVE BLACK BANNER
            // -----------------------------------------------------------
            Container(
              width: double.infinity,
              color: _black,
              padding: EdgeInsets.symmetric(vertical: width < 500 ? 18 : 22),
              child: Column(
                children: [
                  Container(
                    width: avatarSize,
                    height: avatarSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _black,
                      border: Border.all(color: _gold, width: 3),
                    ),
                    child: Center(
                      child: Text(
                        avatarLetter,
                        style: GoogleFonts.montserrat(
                          fontSize: avatarSize * 0.35,
                          fontWeight: FontWeight.w600,
                          color: _white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    name,
                    style: GoogleFonts.montserrat(
                      color: _white,
                      fontWeight: FontWeight.w700,
                      fontSize: nameFont,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),

            // -----------------------------------------------------------
            // TABS AREA
            // -----------------------------------------------------------
            Container(
              color: _white,
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: _maxWidth),
                  child: _buildResponsiveTabs(context),
                ),
              ),
            ),

            Container(height: 1, color: _black.withOpacity(0.15)),
          ],
        );
      },
    );
  }

  /// ----------------------------------------------------------------
  /// CHOOSE LAYOUT BASED ON SCREEN WIDTH
  /// ----------------------------------------------------------------
  Widget _buildResponsiveTabs(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // -----------------------------
    // MOBILE (HORIZONTAL IN ONE ROW)
    // -----------------------------
    if (width < 500) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _mobileTab(context, "My Orders", AccountTab.orders),
          _mobileTab(context, "My Addresses", AccountTab.addresses),
          _mobileTab(context, "My Wishlist", AccountTab.wishlist),
          _mobileTab(context, "Account Settings", AccountTab.settings),
        ],
      );
    }

    // -----------------------------
    // TABLET (same as DESKTOP)
    // -----------------------------
    if (width < 700) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _tabItem(context, "My Orders", AccountTab.orders),
          const SizedBox(width: 28),
          _tabItem(context, "My Addresses", AccountTab.addresses),
          const SizedBox(width: 28),
          _tabItem(context, "My Wishlist", AccountTab.wishlist),
          const SizedBox(width: 28),
          _tabItem(context, "Account Settings", AccountTab.settings),
        ],
      );
    }

    // -----------------------------
    // DESKTOP
    // -----------------------------
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _tabItem(context, "My Orders", AccountTab.orders),
        const SizedBox(width: 36),
        _tabItem(context, "My Addresses", AccountTab.addresses),
        const SizedBox(width: 36),
        _tabItem(context, "My Wishlist", AccountTab.wishlist),
        const SizedBox(width: 36),
        _tabItem(context, "Account Settings", AccountTab.settings),
      ],
    );
  }

  // ----------------------------------------------------------------------
  // MOBILE TAB BOX (compact, horizontal, 2-line text)
  // ----------------------------------------------------------------------
  Widget _mobileTab(BuildContext context, String label, AccountTab tab) {
    final bool isActive = (tab == active);

    // Split into two lines at the first space
    List<String> parts = label.split(" ");
    String line1 = parts.length > 0 ? parts[0] : label;
    String line2 = parts.length > 1 ? parts.sublist(1).join(" ") : "";

    return Expanded(
      child: InkWell(
        onTap: () => _go(context, tab),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                children: [
                  Text(
                    line1,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      height: 1.5,
                      color: _black,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  if (line2.isNotEmpty)
                    Text(
                      line2,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        height: 1.0,
                        color: _black,
                        fontWeight: isActive
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),

            // underline
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 3,
              width: 28,
              decoration: BoxDecoration(
                color: isActive ? _gold : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------------------
  // DESKTOP / TABLET TAB
  // ----------------------------------------------------------------------
  Widget _tabItem(
    BuildContext context,
    String label,
    AccountTab tab, {
    bool mobile = false,
  }) {
    final bool isActive = (tab == active);

    return InkWell(
      onTap: () => _go(context, tab),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
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
