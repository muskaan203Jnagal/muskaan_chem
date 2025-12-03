import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login.dart';

/// ---------------- Hover ----------------
class HoverWidget extends StatefulWidget {
  final Widget Function(bool hovered) builder;
  const HoverWidget({super.key, required this.builder});

  @override
  State<HoverWidget> createState() => _HoverWidgetState();
}

class _HoverWidgetState extends State<HoverWidget> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        child: widget.builder(_hovered),
      ),
    );
  }
}

/// ---------------- Auth ----------------
class AuthService {
  AuthService._();
  static final instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// EMAIL SIGNUP
  Future<UserCredential> signUpEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final userCred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    await userCred.user?.updateDisplayName(name.trim());
    return userCred;
  }

  /// SAVE USER IN FIRESTORE (NO PHONE)
  Future<void> saveUser({
    required String uid,
    required String name,
    required String email,
  }) async {
    await _db.collection("users").doc(uid).set({
      "name": name,
      "email": email,
      "createdAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true)); // merge ensures Google login doesn't overwrite
  }

  Future<UserCredential> guest() async => await _auth.signInAnonymously();

  /// GOOGLE LOGIN + SAVE TO FIRESTORE
  Future<UserCredential> googlePopup() async {
    final provider = GoogleAuthProvider();
    final cred = await _auth.signInWithPopup(provider);

    final user = cred.user;

    if (user != null) {
      await saveUser(
        uid: user.uid,
        name: user.displayName ?? "",
        email: user.email ?? "",
      );
    }

    return cred;
  }
}

/// ---------------- SIGNUP PAGE ----------------
class ClientSignupPage extends StatefulWidget {
  const ClientSignupPage({super.key});

  @override
  State<ClientSignupPage> createState() => _ClientSignupPageState();
}

class _ClientSignupPageState extends State<ClientSignupPage> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _loading = false;
  bool _showPassword = false;

  static const double desktopWidth = 1050;
  static const double leftWidth = 480;
  static const double rightWidth = 320;

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  /// CREATE ACCOUNT (EMAIL/PASSWORD)
  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final cred = await AuthService.instance.signUpEmail(
        name: _name.text.trim(),
        email: _email.text.trim(),
        password: _password.text.trim(),
      );

      /// Save to Firestore (NO PHONE)
      await AuthService.instance.saveUser(
        uid: cred.user!.uid,
        name: _name.text.trim(),
        email: _email.text.trim(),
      );

      _showSnack("Account created successfully");

    } catch (e) {
      _showSnack("Signup failed");
    }

    if (mounted) setState(() => _loading = false);
  }

  InputDecoration _decor(String hint) => InputDecoration(
        hintText: hint,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Colors.black, width: 1.6),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Colors.black, width: 1.6),
        ),
      );

  /// ---------------- LEFT FORM ----------------
  Widget _leftForm() {
    return SizedBox(
      width: leftWidth,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Full Name",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            HoverWidget(
              builder: (_) => TextFormField(
                controller: _name,
                validator: (v) => v!.isEmpty ? "Enter your name" : null,
                decoration: _decor("Enter your name"),
              ),
            ),

            const SizedBox(height: 25),
            const Text("Email",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            HoverWidget(
              builder: (_) => TextFormField(
                controller: _email,
                validator: (v) =>
                    v!.contains("@") ? null : "Enter valid email",
                decoration: _decor("Enter your email"),
              ),
            ),

            const SizedBox(height: 25),
            const Text("Password",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            HoverWidget(
              builder: (_) => TextFormField(
                controller: _password,
                obscureText: !_showPassword,
                validator: (v) =>
                    v!.length < 6 ? "Minimum 6 characters" : null,
                decoration: _decor("Create password").copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                        _showPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey[600]),
                    onPressed: () =>
                        setState(() => _showPassword = !_showPassword),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),
            HoverWidget(
              builder: (hover) => AnimatedOpacity(
                opacity: hover ? 0.85 : 1,
                duration: const Duration(milliseconds: 150),
                child: SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _createAccount,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white),
                    child: _loading
                        ? const CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2)
                        : const Text("Create Account",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ClientLoginPage()));
                },
                child: RichText(
                  text: TextSpan(
                    text: "Already have an account? ",
                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                    children: const [
                      TextSpan(
                        text: "Login",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ---------------- RIGHT PANEL ----------------
  Widget _rightPanelContent() {
    return SizedBox(
      width: rightWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Continue With",
              style: GoogleFonts.montserrat(
                  fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 25),

          _socialButton(
            icon: Image.asset("assets/icons/google_logo.png", height: 22),
            text: "Google",
            onTap: () async {
              try {
                final r = await AuthService.instance.googlePopup();
                _showSnack("Signed in as ${r.user?.email}");
              } catch (_) {
                _showSnack("Google sign-in failed");
              }
            },
          ),

          const SizedBox(height: 16),

          _socialButton(
            icon: const Icon(Icons.person_outline),
            text: "Guest Mode",
            onTap: () async {
              await AuthService.instance.guest();
              _showSnack("Logged in as Guest");
            },
          ),
        ],
      ),
    );
  }

  Widget _socialButton({
    required Widget icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return HoverWidget(
      builder: (hover) {
        final bg = hover ? Colors.black : Colors.white;
        final fg = hover ? Colors.white : Colors.black;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          child: SizedBox(
            height: 48,
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                  backgroundColor: bg,
                  side: const BorderSide(color: Colors.black, width: 1.6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon,
                  const SizedBox(width: 12),
                  Text(text,
                      style: TextStyle(
                          color: fg,
                          fontSize: 17,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// ---------------- MAIN UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) {
            final isMobile = c.maxWidth < 700;
            final width =
                c.maxWidth >= desktopWidth ? desktopWidth : c.maxWidth - 24;

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Stack(
                  children: [
                    Container(
                      width: width,
                      padding: const EdgeInsets.fromLTRB(60, 80, 60, 60),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: const [
                          BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.45),
                              blurRadius: 50),
                        ],
                      ),

                      child: isMobile
                          ? Column(
                              children: [
                                _leftForm(),
                                const SizedBox(height: 20),
                                const SizedBox(
                                    width: 120,
                                    child: Divider(color: Colors.black26)),
                                const SizedBox(height: 20),
                                _rightPanelContent(),
                              ],
                            )
                          : IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _leftForm(),
                                  const SizedBox(width: 50),

                                  Column(
                                    children: [
                                      const SizedBox(height: 70),
                                      Container(
                                        width: 2,
                                        height: 220,
                                        color: Colors.black
                                            .withValues(alpha: 0.75),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(width: 40),

                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 70),
                                      _rightPanelContent(),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                    ),

                    Positioned(
                      top: 25,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Text(
                          "SIGN UP",
                          style: GoogleFonts.montserrat(
                            fontSize: 34,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.4,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
