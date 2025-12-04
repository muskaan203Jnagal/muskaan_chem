// lib/client-suite/my-wishlist.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'widgets/top_banner_tabs.dart';

const Color _black = Colors.black;
const Color _white = Colors.white;
const Color _gold = Color(0xFFC9A34E);
const double _maxWidth = 1000;

class MyWishlistPage extends StatelessWidget {
  const MyWishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _white,
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverToBoxAdapter(child: TopBannerTabs(active: AccountTab.wishlist)),
          SliverAppBar(
            pinned: true,
            backgroundColor: _white,
            elevation: 0,
            toolbarHeight: 0,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(0),
              child: Container(height: 1, color: _black.withOpacity(0.15)),
            ),
          ),
        ],
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Row
                  Row(
                    children: [
                      Container(width: 3, height: 24, color: _gold),
                      const SizedBox(width: 12),
                      Text(
                        "My Wishlist",
                        style: GoogleFonts.montserrat(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: _black,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "Your saved favourite products.",
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --- GRID OF WISHLIST CARDS ---
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = MediaQuery.of(context).size.width;

                      int crossAxis;

                      if (width < 600) {
                        crossAxis = 2; // mobile
                      } else if (width < 1000) {
                        crossAxis = 3; // tablet
                      } else {
                        crossAxis = 4; // desktop
                      }

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: sampleWishlist.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxis,
                          crossAxisSpacing: 18,
                          mainAxisSpacing: 18,
                          mainAxisExtent: width < 600 ? 215 : 240,
                        ),

                        itemBuilder: (context, index) {
                          return WishlistCard(item: sampleWishlist[index]);
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

//
// ────────────────────── WISHLIST ITEM MODEL ──────────────────────
// (Temporary dummy model until backend is implemented)
//

class WishlistItem {
  final String title;
  final String imageUrl;
  final int price;

  WishlistItem({
    required this.title,
    required this.imageUrl,
    required this.price,
  });
}

// Demo sample data
final List<WishlistItem> sampleWishlist = [
  WishlistItem(
    title: "Vanilla Bliss Candle",
    price: 699,
    imageUrl: "https://picsum.photos/300/300?random=4",
  ),
  WishlistItem(
    title: "Galaxy Resin Keychain",
    price: 299,
    imageUrl: "https://picsum.photos/300/300?random=3",
  ),
  WishlistItem(
    title: "Rose Scented Jar",
    price: 499,
    imageUrl: "https://picsum.photos/300/300?random=2",
  ),
  WishlistItem(
    title: "Rose Scented Jar",
    price: 499,
    imageUrl: "https://picsum.photos/300/300?random=1",
  ),
];

//
// ───────────────────────── WISHLIST CARD ─────────────────────────
//

class WishlistCard extends StatefulWidget {
  final WishlistItem item;

  const WishlistCard({super.key, required this.item});

  @override
  State<WishlistCard> createState() => _WishlistCardState();
}

class _WishlistCardState extends State<WishlistCard> {
  bool _hoverRemove = false;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 600;

    return Container(
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(8), // sharp corners
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      /// 🚀 THIS MAKES THE CARD SHRINK TO ITS CONTENT (NO EMPTY SPACE)
      child: Column(
        mainAxisSize: MainAxisSize.min, // <-- THE IMPORTANT FIX
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGE
          ClipRRect(
            borderRadius: BorderRadius.zero,
            child: Image.network(
              widget.item.imageUrl,
              height: isMobile ? 95 : 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(height: 8),

          // TITLE & PRICE
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "₹${widget.item.price}",
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // BUTTON ROW
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text(
                    "Add to Cart",
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _white,
                    ),
                  ),
                ),

                const Spacer(),

                MouseRegion(
                  onEnter: (_) => setState(() => _hoverRemove = true),
                  onExit: (_) => setState(() => _hoverRemove = false),
                  child: GestureDetector(
                    onTap: () {},
                    child: Text(
                      "Remove",
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _hoverRemove ? _black : Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
