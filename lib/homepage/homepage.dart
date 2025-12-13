import 'package:flutter/material.dart';
import 'dart:async'; // Required for the Timer used in the Review Slider
import '/header.dart'; // Import AppScaffold
import '/footer.dart'; // Import Footer, FooterLogo, etc.
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Needed for Footer social icons

// --- 1. PLACEHOLDER DATA AND CONSTANTS ---
final List<Map<String, dynamic>> products = [
  {
    'name': 'TOP T',
    'price': 69.99,
    'imageUrl': 'https://picsum.photos/300/300?random=1',
  },
  {
    'name': 'Product Two',
    'price': 99.50,
    'imageUrl': 'https://picsum.photos/300/300?random=2',
  },
  {
    'name': 'Product Three',
    'price': 25.00,
    'imageUrl': 'https://picsum.photos/300/300?random=3',
  },
  {
    'name': 'Product Four',
    'price': 149.99,
    'imageUrl': 'https://picsum.photos/300/300?random=4',
  },
  // Additional products for testing the "Load More" logic
  {
    'name': 'Elite Stack',
    'price': 199.00,
    'imageUrl': 'https://picsum.photos/300/300?random=9',
  },
  {
    'name': 'Recovery Pro',
    'price': 55.99,
    'imageUrl': 'https://picsum.photos/300/300?random=10',
  },
];

final List<Map<String, String>> goals = [
  {'title': 'HEALTH', 'imageUrl': 'https://picsum.photos/400/500?random=5'},
  {
    'title': 'BUILD MUSCLE',
    'imageUrl': 'https://picsum.photos/400/500?random=6',
  },
  {'title': 'FAT LOSS', 'imageUrl': 'https://picsum.photos/400/500?random=7'},
  {'title': 'LONGEVITY', 'imageUrl': 'https://picsum.photos/400/500?random=8'},
];

final List<Map<String, dynamic>> reviews = [
  {
    'author': 'John D.',
    'rating': 5,
    'text':
        'Unbelievable results in just 30 days. Energy levels are through the roof! This is a game-changer for my routine.',
  },
  {
    'author': 'Sarah M.',
    'rating': 5,
    'text':
        'The best supplement I have ever tried. Highly recommend for muscle gains and recovery. I feel significantly stronger.',
  },
  {
    'author': 'Mike P.',
    'rating': 4,
    'text':
        'A solid product. Noticed improvements in strength and recovery speed. It delivers exactly what it promises.',
  },
  {
    'author': 'Emily T.',
    'rating': 5,
    'text':
        'Effective and no jitters. Customer service was excellent too! I appreciate the clean ingredient list.',
  },
  {
    'author': 'Ben K.',
    'rating': 5,
    'text':
        'Worth every penny. This formula is definitely enhanced. My focus and drive have never been better.',
  },
  {
    'author': 'Lisa R.',
    'rating': 4,
    'text':
        'Saw noticeable fat loss combined with my usual routine. Great buy, will be purchasing again soon.',
  },
];

// NOTE: Replace these with your actual Firebase Storage image links
const String firebaseHeroImageLink = 'YOUR_FIREBASE_STORAGE_HERO_LINK_HERE';
const String firebaseBannerImageLink = 'YOUR_FIREBASE_STORAGE_BANNER_LINK_HERE';
const String firebaseFinalBannerImageLink =
    'YOUR_FIREBASE_STORAGE_FINAL_BANNER_LINK_HERE';

// --- 2. THEME & UTILITIES ---

class AppTheme {
  static const Color accentColor = Color(0xFFC7924F);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const double mobileWidthBreakpoint = 600.0;

  // Utility function for responsive titles
  static TextStyle responsiveTitleStyle(
    BuildContext context, {
    double desktopSize = 36,
    double mobileSize = 24,
  }) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double fontSize = screenWidth > 800
        ? desktopSize
        : (screenWidth > 450 ? desktopSize * 0.75 : mobileSize);
    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w900,
      color: Colors.black,
      letterSpacing: 4.0,
      height: 1.2,
      fontFamily: 'Montserrat',
    );
  }
}

// Animated Title Widget
class _SectionTitle extends StatelessWidget {
  final String title;
  final double desktopSize;
  final double mobileSize;

  const _SectionTitle({
    required this.title,
    this.desktopSize = 36,
    this.mobileSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40.0),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: AppTheme.responsiveTitleStyle(
          context,
          desktopSize: desktopSize,
          mobileSize: mobileSize,
        ),
      ),
    );
  }
}

// Custom Widget for One-Time Scroll Animation (Fade and Slide Up)
class _ScrollFadeIn extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double slideDistance;

  const _ScrollFadeIn({
    required this.child,
    this.duration = const Duration(milliseconds: 800),
    this.slideDistance = 30.0,
  });

  @override
  State<_ScrollFadeIn> createState() => _ScrollFadeInState();
}

class _ScrollFadeInState extends State<_ScrollFadeIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _slideAnimation;

  // Track if the animation has run (simulating 'once' trigger)
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _slideAnimation = Tween<double>(
      begin: widget.slideDistance,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    // Simulating the one-time trigger on build:
    if (!_hasAnimated) {
      _controller.forward();
      _hasAnimated = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: child,
          ),
        );
      },
    );
  }
}

// Custom reusable circular button for sliders
class _SliderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isMobile;

  const _SliderButton({
    required this.icon,
    required this.onTap,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    // Add horizontal margin to prevent touching the screen edge
    double horizontalMargin = isMobile ? 10.0 : 40.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalMargin),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black, // Black background
          shape: BoxShape.circle, // Circular shape
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Icon(
                icon,
                color: Colors.white, // White icon for contrast
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- 3. MAIN APPLICATION WIDGET ---

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final social = [
      SocialLink(
        icon: FontAwesomeIcons.instagram,
        url: 'https://instagram.com',
      ),
      SocialLink(icon: FontAwesomeIcons.facebookF, url: 'https://facebook.com'),
      SocialLink(icon: FontAwesomeIcons.twitter, url: 'https://twitter.com'),
    ];

    void homePage() {
      print("Go to Home Page");
    }

    void categoriesPage() {
      print("Go to Categories Page");
    }

    void productDetailPage() {
      print("Go to Product Detail Page");
    }

    final columns = [
      FooterColumn(
        title: 'QUICK LINKS',
        items: [
          FooterItem(label: 'Home', onTap: homePage),
          FooterItem(label: 'Categories', onTap: categoriesPage),
          FooterItem(label: 'Product Detail', onTap: productDetailPage),
          FooterItem(
            label: 'Contact Us',
            onTap: () {
              Navigator.pushNamed(context, '/contact');
            },
          ),
        ],
      ),
      FooterColumn(
        title: 'CUSTOMER SERVICE',
        items: [
          FooterItem(
            label: 'My Account',
            url: "https://chemrevolutions.com/account",
          ),
          FooterItem(
            label: 'Order Status',
            url: "https://chemrevolutions.com/orders",
          ),
          FooterItem(
            label: 'Wishlist',
            url: "https://chemrevolutions.com/wishlist",
          ),
        ],
      ),
      FooterColumn(
        title: 'INFORMATION',
        items: [
          FooterItem(
            label: 'About Us',
            onTap: () {
              Navigator.pushNamed(context, '/about');
            },
          ),
          FooterItem(
            label: 'Privacy Policy',
            onTap: () {
              Navigator.pushNamed(context, '/policy');
            },
          ),
          FooterItem(
            label: 'Data Collection',
            onTap: () {
              Navigator.pushNamed(context, '/policy');
            },
          ),
        ],
      ),
      FooterColumn(
        title: 'POLICIES',
        items: [
          FooterItem(
            label: 'Privacy Policy',
            onTap: () {
              Navigator.pushNamed(context, '/policy');
            },
          ),
          FooterItem(
            label: 'Data Collection',
            onTap: () {
              Navigator.pushNamed(context, '/policy');
            },
          ),
          FooterItem(
            label: 'Terms & Conditions',
            onTap: () {
              Navigator.pushNamed(context, '/policy');
            },
          ),
        ],
      ),
    ];

    return Theme(
      data: ThemeData(
        // Set Montserrat as the global font family
        fontFamily: 'Montserrat',
        // Apply Montserrat to the default text theme for guaranteed coverage
        textTheme: ThemeData.light().textTheme.apply(fontFamily: 'Montserrat'),
        primaryColor: Colors.black,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.grey)
            .copyWith(
              secondary: AppTheme.accentColor,
              background: AppTheme.backgroundColor,
            ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accentColor,
            foregroundColor: Colors.black,
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Montserrat',
            ),
          ),
        ),
      ),
      child: AppScaffold(
        currentPage: 'HOME',
        body: SingleChildScrollView(
          child: Container(
            color: AppTheme.backgroundColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hero section does not scroll-animate
                const HeroSection(imageUrl: firebaseHeroImageLink),

                // All other sections are wrapped in the scroll-fade-in animation
                _ScrollFadeIn(child: const ProductsGrid(title: 'NEW PRODUCTS')),
                _ScrollFadeIn(
                  child: const BannerGraphicSection(
                    imageUrl: firebaseBannerImageLink,
                  ),
                ),
                _ScrollFadeIn(child: const ProductsGrid(title: 'SHOP POPULAR')),
                _ScrollFadeIn(child: const GoalsSection()),
                _ScrollFadeIn(
                  child: const ReviewsSection(),
                ), // SLIDER with padded buttons
                _ScrollFadeIn(
                  child: const FinalBannerSection(
                    imageUrl: firebaseFinalBannerImageLink,
                  ),
                ),

                const SizedBox(height: 50),

                // Footer
                Theme(
                  data: ThemeData.dark().copyWith(
                    // Ensure the dark theme also uses Montserrat
                    textTheme: ThemeData.dark().textTheme.apply(
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  child: ColoredBox(
                    color: const Color.fromARGB(255, 8, 8, 8),
                    child: Footer(
                      logo: FooterLogo(
                        image: Image.asset(
                          'assets/icons/chemo.png',
                          fit: BoxFit.contain,
                        ),
                        onTapUrl: "https://chemrevolutions.com",
                      ),
                      socialLinks: social,
                      columns: columns,
                      copyright:
                          "© 2025 ChemRevolutions.com. All rights reserved.",
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------

// --- 4. WIDGET COMPONENTS ---

// 4.1 Hero Section
class HeroSection extends StatelessWidget {
  final String imageUrl;

  const HeroSection({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double calculatedHeight = constraints.maxWidth * (1080 / 1920);
        if (calculatedHeight > 800) {
          calculatedHeight = 800;
        }
        return Container(
          width: constraints.maxWidth,
          height: calculatedHeight,
          decoration: BoxDecoration(color: Colors.grey.shade200),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(color: Colors.grey.shade300);
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey.shade400,
                child: const Center(
                  child: Text(
                    "Image Load Error",
                    style: TextStyle(
                      color: Colors.black54,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// 4.2 Products Grid (Stateful to handle scroll controller for buttons)
class ProductsGrid extends StatefulWidget {
  final String title;
  const ProductsGrid({super.key, required this.title});
  @override
  State<ProductsGrid> createState() => _ProductsGridState();
}

class _ProductsGridState extends State<ProductsGrid> {
  final ScrollController _scrollController = ScrollController();
  final double _cardWidth = 320.0;
  final double _cardSpacing = 25.0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scroll(bool isRight) {
    // Calculate the scroll distance (Card width + spacing)
    final double scrollDistance = _cardWidth + _cardSpacing;
    final double targetOffset = isRight
        ? _scrollController.offset + scrollDistance
        : _scrollController.offset - scrollDistance;

    // Animate to the new offset, clamped to boundaries
    _scrollController.animateTo(
      targetOffset.clamp(
        _scrollController.position.minScrollExtent,
        _scrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < AppTheme.mobileWidthBreakpoint;

    // Logic for Desktop: Show max 4 products + Load More button
    final displayedProducts = products.take(4).toList();
    final hasMoreProducts = products.length > 4;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80.0, horizontal: 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _SectionTitle(title: widget.title),

          if (isMobile)
            // MOBILE SLIDER (Uses all products and navigation buttons)
            SizedBox(
              height: 620, // Height for the mobile list view
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ListView.builder(
                    controller: _scrollController, // Attach controller
                    scrollDirection: Axis.horizontal,
                    itemCount: products.length,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      bool isNewFormula =
                          widget.title == 'NEW PRODUCTS' &&
                          product['name'] == 'TOP T';

                      return Padding(
                        padding: EdgeInsets.only(
                          right: index < products.length - 1
                              ? _cardSpacing
                              : 0.0,
                          left: index == 0 ? 0.0 : 0.0,
                        ),
                        child: ProductCard(
                          name: product['name']!,
                          price: product['price']!,
                          imageUrl: product['imageUrl']!,
                          showNewFormulaBadge: isNewFormula,
                          cardWidth: _cardWidth,
                        ),
                      );
                    },
                  ),

                  // Slider Buttons (Positioned outside the ListView, using Stack)
                  Positioned(
                    left: 0,
                    child: _SliderButton(
                      icon: Icons.chevron_left,
                      onTap: () => _scroll(false),
                      isMobile: isMobile,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: _SliderButton(
                      icon: Icons.chevron_right,
                      onTap: () => _scroll(true),
                      isMobile: isMobile,
                    ),
                  ),
                ],
              ),
            )
          else
            // DESKTOP GRID (Uses max 4 products)
            Wrap(
              spacing: 30.0,
              runSpacing: 30.0,
              alignment: WrapAlignment.center,
              children: displayedProducts.map((product) {
                // Only show 4
                bool isNewFormula =
                    widget.title == 'NEW PRODUCTS' &&
                    product['name'] == 'TOP T';
                return ProductCard(
                  name: product['name']!,
                  price: product['price']!,
                  imageUrl: product['imageUrl']!,
                  showNewFormulaBadge: isNewFormula,
                  cardWidth: 350,
                );
              }).toList(),
            ),

          // "Load More" button only for Desktop if there are more products
          if (!isMobile && hasMoreProducts)
            Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 18,
                  ),
                  side: const BorderSide(color: AppTheme.accentColor, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                onPressed: () {
                  // This action would typically trigger a state update to load more items
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Loading more products! (Simulated)'),
                    ),
                  );
                },
                child: const Text(
                  'LOAD MORE PRODUCTS',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.accentColor,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// 4.3 Product Card
class ProductCard extends StatefulWidget {
  final String name;
  final double price;
  final String imageUrl;
  final bool showNewFormulaBadge;
  final double cardWidth;

  const ProductCard({
    super.key,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.showNewFormulaBadge = false,
    required this.cardWidth,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isTapped = false;

  void _onTapDown(_) {
    setState(() => _isTapped = true);
  }

  void _onTapUp(_) {
    setState(() => _isTapped = false);
    print("Tapped on ${widget.name}");
  }

  void _onTapCancel() {
    setState(() => _isTapped = false);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < AppTheme.mobileWidthBreakpoint;

    final scale = _isTapped ? 0.98 : 1.0;

    return MouseRegion(
      onEnter: (event) => setState(() => _isTapped = true),
      onExit: (event) => setState(() => _isTapped = false),
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: Container(
            width: widget.cardWidth,
            padding: const EdgeInsets.all(18.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(color: Colors.grey.shade100),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 1.0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15.0),
                        child: Image.network(
                          widget.imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    if (widget.showNewFormulaBadge)
                      Positioned(
                        top: 15,
                        left: 15,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: const Text(
                            'NEW FORMULA',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  widget.name,
                  style: TextStyle(
                    fontSize: isMobile ? 20 : 24, // Smaller font on mobile
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                    letterSpacing: 0.5,
                    fontFamily: 'Montserrat',
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    const Text(
                      '\$',
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.black54,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    Text(
                      '${widget.price.toInt()}',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    Text(
                      '.${(widget.price % 1 * 100).toInt().toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 22,
                        color: Colors.black,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FeatureRow(
                      text:
                          'Science-backed ingredients for maximum testosterone boost.',
                    ),
                    _FeatureRow(
                      text: 'Naturally elevates hormone levels and libido.',
                    ),
                    _FeatureRow(
                      text:
                          'Supplies essential micronutrients for comprehensive men health.',
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: AppTheme.accentColor,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text(
                      'ADD TO CART',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 4.4 Feature Row Helper
class _FeatureRow extends StatelessWidget {
  final String text;
  const _FeatureRow({required this.text});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: AppTheme.accentColor,
            size: 18,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 4.5 Banner Graphic Section
class BannerGraphicSection extends StatelessWidget {
  final String imageUrl;
  const BannerGraphicSection({super.key, required this.imageUrl});
  @override
  Widget build(BuildContext context) {
    const double bannerAspectRatio = 1440 / 300;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80.0, horizontal: 0),
      child: Column(
        children: [
          _SectionTitle(
            title: 'LIMITED EDITION DROP',
            desktopSize: 24,
            mobileSize: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: AspectRatio(
              aspectRatio: bannerAspectRatio,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Image.network(imageUrl, fit: BoxFit.cover),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 4.6 Goals Section
class GoalsSection extends StatelessWidget {
  const GoalsSection({super.key});
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < AppTheme.mobileWidthBreakpoint;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80.0, horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _SectionTitle(title: 'CHOOSE YOUR GOAL'),
          LayoutBuilder(
            builder: (context, constraints) {
              final widgetWidth = constraints.maxWidth;
              const double spacing = 35.0;

              // If mobile, calculate width for 2 items with spacing
              final cardWidth = isMobile
                  ? (widgetWidth - spacing) /
                        2 // Ensure 2 cards fit across
                  : 300.0; // Fixed width for desktop

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                alignment: WrapAlignment.center,
                children: goals.map((goal) {
                  return GoalCard(
                    title: goal['title']!,
                    imageUrl: goal['imageUrl']!,
                    cardWidth: cardWidth,
                    isSquare: isMobile, // Pass flag to make it square on mobile
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

// 4.7 Goal Card
class GoalCard extends StatefulWidget {
  final String title;
  final String imageUrl;
  final double cardWidth;
  final bool isSquare;

  const GoalCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.cardWidth,
    this.isSquare = false,
  });

  @override
  State<GoalCard> createState() => _GoalCardState();
}

class _GoalCardState extends State<GoalCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    const double desktopCardHeight = 400.0;
    final scale = _isHovered ? 1.05 : 1.0;

    // Set height based on isSquare flag
    final cardHeight = widget.isSquare ? widget.cardWidth : desktopCardHeight;
    final titleFontSize = widget.isSquare
        ? 20.0
        : 28.0; // Smaller font on square/mobile

    return MouseRegion(
      onEnter: (event) => setState(() => _isHovered = true),
      onExit: (event) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          print("Goal tapped: ${widget.title}");
        },
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: Container(
            width: widget.cardWidth,
            height: cardHeight, // Use calculated height
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18.0),
              color: Colors.grey.shade100,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(widget.imageUrl, fit: BoxFit.cover),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.0),
                        Colors.black.withOpacity(_isHovered ? 0.9 : 0.8),
                      ],
                      stops: const [0.4, 1.0],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 25,
                  left: 25,
                  right: 25,
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: titleFontSize, // Use responsive font size
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 4.8 Reviews Section (Auto-looping slider with navigation buttons)
class ReviewsSection extends StatefulWidget {
  const ReviewsSection({super.key});

  @override
  State<ReviewsSection> createState() => _ReviewsSectionState();
}

class _ReviewsSectionState extends State<ReviewsSection> {
  final PageController _pageController = PageController(viewportFraction: 1.0);
  late Timer _timer;
  final int _duration = 5; // Auto-play speed in seconds
  final int _infiniteCount =
      10000; // Artificially large number for infinite scroll

  @override
  void initState() {
    super.initState();
    // Start the auto-play timer
    _timer = Timer.periodic(Duration(seconds: _duration), (Timer timer) {
      if (!_pageController.hasClients) return;

      final page = _pageController.page;
      if (page == null) return;

      _pageController.animateToPage(
        page.round() + 1,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer.cancel(); // MUST cancel the timer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < AppTheme.mobileWidthBreakpoint;

    // Calculate the number of items visible per page
    final itemsPerPage = isMobile ? 1 : 2;

    // The height must be fixed for the PageView/SizedBox (Shorter on mobile)
    final double sliderHeight = isMobile ? 350.0 : 450.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _SectionTitle(title: 'TRUSTED BY THOUSANDS'),

          SizedBox(
            height: sliderHeight,
            child: Stack(
              // Added Stack for buttons
              alignment: Alignment.center,
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: _infiniteCount, // Simulate infinite loop
                  itemBuilder: (context, index) {
                    // Determine the starting index for the current page
                    final startingIndex = index * itemsPerPage;

                    // Use modulo to cycle through the actual data
                    final reviewIndex1 = startingIndex % reviews.length;
                    final reviewIndex2 = (startingIndex + 1) % reviews.length;

                    // Determine the content for the current page (1 item on mobile, 2 on desktop)
                    if (itemsPerPage == 1) {
                      return Padding(
                        // Reduced horizontal padding to 20.0 to make the card wider on mobile
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: ReviewCard(
                          author: reviews[reviewIndex1]['author'],
                          rating: reviews[reviewIndex1]['rating'],
                          text: reviews[reviewIndex1]['text'],
                          isMobile: isMobile,
                        ),
                      );
                    } else {
                      // Desktop view (2 items per page)
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 450.0),
                            child: ReviewCard(
                              author: reviews[reviewIndex1]['author'],
                              rating: reviews[reviewIndex1]['rating'],
                              text: reviews[reviewIndex1]['text'],
                              isMobile: isMobile,
                            ),
                          ),
                          const SizedBox(width: 40.0), // Spacing between cards
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 450.0),
                            child: ReviewCard(
                              author: reviews[reviewIndex2]['author'],
                              rating: reviews[reviewIndex2]['rating'],
                              text: reviews[reviewIndex2]['text'],
                              isMobile: isMobile,
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),

                // Left Button
                Positioned(
                  left: 0,
                  child: _SliderButton(
                    icon: Icons.chevron_left,
                    onTap: () {
                      _timer.cancel(); // Stop auto-play on manual interaction
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                      // Optionally restart timer after a delay
                    },
                    isMobile: isMobile,
                  ),
                ),

                // Right Button
                Positioned(
                  right: 0,
                  child: _SliderButton(
                    icon: Icons.chevron_right,
                    onTap: () {
                      _timer.cancel(); // Stop auto-play on manual interaction
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                      // Optionally restart timer after a delay
                    },
                    isMobile: isMobile,
                  ),
                ),
              ],
            ),
          ),

          // Removed the "VIEW ALL 4.8K REVIEWS" button as requested
        ],
      ),
    );
  }
}

// 4.9 Review Card
class ReviewCard extends StatelessWidget {
  final String author;
  final int rating;
  final String text;
  final bool isMobile;

  const ReviewCard({
    super.key,
    required this.author,
    required this.rating,
    required this.text,
    this.isMobile = false, // Added isMobile flag
  });

  Widget _buildStarRating(int rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star_rate_rounded : Icons.star_border_rounded,
          color: AppTheme.accentColor,
          size: 26,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reviewTextSize = isMobile ? 18.0 : 20.0;
    // Reduced padding on mobile for tighter fit, especially vertically.
    final cardPadding = isMobile
        ? const EdgeInsets.all(25.0)
        : const EdgeInsets.all(35.0);

    return Container(
      padding: cardPadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStarRating(rating),

          const SizedBox(height: 25),

          Text(
            '“$text”',
            style: TextStyle(
              fontSize: reviewTextSize,
              fontWeight: FontWeight.w500,
              color: Colors.black,
              fontStyle: FontStyle.italic,
              height: 1.6,
              fontFamily: 'Montserrat',
            ),
          ),

          const SizedBox(height: 25),

          Text(
            '- $author',
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: Colors.black,
              letterSpacing: 0.8,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }
}

// 4.10 Final Banner Section
class FinalBannerSection extends StatelessWidget {
  final String imageUrl;

  const FinalBannerSection({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    const double bannerAspectRatio = 1440 / 400;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80.0, horizontal: 20.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: AspectRatio(
          aspectRatio: bannerAspectRatio,
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(color: Colors.grey.shade300);
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey.shade400,
                child: const Center(
                  child: Text(
                    "Final Banner Image Load Error",
                    style: TextStyle(
                      color: Colors.black54,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
