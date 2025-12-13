// lib/contact/contact.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

// Use same header/footer wiring as homepage
import '/header.dart';
import '/footer.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  // Footer navigation functions (use context here)

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 768;
    // social & footer columns (copied pattern from homepage)
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
          FooterItem(
            label: 'Home',
            onTap: () {
              Navigator.pushNamed(context, '/home');
            },
          ),
          FooterItem(
            label: 'Categories',
            onTap: () {
              Navigator.pushNamed(context, '/home');
            },
          ),
          FooterItem(
            label: 'Product Detail',
            onTap: () {
              Navigator.pushNamed(context, '/home');
            },
          ),
          FooterItem(
            label: 'Contact Us',
            onTap: () {
              print('FOOTER → CONTACT CLICKED');
              Navigator.pushReplacementNamed(context, '/contact');
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

    return AppScaffold(
      currentPage: 'CONTACT',
      body: SingleChildScrollView(
        child: Container(
          color: const Color(0xFFF6F6F6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 30),

              // Headline above the card
              Column(
                children: [
                  Text(
                    'Contact Us',
                    style: GoogleFonts.montserrat(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFF5A800),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Any question or remarks? Just write us a message!',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 22),
                ],
              ),

              // Card (1196 x 667)
              Center(
                child: isMobile
                    // =======================
                    // 📱 MOBILE LAYOUT
                    // =======================
                    ? Column(
                        children: [
                          // 🖤 FULL SCREEN BLACK PANEL
                          SizedBox(
                            height: MediaQuery.of(context).size.height,
                            width: double.infinity,
                            child: const _BlackPanel(
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),

                          // 📝 FORM SECTION BELOW
                          Container(
                            width: double.infinity,
                            color: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: const _FormArea(),
                          ),
                        ],
                      )
                    // =======================
                    // 🖥 DESKTOP LAYOUT (UNCHANGED)
                    // =======================
                    : SizedBox(
                        width: 1196,
                        height: 667,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // White card background
                            Container(
                              width: 1196,
                              height: 667,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.06),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                            ),

                            // Left black panel
                            const Positioned(
                              left: 28,
                              top: 10,
                              child: _BlackPanel(width: 491, height: 647),
                            ),

                            // Right form area
                            Positioned(
                              left: 28 + 491 + 24,
                              top: 18,
                              child: SizedBox(
                                width: 1196 - (28 + 491 + 28),
                                height: 627,
                                child: const _FormArea(),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),

              const SizedBox(height: 60),

              // FOOTER (same pattern you used on homepage)
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
                    socialLinks: social,
                    columns: columns,
                    copyright:
                        "© 2025 ChemRevolutions.com. All rights reserved.",
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

/// ---------- BLACK PANEL (unchanged) ----------
class _BlackPanel extends StatefulWidget {
  final double width;
  final double height;
  const _BlackPanel({super.key, required this.width, required this.height});

  @override
  State<_BlackPanel> createState() => _BlackPanelState();
}

class _BlackPanelState extends State<_BlackPanel> {
  final List<bool> _hover = [false, false, false];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: widget.width,
            height: widget.height,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                // heading — top-left
                Align(
                  alignment: Alignment.topLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contact Information',
                        style: GoogleFonts.montserrat(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Say something to start a live chat!',
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                // center contact block — aligned with heading
                Expanded(
                  child: Center(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: widget.width * 0.7,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.phone,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  '+1012 3456 789',
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.email,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'demo@gmail.com',
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 2.0),
                                  child: Icon(
                                    Icons.location_on,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    '132 Dartmouth Street Boston, Massachusetts 02156 United States',
                                    style: GoogleFonts.montserrat(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // social icons bottom-left
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4.0, bottom: 6.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(3, (index) {
                        IconData iconData;
                        switch (index) {
                          case 0:
                            iconData = FontAwesomeIcons.facebookF;
                            break;
                          case 1:
                            iconData = FontAwesomeIcons.twitter;
                            break;
                          default:
                            iconData = FontAwesomeIcons.instagram;
                        }

                        final isHover = _hover[index];
                        final bg = isHover
                            ? Colors.white
                            : const Color(0xFFFFC107);
                        final iconColor = isHover ? Colors.black : Colors.white;

                        return MouseRegion(
                          onEnter: (_) => setState(() => _hover[index] = true),
                          onExit: (_) => setState(() => _hover[index] = false),
                          child: GestureDetector(
                            onTap: () {},
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: bg,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(iconData, color: iconColor, size: 18),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Eclipse PNG — placed as before (optional image; adjust path if needed)
          Positioned(
            right: -70,
            bottom: -40,
            child: IgnorePointer(
              child: Image.asset(
                'assets/images/eclipse.png',
                width: 200,
                height: 200,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------- FORM AREA with Firestore submit (notification added) ----------
/// ---------- FORM AREA with Firestore submit + SUCCESS MODAL ----------
/// ---------- FORM AREA with Firestore submit + UX Enhancements ----------
class _FormArea extends StatefulWidget {
  const _FormArea({super.key});

  @override
  State<_FormArea> createState() => _FormAreaState();
}

class _FormAreaState extends State<_FormArea> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _first = TextEditingController();
  final TextEditingController _last = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _message = TextEditingController();

  String? _subject = 'General Inquiry';
  bool _submitting = false;
  bool _showSuccess = false;

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _email.dispose();
    _phone.dispose();
    _message.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _first.text.trim().isNotEmpty &&
        _last.text.trim().isNotEmpty &&
        _email.text.trim().isNotEmpty &&
        RegExp(
          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
        ).hasMatch(_email.text.trim()) &&
        _phone.text.trim().length == 10 &&
        _message.text.trim().isNotEmpty;
  }

  Future<void> _submit() async {
    if (!_isFormValid) return;

    setState(() => _submitting = true);

    try {
      await FirebaseFirestore.instance.collection('contactSubmissions').add({
        'firstName': _first.text.trim(),
        'lastName': _last.text.trim(),
        'email': _email.text.trim(),
        'phone': _phone.text.trim(),
        'subject': _subject,
        'message': _message.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      if (!mounted) return;

      _formKey.currentState!.reset();
      _first.clear();
      _last.clear();
      _email.clear();
      _phone.clear();
      _message.clear();

      setState(() {
        _subject = 'General Inquiry';
        _showSuccess = true;
      });

      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _showSuccess = false);
      });
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Colors.black,
          selectionColor: Color(0x33000000),
          selectionHandleColor: Colors.black,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        child: DefaultTextStyle(
          style: GoogleFonts.montserrat(color: Colors.black87),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // ✅ BLUR BACKGROUND WHEN MODAL SHOWS
              Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: ScrollConfiguration(
                  behavior: const _NoScrollbar(),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _field(
                                controller: _first,
                                label: 'First Name',
                                validator: (v) => v == null || v.trim().isEmpty
                                    ? 'First name is required'
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: _field(
                                controller: _last,
                                label: 'Last Name',
                                validator: (v) => v == null || v.trim().isEmpty
                                    ? 'Last name is required'
                                    : null,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),
                        _field(
                          controller: _email,
                          label: 'Email',
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Enter email';
                            }
                            if (!RegExp(
                              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                            ).hasMatch(v.trim())) {
                              return 'Enter valid email';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 12),
                        _field(
                          controller: _phone,
                          label: 'Phone Number',
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Phone number is required';
                            }
                            if (v.trim().length != 10) {
                              return 'Enter a valid 10-digit phone number';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 18),
                        Text(
                          'Select Subject?',
                          style: GoogleFonts.montserrat(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 12,
                          runSpacing: 6,
                          children: [
                            _radioTile('General Inquiry'),
                            _radioTile('Suggestions'),
                            _radioTile('Product'),
                            _radioTile('Other'),
                          ],
                        ),

                        const SizedBox(height: 18),
                        Text(
                          'Message',
                          style: GoogleFonts.montserrat(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: 160,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          child: TextFormField(
                            controller: _message,
                            maxLines: 6,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _submit(),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Please enter a message'
                                : null,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        Center(
                          child: SizedBox(
                            width: 260,
                            child: ElevatedButton(
                              onPressed: (!_submitting && _isFormValid)
                                  ? _submit
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _submitting
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Send Message',
                                      style: TextStyle(color: Colors.white),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),

              // ✅ SUCCESS MODAL
              _SuccessModal(show: _showSuccess),
            ],
          ),
        ),
      ),
    );
  }

  Widget _radioTile(String label) {
    return InkWell(
      onTap: () => setState(() => _subject = label),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Radio<String>(
            value: label,
            groupValue: _subject,
            activeColor: Colors.black,
            onChanged: (v) => setState(() => _subject = v),
          ),
          Text(label, style: GoogleFonts.montserrat(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(fontSize: 12, color: Colors.black54),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          cursorColor: Colors.black,
          onChanged: (_) => setState(() {}),

          decoration: const InputDecoration(
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 1.6),
            ),
          ),
        ),
      ],
    );
  }
}

/// ---------- SUCCESS MODAL ----------
class _SuccessModal extends StatelessWidget {
  final bool show;
  const _SuccessModal({required this.show});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !show,
      child: AnimatedOpacity(
        opacity: show ? 1 : 0,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        child: AnimatedScale(
          scale: show ? 1 : 0.95,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutExpo,
          child: Container(
            width: 380,
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF5A800)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.45),
                  blurRadius: 30,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 42,
                  color: Color(0xFFF5A800),
                ),
                const SizedBox(height: 14),
                Text(
                  'Message Sent Successfully',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Thank you for reaching out.\nOur team will contact you shortly.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.4,
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

class _NoScrollbar extends ScrollBehavior {
  const _NoScrollbar();

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child; // hides scrollbar visually
  }
}
