// ============================================================================
// lib/getverified/getverified.dart
// Public Page: Verify Scratch Code (Genuine Check)
// Brand Theme: Black · White · Gold (#D4AF37) · Montserrat
// ============================================================================

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../header.dart';
import '../footer.dart'; // <-- IMPORTANT
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GetVerifiedPage extends StatefulWidget {
  const GetVerifiedPage({Key? key}) : super(key: key);

  @override
  State<GetVerifiedPage> createState() => _GetVerifiedPageState();
}

class _GetVerifiedPageState extends State<GetVerifiedPage> {
  final TextEditingController _codeCtrl = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  Map<String, dynamic>? _resultData;
  String _status = ""; // genuine | redeemed | invalid | error

  static const Color gold = Color(0xFFD4AF37);
  static const Color black = Colors.black;
  static const Color white = Colors.white;

  // ---------------------------------------------------------
  // Format CRX-XXXX-XXXX
  // ---------------------------------------------------------
  void _formatCodeInput(String value) {
    value = value.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');

    if (value.length > 4 && value.length <= 8) {
      value = "CRX-" + value.substring(3);
    }

    if (value.length > 7) {
      value =
          "CRX-" +
          value.substring(3, 7) +
          "-" +
          value.substring(7, value.length);
    }

    _codeCtrl.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  // ---------------------------------------------------------
  // VERIFY
  // ---------------------------------------------------------
  Future<void> _verifyCode() async {
    final code = _codeCtrl.text.trim().toUpperCase();
    if (code.isEmpty) return;

    setState(() {
      _isLoading = true;
      _status = "";
      _resultData = null;
    });

    try {
      final snap = await _firestore
          .collection('verification_codes')
          .where('code', isEqualTo: code)
          .limit(1)
          .get();

      if (snap.docs.isEmpty) {
        setState(() => _status = "invalid");
        return;
      }

      final doc = snap.docs.first;
      final data = doc.data();

      if (data['isRedeemed'] == true) {
        setState(() {
          _status = "redeemed";
          _resultData = data;
        });
        return;
      }

      await _firestore.collection('verification_codes').doc(doc.id).update({
        'isRedeemed': true,
        'redeemedAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _status = "genuine";
        _resultData = data;
      });
    } catch (e) {
      setState(() => _status = "error");
    } finally {
      _isLoading = false;
      setState(() {});
    }
  }

  // ---------------------------------------------------------
  // STATUS BOXES
  // ---------------------------------------------------------
  Widget _statusWidget() {
    switch (_status) {
      case "genuine":
        return _successBox();
      case "redeemed":
        return _warningBox();
      case "invalid":
        return _errorBox();
      case "error":
        return _errorText("Something went wrong. Please try again.");
      default:
        return const SizedBox();
    }
  }

  Widget _successBox() {
    return _styledBox(
      bg: Colors.green.withOpacity(0.15),
      border: Colors.green,
      icon: Icons.verified,
      iconColor: Colors.green,
      title: "Genuine Product",
      extra: _resultDetails(),
    );
  }

  Widget _warningBox() {
    return _styledBox(
      bg: Colors.orange.withOpacity(0.15),
      border: Colors.orange,
      icon: Icons.warning_amber_rounded,
      iconColor: Colors.orange,
      title: "Code Already Used",
      extra: _resultDetails(showRedeemed: true),
    );
  }

  Widget _errorBox() {
    return _styledBox(
      bg: Colors.red.withOpacity(0.15),
      border: Colors.red,
      icon: Icons.close,
      iconColor: Colors.red,
      title: "Invalid Code",
      extra: const Text(
        "Please check the code and try again.",
        style: TextStyle(color: white, fontFamily: "Montserrat"),
      ),
    );
  }

  Widget _errorText(String msg) {
    return Text(
      msg,
      style: const TextStyle(color: Colors.red, fontFamily: "Montserrat"),
    );
  }

  Widget _styledBox({
    required Color bg,
    required Color border,
    required IconData icon,
    required Color iconColor,
    required String title,
    Widget? extra,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 2),
        boxShadow: [BoxShadow(color: border.withOpacity(0.3), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 55),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: "Montserrat",
            ),
          ),
          const SizedBox(height: 10),
          if (extra != null) extra,
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // Product Details
  // ---------------------------------------------------------
  Widget _resultDetails({bool showRedeemed = false}) {
    if (_resultData == null) return const SizedBox();

    String? image =
        _resultData!['imageUrls'] != null &&
            _resultData!['imageUrls'].isNotEmpty
        ? _resultData!['imageUrls'][0]
        : null;

    String dateText = "";
    if (showRedeemed && _resultData!['redeemedAt'] != null) {
      DateTime dt = (_resultData!['redeemedAt'] as Timestamp).toDate();
      dateText = "Redeemed on ${DateFormat.yMMMd().format(dt)}";
    }

    return Column(
      children: [
        if (image != null) ...[
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              "https://wsrv.nl/?url=${Uri.encodeComponent(image)}&w=250&h=250&fit=cover",
              width: 180,
              height: 180,
              fit: BoxFit.cover,
            ),
          ),
        ],
        const SizedBox(height: 12),

        Text(
          "Product: ${_resultData!['productName']}",
          style: const TextStyle(
            fontSize: 16,
            fontFamily: "Montserrat",
            color: white,
          ),
        ),

        if (_resultData!['sku'] != null)
          Text(
            "SKU: ${_resultData!['sku']}",
            style: const TextStyle(
              color: Colors.white70,
              fontFamily: "Montserrat",
            ),
          ),

        if (_resultData!['category'] != null)
          Text(
            "Category: ${_resultData!['category']}",
            style: const TextStyle(
              color: Colors.white70,
              fontFamily: "Montserrat",
            ),
          ),

        if (dateText.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            dateText,
            style: const TextStyle(
              color: Colors.orange,
              fontFamily: "Montserrat",
            ),
          ),
        ],

        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // VERIFY ANOTHER
            TextButton.icon(
              onPressed: () {
                _codeCtrl.clear();
                setState(() {
                  _status = "";
                  _resultData = null;
                });
              },
              icon: const Icon(Icons.refresh, color: gold),
              label: const Text(
                "Verify Another",
                style: TextStyle(color: gold, fontFamily: "Montserrat"),
              ),
            ),

            const SizedBox(width: 12),

            // COPY CODE
            TextButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _codeCtrl.text));
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("Code copied!")));
              },
              icon: const Icon(Icons.copy, color: gold),
              label: const Text(
                "Copy Code",
                style: TextStyle(color: gold, fontFamily: "Montserrat"),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------
  // FOOTER (same pattern as dashboard)
  // ---------------------------------------------------------
  Widget _buildVerifiedFooter() {
    final social = [
      SocialLink(
        icon: FontAwesomeIcons.instagram,
        url: "https://instagram.com",
      ),
      SocialLink(icon: FontAwesomeIcons.facebookF, url: "https://facebook.com"),
      SocialLink(icon: FontAwesomeIcons.twitter, url: "https://twitter.com"),
    ];

    final columns = [
      FooterColumn(
        title: "QUICK LINKS",
        items: [
          FooterItem(label: "Home", url: "/"),
          FooterItem(label: "Categories"),
          FooterItem(label: "Contact Us"),
        ],
      ),
      FooterColumn(
        title: "CUSTOMER SERVICE",
        items: [
          FooterItem(label: "My Account"),
          FooterItem(label: "Order Status"),
        ],
      ),
      FooterColumn(
        title: "INFORMATION",
        items: [
          FooterItem(label: "About Us"),
          FooterItem(label: "Privacy Policy"),
        ],
      ),
      FooterColumn(
        title: "POLICIES",
        items: [
          FooterItem(label: "Data Collection"),
          FooterItem(label: "Terms & Conditions"),
        ],
      ),
    ];

    return ColoredBox(
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
    );
  }

  // ---------------------------------------------------------
  // PAGE UI
  // ---------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentPage: "GETVERIFIED",
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ----------------- CONTENT -----------------
              const SizedBox(height: 40),

              Center(
                child: Container(
                  width: 500,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        "Verify Your Product",
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Montserrat",
                          color: Colors.black,
                        ),
                      ),

                      const SizedBox(height: 14),

                      const Text(
                        "Scratch your code and enter it below to confirm authenticity.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.black54,
                          fontFamily: "Montserrat",
                        ),
                      ),

                      const SizedBox(height: 30),

                      TextField(
                        controller: _codeCtrl,
                        onChanged: _formatCodeInput,
                        style: const TextStyle(
                          fontFamily: "Montserrat",
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          hintText: "CRX-XXXX-XXXX",
                          hintStyle: const TextStyle(
                            fontFamily: "Montserrat",
                            color: Colors.black38,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.black26),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.black26),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Color(0xFFD4AF37),
                              width: 2,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      ElevatedButton(
                        onPressed: _isLoading ? null : _verifyCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 14,
                          ),
                          textStyle: const TextStyle(
                            fontFamily: "Montserrat",
                            fontSize: 16,
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text("VERIFY"),
                      ),

                      const SizedBox(height: 30),

                      _statusWidget(),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 60),

              // ----------------- FOOTER -----------------
              _buildVerifiedFooter(),
            ],
          ),
        ),
      ),
    );
  }
}
