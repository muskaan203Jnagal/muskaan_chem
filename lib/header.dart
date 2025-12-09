import 'package:flutter/material.dart';
import 'package:chem_revolutions/homepage/homepage.dart';

import 'package:chem_revolutions/about/about.dart';

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

  Widget _buildDrawer() {
    return Container(
      height: double.infinity,
      width: double.infinity,
      color: Colors.black,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with close button
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.black,
              child: Row(
                children: [
                  Image.asset(
                    'assets/icons/chemo.png',
                    height: 42,
                    fit: BoxFit.contain,
                    errorBuilder: (c, e, s) =>
                        const Icon(Icons.image, color: Colors.white, size: 36),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'CHEM Revolution',
                      style: TextStyle(
                        color: Color(0xFFD4AF37),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _toggleDrawer,
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 28,
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
                    ),
                    _buildDrawerItem(
                      'ABOUT',
                      Icons.info_outline,
                      isActive: widget.currentPage == 'ABOUT',
                      onTap: () => _navigateToPage('ABOUT'),
                    ),
                    _buildDrawerItem(
                      'GET VERIFIED',
                      Icons.verified_user_outlined,
                      isActive: widget.currentPage == 'GETVERIFIED',
                      onTap: () => _navigateToPage('GETVERIFIED'),
                    ),
                    _buildDrawerItem(
                      'PRODUCTS',
                      Icons.shopping_bag_outlined,
                      isActive: widget.currentPage == 'PRODUCTS',
                      onTap: () => _navigateToPage('PRODUCTS'),
                    ),

                    const Divider(color: Colors.white24, height: 1),

                    _buildDrawerItem(
                      'PROFILE',
                      Icons.person_outline,
                      onTap: () {
                        _toggleDrawer();
                      },
                    ),

                    const Divider(color: Colors.white24, height: 1),
                  ],
                ),
              ),
            ),

            // Bottom section with CHEM Revolution logo and social icons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Image.asset(
                    'assets/icons/chemo.png',
                    height: 120,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.image,
                        color: Colors.white,
                        size: 60,
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialIcon(icon: Icons.wechat, onTap: () {}),
                      const SizedBox(width: 15),
                      _buildSocialIcon(icon: Icons.facebook, onTap: () {}),
                      const SizedBox(width: 15),
                      _buildSocialIcon(icon: Icons.camera_alt, onTap: () {}),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialIcon({required IconData icon, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildDrawerItem(
    String text,
    IconData icon, {
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    return Material(
      color: isActive ? Colors.white.withOpacity(0.1) : Colors.black,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.white.withOpacity(0.1),
        highlightColor: Colors.white.withOpacity(0.05),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                size: 22,
              ),
              const SizedBox(width: 14),
              Text(
                text,
                style: TextStyle(
                  color: isActive ? const Color(0xFFD4AF37) : Colors.white,
                  fontSize: 16,
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      body: Stack(
        children: [
          // Main content with header
          CustomScrollView(
            slivers: [
              // Top message bar
              SliverToBoxAdapter(
                child: Container(
                  height: 40,
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
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),

              // Sticky header - Different heights for mobile and desktop
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyHeaderDelegate(
                  child: AppHeader(
                    onMenuTap: _toggleDrawer,
                    currentPage: widget.currentPage,
                    onNavigate: _navigateToPage,
                  ),
                  isMobile: isMobile,
                ),
              ),

              // Page body content
              SliverFillRemaining(child: widget.body),
            ],
          ),

          // Mobile drawer overlay
          if (isMobile &&
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
                        Transform.translate(
                          offset: Offset(0, dy),
                          child: child,
                        ),
                      ],
                    );
                  },
                  child: _buildDrawer(),
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

  _StickyHeaderDelegate({required this.child, required this.isMobile});

  @override
  double get minExtent => isMobile ? 80 : 100;

  @override
  double get maxExtent => isMobile ? 80 : 100;

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
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Material(
      elevation: 4,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: isMobile ? 80 : 100,
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
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 40),
              child: isMobile ? _buildMobileHeader() : _buildDesktopHeader(),
            ),
          ),

          // Desktop logo
          if (!_isSearchActive && !isMobile)
            Positioned(
              left: 60,
              right: 0,
              top: -60,
              child: Center(
                child: Image.asset(
                  'assets/icons/chemo.png',
                  height: 230,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox(
                      height: 230,
                      child: Icon(Icons.image, size: 50, color: Colors.white),
                    );
                  },
                ),
              ),
            ),

          // Mobile logo
          if (!_isSearchActive && isMobile)
            Positioned(
              left: 0,
              right: 0,
              top: -30,
              child: Center(
                child: Image.asset(
                  'assets/icons/chemo.png',
                  height: 140,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox(
                      height: 140,
                      child: Icon(Icons.image, size: 40, color: Colors.white),
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
        ? Row(
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
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.white.withOpacity(0.7),
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isSearchActive = false;
                    _searchController.clear();
                  });
                },
                child: const Icon(Icons.close, color: Colors.white, size: 24),
              ),
            ],
          )
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

  Widget _buildDesktopHeader() {
    return _isSearchActive
        ? Row(
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
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
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
                  child: const Icon(Icons.close, color: Colors.white, size: 28),
                ),
              ),
            ],
          )
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

  Widget _buildCountryDropdown({required bool isMobile}) {
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
                  width: 20,
                  height: 14,
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
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
          horizontal: isMobile ? 8 : 12,
          vertical: isMobile ? 4 : 8,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: isMobile ? 16 : 20,
              height: isMobile ? 12 : 14,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(_countries[_selectedCountry]!),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(width: isMobile ? 6 : 8),
            Text(
              _selectedCountry,
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 12 : 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: isMobile ? 2 : 4),
            Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white,
              size: isMobile ? 16 : 18,
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

  const _NavLink({required this.text, this.isActive = false, this.onTap});

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
          style: TextStyle(
            color: widget.isActive || _isHovered
                ? const Color(0xFFD4AF37)
                : Colors.white,
            fontSize: 14,
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

  const _IconButton({required this.icon, this.onTap});

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
          size: 24,
        ),
      ),
    );
  }
}