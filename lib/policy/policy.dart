import 'package:flutter/material.dart';
import 'package:chem resolution/header.dart';
   // <<< IMPORTANT

class PolicyPageB extends StatefulWidget {
  const PolicyPageB({super.key});

  @override
  State<PolicyPageB> createState() => _PolicyPageBState();
}

class _PolicyPageBState extends State<PolicyPageB> {
  int selectedIndex = 0;

  final ScrollController scrollController = ScrollController();
  late final List<GlobalKey> sectionKeys;

  final List<String> titles = [
    "Terms & Conditions",
    "Data Collection",
    "Cookies Policy",
    "Privacy Policy",
    "Shipping Policy",
    "Contact Us",
  ];

  late final List<Widget> content;

  @override
  void initState() {
    super.initState();

    sectionKeys = List.generate(6, (index) => GlobalKey());

    content = [
      const Text(
        "These Terms & Conditions govern your use of our platform.\n\n"
        "By accessing our website, you agree to follow guidelines, provide correct information, "
        "avoid misuse of service, and respect intellectual property.\n\n"
        "We may update or suspend services anytime.\n\n",
      ),
      const Text(
        "We collect essential data including:\n\n"
        "• Name & Contact\n"
        "• Browser & Device Info\n"
        "• Location\n"
        "• Pages visited\n"
        "• Purchase history\n\n"
        "Your information helps us improve performance & security.\n\n",
      ),
      const Text(
        "Cookies improve browsing experience.\n\n"
        "Types of cookies:\n"
        "• Functional\n"
        "• Performance\n"
        "• Analytics\n"
        "• Personalization\n\n",
      ),
      const Text(
        "Your privacy is protected.\n\n"
        "You may request:\n"
        "• Data correction\n"
        "• Data deletion\n"
        "• Consent withdrawal\n\n"
        "We follow global privacy standards.\n\n",
      ),
      const Text(
        "Shipping Policy:\n\n"
        "• Orders processed in 24–48 hours\n"
        "• 3–7 days delivery (Metro)\n"
        "• 5–10 days (Rest of India)\n\n",
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("Contact Us:\n"),
          Text("Email: support@example.com"),
          SizedBox(height: 8),
          Text("Phone: +91 98765 43210"),
          SizedBox(height: 8),
          Text("Address: Model Town, Jalandhar, Punjab"),
        ],
      ),
    ];
  }

  // --------------------------------------------------------------------
  // MAIN BUILD WITH AppScaffold
  // --------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentPage: "POLICY",   // Highlight correct menu
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final screenHeight = constraints.maxHeight;
          final isMobile = screenWidth < 800;

          final headerPaddingVertical =
              (screenHeight * 0.05).clamp(30.0, 55.0);
          final sidebarWidth = (screenWidth * 0.25).clamp(220.0, 300.0);
          final contentPadding = (screenWidth * 0.04).clamp(15.0, 35.0);

          return Column(
            children: [
              // ---------------- HEADER ----------------
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                    vertical: headerPaddingVertical),
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
                      ),
                    ),
                  ],
                ),
              ),

              // ---------------- BODY ----------------
              Expanded(
                child: isMobile
                    ? _buildMobileView(contentPadding)
                    : _buildDesktopView(sidebarWidth, contentPadding),
              ),
            ],
          );
        },
      ),
    );
  }

  // --------------------------------------------------------------------
  // DESKTOP LAYOUT
  // --------------------------------------------------------------------
  Widget _buildDesktopView(double sidebarWidth, double contentPadding) {
    return Row(
      children: [
        // SIDEBAR
        Container(
          width: sidebarWidth,
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
              )
            ],
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: titles.length,
            itemBuilder: (context, i) {
              return _buildNavItem(
                title: titles[i],
                isActive: selectedIndex == i,
                onTap: () => _scrollToIndex(i),
              );
            },
          ),
        ),

        // CONTENT AREA
        Expanded(child: _buildContentScroll()),
      ],
    );
  }

  // --------------------------------------------------------------------
  // MOBILE LAYOUT
  // --------------------------------------------------------------------
  Widget _buildMobileView(double contentPadding) {
    return SingleChildScrollView(
      controller: scrollController,
      padding:
          EdgeInsets.symmetric(horizontal: contentPadding, vertical: 12),
      child: Column(
        children: [
          // DROPDOWN
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
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
                  (i) => DropdownMenuItem(value: i, child: Text(titles[i])),
                ),
                onChanged: (value) {
                  if (value != null) _scrollToIndex(value);
                },
              ),
            ),
          ),

          const SizedBox(height: 20),

          _buildContentScroll(),
        ],
      ),
    );
  }

  // --------------------------------------------------------------------
  // CONTENT AREA SHARED
  // --------------------------------------------------------------------
  Widget _buildContentScroll() {
    return SingleChildScrollView(
      controller: scrollController,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 18,
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
                        height: 20,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          titles[index],
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
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
    );
  }

  // --------------------------------------------------------------------
  // SCROLL TO SECTION
  // --------------------------------------------------------------------
  void _scrollToIndex(int i) {
    setState(() => selectedIndex = i);

    final context = sectionKeys[i].currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  // --------------------------------------------------------------------
  // SIDEBAR/TAB ITEM WIDGET
  // --------------------------------------------------------------------
  Widget _buildNavItem({
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.amber : Colors.white,
          borderRadius: BorderRadius.circular(10),
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
          ),
        ),
      ),
    );
  }
}
