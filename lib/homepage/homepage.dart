import 'package:flutter/material.dart';
import '/header.dart'; // Import AppScaffold
import '/footer.dart'; // Import Footer, FooterLogo, etc.
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Needed for Footer social icons

// --- 1. PLACEHOLDER DATA AND CONSTANTS ---
final List<Map<String, dynamic>> products = [
  {'name': 'TOP T', 'price': 69.99, 'imageUrl': 'https://picsum.photos/300/300?random=1'},
  {'name': 'Product Two', 'price': 99.50, 'imageUrl': 'https://picsum.photos/300/300?random=2'},
  {'name': 'Product Three', 'price': 25.00, 'imageUrl': 'https://picsum.photos/300/300?random=3'},
  {'name': 'Product Four', 'price': 149.99, 'imageUrl': 'https://picsum.photos/300/300?random=4'},
];

final List<Map<String, String>> goals = [
  {'title': 'HEALTH', 'imageUrl': 'https://picsum.photos/400/500?random=5'},
  {'title': 'BUILD MUSCLE', 'imageUrl': 'https://picsum.photos/400/500?random=6'},
  {'title': 'FAT LOSS', 'imageUrl': 'https://picsum.photos/400/500?random=7'},
  {'title': 'LONGEVITY', 'imageUrl': 'https://picsum.photos/400/500?random=8'},
];

final List<Map<String, dynamic>> reviews = [
  {'author': 'John D.', 'rating': 5, 'text': 'Unbelievable results in just 30 days. Energy levels are through the roof! This is a game-changer for my routine.'},
  {'author': 'Sarah M.', 'rating': 5, 'text': 'The best supplement I have ever tried. Highly recommend for muscle gains and recovery. I feel significantly stronger.'},
  {'author': 'Mike P.', 'rating': 4, 'text': 'A solid product. Noticed improvements in strength and recovery speed. It delivers exactly what it promises.'},
  {'author': 'Emily T.', 'rating': 5, 'text': 'Effective and no jitters. Customer service was excellent too! I appreciate the clean ingredient list.'},
  {'author': 'Ben K.', 'rating': 5, 'text': 'Worth every penny. This formula is definitely enhanced. My focus and drive have never been better.'},
  {'author': 'Lisa R.', 'rating': 4, 'text': 'Saw noticeable fat loss combined with my usual routine. Great buy, will be purchasing again soon.'},
];

// NOTE: Replace these with your actual Firebase Storage image links
const String firebaseHeroImageLink = 
    'YOUR_FIREBASE_STORAGE_HERO_LINK_HERE'; 
const String firebaseBannerImageLink = 
    'YOUR_FIREBASE_STORAGE_BANNER_LINK_HERE'; 
const String firebaseFinalBannerImageLink = 
    'YOUR_FIREBASE_STORAGE_FINAL_BANNER_LINK_HERE'; 

// --- 2. MAIN APPLICATION WIDGET ---

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Define Footer Data
    final social = [
      SocialLink(icon: FontAwesomeIcons.instagram, url: 'https://instagram.com'),
      SocialLink(icon: FontAwesomeIcons.facebookF, url: 'https://facebook.com'),
      SocialLink(icon: FontAwesomeIcons.twitter, url: 'https://twitter.com'),
    ];

    // Placeholder functions for internal navigation (as defined in footer.dart demo)
    void homePage() { print("Go to Home Page"); }
    void categoriesPage() { print("Go to Categories Page"); }
    void productDetailPage() { print("Go to Product Detail Page"); }
    void contactPage() { print("Go to Contact Page"); }

    final columns = [
      FooterColumn(title: 'QUICK LINKS', items: [
        FooterItem(label: 'Home', onTap: homePage),
        FooterItem(label: 'Categories', onTap: categoriesPage),
        FooterItem(label: 'Product Detail', onTap: productDetailPage),
        FooterItem(label: 'Contact Us', onTap: contactPage),
      ]),
      FooterColumn(title: 'CUSTOMER SERVICE', items: [
        FooterItem(label: 'My Account', url: "https://chemrevolutions.com/account"),
        FooterItem(label: 'Order Status', url: "https://chemrevolutions.com/orders"),
        FooterItem(label: 'Wishlist', url: "https://chemrevolutions.com/wishlist"),
      ]),
      FooterColumn(title: 'INFORMATION', items: [
        FooterItem(label: 'About Us', url: "https://chemrevolutions.com/about"),
        FooterItem(label: 'Privacy Policy', url: "https://chemrevolutions.com/privacy"),
        FooterItem(label: 'Data Collection', url: "https://chemrevolutions.com/data"),
      ]),
      FooterColumn(title: 'POLICIES', items: [
        FooterItem(label: 'Privacy Policy', url: "https://chemrevolutions.com/privacy"),
        FooterItem(label: 'Data Collection', url: "https://chemrevolutions.com/data"),
        FooterItem(label: 'Terms & Conditions', url: "https://chemrevolutions.com/terms"),
      ]),
    ];

    // AppScaffold provides the header/scaffold structure
    return AppScaffold(
      currentPage: 'HOME',
      // FIX 1: Wrap the body Column in a SingleChildScrollView to resolve the overflow
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const HeroSection(imageUrl: firebaseHeroImageLink),
            const ProductsGrid(title: 'NEW PRODUCTS'),
            const BannerGraphicSection(imageUrl: firebaseBannerImageLink),
            const ProductsGrid(title: 'SHOP POPULAR'), 
            const GoalsSection(),
            const ReviewsSection(), 
            const FinalBannerSection(imageUrl: firebaseFinalBannerImageLink),
            
            const SizedBox(height: 50), 

            // FIX 2 & 3: Wrap the Footer in a Theme(data: ThemeData.dark())
            // and a ColoredBox to ensure the correct dark background and white text context.
            Theme(
              data: ThemeData.dark(),
              child: ColoredBox(
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------

// --- 3. WIDGET COMPONENTS (All supporting widgets remain the same) ---

// 3.1 Hero Section 
class HeroSection extends StatelessWidget {
  final String imageUrl;
  
  const HeroSection({super.key, required this.imageUrl});
  // ... (Code remains the same)
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
          decoration: BoxDecoration(color: Colors.grey.shade100),
          child: Image.network(
            imageUrl, 
            fit: BoxFit.cover,
            // Added simple loading/error state for better UX
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(color: Colors.grey.shade200);
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey.shade300,
                child: const Center(child: Text("Image Load Error", style: TextStyle(color: Colors.black54))),
              );
            },
          ),
        );
      },
    );
  }
}

// 3.2 Products Grid 
class ProductsGrid extends StatelessWidget {
  final String title;

  const ProductsGrid({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    // UPDATED: Increased vertical padding for more air
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60.0, horizontal: 20.0), 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 40.0), // Increased spacing
            child: Text(
              title, 
              style: const TextStyle(
                fontSize: 36, // Slightly larger
                fontWeight: FontWeight.w900, 
                color: Colors.black, 
                letterSpacing: 4.0, // Increased letter spacing for impact
              ),
            ),
          ),
          
          Wrap(
            spacing: 30.0, // Increased spacing between cards
            runSpacing: 30.0, // Increased spacing between rows
            alignment: WrapAlignment.center, 
            children: products.map((product) {
              bool isNewFormula = title == 'NEW PRODUCTS' && product['name'] == 'TOP T'; 
              return ProductCard(
                name: product['name']!,
                price: product['price']!,
                imageUrl: product['imageUrl']!,
                showNewFormulaBadge: isNewFormula,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// 3.3 Product Card 
class ProductCard extends StatelessWidget {
  final String name; 
  final double price; 
  final String imageUrl; 
  final bool showNewFormulaBadge;
  
  const ProductCard({
    super.key, 
    required this.name, 
    required this.price, 
    required this.imageUrl, 
    this.showNewFormulaBadge = false, 
  });

  @override
  Widget build(BuildContext context) {
    const double cardMaxWidth = 350.0; // Slightly wider card
    
    return Container(
      width: cardMaxWidth,
      padding: const EdgeInsets.all(20.0), // Increased padding
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(15.0), // More rounded corners
        border: Border.all(color: Colors.grey.shade100), // Lighter border
        boxShadow: [ 
          BoxShadow(
            color: Colors.black.withOpacity(0.08), 
            blurRadius: 20, 
            offset: const Offset(0, 10), // Softer, deeper shadow
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
                  borderRadius: BorderRadius.circular(10.0), // Image corner radius
                  child: Image.network(imageUrl, fit: BoxFit.cover)
                ),
              ),
              if (showNewFormulaBadge)
                Positioned(
                  top: 10, left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black, // Monochrome primary color
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'NEW FORMULA', 
                      style: TextStyle(
                        color: Colors.white, 
                        fontSize: 11, 
                        fontWeight: FontWeight.w900, 
                        letterSpacing: 1.0,
                      )
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            name, 
            style: const TextStyle(
              fontSize: 22, 
              fontWeight: FontWeight.w800, 
              color: Colors.black, 
              letterSpacing: 0.5
            )
          ),
          const SizedBox(height: 10),
          // UPDATED: Price styling for emphasis
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text(
                '\$', 
                style: TextStyle(
                  fontSize: 20, 
                  color: Colors.black54, 
                  fontWeight: FontWeight.w900
                )
              ),
              Text(
                '${price.toInt()}', 
                style: const TextStyle(
                  fontSize: 32, // Larger primary price
                  fontWeight: FontWeight.w900, 
                  color: Colors.black
                )
              ),
              Text(
                '.${(price % 1 * 100).toInt().toString().padLeft(2, '0')}', // Added decimal point
                style: const TextStyle(
                  fontSize: 20, 
                  color: Colors.black
                )
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Features Section (Kept as is, but slightly updated row style)
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FeatureRow(text: 'Science-backed ingredients for maximum testosterone boost.'),
              _FeatureRow(text: 'Naturally elevates hormone levels and libido.'),
              _FeatureRow(text: 'Supplies essential micronutrients for comprehensive men health.'),
            ],
          ),
          const SizedBox(height: 30), // Increased spacing before button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, // Main theme button
                foregroundColor: Colors.white, 
                padding: const EdgeInsets.symmetric(vertical: 18), // Taller button
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              ),
              onPressed: () {},
              child: const Text('ADD TO CART', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

// 3.4 Feature Row Helper
class _FeatureRow extends StatelessWidget {
  final String text;
  const _FeatureRow({required this.text});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0), // Slightly more vertical space
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Changed icon to a filled circle for a bolder look
          const Icon(Icons.check_circle_rounded, color: Colors.black, size: 16), 
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              text, 
              style: const TextStyle(
                fontSize: 14, 
                color: Colors.black87, 
                height: 1.4 // Better readability
              )
            )
          ),
        ],
      ),
    );
  }
}

// 3.5 Banner Graphic Section (1440:300)
class BannerGraphicSection extends StatelessWidget {
  final String imageUrl;
  const BannerGraphicSection({super.key, required this.imageUrl});
  @override
  Widget build(BuildContext context) {
    const double bannerAspectRatio = 1440 / 300;
    return Padding(
      // UPDATED: Increased padding and removed horizontal padding
      padding: const EdgeInsets.symmetric(vertical: 60.0, horizontal: 0),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 25.0),
            child: Text(
              'LIMITED EDITION DROP', // Slightly updated text
              style: TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.w900, 
                color: Colors.black, 
                letterSpacing: 3.0
              )
            ),
          ),
          // Added horizontal padding to the image for better mobile display
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0), 
            child: AspectRatio(
              aspectRatio: bannerAspectRatio, 
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0), // Rounded corners
                child: Image.network(imageUrl, fit: BoxFit.cover)
              )
            ),
          ),
        ],
      ),
    );
  }
}

// 3.6 Goals Section
class GoalsSection extends StatelessWidget {
  const GoalsSection({super.key});
  @override
  Widget build(BuildContext context) {
    // UPDATED: Increased vertical padding
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60.0, horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 40.0),
            child: Text(
              'CHOOSE YOUR GOAL', // Slightly updated text
              style: TextStyle(
                fontSize: 36, 
                fontWeight: FontWeight.w900, 
                color: Colors.black, 
                letterSpacing: 4.0
              )
            ),
          ),
          Wrap(
            spacing: 30.0, runSpacing: 30.0, alignment: WrapAlignment.center, // Increased spacing
            children: goals.map((goal) {
              return GoalCard(title: goal['title']!, imageUrl: goal['imageUrl']!);
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// 3.7 Goal Card
class GoalCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  const GoalCard({super.key, required this.title, required this.imageUrl});
  @override
  Widget build(BuildContext context) {
    const double cardMaxWidth = 300.0; // Slightly larger card
    const double cardHeight = 400.0;
    return Container(
      width: cardMaxWidth, height: cardHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0), // Maintained radius
        color: Colors.grey.shade100, 
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), 
            blurRadius: 15, 
            offset: const Offset(0, 8)
          ), // Softer shadow
        ],
      ),
      clipBehavior: Clip.antiAlias, 
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(imageUrl, fit: BoxFit.cover),
          Container(
            decoration: BoxDecoration(
              // UPDATED: Stronger, more focused gradient
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Colors.black.withOpacity(0.0), Colors.black.withOpacity(0.8)], 
                stops: const [0.4, 1.0]), // Starts darker higher up
            ),
          ),
          Positioned(
            bottom: 25, left: 25, right: 25,
            child: Text(
              title, 
              style: const TextStyle(
                color: Colors.white, 
                fontSize: 26, // Larger text
                fontWeight: FontWeight.w900, // Heavier weight
                letterSpacing: 2.0
              )
            ),
          ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent, 
              child: InkWell(
                onTap: () {},
                // Added a subtle hover effect
                splashColor: Colors.white.withOpacity(0.3), 
              )
            )
          ),
        ],
      ),
    );
  }
}

// 3.8 Reviews Section (UPDATED: Two-Column Grid)
class ReviewsSection extends StatelessWidget {
  const ReviewsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final displayReviews = reviews.take(4).toList();

    // UPDATED: Increased vertical padding
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60.0, horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 40.0),
            child: Text(
              'TRUSTED BY THOUSANDS',
              style: TextStyle(
                fontSize: 36, // Larger size
                fontWeight: FontWeight.w900, 
                color: Colors.black, 
                letterSpacing: 4.0, // Increased spacing
              ),
            ),
          ),
          
          Wrap(
            spacing: 40.0, // Increased spacing
            runSpacing: 40.0, 
            alignment: WrapAlignment.center,
            children: displayReviews.map((review) {
              return ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450.0, minWidth: 300.0), // Wider max width for reviews
                child: ReviewCard(
                  author: review['author'],
                  rating: review['rating'],
                  text: review['text'],
                ),
              );
            }).toList(),
          ),
          
          // View More Reviews Button
          Padding(
            padding: const EdgeInsets.only(top: 60.0), // More space above button
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18), // Larger button
                side: const BorderSide(color: Colors.black, width: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)), // Consistent radius
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Navigating to the full Reviews page!')),
                );
              },
              child: const Text(
                'VIEW ALL 4.8K REVIEWS', // Uppercase text
                style: TextStyle(
                  fontSize: 18, 
                  color: Colors.black, 
                  fontWeight: FontWeight.w800, 
                  letterSpacing: 1.0
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 3.9 Review Card (Style Maintained, used in new grid)
class ReviewCard extends StatelessWidget {
  final String author;
  final int rating;
  final String text;

  const ReviewCard({
    super.key, 
    required this.author, 
    required this.rating, 
    required this.text,
  });
  
  Widget _buildStarRating(int rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          // Using slightly bolder star icons
          index < rating ? Icons.star_rate_rounded : Icons.star_border_rounded,
          color: Colors.black, // Changed star color to black/monochrome for a cleaner look
          size: 24, // Slightly larger stars
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30.0), // Increased card padding
      decoration: BoxDecoration(
        color: Colors.grey.shade50, // Slight off-white background
        borderRadius: BorderRadius.circular(15.0), 
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [ 
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start, 
        mainAxisSize: MainAxisSize.min, 
        children: [
          _buildStarRating(rating),
          
          const SizedBox(height: 20), // Increased spacing

          // Review Text 
          Text(
            '“$text”', 
            style: const TextStyle(
              fontSize: 19, // Slightly larger font
              fontWeight: FontWeight.w500, 
              color: Colors.black,
              fontStyle: FontStyle.italic, // Added italics for a quote feel
              height: 1.5, // Improved line height
            ),
          ),
          
          const SizedBox(height: 20),

          // Author
          Text(
            '- $author',
            style: const TextStyle(
              fontWeight: FontWeight.w900, // Heavier weight
              color: Colors.black,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// 3.10 Final Banner Section (1440:400)
class FinalBannerSection extends StatelessWidget {
  final String imageUrl;

  const FinalBannerSection({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    const double bannerAspectRatio = 1440 / 400;

    // UPDATED: Increased vertical padding and added horizontal padding to the image
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60.0, horizontal: 20.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0), // Consistent radius
        child: AspectRatio(
          aspectRatio: bannerAspectRatio,
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover, 
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(color: Colors.grey.shade200);
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey.shade300,
                child: const Center(child: Text("Final Banner Image Load Error", style: TextStyle(color: Colors.black54))),
              );
            },
          ),
        ),
      ),
    );
  }
}