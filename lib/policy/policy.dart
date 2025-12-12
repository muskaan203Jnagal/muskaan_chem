import 'package:flutter/material.dart';
import 'package:chem_revolutions/header.dart';
import 'package:chem_revolutions/footer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
    "Contact Us",
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
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentPage: 'POLICY',
      body: Container(
        color: const Color(0xFFF7F8FA),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final isMobile = screenWidth < 800;

            final sidebarWidth = (screenWidth * 0.25).clamp(220.0, 300.0);
            final contentPadding = (screenWidth * 0.04).clamp(15.0, 35.0);

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        isMobile
                            ? _buildMobileView(contentPadding)
                            : _buildDesktopView(sidebarWidth, contentPadding),

                        const SizedBox(height: 40),

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
                                    FooterItem(label: 'Home'),
                                    FooterItem(label: 'Categories'),
                                    FooterItem(label: 'Product Detail'),
                                    FooterItem(label: 'Contact Us'),
                                  ],
                                ),
                                FooterColumn(
                                  title: 'CUSTOMER SERVICE',
                                  items: [
                                    FooterItem(
                                      label: 'My Account',
                                      url:
                                          "https://chemrevolutions.com/account",
                                    ),
                                    FooterItem(
                                      label: 'Order Status',
                                      url: "https://chemrevolutions.com/orders",
                                    ),
                                    FooterItem(
                                      label: 'Wishlist',
                                      url:
                                          "https://chemrevolutions.com/wishlist",
                                    ),
                                  ],
                                ),
                                FooterColumn(
                                  title: 'INFORMATION',
                                  items: [
                                    FooterItem(label: 'About Us'),
                                    FooterItem(label: 'Privacy Policy'),
                                    FooterItem(label: 'Data Collection'),
                                  ],
                                ),
                                FooterColumn(
                                  title: 'POLICIES',
                                  items: [
                                    FooterItem(label: 'Privacy Policy'),
                                    FooterItem(label: 'Data Collection'),
                                    FooterItem(label: 'Terms & Conditions'),
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
            );
          },
        ),
      ),
    );
  }

  // -------------------------- DESKTOP VIEW --------------------------
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
              BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15),
            ],
          ),
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
              SizedBox(height: 20),

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

        Expanded(child: _buildContentScroll()),
      ],
    );
  }

  // -------------------------- MOBILE VIEW --------------------------
  Widget _buildMobileView(double contentPadding) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(contentPadding),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(blurRadius: 8, color: Colors.black.withOpacity(0.1)),
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
                  child: Text(titles[i], overflow: TextOverflow.ellipsis),
                ),
              ),
              onChanged: (value) {
                setState(() => selectedIndex = value!);
                Scrollable.ensureVisible(
                  sectionKeys[value!].currentContext!,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              },
            ),
          ),
        ),

        SizedBox(height: contentPadding),

        _buildContentScroll(),
      ],
    );
  }

  // ----------------------- MAIN CONTENT AREA -----------------------
  Widget _buildContentScroll() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 800),
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20),
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
                    SizedBox(width: 10),
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
    );
  }

  // -------------------------- NAV ITEM --------------------------
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
        ),
      ),
    );
  }
}
//12-12-25
