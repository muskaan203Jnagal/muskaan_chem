// lib/client-suite/account_settings.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ---------------------------------------------------------------
/// ACCOUNT SETTINGS PAGE - PREMIUM BLACK • WHITE • GOLD UI
/// ---------------------------------------------------------------
/// ✔ Sticky centered tab bar
/// ✔ Subtle black ripple (NO purple anywhere)
/// ✔ Gold underline for active tab
/// ✔ Minimal gold accents (vertical bars, avatar ring)
/// ✔ Input fields: black border, gold on focus
/// ✔ Buttons: black; subtle black ripple
/// ✔ Fully responsive (2-column → 1-column)
/// ✔ Pixel-perfect luxury design
/// ---------------------------------------------------------------

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({Key? key}) : super(key: key);

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage>
    with SingleTickerProviderStateMixin {
  // Colors
  static const Color _black = Colors.black;
  static const Color _white = Colors.white;
  static const Color _gold = Color(0xFFC9A34E);

  // Sizes
  static const double _avatarSize = 90;
  static const double _maxWidth = 1000;

  late TabController _tabController;

  // Avatar URL
  String? _avatarUrl;

  // Dummy form controllers
  final TextEditingController _firstName = TextEditingController(text: "Isha");
  final TextEditingController _lastName = TextEditingController(text: "Nigah");
  final TextEditingController _phone = TextEditingController(text: "+91");
  final TextEditingController _email = TextEditingController(
    text: "ishani...@gmail.com",
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: 3);
  }

  // Edit avatar URL dialog
  Future<void> _editAvatar() async {
    final controller = TextEditingController(text: _avatarUrl ?? "");

    final result = await showDialog<String?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: _white,
          title: Text(
            "Set Profile Image URL",
            style: GoogleFonts.montserrat(color: _black),
          ),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "https://..."),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text("Save"),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() => _avatarUrl = result.isEmpty ? null : result);
    }
  }

  // Input field builder
  Widget _formInput({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),

        Focus(
          onFocusChange: (_) => setState(() {}),
          child: Builder(
            builder: (context) {
              final bool isFocused = Focus.of(context).hasFocus;

              return TextField(
                controller: controller,
                style: GoogleFonts.montserrat(),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: _black),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: _black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: _gold, width: 2),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Gold heading
  Widget _goldHeading(String text) {
    return Row(
      children: [
        Container(width: 3, height: 24, color: _gold),
        const SizedBox(width: 10),
        Text(
          text,
          style: GoogleFonts.montserrat(
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isWide = width > 760; // responsive breakpoint

    return Theme(
      data: Theme.of(context).copyWith(
        // Remove all purple + add subtle black ripple
        splashColor: Colors.black.withOpacity(0.12),
        highlightColor: Colors.black.withOpacity(0.08),
        hoverColor: Colors.black.withOpacity(0.05),
        focusColor: Colors.black.withOpacity(0.08),

        tabBarTheme: TabBarThemeData(
          overlayColor: MaterialStateProperty.all(
            Colors.black.withOpacity(0.08),
          ),
          labelStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.montserrat(),
        ),

        textSelectionTheme: TextSelectionThemeData(
          cursorColor: _black,
          selectionColor: Colors.black.withOpacity(0.2),
          selectionHandleColor: _black,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            overlayColor: MaterialStateProperty.all(
              Colors.black.withOpacity(0.12),
            ),
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: ButtonStyle(
            overlayColor: MaterialStateProperty.all(
              Colors.black.withOpacity(0.10),
            ),
            foregroundColor: MaterialStateProperty.all(_black),
            side: MaterialStateProperty.all(const BorderSide(color: _black)),
            padding: MaterialStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ),
      ),

      child: Scaffold(
        backgroundColor: _white,
        body: NestedScrollView(
          headerSliverBuilder: (context, _) {
            return [
              // ----------------------------------------------------------
              // BLACK BANNER + AVATAR
              // ----------------------------------------------------------
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  color: _black,
                  padding: const EdgeInsets.symmetric(vertical: 22),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _editAvatar,
                        child: Container(
                          width: _avatarSize,
                          height: _avatarSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _black,
                            border: Border.all(color: _gold, width: 3),
                            image: _avatarUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(_avatarUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "ISHA",
                        style: GoogleFonts.montserrat(
                          color: _white,
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ----------------------------------------------------------
              // STICKY TAB BAR
              // ----------------------------------------------------------
              SliverAppBar(
                pinned: true,
                backgroundColor: _white,
                elevation: 0,
                toolbarHeight: 0,
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(50),
                  child: Column(
                    children: [
                      Center(
                        child: TabBar(
                          controller: _tabController,
                          labelColor: _black,
                          unselectedLabelColor: _black,
                          indicatorColor: _gold,
                          indicatorWeight: 3,
                          indicatorSize: TabBarIndicatorSize.label,
                          tabs: const [
                            Tab(text: "My Orders"),
                            Tab(text: "My Addresses"),
                            Tab(text: "My Wishlist"),
                            Tab(text: "Account Settings"),
                          ],
                        ),
                      ),
                      Container(height: 1, color: _black.withOpacity(0.15)),
                    ],
                  ),
                ),
              ),
            ];
          },

          // ----------------------------------------------------------
          // TAB CONTENT
          // ----------------------------------------------------------
          body: TabBarView(
            controller: _tabController,
            children: [
              _placeholder("My Orders"),
              _placeholder("My Addresses"),
              _placeholder("My Wishlist"),

              // ------------------------------------------------------
              // ACCOUNT SETTINGS CONTENT
              // ------------------------------------------------------
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 30,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: _maxWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _goldHeading("Account"),
                        const SizedBox(height: 10),
                        Text(
                          "View and edit your personal info below.",
                          style: GoogleFonts.montserrat(fontSize: 14),
                        ),
                        const SizedBox(height: 36),

                        _goldHeading("Personal Info"),
                        const SizedBox(height: 20),

                        // Responsive fields
                        isWide
                            ? Row(
                                children: [
                                  Expanded(
                                    child: _formInput(
                                      label: "First name",
                                      controller: _firstName,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _formInput(
                                      label: "Last name",
                                      controller: _lastName,
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  _formInput(
                                    label: "First name",
                                    controller: _firstName,
                                  ),
                                  const SizedBox(height: 16),
                                  _formInput(
                                    label: "Last name",
                                    controller: _lastName,
                                  ),
                                ],
                              ),

                        const SizedBox(height: 16),
                        _formInput(label: "Phone", controller: _phone),

                        const SizedBox(height: 30),

                        Row(
                          children: [
                            OutlinedButton(
                              onPressed: () {},
                              child: const Text("Discard"),
                            ),
                            const SizedBox(width: 14),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _black,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                              ),
                              onPressed: () {},
                              child: Text(
                                "Update Info",
                                style: GoogleFonts.montserrat(
                                  color: _white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),
                        Container(height: 1, color: _black.withOpacity(0.2)),
                        const SizedBox(height: 40),

                        _goldHeading("Login Info"),
                        const SizedBox(height: 20),

                        // EMAIL
                        Text(
                          "Login email:",
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),

                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                readOnly: true,
                                controller: _email,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: _white,
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: _black),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(color: _gold),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton(
                              onPressed: () {},
                              child: const Text("Change Email"),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // PASSWORD
                        Text(
                          "Password:",
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),

                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 13,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: _black),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  "•••••••",
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16,
                                    letterSpacing: 3,
                                    color: _black,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton(
                              onPressed: () {},
                              child: const Text("Change Password"),
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _black,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                          ),
                          onPressed: () {},
                          child: Text(
                            "Logout",
                            style: GoogleFonts.montserrat(
                              color: _white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder(String text) {
    return Center(
      child: Text(
        "$text Page Coming Soon...",
        style: GoogleFonts.montserrat(
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
