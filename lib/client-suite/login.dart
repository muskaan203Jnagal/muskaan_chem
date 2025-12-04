// lib/client-suite/login.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'signup.dart';
import 'my-account-dashboard.dart';

/// HOVER WIDGET
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

/// AUTH SERVICE (FINAL, WEB COMPATIBLE)
class AuthService {
  static final instance = AuthService._();
  AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential> loginEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  Future<UserCredential> guestLogin() async => _auth.signInAnonymously();

  /// GOOGLE LOGIN (WEB POPUP)
  Future<UserCredential> googleWebPopup() async {
    final provider = GoogleAuthProvider();
    return await _auth.signInWithPopup(provider);
  }
}

/// LOGIN PAGE
class ClientLoginPage extends StatefulWidget {
  const ClientLoginPage({super.key});

  @override
  State<ClientLoginPage> createState() => _ClientLoginPageState();
}

class _ClientLoginPageState extends State<ClientLoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _form = GlobalKey<FormState>();

  bool loading = false;
  bool show = false;

  static const double W = 1050, LW = 480, RW = 320;

  void _sn(String t) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));

  /// ---------------- EMAIL LOGIN ----------------
  Future<void> login() async {
    if (!_form.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      await AuthService.instance.loginEmail(_email.text, _password.text);
      _sn("Login successful");

      // ⭐ REDIRECT TO DASHBOARD
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MyAccountDashboard()),
      );

    } catch (e) {
      _sn("Login failed");
    }

    if (mounted) setState(() => loading = false);
  }

  InputDecoration deco(String hint) => InputDecoration(
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

  /// LEFT PANEL
  Widget leftPanel() => SizedBox(
        width: LW,
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Email",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),

              HoverWidget(
                builder: (_) => TextFormField(
                  controller: _email,
                  validator: (v) =>
                      v!.contains("@") ? null : "Enter valid email",
                  decoration: deco("Enter your email"),
                ),
              ),

              const SizedBox(height: 25),

              const Text("Password",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),

              HoverWidget(
                builder: (_) => TextFormField(
                  controller: _password,
                  obscureText: !show,
                  validator: (v) => v!.isEmpty ? "Enter password" : null,
                  decoration: deco("Enter your password").copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(show
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () => setState(() => show = !show),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              HoverWidget(
                builder: (hover) => AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: hover ? 0.85 : 1,
                  child: SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: loading ? null : login,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white),
                      child: loading
                          ? const CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2)
                          : const Text("Login",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600)),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Center(
                child: HoverWidget(
                  builder: (hover) => GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ClientSignupPage()),
                      );
                    },
                    child: RichText(
                      text: TextSpan(
                        text: "Don’t have an account? ",
                        style: TextStyle(
                            color: Colors.grey[700], fontSize: 13),
                        children: [
                          TextSpan(
                            text: "Sign Up",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                              decoration: hover
                                  ? TextDecoration.underline
                                  : TextDecoration.none,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      );

  /// SOCIAL BUTTON
  Widget socialBtn({
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
                    borderRadius: BorderRadius.circular(6)),
              ),
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

  /// RIGHT PANEL
  Widget rightPanel() => Padding(
        padding: const EdgeInsets.only(top: 60),
        child: SizedBox(
          width: RW,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Continue With",
                  style: GoogleFonts.montserrat(
                      fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 25),

              // GOOGLE BUTTON
              socialBtn(
                icon: Image.asset("assets/icons/google_logo.png", height: 22),
                text: "Google",
                onTap: () async {
                  try {
                    final r = await AuthService.instance.googleWebPopup();
                    _sn("Logged in as ${r.user?.email}");

                    // ⭐ REDIRECT
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const MyAccountDashboard()),
                    );

                  } catch (_) {
                    _sn("Google sign-in failed");
                  }
                },
              ),

              const SizedBox(height: 16),

              // GUEST LOGIN
              socialBtn(
                icon: const Icon(Icons.person_outline),
                text: "Guest Mode",
                onTap: () async {
                  await AuthService.instance.guestLogin();
                  _sn("Logged in as Guest");

                  // ⭐ REDIRECT
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const MyAccountDashboard()),
                  );
                },
              ),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, s) {
            final isMobile = s.maxWidth < 700;
            final w = s.maxWidth >= W ? W : s.maxWidth - 24;

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Stack(
                  children: [
                    Container(
                      width: w,
                      padding: const EdgeInsets.fromLTRB(60, 80, 60, 60),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: const [
                          BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.45),
                              blurRadius: 50)
                        ],
                      ),

                      child: isMobile
                          ? Column(
                              children: [
                                leftPanel(),
                                const SizedBox(height: 20),
                                const SizedBox(
                                    width: 120,
                                    child: Divider(color: Colors.black26)),
                                const SizedBox(height: 20),
                                rightPanel(),
                              ],
                            )
                          : IntrinsicHeight(
                              child: Row(
                                children: [
                                  leftPanel(),
                                  const SizedBox(width: 40),
                                  Container(
                                    width: 1.4,
                                    height: 180,
                                    margin: const EdgeInsets.only(top: 8),
                                    color: Colors.black.withOpacity(.75),
                                  ),
                                  const SizedBox(width: 40),
                                  rightPanel(),
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
                          "LOGIN",
                          style: GoogleFonts.montserrat(
                              fontSize: 34,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.3),
                        ),
                      ),
                    )
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
