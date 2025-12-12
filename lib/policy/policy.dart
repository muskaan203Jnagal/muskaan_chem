import 'package:flutter/material.dart';

// import your header (AppScaffold) and footer (Footer) files
import 'package:chem_revolutions/header.dart';
import 'package:chem_revolutions/footer.dart'; // <-- adjust path if needed

class PolicyPageB extends StatefulWidget {
  const PolicyPageB({super.key});

  @override
  State<PolicyPageB> createState() => _PolicyPageBState();
}

class _PolicyPageBState extends State<PolicyPageB> {
  int selectedIndex = 0;

  final ScrollController scrollController = ScrollController();
  final List<GlobalKey> sectionKeys = List.generate(6, (index) => GlobalKey());

  final List<String> titles = [
    "Terms & Conditions",
    "Data Collection",
    "Cookies Policy",
    "Privacy Policy",
    "Shipping Policy",
    "Contact Us"
  ];

  final List<Widget> content = [
    Text(
      "These Terms & Conditions govern your use of our platform.\n\n"
      "By accessing our website, you agree to follow guidelines, provide correct information, "
      "avoid misuse of service, and respect intellectual property.\n\n"
      "We may update or suspend services anytime.\n\n",
    ),
    Text(
      "We collect essential data including:\n\n"
      "• Name & Contact\n"
      "• Browser & Device Info\n"
      "• Location\n"
      "• Pages visited\n"
      "• Purchase history\n\n"
      "Your information helps us improve performance & security.\n\n",
    ),
    Text(
      "Cookies improve browsing experience.\n\n"
      "Types of cookies:\n"
      "• Functional\n"
      "• Performance\n"
      "• Analytics\n"
      "• Personalization\n\n",
    ),
    Text(
      "Your privacy is protected.\n\n"
      "You may request:\n"
      "• Data correction\n"
      "• Data deletion\n"
      "• Consent withdrawal\n\n"
      "We follow global privacy standards.\n\n",
    ),
    Text(
      "Shipping Policy:\n\n"
      "• Orders processed in 24–48 hours\n"
      "• 3–7 days delivery (Metro)\n"
      "• 5–10 days (Rest of India)\n\n",
    ),
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Contact Us:\n"),
        Text("Email: support@example.com"),
        SizedBox(height: 8),
        Text("Phone: +91 98765 43210"),
        SizedBox(height: 8),
        Text("Address: Model Town, Jalandhar, Punjab"),
      ],
    )
  ];

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Wrap the whole page inside your AppScaffold so header/drawer works
    return AppScaffold(
      currentPage: 'POLICY',
      body: _buildPageContent(context),
    );
  }

  // builds the page content that will be put into the AppScaffold's body
  Widget _buildPageContent(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;
        final isMobile = screenWidth < 800;

        // responsive sizes
        final headerPaddingVertical = (screenHeight * 0.05).clamp(30.0, 55.0);
        final sidebarWidth = (screenWidth * 0.25).clamp(220.0, 300.0);
        final contentPadding = (screenWidth * 0.04).clamp(15.0, 35.0);

        return Column(
          children: [
            // header area (page header inside body)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: headerPaddingVertical),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black, Color(0xFF222222)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      "Privacy Policy",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: (screenWidth * 0.07).clamp(24.0, 40.0),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(height: (screenHeight * 0.01).clamp(6.0, 8.0)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: contentPadding),
                    child: Text(
                      "Your privacy, security & trust are our responsibility.",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: (screenWidth * 0.04).clamp(12.0, 16.0),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // body area
            Expanded(
              child: isMobile
                  ? _buildMobileView(contentPadding)
                  : _buildDesktopView(sidebarWidth, contentPadding),
            ),
          ],
        );
      },
    );
  }

  // Desktop layout (keeps your existing sidebar + content behaviour)
  Widget _buildDesktopView(double sidebarWidth, double contentPadding) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: sidebarWidth,
          margin: EdgeInsets.all((sidebarWidth * 0.08).clamp(15.0, 25.0)),
          padding: EdgeInsets.all((sidebarWidth * 0.08).clamp(15.0, 25.0)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 15,
              )
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Quick Navigation",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: (sidebarWidth * 0.08).clamp(15.0, 18.0),
                  ),
                ),
                SizedBox(height: (sidebarWidth * 0.07).clamp(14.0, 20.0)),
                for (int i = 0; i < titles.length; i++)
                  _buildNavItem(
                    title: titles[i],
                    isActive: selectedIndex == i,
                    onTap: () {
                      setState(() => selectedIndex = i);
                      Scrollable.ensureVisible(
                        sectionKeys[i].currentContext!,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    },
                  ),
              ],
            ),
          ),
        ),

        // main content + footer
        Expanded(
          child: _buildContentScroll(includeFooter: true),
        ),
      ],
    );
  }

  // Mobile layout
  Widget _buildMobileView(double contentPadding) {
    return SingleChildScrollView(
      controller: scrollController,
      padding: EdgeInsets.symmetric(horizontal: contentPadding, vertical: 8),
      child: Column(
        children: [
          // Dropdown navigation for mobile
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: contentPadding,
              vertical: (contentPadding * 0.8).clamp(10.0, 14.0),
            ),
            margin: EdgeInsets.symmetric(horizontal: contentPadding),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  blurRadius: 8,
                  color: Colors.black.withOpacity(0.1),
                )
              ],
            ),
            child: DropdownButtonHideUnderline(
             child: DropdownButton<int>(
  value: selectedIndex,
  isExpanded: true,
  items: List.generate(
    titles.length,
    (i) => DropdownMenuItem(
      value: i,
      child: Text(
        titles[i],
        overflow: TextOverflow.ellipsis,
      ),
    ),
  ),
  onChanged: (value) {
    if (value == null) return; // prevent null crash

    setState(() => selectedIndex = value);

    Scrollable.ensureVisible(
      sectionKeys[value].currentContext!,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  },
),

            ),
          ),

          SizedBox(height: contentPadding),

          _buildContentScroll(includeFooter: true),
        ],
      ),
    );
  }

  // Shared content builder; set includeFooter true to attach the Footer widget
  Widget _buildContentScroll({bool includeFooter = false}) {
    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 800),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                titles.length,
                (index) => Container(
                  key: sectionKeys[index],
                  margin: const EdgeInsets.only(bottom: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 5,
                            height: 18,
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              titles[index],
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DefaultTextStyle(
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.6,
                          color: Colors.black87,
                        ),
                        child: content[index],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // small spacing before footer
          const SizedBox(height: 30),

          // include your footer (constructed like FooterDemoPage)
          if (includeFooter) _buildFooter(),
        ],
      ),
    );
  }

  // Reuse the Footer widget (not MyFooter) and construct demo columns + socials
  Widget _buildFooter() {
    // create the columns & social links same as FooterDemoPage in footer.dart
    final social = [
      SocialLink(icon: Icons.camera_alt, url: 'https://instagram.com'),
      SocialLink(icon: Icons.facebook, url: 'https://facebook.com'),
      SocialLink(icon: Icons.share, url: 'https://twitter.com'),
    ];

    final columns = [
      FooterColumn(
        title: 'QUICK LINKS',
        items: [
          FooterItem(label: 'Home', onTap: () {}),
          FooterItem(label: 'Categories', onTap: () {}),
          FooterItem(label: 'Product Detail', onTap: () {}),
          FooterItem(label: 'Contact Us', onTap: () {}),
        ],
      ),
      FooterColumn(
        title: 'CUSTOMER SERVICE',
        items: [
          FooterItem(label: 'My Account', url: "https://chemrevolutions.com/account"),
          FooterItem(label: 'Order Status', url: "https://chemrevolutions.com/orders"),
          FooterItem(label: 'Wishlist', url: "https://chemrevolutions.com/wishlist"),
        ],
      ),
      FooterColumn(
        title: 'INFORMATION',
        items: [
          FooterItem(
            label: 'About Us',
            onTap: () {
              // navigate if your app has route
            },
          ),
          FooterItem(label: 'Privacy Policy', url: "https://chemrevolutions.com/privacy"),
          FooterItem(label: 'Data Collection', url: "https://chemrevolutions.com/data"),
        ],
      ),
      FooterColumn(
        title: 'POLICIES',
        items: [
          FooterItem(label: 'Privacy Policy', url: "https://chemrevolutions.com/privacy"),
          FooterItem(label: 'Data Collection', url: "https://chemrevolutions.com/data"),
          FooterItem(label: 'Terms & Conditions', url: "https://chemrevolutions.com/terms"),
        ],
      ),
    ];

    final footerLogo = FooterLogo(
      image: Image.asset('assets/icons/chemo.png', fit: BoxFit.contain),
      onTapUrl: "https://chemrevolutions.com",
    );

    return Footer(
      logo: footerLogo,
      socialLinks: social,
      columns: columns,
      copyright: "© 2025 ChemRevolutions.com. All rights reserved.",
    );
  }

  // Navigation item builder (unchanged)
  Widget _buildNavItem({
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.amber : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border(
            left: BorderSide(
              color: isActive ? Colors.black : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: Colors.black,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
