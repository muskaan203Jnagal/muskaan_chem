import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:chem_revolutions/header.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:chem_revolutions/homepage/homepage.dart';
import 'package:chem_revolutions/footer.dart';

void main() {
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: HomePage()));
}

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage>
    with SingleTickerProviderStateMixin {
  int activeCard = -1;

  late final AnimationController _titleController;
  late final Animation<double> _titleAnim;

  @override
  void initState() {
    super.initState();
    _titleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _titleAnim = Tween<double>(
      begin: -1.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _titleController, curve: Curves.linear));
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  double responsiveImgHeight(double w) {
    if (w < 560) return 110;
    if (w < 1200) return 150;
    return 180;
  }

  // ---------------- PRODUCT POPUP ----------------
  void showProductPopup({
    required String title,
    required String subtitle,
    required String img,
    required List<String> benefits,
  }) {
    final w = MediaQuery.of(context).size.width;
    final imgHeight = responsiveImgHeight(w) + 40;

    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: const Color(0xff0f0f0f),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Image.asset(
                    "assets/images/products/$img",
                    height: imgHeight,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 12),

                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),

                  const SizedBox(height: 15),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Benefits",
                      style: TextStyle(
                        color: Color(0xffd4b15f),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  ...benefits.map(
                    (b) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.check,
                            color: Colors.amber,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              b,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffd4b15f),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 26,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      "Close",
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------- BUILD START ----------------
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    final List<Map<String, dynamic>> products = [
      {
        "title": "Bovine Aminos",
        "subtitle": "Pure amino matrix for recovery & muscle support.",
        "img": "aminos.png",
        "benefits": [
          "Speeds up muscle recovery",
          "Supports lean muscle growth",
          "Reduces muscle soreness",
        ],
      },
      {
        "title": "Monster Pack",
        "subtitle": "Ultimate strength & endurance stack.",
        "img": "monster_pack.png",
        "benefits": [
          "Boosts stamina & strength",
          "Enhances recovery",
          "Improves workout performance",
        ],
      },
      {
        "title": "Creatine Monohydrate",
        "subtitle": "Micronized creatine for explosive strength.",
        "img": "creatine.png",
        "benefits": [
          "Boosts power output",
          "Increases muscle fullness",
          "Enhances ATP production",
        ],
      },
      {
        "title": "Multivitamins",
        "subtitle": "Daily micronutrients for full-body performance.",
        "img": "multivitamin.png",
        "benefits": [
          "Boosts immunity",
          "Supports metabolism",
          "Improves energy levels",
        ],
      },
      {
        "title": "Liver Support",
        "subtitle": "Advanced detox & liver protection.",
        "img": "liver_support.png",
        "benefits": [
          "Detoxifies liver",
          "Improves enzyme activity",
          "Supports liver function",
        ],
      },
      {
        "title": "D3 + K2",
        "subtitle": "Bone, immunity & cardiovascular support.",
        "img": "d3k2.png",
        "benefits": [
          "Strengthens bones",
          "Boosts immune system",
          "Supports heart health",
        ],
      },
      {
        "title": "NAC + TUDCA",
        "subtitle": "Advanced antioxidant & liver support.",
        "img": "nac_tudca.png",
        "benefits": [
          "Boosts glutathione",
          "Repairs liver damage",
          "Reduces oxidative stress",
        ],
      },
      {
        "title": "CoQ10",
        "subtitle": "Energy & heart health support.",
        "img": "coq10.png",
        "benefits": [
          "Boosts cellular energy",
          "Improves endurance",
          "Supports cardiovascular health",
        ],
      },
    ];

    int crossAxis = w < 560
        ? 1
        : w < 950
        ? 2
        : 4; // responsive grid

    return DefaultTextStyle.merge(
      style: GoogleFonts.montserrat(),
      child: AppScaffold(
        currentPage: 'ABOUT',
        body: Stack(
          children: [
            // BACKGROUND
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/bg.jpg"),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.35),
                    BlendMode.darken,
                  ),
                ),
              ),
            ),
            // LEFT SIDE GYM GIRL IMAGE
            Positioned(
              left: 20,
              top: 40,
              child: Opacity(
                opacity: 0.25,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(
                    sigmaX: 0.8,
                    sigmaY: 0.8,
                  ), // ⭐ blur ghataya
                  child: SizedBox(
                    height: w < 560
                        ? 260
                        : w < 950
                        ? 360
                        : 500,
                    width:
                        (w < 560
                            ? 260
                            : w < 950
                            ? 360
                            : 500) *
                        0.70,
                    child: Image.asset(
                      "assets/images/girl.jpg",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),

            // RIGHT SIDE STATIC GYM IMAGE
            Positioned(
              right: 20, // ⭐ shift more inside
              top: 40, // ⭐ little up
              child: Opacity(
                opacity: 0.25,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                  child: SizedBox(
                    height: w < 560
                        ? 260
                        : w < 950
                        ? 360
                        : 500,
                    width:
                        (w < 560
                            ? 260
                            : w < 950
                            ? 360
                            : 500) *
                        0.70,
                    child: Image.asset(
                      "assets/images/boy.jpg",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),

            // MAIN CONTENT
            SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // LOGO
                    Image.asset("assets/images/chem-logo.png", height: 110),
                    const SizedBox(height: 12),

                    // HERO SECTION
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Column(
                        children: [
                          AnimatedBuilder(
                            animation: _titleAnim,
                            builder: (_, __) {
                              return ShaderMask(
                                shaderCallback: (bounds) {
                                  return LinearGradient(
                                    begin: Alignment(_titleAnim.value, 0),
                                    end: Alignment(_titleAnim.value + 1, 0),
                                    colors: [
                                      Colors.white,
                                      Colors.white,
                                      Color(0xffd4b15f),
                                      Colors.white,
                                    ],
                                    stops: const [0.0, 0.4, 0.6, 1.0],
                                  ).createShader(bounds);
                                },
                                child: const Text(
                                  "ABOUT CHEM REVOLUTION",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 1,
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 12),

                          Container(
                            width: 160,
                            height: 4,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              gradient: LinearGradient(
                                colors: [Color(0xffd4b15f), Color(0xffb89443)],
                              ),
                            ),
                          ),

                          const SizedBox(height: 22),

                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 780),
                            child: const Text(
                              '"CHEM Revolution — Elite Series defines the future of high-performance nutrition. Powered by clinically validated active ingredients and precision-engineered formulations, every product is crafted to enhance strength, elevate endurance capacity, and accelerate deep cellular recovery—unlocking peak human performance. Each blend is developed through rigorous research and real-world athletic testing to ensure unmatched effectiveness. With superior bioavailability and targeted nutrient delivery, our formulas work faster, penetrate deeper, and last longer. CHEM Revolution sets a new gold standard for athletes who demand nothing less than elite-level precision and performance."',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 15,
                                height: 1.7,
                              ),
                            ),
                          ),

                          const SizedBox(height: 22),

                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, "/product");
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              elevation: 6,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                                side: BorderSide(
                                  color: Color(0xffd4b15f),
                                  width: 1.2,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 26,
                                vertical: 12,
                              ),
                            ),
                            child: const Text(
                              "Shop Now",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 34),

                    // ---------------- SUPPLEMENT GRID ----------------
                    const Text(
                      "Our Core Supplements",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xffd4b15f),
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Scientifically formulated and athlete-trusted.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: products.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxis,
                          crossAxisSpacing: 18,
                          mainAxisSpacing: 18,
                          childAspectRatio: w < 560
                              ? 0.80
                              : w < 950
                              ? 0.85
                              : 0.95,
                        ),
                        itemBuilder: (context, index) {
                          final p = products[index];

                          return GestureDetector(
                            onTapDown: (_) =>
                                setState(() => activeCard = index),
                            onTapUp: (_) {
                              Future.delayed(
                                const Duration(milliseconds: 120),
                                () => setState(() => activeCard = -1),
                              );

                              showProductPopup(
                                title: p["title"],
                                subtitle: p["subtitle"],
                                img: p["img"],
                                benefits: List<String>.from(p["benefits"]),
                              );
                            },
                            onTapCancel: () => setState(() => activeCard = -1),

                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: activeCard == index
                                      ? Color(0xffd4b15f)
                                      : Colors.white24,
                                  width: activeCard == index ? 2 : 1,
                                ),
                                boxShadow: activeCard == index
                                    ? [
                                        BoxShadow(
                                          color: Color(
                                            0xffd4b15f,
                                          ).withOpacity(0.6),
                                          blurRadius: 18,
                                          spreadRadius: 1,
                                        ),
                                      ]
                                    : [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.30),
                                          blurRadius: 8,
                                          spreadRadius: 1,
                                        ),
                                      ],
                              ),

                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Image.asset(
                                      "assets/images/products/${p["img"]}",
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    p["title"],
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 40),

                    // ---------------- WHY CHOOSE SECTION ----------------
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const Text(
                            "WHY CHOOSE CHEM ELITE?",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xffd4b15f),
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 10),

                          Container(
                            width: 120,
                            height: 3,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xffd4b15f), Color(0xffb89443)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),

                          const SizedBox(height: 16),

                          const Text(
                            "High-purity ingredients\n"
                            "Lab-tested quality\n"
                            "Safe & effective formulations\n"
                            "Designed for real-world athletic performance",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white70,
                              height: 1.6,
                              fontSize: 15,
                            ),
                          ),

                          const SizedBox(height: 24),

                          LayoutBuilder(
                            builder: (context, constraints) {
                              bool isMobile = constraints.maxWidth < 260;

                              if (isMobile) {
                                return Column(
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pushNamed(
                                          context,
                                          "/product",
                                        );
                                      },
                                      style: TextButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 22,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            26,
                                          ),
                                          side: BorderSide(
                                            color: Color(0xffd4b15f),
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        "Buy Now",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    OutlinedButton(
                                      onPressed: () {
                                        Navigator.of(
                                          context,
                                          rootNavigator: true,
                                        ).pushNamed('/contact');
                                      },
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(color: Colors.white70),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 22,
                                          vertical: 12,
                                        ),
                                      ),
                                      child: Text(
                                        "Contact",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                );
                              }

                              // TABLET + DESKTOP
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushNamed(context, "/product");
                                    },
                                    style: TextButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 22,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(26),
                                        side: BorderSide(
                                          color: Color(0xffd4b15f),
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      "Buy Now",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  SizedBox(width: 14),
                                  OutlinedButton(
                                    onPressed: () {
                                      Navigator.of(
                                        context,
                                        rootNavigator: true,
                                      ).pushNamed('/contact');
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: Colors.white70),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 22,
                                        vertical: 12,
                                      ),
                                    ),
                                    child: Text(
                                      "Contact",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    Theme(
                      data: ThemeData.dark().copyWith(
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
                          socialLinks: [
                            SocialLink(
                              icon: FontAwesomeIcons.instagram,
                              url: 'https://instagram.com',
                            ),
                            SocialLink(
                              icon: FontAwesomeIcons.facebookF,
                              url: 'https://facebook.com',
                            ),
                            SocialLink(
                              icon: FontAwesomeIcons.twitter,
                              url: 'https://twitter.com',
                            ),
                          ],
                          columns: [
                            FooterColumn(
                              title: 'QUICK LINKS',
                              items: [
                                FooterItem(
                                  label: 'Home',
                                  onTap: () {
                                    Navigator.of(
                                      context,
                                      rootNavigator: true,
                                    ).pushReplacementNamed('/home');
                                  },
                                ),
                                FooterItem(
                                  label: 'Categories',
                                  onTap: () {
                                    Navigator.of(
                                      context,
                                      rootNavigator: true,
                                    ).pushReplacementNamed('/home');
                                  },
                                ),
                                FooterItem(
                                  label: 'Product Detail',
                                  onTap: () {
                                    Navigator.of(
                                      context,
                                      rootNavigator: true,
                                    ).pushReplacementNamed('/home');
                                  },
                                ),
                                FooterItem(
                                  label: 'Contact Us',
                                  onTap: () {
                                    Navigator.of(
                                      context,
                                      rootNavigator: true,
                                    ).pushReplacementNamed('/contact');
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
                                   onTap: () {
                                    Navigator.pushNamed(context, '/my-wishlist');
                                  },
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
                                  label: 'policy',
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
                                  label: 'Terms and Conditions',
                                  onTap: () {
                                    Navigator.pushNamed(context, '/policy');
                                  },
                                ),
                              ],
                            ),
                          ],
                          copyright:
                              "© 2025 ChemRevolutions.com. All rights reserved.",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
