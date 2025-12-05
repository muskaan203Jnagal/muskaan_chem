// lib/client-suite/my-wishlist.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// IMPORT PRODUCT MODEL + PRODUCT PAGE
import 'package:chem_revolutions/models/product.dart';
import 'package:chem_revolutions/product_page/product_page.dart';

// TOP BANNER
import 'widgets/top_banner_tabs.dart';

const Color _black = Colors.black;
const Color _white = Colors.white;
const Color _gold = Color(0xFFC9A34E);
const double _maxWidth = 1000;

class MyWishlistPage extends StatelessWidget {
  const MyWishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

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

        // ---------------- REAL WISHLIST DATA ----------------
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("users")
              .doc(user!.uid)
              .collection("wishlist")
              .snapshots(),
          builder: (context, wishlistSnap) {
            if (wishlistSnap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!wishlistSnap.hasData || wishlistSnap.data!.docs.isEmpty) {
              return _emptyWishlistUI();
            }

            final wishlistDocs = wishlistSnap.data!.docs;
            final productIds = wishlistDocs.map((d) => d.id).toList();

            return FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection("products")
                  .where(FieldPath.documentId, whereIn: productIds)
                  .get(),
              builder: (context, productSnap) {
                if (!productSnap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final products = productSnap.data!.docs
                    .map((doc) => Product.fromFirestore(doc))
                    .toList();

                return _wishlistUI(context, products);
              },
            );
          },
        ),
      ),
    );
  }

  // ---------------- EMPTY UI ----------------
  Widget _emptyWishlistUI() {
    return Center(
      child: Text(
        "Your wishlist is empty",
        style: GoogleFonts.montserrat(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: _black,
        ),
      ),
    );
  }

  // ---------------- MAIN UI ----------------
  Widget _wishlistUI(BuildContext context, List<Product> products) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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

              LayoutBuilder(
                builder: (context, constraints) {
                  final width = MediaQuery.of(context).size.width;

                  int crossAxis;
                  if (width < 600) {
                    crossAxis = 2;
                  } else if (width < 1000) {
                    crossAxis = 3;
                  } else {
                    crossAxis = 4;
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: products.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxis,
                      crossAxisSpacing: 18,
                      mainAxisSpacing: 18,
                      mainAxisExtent: width < 600 ? 215 : 240,
                    ),
                    itemBuilder: (context, index) {
                      return WishlistCard(product: products[index]);
                    },
                  );
                },
              ),

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}

//
// ───────────────────────── WISHLIST CARD ─────────────────────────
//

class WishlistCard extends StatefulWidget {
  final Product product;
  const WishlistCard({super.key, required this.product});

  @override
  State<WishlistCard> createState() => _WishlistCardState();
}

class _WishlistCardState extends State<WishlistCard> {
  bool _hoverRemove = false;

  Future<void> _removeFromWishlist() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("wishlist")
        .doc(widget.product.id)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 600;

    // ⭐ FIXED IMAGE USING PROXY
    final String proxiedImage =
        'https://wsrv.nl/?url=${Uri.encodeComponent(widget.product.mainImageUrl)}';

    return Container(
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------------- IMAGE ----------------
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductPage(product: widget.product),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.zero,
              child: Image.network(
                proxiedImage, // ⭐ FIXED
                height: isMobile ? 95 : 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: isMobile ? 95 : 120,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.broken_image, size: 30),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // ---------------- NAME + PRICE ----------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "₹${widget.product.price.toStringAsFixed(0)}",
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ---------------- BUTTONS ----------------
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
                    onTap: _removeFromWishlist,
                    child: Text(
                      "Remove",
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _hoverRemove ? Colors.red : Colors.grey.shade600,
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
