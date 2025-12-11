import 'package:flutter/material.dart';
import 'package:chem_revolutions/homepage/homepage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:chem_revolutions/about/about.dart';

// Responsive breakpoints
class ResponsiveBreakpoints {
  static const double mobile = 768;
  static const double tablet = 1024;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobile;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobile && width < tablet;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tablet;
}

// Main reusable widget that wraps your pages with header and drawer
class AppScaffold extends StatefulWidget {
  final String currentPage;
  final Widget body;

  const AppScaffold({Key? key, required this.currentPage, required this.body})
    : super(key: key);

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isDrawerOpen = false;
  AnimationController? _drawerAnimationController;
  Animation<double>? _drawerSlideAnimation;

  final List<String> _messages = [
    'FREE SHIPPING ON ORDERS OVER \$50 | PREMIUM QUALITY GUARANTEED',
    'ELITE SERIES - ULTIMATE PERFORMANCE & POWER',
    'NEW ARRIVALS - SHOP THE LATEST COLLECTION NOW',
    'LIMITED TIME OFFER - 20% OFF ON SELECT PRODUCTS',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    Future.delayed(Duration.zero, () {
      _startMessageRotation();
    });
  }

  void _initializeAnimations() {
    _drawerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _drawerSlideAnimation = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _drawerAnimationController!,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _drawerAnimationController?.dispose();
    super.dispose();
  }

  void _startMessageRotation() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _messages.length;
        });
        return true;
      }
      return false;
    });
  }

  void _toggleDrawer() {
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
    });

    if (_isDrawerOpen) {
      _drawerAnimationController?.forward();
    } else {
      _drawerAnimationController?.reverse();
    }
  }

  void _navigateToPage(String page) {
    // Close drawer first
    if (_isDrawerOpen) {
      setState(() {
        _isDrawerOpen = false;
      });
      _drawerAnimationController?.reverse();
    }

    // Navigate if different page
    if (widget.currentPage != page) {
      Navigator.pushReplacementNamed(context, '/${page.toLowerCase()}');
    }
  }

  Widget _buildDrawer(bool isTablet) {
    return Container(
      height: double.infinity,
      width: isTablet ? 400 : double.infinity, // Fixed width for tablet
      color: Colors.black,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with close button
            Container(
              padding: EdgeInsets.all(isTablet ? 24 : 20),
              color: Colors.black,
              child: Row(
                children: [
                  Image.asset(
                    'assets/icons/chemo.png',
                    height: isTablet ? 48 : 42,
                    fit: BoxFit.contain,
                    errorBuilder: (c, e, s) => Icon(
                      Icons.image,
                      color: Colors.white,
                      size: isTablet ? 40 : 36,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'CHEM Revolution',
                      style: TextStyle(
                        color: const Color(0xFFD4AF37),
                        fontSize: isTablet ? 20 : 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _toggleDrawer,
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: isTablet ? 30 : 28,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(color: Colors.white24, height: 1),

            // Scrollable navigation items
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDrawerItem(
                      'HOME',
                      Icons.home_outlined,
                      isActive: widget.currentPage == 'HOME',
                      onTap: () => _navigateToPage('HOME'),
                      isTablet: isTablet,
                    ),
                    _buildDrawerItem(
                      'ABOUT',
                      Icons.info_outline,
                      isActive: widget.currentPage == 'ABOUT',
                      onTap: () => _navigateToPage('ABOUT'),
                      isTablet: isTablet,
                    ),
                    _buildDrawerItem(
                      'GET VERIFIED',
                      Icons.verified_user_outlined,
                      isActive: widget.currentPage == 'GETVERIFIED',
                      onTap: () => _navigateToPage('GETVERIFIED'),
                      isTablet: isTablet,
                    ),
                    _buildDrawerItem(
                      'PRODUCTS',
                      Icons.shopping_bag_outlined,
                      isActive: widget.currentPage == 'PRODUCTS',
                      onTap: () => _navigateToPage('PRODUCTS'),
                      isTablet: isTablet,
                    ),

                    const Divider(color: Colors.white24, height: 1),

                    _buildDrawerItem(
                      'PROFILE',
                      Icons.person_outline,
                      onTap: () {
                        _toggleDrawer();
                      },
                      isTablet: isTablet,
                    ),

                    const Divider(color: Colors.white24, height: 1),
                  ],
                ),
              ),
            ),

            // Bottom section with logo and social icons
            Container(
              padding: EdgeInsets.symmetric(
                vertical: isTablet ? 24 : 20,
                horizontal: isTablet ? 20 : 16,
              ),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo
                  Image.asset(
                    'assets/icons/chemo.png',
                    height: isTablet ? 140 : 120,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.image,
                        color: Colors.white,
                        size: isTablet ? 70 : 60,
                      );
                    },
                  ),
                  SizedBox(width: isTablet ? 28 : 24),
                  // Social icons
                  _buildSocialIcon(
                    icon: FontAwesomeIcons.instagram,
                    onTap: () {},
                    isTablet: isTablet,
                  ),
                  SizedBox(width: isTablet ? 16 : 12),
                  _buildSocialIcon(
                    icon: Icons.facebook,
                    onTap: () {},
                    isTablet: isTablet,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialIcon({
    required IconData icon,
    VoidCallback? onTap,
    bool isTablet = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isTablet ? 12 : 10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        child: Icon(icon, color: Colors.white, size: isTablet ? 26 : 24),
      ),
    );
  }

  Widget _buildDrawerItem(
    String text,
    IconData icon, {
    bool isActive = false,
    VoidCallback? onTap,
    bool isTablet = false,
  }) {
    return Material(
      color: isActive ? Colors.white.withOpacity(0.1) : Colors.black,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.white.withOpacity(0.1),
        highlightColor: Colors.white.withOpacity(0.05),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 24 : 20,
            vertical: isTablet ? 18 : 16,
          ),
          decoration: BoxDecoration(
            border: isActive
                ? const Border(
                    left: BorderSide(color: Color(0xFFD4AF37), width: 4),
                  )
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isActive ? const Color(0xFFD4AF37) : Colors.white,
                size: isTablet ? 24 : 22,
              ),
              SizedBox(width: isTablet ? 16 : 14),
              Text(
                text,
                style: GoogleFonts.montserrat(
                  color: isActive ? const Color(0xFFD4AF37) : Colors.white,
                  fontSize: isTablet ? 17 : 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.isMobile(context);
    final isTablet = ResponsiveBreakpoints.isTablet(context);
    final isDesktop = ResponsiveBreakpoints.isDesktop(context);

    return Scaffold(
      body: Stack(
        children: [
          // Main content with header
          CustomScrollView(
            slivers: [
              // Top message bar
              SliverToBoxAdapter(
                child: Container(
                  height: isTablet ? 44 : (isMobile ? 40 : 40),
                  color: const Color(0xFFB8860B),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                      child: Text(
                        _messages[_currentIndex],
                        key: ValueKey<int>(_currentIndex),
                        style: GoogleFonts.montserrat(
                          color: Colors.black,
                          fontSize: isTablet ? 13 : 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),

              // Sticky header
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyHeaderDelegate(
                  child: AppHeader(
                    onMenuTap: _toggleDrawer,
                    currentPage: widget.currentPage,
                    onNavigate: _navigateToPage,
                  ),
                  isMobile: isMobile,
                  isTablet: isTablet,
                ),
              ),

              // Page body content
              SliverFillRemaining(child: widget.body),
            ],
          ),

          // Drawer overlay for mobile and tablet
          if ((isMobile || isTablet) &&
              _drawerSlideAnimation != null &&
              _drawerAnimationController != null)
            Positioned.fill(
              child: IgnorePointer(
                ignoring: !_isDrawerOpen,
                child: AnimatedBuilder(
                  animation: _drawerAnimationController!,
                  builder: (context, child) {
                    final screenHeight = MediaQuery.of(context).size.height;
                    final dy = _drawerSlideAnimation!.value * screenHeight;
                    final scrimOpacity =
                        _drawerAnimationController!.value * 0.7;

                    return Stack(
                      children: [
                        if (_drawerAnimationController!.value > 0)
                          Positioned.fill(
                            child: Opacity(
                              opacity: scrimOpacity,
                              child: GestureDetector(
                                onTap: _toggleDrawer,
                                behavior: HitTestBehavior.opaque,
                                child: Container(color: Colors.black),
                              ),
                            ),
                          ),
                        // For tablet, align drawer to the right
                        if (isTablet)
                          Positioned(
                            right: 0,
                            top: 0,
                            bottom: 0,
                            child: Transform.translate(
                              offset: Offset(
                                400 * (1 - _drawerAnimationController!.value),
                                0,
                              ),
                              child: _buildDrawer(true),
                            ),
                          )
                        else
                          Transform.translate(
                            offset: Offset(0, dy),
                            child: _buildDrawer(false),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final bool isMobile;
  final bool isTablet;

  _StickyHeaderDelegate({
    required this.child,
    required this.isMobile,
    required this.isTablet,
  });

  @override
  double get minExtent => isMobile ? 80 : (isTablet ? 90 : 100);

  @override
  double get maxExtent => isMobile ? 80 : (isTablet ? 90 : 100);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(_StickyHeaderDelegate oldDelegate) => false;
}

class AppHeader extends StatefulWidget {
  final VoidCallback onMenuTap;
  final String currentPage;
  final Function(String) onNavigate;

  const AppHeader({
    Key? key,
    required this.onMenuTap,
    required this.currentPage,
    required this.onNavigate,
  }) : super(key: key);

  @override
  State<AppHeader> createState() => _AppHeaderState();
}

class _AppHeaderState extends State<AppHeader> {
  String _selectedCountry = 'US';
  bool _isSearchActive = false;
  final TextEditingController _searchController = TextEditingController();

  final Map<String, String> _countries = {
    'US': 'https://flagcdn.com/w40/us.png',
    'IND': 'https://flagcdn.com/w40/in.png',
    'UK': 'https://flagcdn.com/w40/gb.png',
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.isMobile(context);
    final isTablet = ResponsiveBreakpoints.isTablet(context);
    final isDesktop = ResponsiveBreakpoints.isDesktop(context);

    final headerHeight = isMobile ? 80.0 : (isTablet ? 90.0 : 100.0);
    final horizontalPadding = isMobile ? 16.0 : (isTablet ? 28.0 : 40.0);

    return Material(
      elevation: 4,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: headerHeight,
            decoration: BoxDecoration(
              color: Colors.black,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: isMobile
                  ? _buildMobileHeader()
                  : (isTablet ? _buildTabletHeader() : _buildDesktopHeader()),
            ),
          ),

          // Logo positioning
          if (!_isSearchActive)
            Positioned(
              left: isTablet ? 40 : (isDesktop ? 60 : 20),
              right: 0,
              top: isTablet ? -30 : (isDesktop ? -46 : -15),
              child: Center(
                child: Image.asset(
                  'assets/icons/chemo.png',
                  height: isTablet ? 160 : (isDesktop ? 200 : 120),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return SizedBox(
                      height: isTablet ? 160 : (isDesktop ? 200 : 120),
                      child: Icon(
                        Icons.image,
                        size: isTablet ? 45 : (isDesktop ? 50 : 40),
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMobileHeader() {
    return _isSearchActive
        ? _buildSearchBar(isMobile: true)
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _IconButton(icon: Icons.menu, onTap: widget.onMenuTap),
                  const SizedBox(width: 12),
                  _buildCountryDropdown(isMobile: true),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  _IconButton(
                    icon: Icons.search,
                    onTap: () => setState(() => _isSearchActive = true),
                  ),
                  const SizedBox(width: 12),
                  const _IconButton(icon: Icons.shopping_cart_outlined),
                ],
              ),
            ],
          );
  }

  Widget _buildTabletHeader() {
    return _isSearchActive
        ? _buildSearchBar(isTablet: true)
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _IconButton(
                    icon: Icons.menu,
                    onTap: widget.onMenuTap,
                    size: 26,
                  ),
                  const SizedBox(width: 20),
                  _NavLink(
                    text: 'HOME',
                    isActive: widget.currentPage == 'HOME',
                    onTap: () => widget.onNavigate('HOME'),
                    fontSize: 13,
                  ),
                  const SizedBox(width: 28),
                  _NavLink(
                    text: 'ABOUT',
                    isActive: widget.currentPage == 'ABOUT',
                    onTap: () => widget.onNavigate('ABOUT'),
                    fontSize: 13,
                  ),
                  const SizedBox(width: 28),
                  _NavLink(
                    text: 'PRODUCTS',
                    isActive: widget.currentPage == 'PRODUCTS',
                    onTap: () => widget.onNavigate('PRODUCTS'),
                    fontSize: 13,
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  _buildCountryDropdown(isTablet: true),
                  const SizedBox(width: 24),
                  _IconButton(
                    icon: Icons.search,
                    onTap: () => setState(() => _isSearchActive = true),
                    size: 25,
                  ),
                  const SizedBox(width: 20),
                  const _IconButton(icon: Icons.person_outline, size: 25),
                  const SizedBox(width: 20),
                  const _IconButton(
                    icon: Icons.shopping_cart_outlined,
                    size: 25,
                  ),
                ],
              ),
            ],
          );
  }

  Widget _buildDesktopHeader() {
    return _isSearchActive
        ? _buildSearchBar(isDesktop: true)
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _NavLink(
                    text: 'HOME',
                    isActive: widget.currentPage == 'HOME',
                    onTap: () => widget.onNavigate('HOME'),
                  ),
                  const SizedBox(width: 40),
                  _NavLink(
                    text: 'ABOUT',
                    isActive: widget.currentPage == 'ABOUT',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AboutPage()),
                      );
                    },
                  ),

                  const SizedBox(width: 40),
                  _NavLink(
                    text: 'GETVERIFIED',
                    isActive: widget.currentPage == 'GETVERIFIED',
                    onTap: () => widget.onNavigate('GETVERIFIED'),
                  ),
                  const SizedBox(width: 40),
                  _NavLink(
                    text: 'PRODUCTS',
                    isActive: widget.currentPage == 'PRODUCTS',
                    onTap: () => widget.onNavigate('PRODUCTS'),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  _buildCountryDropdown(isMobile: false),
                  const SizedBox(width: 40),
                  _IconButton(
                    icon: Icons.search,
                    onTap: () => setState(() => _isSearchActive = true),
                  ),
                  const SizedBox(width: 30),
                  const _IconButton(icon: Icons.person_outline),
                  const SizedBox(width: 30),
                  const _IconButton(icon: Icons.shopping_cart_outlined),
                ],
              ),
            ],
          );
  }

  Widget _buildSearchBar({
    bool isMobile = false,
    bool isTablet = false,
    bool isDesktop = false,
  }) {
    final fontSize = isMobile ? 14.0 : (isTablet ? 15.0 : 16.0);
    final closeIconSize = isMobile ? 24.0 : (isTablet ? 26.0 : 28.0);

    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: fontSize,
              ),
              decoration: InputDecoration(
                hintText: 'Search products...',
                hintStyle: GoogleFonts.montserrat(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: fontSize,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : (isTablet ? 18 : 20),
                  vertical: isMobile ? 12 : (isTablet ? 13 : 15),
                ),
                prefixIcon: isMobile
                    ? Icon(
                        Icons.search,
                        color: Colors.white.withOpacity(0.7),
                        size: 20,
                      )
                    : null,
              ),
            ),
          ),
        ),
        const SizedBox(width: 15),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _isSearchActive = false;
                _searchController.clear();
              });
            },
            child: Icon(Icons.close, color: Colors.white, size: closeIconSize),
          ),
        ),
      ],
    );
  }

  Widget _buildCountryDropdown({bool isMobile = false, bool isTablet = false}) {
    final horizontalPadding = isMobile ? 8.0 : (isTablet ? 10.0 : 12.0);
    final verticalPadding = isMobile ? 4.0 : (isTablet ? 6.0 : 8.0);
    final flagWidth = isMobile ? 16.0 : (isTablet ? 18.0 : 20.0);
    final flagHeight = isMobile ? 12.0 : (isTablet ? 13.0 : 14.0);
    final fontSize = isMobile ? 12.0 : (isTablet ? 13.0 : 14.0);
    final spacing = isMobile ? 6.0 : (isTablet ? 7.0 : 8.0);
    final iconSize = isMobile ? 16.0 : (isTablet ? 17.0 : 18.0);

    return PopupMenuButton<String>(
      onSelected: (String value) {
        setState(() {
          _selectedCountry = value;
        });
      },
      offset: const Offset(0, 45),
      color: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Colors.white, width: 1),
      ),
      itemBuilder: (BuildContext context) {
        return _countries.entries.map((entry) {
          return PopupMenuItem<String>(
            value: entry.key,
            child: Row(
              children: [
                Container(
                  width: flagWidth,
                  height: flagHeight,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(entry.value),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  entry.key,
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: flagWidth,
              height: flagHeight,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(_countries[_selectedCountry]!),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(width: spacing),
            Text(
              _selectedCountry,
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: spacing - 2),
            Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white,
              size: iconSize,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavLink extends StatefulWidget {
  final String text;
  final bool isActive;
  final VoidCallback? onTap;
  final double? fontSize;

  const _NavLink({
    required this.text,
    this.isActive = false,
    this.onTap,
    this.fontSize,
  });

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap ?? () {},
        child: Text(
          widget.text,
          style: GoogleFonts.montserrat(
            color: widget.isActive || _isHovered
                ? const Color(0xFFD4AF37)
                : Colors.white,
            fontSize: widget.fontSize ?? 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

class _IconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double? size; // Add size parameter

  const _IconButton({
    required this.icon,
    this.onTap,
    this.size, // Add to constructor
  });

  @override
  State<_IconButton> createState() => _IconButtonState();
}

class _IconButtonState extends State<_IconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap ?? () {},
        child: Icon(
          widget.icon,
          color: _isHovered ? const Color(0xFFD4AF37) : Colors.white,
          size: widget.size ?? 24, // Use the size parameter with default of 24
        ),
      ),
    );
  }
}
