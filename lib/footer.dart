// /lib/main.dart
// Fully responsive footer for mobile and desktop

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:chem_revolutions/about/about.dart';

class MyFooter extends StatelessWidget {
  const MyFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChemRevolutions Footer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color.fromARGB(255, 8, 8, 8),
      ),
      home: const Scaffold(body: FooterDemoPage()),
    );
  }
}

class FooterDemoPage extends StatelessWidget {
  const FooterDemoPage({super.key});

  // ----------- INTERNAL PAGE FUNCTIONS -------------
  void homePage() {
    print("Go to Home Page");
  }

  void categoriesPage() {
    print("Go to Categories Page");
  }

  void productDetailPage() {
    print("Go to Product Detail Page");
  }

  void contactPage() {
    print("Go to Contact Page");
  }
  // --------------------------------------------------

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

    final columns = [
      FooterColumn(
        title: 'QUICK LINKS',
        items: [
          FooterItem(label: 'Home', onTap: homePage),
          FooterItem(label: 'Categories', onTap: categoriesPage),
          FooterItem(label: 'Product Detail', onTap: productDetailPage),
          FooterItem(label: 'Contact Us', onTap: contactPage),
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutPage()),
              );
            },
          ),

          FooterItem(
            label: 'Privacy Policy',
            url: "https://chemrevolutions.com/privacy",
          ),
          FooterItem(
            label: 'Data Collection',
            url: "https://chemrevolutions.com/data",
          ),
        ],
      ),
      FooterColumn(
        title: 'POLICIES',
        items: [
          FooterItem(
            label: 'Privacy Policy',
            url: "https://chemrevolutions.com/privacy",
          ),
          FooterItem(
            label: 'Data Collection',
            url: "https://chemrevolutions.com/data",
          ),
          FooterItem(
            label: 'Terms & Conditions',
            url: "https://chemrevolutions.com/terms",
          ),
        ],
      ),
    ];

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 50),
          Footer(
            logo: FooterLogo(
              image: Image.asset('assets/icons/chemo.png', fit: BoxFit.contain),
              onTapUrl: "https://chemrevolutions.com",
            ),
            socialLinks: social,
            columns: columns,
            copyright: "© 2025 ChemRevolutions.com. All rights reserved.",
          ),
        ],
      ),
    );
  }
}

// MODELS ---------------------------------------------

class FooterItem {
  final String label;
  final String? url;
  final VoidCallback? onTap;
  FooterItem({required this.label, this.url, this.onTap});
}

class FooterColumn {
  final String title;
  final List<FooterItem> items;
  FooterColumn({required this.title, required this.items});
}

class SocialLink {
  final IconData icon;
  final String? url;
  SocialLink({required this.icon, this.url});
}

class FooterLogo {
  final Image image;
  final String? onTapUrl;
  FooterLogo({required this.image, this.onTapUrl});
}

// FOOTER WIDGET --------------------------------------

class Footer extends StatelessWidget {
  final FooterLogo logo;
  final List<SocialLink> socialLinks;
  final List<FooterColumn> columns;
  final String copyright;

  const Footer({
    super.key,
    required this.logo,
    required this.socialLinks,
    required this.columns,
    required this.copyright,
  });

  @override
  Widget build(BuildContext context) {
    final muted = const Color.fromARGB(255, 248, 244, 244);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1000;

    return Container(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 16 : 20,
        isMobile ? 30 : 40,
        isMobile ? 16 : 20,
        isMobile ? 20 : 30,
      ),
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          children: [
            if (isMobile)
              _mobileLayout(muted)
            else if (isTablet)
              _tabletLayout(muted)
            else
              _desktopLayout(muted),
            SizedBox(height: isMobile ? 20 : 30),
            Text(
              copyright,
              textAlign: TextAlign.center,
              style: TextStyle(color: muted, fontSize: isMobile ? 11 : 13),
            ),
          ],
        ),
      ),
    );
  }

  // Desktop Layout (1000px+)
  Widget _desktopLayout(Color muted) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 260, child: _brand(muted, false)),
        const SizedBox(width: 20),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: columns.map((c) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 30),
                  child: _column(c, muted, false),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // Tablet Layout (600px - 999px)
  Widget _tabletLayout(Color muted) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _brand(muted, true),
        const SizedBox(height: 30),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 30,
          runSpacing: 25,
          children: columns
              .map((c) => SizedBox(width: 200, child: _column(c, muted, false)))
              .toList(),
        ),
      ],
    );
  }

  // Mobile Layout (<600px)
  Widget _mobileLayout(Color muted) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _brand(muted, true),
        const SizedBox(height: 10),
        // First row: Quick Links and Customer Service
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _column(columns[0], muted, true)),
            const SizedBox(width: 16),
            Expanded(child: _column(columns[1], muted, true)),
          ],
        ),
        const SizedBox(height: 20),
        // Second row: Information and Policies
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _column(columns[2], muted, true)),
            const SizedBox(width: 16),
            Expanded(child: _column(columns[3], muted, true)),
          ],
        ),
      ],
    );
  }

  Widget _brand(Color muted, bool isCentered) {
    return Transform.translate(
      offset: const Offset(0, -24),
      child: Column(
        crossAxisAlignment: isCentered
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: logo.onTapUrl == null
                ? null
                : () async => _openUrl(logo.onTapUrl!),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isCentered ? 200 : 260,
                maxHeight: isCentered ? 120 : 150,
              ),
              child: logo.image,
            ),
          ),
          Transform.translate(
            offset: Offset(0, isCentered ? -35 : -40),
            child: Column(
              children: [
                Text(
                  "Follow Us",
                  style: TextStyle(
                    fontSize: isCentered ? 14 : 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: socialLinks.map((s) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: HoverIcon(
                        icon: s.icon,
                        isMobile: isCentered,
                        onTap: () async =>
                            s.url != null ? await _openUrl(s.url!) : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _column(FooterColumn column, Color muted, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          column.title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isMobile ? 14 : 16,
          ),
        ),
        SizedBox(height: isMobile ? 8 : 12),
        ...column.items.map((item) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: isMobile ? 4 : 6),
            child: LinkText(
              label: item.label,
              mutedColor: muted,
              isMobile: isMobile,
              onTap:
                  item.onTap ??
                  () async {
                    if (item.url != null) await _openUrl(item.url!);
                  },
            ),
          );
        }),
      ],
    );
  }
}

// HOVER LINK -----------------------------------------

class LinkText extends StatefulWidget {
  final String label;
  final Color mutedColor;
  final VoidCallback onTap;
  final bool isMobile;

  const LinkText({
    super.key,
    required this.label,
    required this.mutedColor,
    required this.onTap,
    this.isMobile = false,
  });

  @override
  State<LinkText> createState() => _LinkTextState();
}

class _LinkTextState extends State<LinkText> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 150),
          style: TextStyle(
            color: hover
                ? const Color.fromARGB(255, 209, 209, 170)
                : widget.mutedColor,
            decoration: hover ? TextDecoration.underline : TextDecoration.none,
            fontSize: widget.isMobile ? 13 : 15,
          ),
          child: Text(widget.label, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}

// HOVER ICON -----------------------------------------

class HoverIcon extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool isMobile;

  const HoverIcon({
    super.key,
    required this.icon,
    this.onTap,
    this.isMobile = false,
  });

  @override
  State<HoverIcon> createState() => _HoverIconState();
}

class _HoverIconState extends State<HoverIcon> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    final size = widget.isMobile ? 32.0 : 28.0;
    final iconSize = widget.isMobile ? 14.0 : 12.0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: hover ? Colors.white24 : Colors.white10,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: AnimatedScale(
              scale: hover ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 150),
              child: FaIcon(widget.icon, size: iconSize, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

// open external links
Future<void> _openUrl(String url) async {
  final uri = Uri.parse(url);
  if (!await canLaunchUrl(uri)) return;
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}
