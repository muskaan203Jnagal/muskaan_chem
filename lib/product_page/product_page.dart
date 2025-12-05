// product_page.dart (CORRECTED - Full Firebase Integration)
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart'; // Required for Firebase initialization

void main() async {
  // Ensure Flutter is initialized before using Firebase
  WidgetsFlutterBinding.ensureInitialized();
  // TODO: Replace with your actual Firebase options
  await Firebase.initializeApp(
    // options: DefaultFirebaseOptions.currentPlatform, 
  );
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
      // IMPORTANT: Using a placeholder product ID for demonstration.
      // Replace '3q37lkkxQkZajqwVeAfU' with a real ID from your 'products' collection.
      home: const ProductPage(productId: '3q37lkkxQkZajqwVeAfU'), 
    );
  }
}

/// ===============================
/// MODELS (Updated to match Firestore Schema and use URLs)
/// ===============================

class Product {
  final String id;
  final String name;
  final String description; // Using description as the main text
  final String mainImageUrl;
  final List<String> imageUrls;
  final double price;
  final int stock;
  final String status;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.mainImageUrl,
    required this.imageUrls,
    required this.price,
    required this.stock,
    required this.status,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Process image URLs
    List<String> urls = [];
    if (data.containsKey('imageUrls') && data['imageUrls'] is List) {
      urls = List<String>.from(data['imageUrls']);
    }
    
    return Product(
      id: doc.id,
      name: data['name'] ?? 'Untitled Product',
      description: data['description'] ?? 'No description provided.',
      // Use mainImageUrl or the first URL as fallback
      mainImageUrl: data['mainImageUrl'] ?? (urls.isNotEmpty ? urls.first : ''),
      imageUrls: urls,
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      stock: (data['stock'] as int?) ?? 0,
      status: data['status'] ?? 'inactive',
    );
  }
}

class Review {
  final String name;
  final String comment;
  final double rating;
  final String date;
  
  // Dummy fields for UI
  final String initials;
  final String country; 
  final String title;

  Review({
    required this.name,
    required this.comment,
    required this.rating,
    required this.date,
    required this.initials,
    required this.country,
    required this.title,
  });
  
  factory Review.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final name = data['proxyName'] ?? 'Anonymous';
    
    // You'll need to calculate these based on your logic/schema
    final initials = name.split(' ').map((n) => n.substring(0, 1)).join();
    const country = 'United States'; // Dummy for UI
    const title = 'Verified Review'; // Dummy for UI
    
    // Format timestamp to a date string
    String dateString = 'N/A';
    if (data['createdAt'] is Timestamp) {
      dateString = (data['createdAt'] as Timestamp).toDate().toLocal().toString().split(' ')[0];
    }

    return Review(
      name: name,
      comment: data['comment'] ?? 'No comment.',
      rating: (data['rating'] as num?)?.toDouble() ?? 5.0,
      date: dateString,
      initials: initials,
      country: country,
      title: title,
    );
  }
}

// Kept simple for static related products
class RelatedProduct {
  final String name;
  final double price;
  final double? premiumPrice;
  final List<String> bullets;

  RelatedProduct({
    required this.name,
    required this.price,
    this.premiumPrice,
    required this.bullets,
  });
}

/// ===============================
/// MAIN PRODUCT PAGE
/// ===============================

class ProductPage extends StatefulWidget {
  final String productId;
  const ProductPage({super.key, required this.productId});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  // Firestore references
  final CollectionReference _productsCollection =
      FirebaseFirestore.instance.collection('products');
  final CollectionReference _reviewsCollection =
      FirebaseFirestore.instance.collection('reviews');

  // Dynamic Data
  Product? _product;
  List<Review> _reviews = [];
  bool _isLoading = true;

  // Static/Placeholder data for the design elements
  final List<RelatedProduct> _related = _staticRelatedProducts;

  // State variables
  int _selectedImageIndex = 0;
  int _quantity = 1;
  bool _subscriptionSelected = false;
  bool _seeMoreDescription = false;
  bool _hoverAddToCart = false;

  int _selectedReviewTab = 0; // 0 = Reviews, 1 = Questions
  int _reviewsToShow = 3; // for "Load more"

  @override
  void initState() {
    super.initState();
    _fetchProductData();
  }

  // Method to fetch all dynamic data
  Future<void> _fetchProductData() async {
    try {
      // 1. Fetch Product
      final productDoc = await _productsCollection.doc(widget.productId).get();
      if (productDoc.exists) {
        _product = Product.fromFirestore(productDoc);
      } else {
        debugPrint('Product with ID ${widget.productId} not found.');
      }

      // 2. Fetch Reviews for this product
      final reviewsSnapshot = await _reviewsCollection
          .where('productID', isEqualTo: widget.productId)
          .orderBy('createdAt', descending: true)
          .get();

      _reviews = reviewsSnapshot.docs.map((doc) => Review.fromFirestore(doc)).toList();

    } catch (e) {
      debugPrint('Error fetching product data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Product not found or failed to load.')),
      );
    }
    
    final product = _product!;
    final productReviews = _reviews;

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
                        _buildTopProductSection(isWide, product),
                        const SizedBox(height: 40),
                        _buildReviewsSection(product, productReviews),
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

  Widget _buildTopProductSection(bool isWide, Product product) {
    final left = Expanded(
      flex: 5,
      child: _buildImageGallery(product),
    );

    final right = Expanded(
      flex: 6,
      child: _buildProductDetails(product),
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

  Widget _buildImageGallery(Product product) {
    // Determine the list of images to show. Use the first image if imageUrls is empty.
    final images = product.imageUrls.isEmpty
        ? [product.mainImageUrl]
        : product.imageUrls;

    // Use the main image URL for the large display
    final mainImage = images.isNotEmpty ? images[_selectedImageIndex] : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AspectRatio(
          aspectRatio: 3 / 4,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              color: Colors.white,
              // FIX: Use Image.network
              child: Image.network(
                mainImage,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Icon(Icons.image_not_supported, size: 50));
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Thumbnail Row - only show if there's more than one image
        if (images.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              images.length,
              (index) => GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedImageIndex = index;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _selectedImageIndex == index
                          ? Colors.redAccent
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    // FIX: Use Image.network for thumbnails
                    child: Image.network(
                      images[index],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(child: Icon(Icons.image, size: 20));
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProductDetails(Product product) {
    // Calculate dummy average rating and review count from fetched data
    final double averageRating = _reviews.isNotEmpty
        ? _reviews.map((r) => r.rating).reduce((a, b) => a + b) / _reviews.length
        : 5.0; // Default to 5.0 if no reviews

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
          product.name,
          style: GoogleFonts.montserrat(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          product.description, // Using description as the main subtitle/text
          style: GoogleFonts.montserrat(
            fontSize: 13,
            color: Colors.grey[800],
          ),
          maxLines: 2, // Limit subtitle to 2 lines for design
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Text(
          'In Stock: ${product.stock}',
          style: GoogleFonts.montserrat(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        _buildDescriptionText(product.description),
        const SizedBox(height: 12),

        // Rating
        Row(
          children: [
            _buildStars(averageRating),
            const SizedBox(width: 6),
            Text(
              averageRating.toStringAsFixed(1),
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'Based on ${_reviews.length} Reviews',
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
              '\$${product.price.toStringAsFixed(2)}',
              style: GoogleFonts.montserrat(
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: product.stock > 0 ? const Color(0xFF16A34A) : Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                product.stock > 0 ? 'In stock' : 'Out of Stock',
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

        // Subscription card - Using a dummy subscription price for UI
        _buildPurchaseOptionsCard(product.price, product.price * 0.85), 
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
        _buildAddToCartButton(product),
        const SizedBox(height: 16),

        // Icons row
        _buildFeatureIcons(),
      ],
    );
  }

  Widget _buildDescriptionText(String fullDesc) {
    const maxShortLength = 100;
    
    final short = fullDesc.length > maxShortLength
        ? '${fullDesc.substring(0, maxShortLength)}...'
        : fullDesc;

    final showingText = _seeMoreDescription ? fullDesc : short;

    final canToggle = fullDesc.length > maxShortLength;

    return GestureDetector(
      onTap: canToggle 
          ? () {
              setState(() => _seeMoreDescription = !_seeMoreDescription);
            }
          : null,
      child: RichText(
        text: TextSpan(
          text: showingText,
          style: GoogleFonts.montserrat(
            fontSize: 12,
            color: Colors.grey[800],
            height: 1.4,
          ),
          children: [
            if (canToggle)
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

  Widget _buildPurchaseOptionsCard(double regularPrice, double subPrice) {
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
            price: subPrice,
            onTap: () {
              setState(() => _subscriptionSelected = true);
            },
          ),
          const Divider(height: 0),
          _buildPurchaseOptionRow(
            selected: !_subscriptionSelected,
            title: 'One Time Purchase',
            price: regularPrice,
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
              color: selected ? Colors.black : Colors.grey[500],
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
              child: Center(
                child: Icon(Icons.remove, size: 16, color: _quantity > 1 ? Colors.black : Colors.grey),
              ),
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

  Widget _buildAddToCartButton(Product product) {
    final bool canAdd = product.stock > 0;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _hoverAddToCart = true),
      onExit: (_) => setState(() => _hoverAddToCart = false),
      child: GestureDetector(
        onTap: canAdd ? () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Added $_quantity x ${product.name} to cart (${_subscriptionSelected ? 'Subscription' : 'One-time'})',
              ),
            ),
          );
        } : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: canAdd 
                ? (_hoverAddToCart ? const Color(0xFFB8860B) : Colors.black)
                : Colors.grey[400],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            canAdd ? 'ADD TO CART' : 'OUT OF STOCK',
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

  Widget _buildReviewsSection(Product product, List<Review> reviews) {
    final double averageRating = reviews.isNotEmpty
        ? reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length
        : 5.0;
        
    final totalReviews = reviews.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: _buildRatingSummary(averageRating, totalReviews, reviews),
            ),
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
                    onTap: () => _openReviewSheet(product),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildReviewsTabs(totalReviews),
        const SizedBox(height: 16),
        if (_selectedReviewTab == 0) _buildReviewsList(product),
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

  Widget _buildRatingSummary(double averageRating, int totalReviews, List<Review> reviews) {
    Map<int, int> starCounts = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (var r in reviews) {
      if (r.rating >= 4.5) starCounts[5] = (starCounts[5] ?? 0) + 1;
      else if (r.rating >= 3.5) starCounts[4] = (starCounts[4] ?? 0) + 1;
      else if (r.rating >= 2.5) starCounts[3] = (starCounts[3] ?? 0) + 1;
      else if (r.rating >= 1.5) starCounts[2] = (starCounts[2] ?? 0) + 1;
      else starCounts[1] = (starCounts[1] ?? 0) + 1;
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              averageRating.toStringAsFixed(1),
              style: GoogleFonts.montserrat(
                fontSize: 32,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 6),
            _buildStars(averageRating, size: 20),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Based on $totalReviews Reviews',
          style: GoogleFonts.montserrat(
            fontSize: 12,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 16),
        Column(
          children: List.generate(5, (i) {
            final star = 5 - i;
            final count = starCounts[star] ?? 0;
            final ratio = totalReviews == 0 ? 0.0 : count / totalReviews;

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

  Widget _buildReviewsTabs(int totalReviews) {
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
        tab('Reviews', 0, totalReviews),
        tab('Questions', 1, 0), // Assuming 0 questions for now
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

  Widget _buildReviewsList(Product product) {
    if (_reviews.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 20),
          child: Text('Be the first to leave a review!'),
        ),
      );
    }
    
    final toShow = _reviews.take(_reviewsToShow).toList();

    return Column(
      children: toShow.map((review) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                          review.comment,
                          style: GoogleFonts.montserrat(
                            fontSize: 13,
                            color: Colors.grey[800],
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.name,
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

  void _openReviewSheet(Product product) {
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
                      product.name,
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
                          // TODO: Implement actual review submission to Firestore
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
                  _product!.name,
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
          // FIX: Replaced Image.asset with Icon for Related Products (static data)
          Center(
            child: SizedBox(
              height: 130,
              child: Icon(
                Icons.fitness_center, // Use a default icon
                size: 80, 
                color: Colors.redAccent,
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
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Added ${p.name} to cart (Related)!'),
                    duration: const Duration(milliseconds: 800),
                  ),
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
    );
  }
  
  // Static list for related products
  static final List<RelatedProduct> _staticRelatedProducts = [
    RelatedProduct(
      name: 'BLACK OX',
      price: 69.99,
      premiumPrice: 55.99,
      bullets: const [
        'Clinically-dosed ingredients for testosterone.',
        'Boost strength, stamina & muscle growth.',
      ],
    ),
    RelatedProduct(
      name: 'MUSCLE PRO',
      price: 85.99,
      premiumPrice: 68.79,
      bullets: const [
        'Strongest natural muscle builder.',
        'Enhances anabolism & growth.',
      ],
    ),
    RelatedProduct(
      name: 'SHRED',
      price: 49.99,
      premiumPrice: 39.99,
      bullets: const [
        'High-stimulant fat burning.',
        'Controls appetite & blood sugar.',
      ],
    ),
  ];
}