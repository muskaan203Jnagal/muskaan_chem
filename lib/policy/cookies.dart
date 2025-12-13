import 'package:flutter/material.dart';
import '/homepage/homepage.dart'; // ✅ Real HomePage
import 'policy.dart';

class CookieApp extends StatefulWidget {
  const CookieApp({super.key});

  @override
  State<CookieApp> createState() => _CookieAppState();
}

class _CookieAppState extends State<CookieApp> {
  bool showPopup = true;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // 🔥 Real HomePage
          const HomePage(),

          // 🍪 Cookie popup overlay
          if (showPopup)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.25),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: screenWidth > 500 ? 430.0 : screenWidth * 0.9,
                      maxHeight: screenHeight * 0.85,
                    ),
                    child: SingleChildScrollView(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Material(
                          color: Colors.white,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              (screenWidth * 0.06).clamp(16.0, 28.0),
                              24.0,
                              (screenWidth * 0.06).clamp(16.0, 28.0),
                              20.0,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),

                                // ✅ Cookie Icon
                                SizedBox(
                                  width: (screenWidth * 0.13).clamp(48.0, 65.0),
                                  height: (screenWidth * 0.13).clamp(48.0, 65.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.cookie,
                                      color: Colors.white,
                                      size: 26,
                                    ),
                                  ),
                                ),

                                SizedBox(height: (screenHeight * 0.02).clamp(12.0, 22.0)),

                                // ✅ Title
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    "We respect your privacy",
                                    style: TextStyle(
                                      fontSize: (screenWidth * 0.055).clamp(18.0, 22.0),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),

                                SizedBox(height: (screenHeight * 0.015).clamp(8.0, 12.0)),

                                // ✅ Description
                                Flexible(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Text(
                                      "Our website uses cookies. By continuing, we assume your "
                                      "permission to deploy cookies. Read our detailed policy below.",
                                      style: TextStyle(
                                        fontSize: (screenWidth * 0.037).clamp(13.0, 15.0),
                                        height: 1.45,
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(height: (screenHeight * 0.01).clamp(6.0, 8.0)),

                                // ✅ Privacy Policy Link
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const PolicyPageB(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "Privacy Policy",
                                    style: TextStyle(
                                      fontSize: (screenWidth * 0.037).clamp(13.0, 15.0),
                                      color: const Color(0xFFC29700),
                                      decoration: TextDecoration.underline,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),

                                SizedBox(height: (screenHeight * 0.025).clamp(16.0, 22.0)),
                                Container(height: 1, color: const Color(0xFFE3E3E3)),
                                SizedBox(height: (screenHeight * 0.025).clamp(16.0, 22.0)),

                                // ✅ Buttons
                                Padding(
                                  padding: EdgeInsets.only(
                                    right: (screenWidth * 0.02).clamp(8.0, 15.0),
                                  ),
                                  child: Row(
                                    children: [
                                      // Decline cookies
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () {
                                            setState(() {
                                              showPopup = false;
                                            });
                                          },
                                          style: OutlinedButton.styleFrom(
                                            padding: EdgeInsets.symmetric(
                                              vertical: (screenHeight * 0.018).clamp(12.0, 14.0),
                                            ),
                                            side: const BorderSide(
                                              color: Color(0xFFD7D7D7),
                                              width: 1.5,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(14),
                                            ),
                                          ),
                                          child: Text(
                                            "Decline cookies",
                                            style: TextStyle(
                                              fontSize: (screenWidth * 0.037).clamp(13.0, 15.0),
                                              color: Colors.black54,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),

                                      SizedBox(width: (screenWidth * 0.04).clamp(10.0, 15.0)),

                                      // Accept cookies (gradient)
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(14),
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFFFFD54F),
                                                Color(0xFFFFB300),
                                                Color(0xFFFF8F00),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                          ),
                                          child: ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                showPopup = false;
                                              });
                                            },
                                            style: ElevatedButton.styleFrom(
                                              padding: EdgeInsets.symmetric(
                                                vertical: (screenHeight * 0.018).clamp(12.0, 14.0),
                                              ),
                                              backgroundColor: Colors.transparent,
                                              shadowColor: Colors.transparent,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(14),
                                              ),
                                            ),
                                            child: Text(
                                              "Accept cookies",
                                              style: TextStyle(
                                                fontSize: (screenWidth * 0.037).clamp(13.0, 15.0),
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 8), // Bottom padding
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
