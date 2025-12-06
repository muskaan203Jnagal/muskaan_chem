// lib/product_page/product_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 💡 Imports for your existing shared models
import 'package:chem_revolutions/models/product.dart';
import 'package:chem_revolutions/models/review.dart';
// Assuming the path to ProductPage is correct for recursive navigation
import 'package:chem_revolutions/product_page/product_page.dart';

/// ===============================
/// MAIN PRODUCT PAGE (STATEFUL)
/// ===============================

class ProductPage extends StatefulWidget {
  final Product product;

  const ProductPage({super.key, required this.product});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  // --- STATE MANAGEMENT ---
  int _quantity = 1;
  bool _subscriptionSelected = false;
  bool _hoverAddToCart = false;
  bool _hoverWishlist = false;

  int _selectedReviewTab = 0; // 0 = Reviews, 1 = Questions
  int _reviewsToShow = 3; // for "Load more" functionality

  // --------------------------
  // Firestore helpers for wishlist
  // --------------------------
  Future<void> addToWishlist(String productId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please log in to use wishlist.")),
      );
      return;
    }
    final uid = user.uid;
    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('wishlist')
        .doc(productId);

    await ref.set({'addedAt': FieldValue.serverTimestamp()});
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Added to wishlist")));
  }

  Future<void> removeFromWishlist(String productId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please log in to use wishlist.")),
      );
      return;
    }
    final uid = user.uid;
    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('wishlist')
        .doc(productId);

    await ref.delete();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Removed from wishlist")));
  }

  Stream<bool> isWishlisted(String productId) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // user not logged in -> always false
      return Stream.value(false);
    }
    final uid = user.uid;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('wishlist')
        .doc(productId)
        .snapshots()
        .map((doc) => doc.exists);
  }

  @override
  Widget build(BuildContext context) {
    final proxiedUrl =
        'https://wsrv.nl/?url=${Uri.encodeComponent(widget.product.mainImageUrl)}';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(widget.product.name),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 900;

            return SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTopProductSection(isWide, proxiedUrl),
                        const SizedBox(height: 40),
                        _buildReviewsSection(widget.product.id),
                        const SizedBox(height: 32),
                        _buildDynamicRelatedProducts(widget.product.id),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// ===============================
  /// TOP SECTION (PRODUCT + DETAILS)
  /// ===============================

  Widget _buildTopProductSection(bool isWide, String proxiedUrl) {
    final left = Expanded(flex: 5, child: _buildImageGallery(proxiedUrl));

    final right = Expanded(flex: 6, child: _buildProductDetails());

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F2),
        borderRadius: BorderRadius.circular(18),
      ),
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [left, const SizedBox(width: 32), right],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [left, const SizedBox(height: 24), right],
            ),
    );
  }

  Widget _buildImageGallery(String proxiedUrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AspectRatio(
          aspectRatio: 3 / 4,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              color: Colors.white,
              child: Image.network(
                proxiedUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 80,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          widget.product.name,
          style: GoogleFonts.montserrat(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        // Subtitle
        Text(
          widget.product.description.split('.').first,
          style: GoogleFonts.montserrat(fontSize: 13, color: Colors.grey[800]),
        ),
        const SizedBox(height: 8),
        // Rating
        Row(
          children: [
            _buildStars(5.0),
            const SizedBox(width: 6),
            Text(
              5.0.toStringAsFixed(1),
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'Based on 8 Reviews',
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Price + stock
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '\$${widget.product.price.toStringAsFixed(2)}',
              style: GoogleFonts.montserrat(
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF16A34A),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'In stock',
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Subscription card
        _buildPurchaseOptionsCard(),
        const SizedBox(height: 16),

        // Quantity
        Row(
          children: [
            Text('Quantity', style: GoogleFonts.montserrat(fontSize: 13)),
            const SizedBox(width: 16),
            _buildQuantitySelector(),
          ],
        ),
        const SizedBox(height: 18),

        // Add to cart + Wishlist row (updated)
        _buildAddToCartAndWishlistRow(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPurchaseOptionsCard() {
    final price = widget.product.price;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE4E4E7)),
      ),
      child: Column(
        children: [
          _buildPurchaseOptionRow(
            selected: _subscriptionSelected,
            title: 'Subscribe and save 15%',
            price: price * 0.85,
            onTap: () {
              setState(() => _subscriptionSelected = true);
            },
          ),
          const Divider(height: 0),
          _buildPurchaseOptionRow(
            selected: !_subscriptionSelected,
            title: 'One Time Purchase',
            price: price,
            onTap: () {
              setState(() => _subscriptionSelected = false);
            },
          ),
        ],
      ),
    );
  }

  // -----------------------
  // New: Add to cart + Wishlist row
  // -----------------------
  Widget _buildAddToCartAndWishlistRow() {
    return Row(
      children: [
        // Add to cart (reduced width using Expanded)
        Expanded(
          flex: 5,
          child: MouseRegion(
            onEnter: (_) => setState(() => _hoverAddToCart = true),
            onExit: (_) => setState(() => _hoverAddToCart = false),
            child: GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Added $_quantity x ${widget.product.name} to cart (${_subscriptionSelected ? 'Subscription' : 'One-time'})',
                    ),
                  ),
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _hoverAddToCart
                      ? const Color(0xFFB8860B)
                      : Colors.black,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'ADD TO CART',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Wishlist button: uses StreamBuilder to get real-time wishlist state
        SizedBox(
          width: 46,
          height: 46,
          child: StreamBuilder<bool>(
            stream: isWishlisted(widget.product.id),
            builder: (context, snap) {
              final wishlisted = snap.data ?? false;

              Color bgColor;
              IconData iconData;
              Color iconColor = Colors.white;

              if (wishlisted) {
                // already wishlisted -> gold background + filled heart
                bgColor = _hoverWishlist
                    ? const Color(0xFFB8860B).withOpacity(0.95)
                    : const Color(0xFFB8860B);
                iconData = Icons.favorite;
              } else {
                // not wishlisted -> black background, outline heart
                bgColor = _hoverWishlist
                    ? const Color(0xFFB8860B)
                    : Colors.black;
                iconData = Icons.favorite_border;
              }

              return MouseRegion(
                onEnter: (_) => setState(() => _hoverWishlist = true),
                onExit: (_) => setState(() => _hoverWishlist = false),
                child: GestureDetector(
                  onTap: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please log in to use wishlist."),
                        ),
                      );
                      return;
                    }
                    if (wishlisted) {
                      await removeFromWishlist(widget.product.id);
                    } else {
                      await addToWishlist(widget.product.id);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(iconData, color: iconColor, size: 22),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 💡 HELPER WIDGETS (Defined only once)

  Widget _buildStars(double rating, {double size = 18}) {
    final full = rating.floor();
    final half = (rating - full) >= 0.5;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < full) {
          return Icon(Icons.star, size: size, color: const Color(0xFFFACC15));
        } else if (index == full && half) {
          return Icon(
            Icons.star_half,
            size: size,
            color: const Color(0xFFFACC15),
          );
        } else {
          return Icon(
            Icons.star_border,
            size: size,
            color: const Color(0xFFFACC15),
          );
        }
      }),
    );
  }

  Widget _buildPurchaseOptionRow({
    required bool selected,
    required String title,
    required double price,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off_outlined,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              '\$${price.toStringAsFixed(2)}',
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      width: 80,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFD4D4D8)),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  if (_quantity > 1) _quantity--;
                });
              },
              child: const Center(child: Icon(Icons.remove, size: 16)),
            ),
          ),
          Container(width: 1, color: const Color(0xFFE4E4E7)),
          Expanded(
            child: Center(
              child: Text(
                '$_quantity',
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Container(width: 1, color: const Color(0xFFE4E4E7)),
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _quantity++;
                });
              },
              child: const Center(child: Icon(Icons.add, size: 16)),
            ),
          ),
        ],
      ),
    );
  }

  /// ===============================
  /// REVIEWS SECTION (INTEGRATED WITH FIREBASE)
  /// ===============================
  Widget _buildReviewsSection(String productId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('reviews')
          .where('productId', isEqualTo: productId)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading reviews: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final reviews = snapshot.data!.docs
            .map((doc) => Review.fromFirestore(doc))
            .toList();
        final reviewCount = reviews.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top rating + buttons
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _buildRatingSummary(reviewCount)),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _primaryRedButton(
                        'Ask a Question',
                        onTap: _openQuestionSheet,
                      ),
                      const SizedBox(width: 8),
                      _primaryRedButton(
                        'Write a Review',
                        onTap: _openReviewSheet,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildReviewsTabs(reviewCount),
            const SizedBox(height: 16),
            if (_selectedReviewTab == 0) _buildReviewsList(reviews),
            if (_selectedReviewTab == 1)
              Text(
                'No questions yet. Be the first to ask!',
                style: GoogleFonts.montserrat(fontSize: 13),
              ),
            const SizedBox(height: 24),
            if (_selectedReviewTab == 0 && _reviewsToShow < reviews.length)
              Center(
                child: SizedBox(
                  height: 36,
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _reviewsToShow = reviews.length;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.black),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                    ),
                    child: Text(
                      'Load More Reviews',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildRatingSummary(int reviewCount) {
    // Dummy rating logic to match the design style
    final dummyRating = 5.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              dummyRating.toStringAsFixed(1),
              style: GoogleFonts.montserrat(
                fontSize: 32,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 6),
            _buildStars(dummyRating, size: 20),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Based on $reviewCount Reviews',
          style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey[700]),
        ),
        const SizedBox(height: 16),
        Column(
          children: List.generate(5, (i) {
            final star = 5 - i;
            final count = star == 5 ? reviewCount : 0;
            final ratio = star == 5 ? 1.0 : 0.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Text('$star', style: GoogleFonts.montserrat(fontSize: 11)),
                  const SizedBox(width: 4),
                  const Icon(Icons.star, size: 12, color: Color(0xFFFACC15)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5E7EB),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: ratio,
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFACC15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '($count)',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _primaryRedButton(String label, {required VoidCallback onTap}) {
    return SizedBox(
      height: 36,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE11D2A),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        child: Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildReviewsTabs(int reviewCount) {
    Widget tab(String label, int index, int count) {
      final selected = _selectedReviewTab == index;
      return InkWell(
        onTap: () => setState(() => _selectedReviewTab = index),
        child: Padding(
          padding: const EdgeInsets.only(right: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$label  $count',
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? Colors.black : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 4),
              Container(
                height: 2,
                width: 60,
                color: selected ? Colors.black : Colors.transparent,
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        tab('Reviews', 0, reviewCount),
        tab('Questions', 1, 2), // Dummy count for questions
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFFE4E4E7)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Most Recent',
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down, size: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsList(List<Review> reviews) {
    final toShow = reviews.take(_reviewsToShow).toList();

    if (toShow.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Text(
          'Be the first to leave a review for ${widget.product.name}!',
          style: GoogleFonts.montserrat(fontSize: 13, color: Colors.grey[700]),
        ),
      );
    }

    return Column(
      children: toShow.map((review) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: avatar + name + date
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFFE5E7EB),
                    child: Text(
                      review.initials,
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              review.name,
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Verified Buyer',
                              style: GoogleFonts.montserrat(
                                fontSize: 11,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        _buildStars(review.rating, size: 16),
                        const SizedBox(height: 2),
                        Text(
                          review.title,
                          style: GoogleFonts.montserrat(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          review.text,
                          style: GoogleFonts.montserrat(
                            fontSize: 13,
                            color: Colors.grey[800],
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.share, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              'Share',
                              style: GoogleFonts.montserrat(
                                fontSize: 11,
                                color: Colors.grey[700],
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'Was this helpful?',
                              style: GoogleFonts.montserrat(
                                fontSize: 11,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.thumb_up_alt_outlined, size: 14),
                            const SizedBox(width: 2),
                            Text(
                              '0',
                              style: GoogleFonts.montserrat(fontSize: 11),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.thumb_down_alt_outlined, size: 14),
                            const SizedBox(width: 2),
                            Text(
                              '0',
                              style: GoogleFonts.montserrat(fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    review.date,
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // --- Modal Logic (Defined only once) ---

  void _openReviewSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        final nameCtrl = TextEditingController();
        final emailCtrl = TextEditingController();
        final titleCtrl = TextEditingController();
        final reviewCtrl = TextEditingController();
        double rating = 5;

        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              Widget star(double index) {
                final selected = index <= rating;
                return IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    selected ? Icons.star : Icons.star_border,
                    color: const Color(0xFFFACC15),
                    size: 22,
                  ),
                  onPressed: () {
                    setModalState(() => rating = index);
                  },
                );
              }

              InputDecoration decoration(String label) => InputDecoration(
                labelText: label,
                labelStyle: GoogleFonts.montserrat(fontSize: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              );

              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Write a Review',
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.product.name,
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Overall Rating',
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [star(1), star(2), star(3), star(4), star(5)],
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: titleCtrl,
                      decoration: decoration('Review Title'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: reviewCtrl,
                      maxLines: 4,
                      decoration: decoration('Your Review'),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: nameCtrl,
                            decoration: decoration('Name'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: emailCtrl,
                            decoration: decoration('Email'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () {
                          // This is where you would submit the review to Firestore
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Review submitted (demo only).'),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE11D2A),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: Text(
                          'Submit Review',
                          style: GoogleFonts.montserrat(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _openQuestionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) {
        final nameCtrl = TextEditingController();
        final emailCtrl = TextEditingController();
        final questionCtrl = TextEditingController();

        InputDecoration decoration(String label) => InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.montserrat(fontSize: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        );

        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Ask a Question',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  widget.product.name,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: questionCtrl,
                  maxLines: 4,
                  decoration: decoration('Your Question'),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: nameCtrl,
                        decoration: decoration('Name'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: emailCtrl,
                        decoration: decoration('Email'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Question submitted (demo only).'),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE11D2A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: Text(
                      'Submit Question',
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// ===============================
  /// DYNAMIC RELATED PRODUCTS SECTION
  /// ===============================

  Widget _buildDynamicRelatedProducts(String currentProductId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('products')
          .orderBy('createdAt', descending: true)
          .limit(4)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading related products: ${snapshot.error}'),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final allProducts = snapshot.data!.docs
            .map((doc) => Product.fromFirestore(doc))
            .toList();
        final relatedProducts = allProducts
            .where((p) => p.id != currentProductId)
            .toList();

        if (relatedProducts.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'YOU MAY ALSO LIKE',
              style: GoogleFonts.montserrat(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: const Color(0xFFE11D2A),
              ),
            ),
            const SizedBox(height: 18),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: relatedProducts
                    .map((p) => _buildRelatedCard(p))
                    .toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRelatedCard(Product p) {
    // Generate benefits/bullets from the first two sentences of the description
    final bullets = p.description
        .split('.')
        .take(2)
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final proxiedUrl =
        'https://wsrv.nl/?url=${Uri.encodeComponent(p.mainImageUrl)}';

    return InkWell(
      onTap: () {
        // Navigate to the product page for the related product
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => ProductPage(product: p)),
        );
      },
      child: Container(
        width: 230,
        margin: const EdgeInsets.only(right: 16, bottom: 8, top: 8),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE4E4E7)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Center(
              child: SizedBox(
                height: 130,
                child: Image.network(
                  proxiedUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.broken_image, size: 40),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              p.name,
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 8),
            // Dynamic bullets from description
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: bullets
                  .map(
                    (b) => Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.check,
                            size: 14,
                            color: Color(0xFF16A34A),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              b,
                              style: GoogleFonts.montserrat(
                                fontSize: 11.5,
                                color: Colors.grey[800],
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 10),
            // Price
            Text(
              '\$${p.price.toStringAsFixed(2)}',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 32,
              child: OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${p.name} added to cart!')),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE11D2A)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.zero,
                ),
                child: Text(
                  'Add To Cart',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFE11D2A),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
