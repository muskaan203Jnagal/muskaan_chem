// lib/client-suite/account_settings.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// NEW — common top banner
import 'widgets/top_banner_tabs.dart';

/// ACCOUNT SETTINGS — Loads once in initState()
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
        setState(() => _loading = false);
        return;
      }

      await user.reload();
      final reloaded = _auth.currentUser!;
      _uid = reloaded.uid;

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

      setState(() => _loading = false);
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to load user data: $e")));
      }
    }
  }

  // ---------------- Update info ----------------
  Future<void> _updateInfo() async {
    if (_uid.isEmpty) return;

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

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Updated Successfully")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Update failed")));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ---------------- CHANGE EMAIL DIALOG ----------------
  Future<void> _openChangeEmailDialog() async {
    final newEmailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Change Email",
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w700),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: newEmailCtrl,
                decoration: const InputDecoration(hintText: "New email"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordCtrl,
                obscureText: true,
                decoration: const InputDecoration(hintText: "Current password"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
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
                      content: Text("Enter password for verification"),
                    ),
                  );
                  return;
                }

                try {
                  final user = _auth.currentUser!;
                  final cred = EmailAuthProvider.credential(
                    email: user.email ?? "",
                    password: password,
                  );
                  await user.reauthenticateWithCredential(cred);
                  await user.verifyBeforeUpdateEmail(newEmail);

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Verification sent to new email."),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Failed to request email change"),
                    ),
                  );
                }
              },
              child: const Text("Send"),
            ),
          ],
        );
      },
    );
  }

  // ---------------- CHANGE PASSWORD DIALOG ----------------
  Future<void> _openChangePasswordDialog() async {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Change Password",
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w700),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: "Current password",
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: newCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: "New password (min 6 chars)",
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: confirmCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: "Confirm new password",
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                final current = currentCtrl.text;
                final n1 = newCtrl.text;
                final n2 = confirmCtrl.text;

                if (n1.length < 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "New password must be at least 6 characters",
                      ),
                    ),
                  );
                  return;
                }

                if (n1 != n2) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Passwords do not match")),
                  );
                  return;
                }

                try {
                  final user = _auth.currentUser!;
                  final cred = EmailAuthProvider.credential(
                    email: user.email ?? "",
                    password: current,
                  );
                  await user.reauthenticateWithCredential(cred);
                  await user.updatePassword(n1);

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Password updated")),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Failed to update password")),
                  );
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
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
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
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

    return Theme(
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
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: _black))
            : NestedScrollView(
                headerSliverBuilder: (context, _) {
                  return [
                    SliverToBoxAdapter(
                      child: TopBannerTabs(active: AccountTab.settings),
                    ),

                    SliverAppBar(
                      pinned: true,
                      backgroundColor: _white,
                      elevation: 0,
                      toolbarHeight: 0,
                      bottom: PreferredSize(
                        preferredSize: const Size.fromHeight(0),
                        child: Container(
                          height: 1,
                          color: Colors.black.withOpacity(0.15),
                        ),
                      ),
                    ),
                  ];
                },
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    _placeholder("My Orders"),
                    _placeholder("My Addresses"),
                    _placeholder("My Wishlist"),

                    // ACCOUNT SETTINGS UI
                    SingleChildScrollView(
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
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                            color: _gold,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
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
                                  OutlinedButton(
                                    onPressed: _openChangePasswordDialog,
                                    child: const Text("Change Password"),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 40),

                              ElevatedButton(
                                onPressed: () async {
                                  await FirebaseAuth.instance.signOut();
                                  if (!mounted) return;
                                  Navigator.pop(context);
                                },
                                child: const Text("Logout"),
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
}
