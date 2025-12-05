import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const ProductApp());
}

class ProductApp extends StatelessWidget {
  const ProductApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product Page',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
        textTheme: GoogleFonts.montserratTextTheme(),
      ),
      home: const ProductPage(),
    );
  }
}

/// ===============================
/// MODELS
/// ===============================

class Product {
  final String id;
  final String name;
  final String subtitle;
  final String imageAsset;
  final double price;
  final double? subscriptionPrice;
  final double rating;
  final int reviewCount;
  final List<String> benefits;

  Product({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.imageAsset,
    required this.price,
    this.subscriptionPrice,
    required this.rating,
    required this.reviewCount,
    required this.benefits,
  });
}

class Review {
  final String initials;
  final String name;
  final String title;
  final String country;
  final double rating;
  final String date;
  final String text;

  Review({
    required this.initials,
    required this.name,
    required this.title,
    required this.country,
    required this.rating,
    required this.date,
    required this.text,
  });
}

class RelatedProduct {
  final String name;
  final String imageAsset;
  final double price;
  final double? premiumPrice;
  final List<String> bullets;

  RelatedProduct({
    required this.name,
    required this.imageAsset,
    required this.price,
    this.premiumPrice,
    required this.bullets,
  });
}

/// ===============================
/// MAIN PRODUCT PAGE
/// ===============================

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  // main product
  final Product _product = Product(
    id: 'top-t',
    name: 'TOP T',
    subtitle: 'Advanced 8 Potent Testosterone Booster',
    imageAsset: 'assets/images/images.jpeg',
    price: 69.99,
    subscriptionPrice: 59.99,
    rating: 5.0,
    reviewCount: 8,
    benefits: const [
      'Clinically dosed ingredients for testosterone support.',
      'Boosts strength, stamina & performance.',
      'Supports mood, energy and overall well-being.',
    ],
  );

  final List<String> _galleryImages = const [
    'assets/images/images.jpeg',
  ];

  final List<Review> _reviews = [
    Review(
      initials: 'CS',
      name: 'Christopher S.',
      title: 'Not Your Average Booster!',
      country: 'United States',
      rating: 5,
      date: '07/31/2025',
      text:
          'I can physically & mentally feel the boost in & outside the gym! Top T.',
    ),
    Review(
      initials: 'J',
      name: 'Jeb',
      title: 'Top Tier',
      country: 'United States',
      rating: 5,
      date: '07/10/2025',
      text: 'Best on the market. Top T.',
    ),
    Review(
      initials: 'CC',
      name: 'Christian C.',
      title: 'Not Your Average Testosterone Booster',
      country: 'United States',
      rating: 5,
      date: '06/04/2025',
      text:
          'Formula goes above and beyond other test boosters. Highly recommend for anyone looking to push harder and improve overall wellbeing. Top T.',
    ),
    // extra dummy reviews to show load more effect
    Review(
      initials: 'AK',
      name: 'Arjun K.',
      title: 'Great energy',
      country: 'India',
      rating: 5,
      date: '05/10/2025',
      text: 'Energy and focus improved a lot, will reorder.',
    ),
    Review(
      initials: 'MS',
      name: 'Mandeep S.',
      title: 'Solid results',
      country: 'India',
      rating: 4.5,
      date: '04/22/2025',
      text: 'Strength went up in 3 weeks. Good booster.',
    ),
  ];

  final List<RelatedProduct> _related = [
    RelatedProduct(
      name: 'BLACK OX',
      imageAsset: 'assets/images/images.jpeg',
      price: 69.99,
      premiumPrice: 55.99,
      bullets: const [
        'Clinically-dosed ingredients for testosterone.',
        'Boost strength, stamina & muscle growth.',
      ],
    ),
    RelatedProduct(
      name: 'MUSCLE PRO',
      imageAsset: 'assets/images/images.jpeg',
      price: 85.99,
      premiumPrice: 68.79,
      bullets: const [
        'Strongest natural muscle builder.',
        'Enhances anabolism & growth.',
      ],
    ),
    RelatedProduct(
      name: 'SHRED',
      imageAsset: 'assets/images/images.jpeg',
      price: 49.99,
      premiumPrice: 39.99,
      bullets: const [
        'High-stimulant fat burning.',
        'Controls appetite & blood sugar.',
      ],
    ),
    RelatedProduct(
      name: 'ENHANCED 3-AD',
      imageAsset: 'assets/images/images.jpeg',
      price: 89.99,
      premiumPrice: 71.99,
      bullets: const [
        'Boosts testosterone for rapid gains.',
        'Amplify metabolism & lean look.',
      ],
    ),
    RelatedProduct(
      name: 'ORGAN HEALTH',
      imageAsset: 'assets/images/images.jpeg',
      price: 39.99,
      premiumPrice: 31.99,
      bullets: const [
        'Comprehensive organ support.',
        'Kidney, liver & heart function.',
      ],
    ),
  ];

  int _selectedImageIndex = 0;
  int _quantity = 1;
  bool _subscriptionSelected = false;
  bool _seeMoreDescription = false;
  bool _hoverAddToCart = false;

  int _selectedReviewTab = 0; // 0 = Reviews, 1 = Questions
  int _reviewsToShow = 3; // for "Load more"

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 900;

            return SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTopProductSection(isWide),
                        const SizedBox(height: 40),
                        _buildReviewsSection(),
                        const SizedBox(height: 32),
                        _buildRelatedProductsSection(),
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

  Widget _buildTopProductSection(bool isWide) {
    final left = Expanded(
      flex: 5,
      child: _buildImageGallery(),
    );

    final right = Expanded(
      flex: 6,
      child: _buildProductDetails(),
    );

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F2),
        borderRadius: BorderRadius.circular(18),
      ),
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                left,
                const SizedBox(width: 32),
                right,
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                left,
                const SizedBox(height: 24),
                right,
              ],
            ),
    );
  }

  Widget _buildImageGallery() {
    // thumbnails removed – only main product image
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AspectRatio(
          aspectRatio: 3 / 4,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              color: Colors.white,
              child: Image.asset(
                _galleryImages[_selectedImageIndex],
                fit: BoxFit.contain,
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
        // Breadcrumb
        Text(
          'Home  ›  Collections  ›  All Supplements',
          style: GoogleFonts.montserrat(
            fontSize: 11,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        // Title
        Text(
          _product.name,
          style: GoogleFonts.montserrat(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _product.subtitle,
          style: GoogleFonts.montserrat(
            fontSize: 13,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Get 250 points when you purchase this item',
          style: GoogleFonts.montserrat(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        _buildDescriptionText(),
        const SizedBox(height: 12),

        // Rating
        Row(
          children: [
            _buildStars(_product.rating),
            const SizedBox(width: 6),
            Text(
              _product.rating.toStringAsFixed(1),
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'Based on ${_product.reviewCount} Reviews',
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
              '\$${_product.price.toStringAsFixed(2)}',
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
            Text(
              'Quantity',
              style: GoogleFonts.montserrat(fontSize: 13),
            ),
            const SizedBox(width: 16),
            _buildQuantitySelector(),
          ],
        ),
        const SizedBox(height: 18),

        // Add to cart
        _buildAddToCartButton(),
        const SizedBox(height: 16),

        // Icons row
        _buildFeatureIcons(),
      ],
    );
  }

  Widget _buildDescriptionText() {
    const fullDesc =
        'We\'ve combined the power of a new generation of premium testosterone boosters, cutting-edge estrogen regulators, vitamins, minerals, and proprietary ingredients to deliver serious results.';

    final short = 'We\'ve combined the power of a new generation of premium '
        'testosterone boosters, cutting-edge estrogen regulators...';

    final showingText = _seeMoreDescription ? fullDesc : short;

    return GestureDetector(
      onTap: () {
        setState(() => _seeMoreDescription = !_seeMoreDescription);
      },
      child: RichText(
        text: TextSpan(
          text: showingText,
          style: GoogleFonts.montserrat(
            fontSize: 12,
            color: Colors.grey[800],
            height: 1.4,
          ),
          children: [
            TextSpan(
              text: _seeMoreDescription ? '  See Less' : '  See More',
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.redAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchaseOptionsCard() {
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
            price: _product.subscriptionPrice ?? _product.price,
            onTap: () {
              setState(() => _subscriptionSelected = true);
            },
          ),
          const Divider(height: 0),
          _buildPurchaseOptionRow(
            selected: !_subscriptionSelected,
            title: 'One Time Purchase',
            price: _product.price,
            onTap: () {
              setState(() => _subscriptionSelected = false);
            },
          ),
        ],
      ),
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
          Container(
            width: 1,
            color: const Color(0xFFE4E4E7),
          ),
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
          Container(
            width: 1,
            color: const Color(0xFFE4E4E7),
          ),
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

  Widget _buildAddToCartButton() {
    return MouseRegion(
      onEnter: (_) => setState(() => _hoverAddToCart = true),
      onExit: (_) => setState(() => _hoverAddToCart = false),
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Added $_quantity x ${_product.name} to cart (${_subscriptionSelected ? 'Subscription' : 'One-time'})',
              ),
            ),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _hoverAddToCart ? const Color(0xFFB8860B) : Colors.black,
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
    );
  }

  Widget _buildFeatureIcons() {
    Text text(String label) => Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.attach_money, size: 18, color: Colors.redAccent),
            const SizedBox(width: 6),
            text('100% MONEY BACK'),
          ],
        ),
        Row(
          children: [
            const Icon(Icons.local_shipping_outlined,
                size: 18, color: Colors.redAccent),
            const SizedBox(width: 6),
            text('FREE SHIPPING'),
          ],
        ),
        Row(
          children: [
            const Icon(Icons.verified, size: 18, color: Colors.redAccent),
            const SizedBox(width: 6),
            text('FDA INSPECTED FACILITY'),
          ],
        ),
      ],
    );
  }

  /// ===============================
  /// REVIEWS SECTION
  /// ===============================

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top rating + buttons
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // average rating + bars
            Expanded(
              flex: 3,
              child: _buildRatingSummary(),
            ),
            const SizedBox(width: 16),
            // buttons
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
        _buildReviewsTabs(),
        const SizedBox(height: 16),
        if (_selectedReviewTab == 0) _buildReviewsList(),
        if (_selectedReviewTab == 1)
          Text(
            'No questions yet. Be the first to ask!',
            style: GoogleFonts.montserrat(fontSize: 13),
          ),
        const SizedBox(height: 24),
        if (_selectedReviewTab == 0 && _reviewsToShow < _reviews.length)
          Center(
            child: SizedBox(
              height: 36,
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _reviewsToShow = _reviews.length;
                  });
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.black),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
  }

  Widget _buildRatingSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              _product.rating.toStringAsFixed(1),
              style: GoogleFonts.montserrat(
                fontSize: 32,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 6),
            _buildStars(_product.rating, size: 20),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Based on ${_product.reviewCount} Reviews',
          style: GoogleFonts.montserrat(
            fontSize: 12,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 16),
        Column(
          children: List.generate(5, (i) {
            final star = 5 - i;
            final count = star == 5 ? 8 : 0; // dummy distribution
            final ratio = star == 5 ? 1.0 : 0.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Text(
                    '$star',
                    style: GoogleFonts.montserrat(fontSize: 11),
                  ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
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

  Widget _buildReviewsTabs() {
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
        tab('Reviews', 0, _reviews.length),
        tab('Questions', 1, 2),
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

  Widget _buildReviewsList() {
    final toShow = _reviews.take(_reviewsToShow).toList();

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
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.flag, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              review.country,
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
                        const SizedBox(height: 4),
                        Text(
                          'Top T',
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            color: Colors.grey[700],
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
                        )
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

  Widget _buildStars(double rating, {double size = 18}) {
    final full = rating.floor();
    final half = (rating - full) >= 0.5;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < full) {
          return Icon(Icons.star,
              size: size, color: const Color(0xFFFACC15));
        } else if (index == full && half) {
          return Icon(Icons.star_half,
              size: size, color: const Color(0xFFFACC15));
        } else {
          return Icon(Icons.star_border,
              size: size, color: const Color(0xFFFACC15));
        }
      }),
    );
  }

  /// ===============================
  /// BOTTOM SHEETS: REVIEW & QUESTION
  /// ===============================

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
                      _product.name,
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
                      children: [
                        star(1),
                        star(2),
                        star(3),
                        star(4),
                        star(5),
                      ],
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
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
              ),
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
                  _product.name,
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
  /// RELATED PRODUCTS SECTION
  /// ===============================

  Widget _buildRelatedProductsSection() {
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
            children: _related.map((p) => _buildRelatedCard(p)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildRelatedCard(RelatedProduct p) {
    return Container(
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
          // image
          Center(
            child: SizedBox(
              height: 130,
              child: Image.asset(
                p.imageAsset,
                fit: BoxFit.contain,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: p.bullets
                .map(
                  (b) => Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check,
                            size: 14, color: Color(0xFF16A34A)),
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
          Text(
            '\$${p.price.toStringAsFixed(2)}',
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (p.premiumPrice != null) ...[
            const SizedBox(height: 2),
            Row(
              children: [
                Text(
                  '\$${p.premiumPrice!.toStringAsFixed(2)} ',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: const Color(0xFF16A34A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    'PREMIUM',
                    style: GoogleFonts.montserrat(
                      fontSize: 9,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 32,
            child: OutlinedButton(
              onPressed: () {},
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
    );
  }
}