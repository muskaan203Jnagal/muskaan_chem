// lib/client-suite/account_settings.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// NEW — common top banner (you said this file already exists)
import 'widgets/top_banner_tabs.dart';
import '../header.dart';
import '../footer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// -----------------------------------------------------------------
// ACCOUNT SETTINGS PAGE — Wrapped with AppScaffold (shared header)
// -----------------------------------------------------------------

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
  static const double _maxWidth = 1000;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  late TabController _tabController;

  // Controllers
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _email = TextEditingController();

  String avatarLetter = "";
  String _uid = "";

  bool _loading = true;
  bool _saving = false;

  bool _hasPasswordProvider = false; // detect if 'password' provider available

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: 3);
    _loadUserOnce();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  // ---------------- Helper: split name ----------------
  void _splitName(String fullName) {
    final parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      _firstName.text = "";
      _lastName.text = "";
    } else if (parts.length == 1) {
      _firstName.text = parts[0];
      _lastName.text = "";
    } else {
      _firstName.text = parts.first;
      _lastName.text = parts.sublist(1).join(" ");
    }
    avatarLetter = fullName.trim().isNotEmpty
        ? fullName.trim()[0].toUpperCase()
        : "";
  }

  // ---------------- Load user once ----------------
  Future<void> _loadUserOnce() async {
    if (!mounted) return;
    setState(() => _loading = true);

    try {
      final user = _auth.currentUser;
      if (user == null) {
        _uid = "";
        _email.text = "";
        _firstName.text = "";
        _lastName.text = "";
        _phone.text = "";
        avatarLetter = "";
        _hasPasswordProvider = false;
        if (mounted) setState(() => _loading = false);
        return;
      }

      // refresh
      await user.reload();
      final reloaded = _auth.currentUser!;
      _uid = reloaded.uid;

      // provider detection
      _hasPasswordProvider = reloaded.providerData
          .any((p) => p.providerId == 'password');

      final docRef = _db.collection('users').doc(_uid);
      final snap = await docRef.get();

      if (!snap.exists) {
        final defaultName = reloaded.displayName ?? "";
        final letter = defaultName.isNotEmpty
            ? defaultName[0].toUpperCase()
            : "";
        await docRef.set({
          "name": defaultName,
          "email": reloaded.email ?? "",
          "phone": "",
          "avatarLetter": letter,
          "createdAt": FieldValue.serverTimestamp(),
          "updatedAt": FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      final fresh = await docRef.get();
      final data = fresh.data() ?? {};

      final String name =
          (data['name'] ?? reloaded.displayName ?? "") as String;
      final String phone = (data['phone'] ?? "") as String;
      final String email = (data['email'] ?? reloaded.email ?? "") as String;
      final String letter = (data['avatarLetter'] ?? "") as String;

      _splitName(name);
      _phone.text = phone;
      _email.text = email;
      avatarLetter = letter.isNotEmpty ? letter : avatarLetter;

      if (mounted) setState(() {
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to load user data: $e")),
        );
      }
    }
  }

  // ---------------- Update info ----------------
  Future<void> _updateInfo() async {
    if (_uid.isEmpty || !mounted) return;

    final fullName = "${_firstName.text.trim()} ${_lastName.text.trim()}"
        .trim();
    final letter = fullName.isNotEmpty ? fullName[0].toUpperCase() : "";

    setState(() => _saving = true);

    try {
      await _db.collection('users').doc(_uid).update({
        "name": fullName,
        "phone": _phone.text.trim(),
        "avatarLetter": letter,
        "updatedAt": FieldValue.serverTimestamp(),
      });

      try {
        final user = _auth.currentUser;
        if (user != null) await user.updateDisplayName(fullName);
      } catch (_) {}

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Updated Successfully")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Update failed")),
      );
    } finally {
      if (!mounted) return;
      setState(() => _saving = false);
    }
  }

  // ---------------- UTILS: styled dialog widgets ----------------
  Dialog _styledDialog({
    required Widget title,
    required Widget content,
    required List<Widget> actions,
    double? width,
  }) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: _gold, width: 2),
      ),
      child: Container(
        constraints: BoxConstraints(maxWidth: width ?? 520),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title area (black header + gold underline)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: _black,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(child: title),
            ),
            const SizedBox(height: 14),
            content,
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: actions,
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _popupInputDec({String? hint}) {
    return InputDecoration(
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: _black),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: _gold, width: 2),
      ),
    );
  }

  Text _dialogTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.montserrat(
        color: _white,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  // ---------------- CHANGE EMAIL DIALOG (styled) ----------------
  Future<void> _openChangeEmailDialog() async {
    final newEmailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    bool _busy = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return _styledDialog(
            title: _dialogTitle("Change Email"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: newEmailCtrl,
                  decoration: _popupInputDec(hint: "New email"),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordCtrl,
                  obscureText: true,
                  decoration: _popupInputDec(hint: "Current password"),
                ),
              ],
            ),
            actions: [
              // CANCEL — black text
              TextButton(
                style: TextButton.styleFrom(foregroundColor: _black),
                onPressed: _busy ? null : () => Navigator.pop(context),
                child: Text("Cancel", style: GoogleFonts.montserrat()),
              ),
              const SizedBox(width: 8),
              // SEND — filled black
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _black,
                  foregroundColor: _white,
                ),
                onPressed: _busy
                    ? null
                    : () async {
                        final newEmail = newEmailCtrl.text.trim();
                        final password = passwordCtrl.text;

                        if (newEmail.isEmpty || !newEmail.contains("@")) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Enter a valid email")),
                          );
                          return;
                        }
                        if (password.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text("Enter password for verification")),
                          );
                          return;
                        }

                        setStateDialog(() => _busy = true);

                        try {
                          final user = _auth.currentUser!;
                          final cred = EmailAuthProvider.credential(
                            email: user.email ?? "",
                            password: password,
                          );
                          await user.reauthenticateWithCredential(cred);
                          await user.verifyBeforeUpdateEmail(newEmail);

                          if (!mounted) return;
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text("Verification sent to new email."),
                            ),
                          );
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Failed to request email change")),
                          );
                        } finally {
                          if (mounted) setStateDialog(() => _busy = false);
                        }
                      },
                child: Text("Send", style: GoogleFonts.montserrat()),
              ),
            ],
          );
        });
      },
    );
  }

  // ---------------- CREATE PASSWORD (for Google-only users) ----------------
  Future<void> _openCreatePasswordDialog() async {
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool _busy = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return _styledDialog(
            title: _dialogTitle("Create Password"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "You signed in with Google. Create a password to enable email/password login.",
                  style: GoogleFonts.montserrat(fontSize: 13),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: newCtrl,
                  obscureText: true,
                  decoration: _popupInputDec(hint: "New password (min 6 chars)"),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmCtrl,
                  obscureText: true,
                  decoration: _popupInputDec(hint: "Confirm password"),
                ),
              ],
            ),
            actions: [
              // Cancel — black text
              TextButton(
                style: TextButton.styleFrom(foregroundColor: _black),
                onPressed: _busy ? null : () => Navigator.pop(context),
                child: Text("Cancel", style: GoogleFonts.montserrat()),
              ),
              const SizedBox(width: 8),
              // Create — filled black
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _black,
                  foregroundColor: _white,
                ),
                onPressed: _busy
                    ? null
                    : () async {
                        final p1 = newCtrl.text.trim();
                        final p2 = confirmCtrl.text.trim();

                        if (p1.length < 6) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    "Password must be at least 6 characters")),
                          );
                          return;
                        }
                        if (p1 != p2) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Passwords do not match")),
                          );
                          return;
                        }

                        setStateDialog(() => _busy = true);

                        try {
                          final user = _auth.currentUser!;
                          final email = user.email;
                          if (email == null || email.isEmpty) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Missing email on account.")),
                            );
                            return;
                          }

                          // Link the email/password credential to current user
                          final credential = EmailAuthProvider.credential(
                              email: email, password: p1);
                          final result = await user.linkWithCredential(credential);

                          // update Firestore updatedAt (and ensure email saved)
                          await _db.collection('users').doc(result.user!.uid).set({
                            "email": email,
                            "updatedAt": FieldValue.serverTimestamp(),
                          }, SetOptions(merge: true));

                          // refresh local state
                          await _loadUserOnce();

                          if (!mounted) return;
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Password created successfully")),
                          );
                        } on FirebaseAuthException catch (e) {
                          if (!mounted) return;
                          String msg = "Failed to create password";
                          if (e.code == 'provider-already-linked') {
                            msg = "Password provider already linked.";
                          } else if (e.code == 'credential-already-in-use') {
                            msg = "This email already has a password account.";
                          } else if (e.code == 'requires-recent-login') {
                            msg = "Please re-login and try again.";
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(msg)),
                          );
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Failed to create password")),
                          );
                        } finally {
                          if (mounted) setStateDialog(() => _busy = false);
                        }
                      },
                child: Text("Create", style: GoogleFonts.montserrat()),
              ),
            ],
          );
        });
      },
    );
  }

  // ---------------- CHANGE PASSWORD (styled) ----------------
  Future<void> _openChangePasswordDialog() async {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool _busy = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return _styledDialog(
            title: _dialogTitle("Change Password"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!_hasPasswordProvider)
                  Text(
                    "You don't have a password yet. Use Create Password first.",
                    style: GoogleFonts.montserrat(fontSize: 13),
                  ),
                if (_hasPasswordProvider) ...[
                  TextField(
                    controller: currentCtrl,
                    obscureText: true,
                    decoration: _popupInputDec(hint: "Current password"),
                  ),
                  const SizedBox(height: 12),
                ],
                TextField(
                  controller: newCtrl,
                  obscureText: true,
                  decoration: _popupInputDec(hint: "New password (min 6 chars)"),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmCtrl,
                  obscureText: true,
                  decoration: _popupInputDec(hint: "Confirm new password"),
                ),
              ],
            ),
            actions: [
              // Cancel — black text
              TextButton(
                style: TextButton.styleFrom(foregroundColor: _black),
                onPressed: _busy ? null : () => Navigator.pop(context),
                child: Text("Cancel", style: GoogleFonts.montserrat()),
              ),
              const SizedBox(width: 8),
              // Save — filled black
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _black,
                  foregroundColor: _white,
                ),
                onPressed: _busy
                    ? null
                    : () async {
                        final old = currentCtrl.text.trim();
                        final p1 = newCtrl.text.trim();
                        final p2 = confirmCtrl.text.trim();

                        if (p1.length < 6) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    "New password must be at least 6 characters")),
                          );
                          return;
                        }
                        if (p1 != p2) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Passwords do not match")),
                          );
                          return;
                        }

                        setStateDialog(() => _busy = true);

                        try {
                          final user = _auth.currentUser!;
                          if (_hasPasswordProvider) {
                            // reauthenticate with current password
                            final cred = EmailAuthProvider.credential(
                                email: user.email ?? "", password: old);
                            await user.reauthenticateWithCredential(cred);
                            await user.updatePassword(p1);

                            if (!mounted) return;
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Password updated")),
                            );
                          } else {
                            // No password provider: guide user to create one
                            if (!mounted) return;
                            Navigator.pop(context);
                            await _openCreatePasswordDialog();
                          }
                        } on FirebaseAuthException catch (e) {
                          if (!mounted) return;
                          String msg = "Failed to update password";
                          if (e.code == 'wrong-password') msg = "Current password is incorrect";
                          if (e.code == 'requires-recent-login') msg = "Please re-login and try again";
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(msg)),
                          );
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Failed to update password")),
                          );
                        } finally {
                          if (mounted) setStateDialog(() => _busy = false);
                        }
                      },
                child: Text("Save", style: GoogleFonts.montserrat()),
              ),
            ],
          );
        });
      },
    );
  }

  // ---------------- Logout confirm (styled) ----------------
  Future<void> _confirmLogout() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return _styledDialog(
          title: _dialogTitle("Confirm Logout"),
          content: Text(
            "Are you sure you want to logout?",
            style: GoogleFonts.montserrat(fontSize: 14),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: _black),
              onPressed: () => Navigator.pop(context, false),
              child: Text("Cancel", style: GoogleFonts.montserrat()),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _black,
                foregroundColor: _white,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: Text("Logout", style: GoogleFonts.montserrat()),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  // ---------------- FORM INPUT HELPER ----------------
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
        TextField(
          controller: controller,
          style: GoogleFonts.montserrat(),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: _black),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: _gold, width: 2),
            ),
          ),
        ),
      ],
    );
  }

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

  // ---------------- BUILD ----------------
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isWide = width > 760;

    // Footer data same as homepage to keep consistency
    final social = [
      SocialLink(icon: FontAwesomeIcons.instagram, url: 'https://instagram.com'),
      SocialLink(icon: FontAwesomeIcons.facebookF, url: 'https://facebook.com'),
      SocialLink(icon: FontAwesomeIcons.twitter, url: 'https://twitter.com'),
    ];

    void homePage() { print("Go to Home Page"); }
    void categoriesPage() { print("Go to Categories Page"); }
    void productDetailPage() { print("Go to Product Detail Page"); }

    final columns = [
      FooterColumn(title: 'QUICK LINKS', items: [
        FooterItem(label: 'Home', onTap: homePage),
        FooterItem(label: 'Categories', onTap: categoriesPage),
        FooterItem(label: 'Product Detail', onTap: productDetailPage),
  FooterItem(
  label: 'Contact Us',
  onTap: () {
    Navigator.pushNamed(context, '/contact');
  },
),

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

    return AppScaffold(
      currentPage: 'PROFILE',
      body: Theme(
        data: Theme.of(context).copyWith(
          primaryColor: _black,
          splashColor: Colors.black12,
          highlightColor: Colors.black12,
          hoverColor: Colors.black12,
          colorScheme: const ColorScheme.light(
            primary: _black,
            secondary: _gold,
            surface: _white,
            onPrimary: _white,
            onSecondary: _black,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: _black,
              overlayColor: Colors.black12,
              textStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: _black, width: 1.2),
              foregroundColor: _black,
              textStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: _black,
              foregroundColor: _white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              textStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        child: Scaffold(
          backgroundColor: _white,
          // Show spinner while loading
          body: _loading
              ? const Center(child: CircularProgressIndicator(color: _black))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top banner tabs (same as before)
                      TopBannerTabs(active: AccountTab.settings),

                      // Main content area — keep original layout intact
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 30,
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: _maxWidth,
                            ),
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
                                      onPressed: () => _loadUserOnce(),
                                      child: const Text("Discard"),
                                    ),
                                    const SizedBox(width: 14),
                                    ElevatedButton(
                                      onPressed: _saving ? null : _updateInfo,
                                      child: _saving
                                          ? const SizedBox(
                                              height: 18,
                                              width: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Text("Update Info"),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 40),
                                Container(
                                  height: 1,
                                  color: Colors.black.withOpacity(0.2),
                                ),
                                const SizedBox(height: 40),

                                _goldHeading("Login Info"),
                                const SizedBox(height: 20),

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
                                            borderSide: const BorderSide(
                                              color: _black,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide:
                                                const BorderSide(color: _gold),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    OutlinedButton(
                                      onPressed: _openChangeEmailDialog,
                                      child: const Text("Change Email"),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 24),

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
                                    // Button label depends on whether user has password provider
                                    OutlinedButton(
                                      onPressed: _hasPasswordProvider
                                          ? _openChangePasswordDialog
                                          : _openCreatePasswordDialog,
                                      child: Text(
                                        _hasPasswordProvider
                                            ? "Change Password"
                                            : "Create Password",
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 40),

                                ElevatedButton(
                                  onPressed: _confirmLogout,
                                  child: const Text("Logout"),
                                ),

                                const SizedBox(height: 100),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Footer — styled the same as homepage
                      Theme(
                        data: ThemeData.dark().copyWith(
                          textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Montserrat'),
                        ),
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
        ),
      )
    );
  }
}
