// lib/client-suite/widgets/top_banner_tabs.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Pages
import '../my-orders.dart';
import '../my-addresses.dart';
import '../my-wishlist.dart';
import '../account-settings.dart';

// THEME
const Color _black = Color(0xFF0D0D0D);
const Color _white = Colors.white;
const Color _gold = Color(0xFFC9A34E);

enum AccountTab { orders, addresses, wishlist, settings }

class TopBannerTabs extends StatelessWidget {
  final AccountTab active;

  const TopBannerTabs({super.key, required this.active});

  void _go(BuildContext context, AccountTab tab) {
    if (tab == active) return;

    Widget page;
    switch (tab) {
      case AccountTab.orders:
        page = const MyOrdersPage();
        break;
      case AccountTab.addresses:
        page = const MyAddressesPage();
        break;
      case AccountTab.wishlist:
        page = const MyWishlistPage();
        break;
      default:
        page = const AccountSettingsPage();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return FutureBuilder(
      future: user == null
          ? null
          : FirebaseFirestore.instance.collection("users").doc(user.uid).get(),
      builder: (context, snapshot) {
        String name = "My Account";

        if (snapshot.hasData && snapshot.data!.data() != null) {
          name = (snapshot.data!.data() as Map)["name"] ?? "My Account";
        }

        return Column(
          children: [
            // NAME SECTION — Minimal premium style
            Container(
              padding: const EdgeInsets.only(top: 24, bottom: 12),
              child: Text(
                name,
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w600,
                  fontSize: 19,
                  letterSpacing: 0.5,
                  color: _black,
                ),
              ),
            ),

            // GOLD HAIRLINE — PREMIUM TOUCH
            Container(
              height: 2,
              width: 160,
              decoration: BoxDecoration(
                color: _gold,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: 22),

            // TAB BAR AREA
            Container(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildTabs(context),
            ),

            Divider(color: Colors.black.withOpacity(0.14), height: 1),
          ],
        );
      },
    );
  }

  Widget _buildTabs(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < 520) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _tab(context, "My Orders", AccountTab.orders),
              _tab(context, "My Addresses", AccountTab.addresses),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _tab(context, "My Wishlist", AccountTab.wishlist),
              _tab(context, "Account Settings", AccountTab.settings),
            ],
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _tab(context, "My Orders", AccountTab.orders),
        _gap(),
        _tab(context, "My Addresses", AccountTab.addresses),
        _gap(),
        _tab(context, "My Wishlist", AccountTab.wishlist),
        _gap(),
        _tab(context, "Account Settings", AccountTab.settings),
      ],
    );
  }

  Widget _gap() => const SizedBox(width: 38);

  Widget _tab(BuildContext context, String label, AccountTab tab) {
    final bool isActive = tab == active;

    return InkWell(
      onTap: () => _go(context, tab),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: _black,
            ),
          ),
          const SizedBox(height: 6),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 2.2,
            width: 46,
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
