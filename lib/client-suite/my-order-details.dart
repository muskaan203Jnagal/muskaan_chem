// lib/client-suite/my-order-details.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// TOP TABS
import 'widgets/top_banner_tabs.dart';

// SHARED HEADER + FOOTER
import '../header.dart';
import '../footer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

const Color _black = Colors.black;
const Color _white = Colors.white;
const Color _gold = Color(0xFFC9A34E);
const double _maxWidth = 1000;

class OrderDetailsPage extends StatelessWidget {
  final String orderId;

  const OrderDetailsPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    // FOOTER DATA (same as all profile pages)
    final social = [
      SocialLink(icon: FontAwesomeIcons.instagram, url: 'https://instagram.com'),
      SocialLink(icon: FontAwesomeIcons.facebookF, url: 'https://facebook.com'),
      SocialLink(icon: FontAwesomeIcons.twitter, url: 'https://twitter.com'),
    ];

    void homePage() {}
    void categoriesPage() {}
    void productDetailPage() {}


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
      currentPage: "PROFILE",
      body: SingleChildScrollView(
        child: Column(
          children: [
            // TOP BANNER
            const TopBannerTabs(active: AccountTab.orders),

            // MAIN CONTENT
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection("orders")
                  .doc(orderId)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 80),
                    child: Center(child: Text("Order not found")),
                  );
                }

                final data = snapshot.data!.data() as Map<String, dynamic>;

                final placedDate = data["orderDate"]?.toDate();
                final items = List.from(data["items"] ?? []);
                final address = data["shippingAddress"] ?? {};
                final status = data["status"] ?? "Processing";
                final totalAmount = data["totalAmount"] ?? 0;
                final paymentMode = data["paymentMode"] ?? "Manual";

                return _buildContent(
                  context,
                  placedDate,
                  items,
                  address,
                  status,
                  totalAmount,
                  paymentMode,
                );
              },
            ),

            const SizedBox(height: 60),

            // FOOTER (same as profile pages)
            Theme(
              data: ThemeData.dark().copyWith(
                textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Montserrat'),
              ),
              child: ColoredBox(
                color: const Color.fromARGB(255, 8, 8, 8),
                child: Footer(
                  logo: FooterLogo(
                    image: Image.asset('assets/icons/chemo.png'),
                    onTapUrl: "https://chemrevolutions.com",
                  ),
                  socialLinks: social,
                  columns: columns,
                  copyright:
                      "© 2025 ChemRevolutions.com. All rights reserved.",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------- CONTENT UI -------------------------
  Widget _buildContent(
    BuildContext context,
    DateTime placedDate,
    List items,
    Map address,
    String status,
    num totalAmount,
    String paymentMode,
  ) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Order #${orderId.substring(0, 8)}",
                style: GoogleFonts.montserrat(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),

              Text(
                "Placed on ${placedDate.day} ${_month(placedDate.month)} ${placedDate.year}",
                style: GoogleFonts.montserrat(fontSize: 15),
              ),

              const SizedBox(height: 30),

              // STATUS CARD
              _whiteCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle("Order Status"),
                    const SizedBox(height: 20),
                    _timeline("Order Placed", "25 Nov 2025", true),
                    _timeline("Order Confirmed", "25 Nov 2025", true),
                    _timeline("Packed", "26 Nov 2025", true),
                    _timeline("Shipped", "27 Nov 2025", true),
                    _timeline("Delivered", "29 Nov 2025", true),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ITEMS CARD
              _whiteCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle("Items"),
                    const SizedBox(height: 20),

                    for (var item in items)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: item["image"] == null
                                  ? const Icon(Icons.image_not_supported)
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        item["image"],
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item["name"] ?? "Product",
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  "Qty: ${item["quantity"]}",
                                  style: GoogleFonts.montserrat(fontSize: 14),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // ADDRESS
              _whiteCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle("Delivery Address"),
                    const SizedBox(height: 10),

                    Text(
                      "${address["firstName"]} ${address["lastName"]}",
                      style: GoogleFonts.montserrat(fontSize: 15),
                    ),
                    Text(
                      address["addressLine"] ?? "",
                      style: GoogleFonts.montserrat(fontSize: 15),
                    ),
                    Text(
                      "${address["city"]}, ${address["state"]} - ${address["zip"]}",
                      style: GoogleFonts.montserrat(fontSize: 15),
                    ),
                    Text(
                      "Phone: ${address["phone"]}",
                      style: GoogleFonts.montserrat(fontSize: 15),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // PAYMENT
              _whiteCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle("Payment Method"),
                    const SizedBox(height: 10),
                    Text(paymentMode, style: GoogleFonts.montserrat(fontSize: 16)),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // PRICE SUMMARY
              _whiteCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle("Price Summary"),
                    const SizedBox(height: 10),

                    _priceRow("Subtotal", "₹$totalAmount"),
                    _priceRow("Shipping", "₹0"),
                    _priceRow("Discount", "₹0"),

                    const Divider(color: Colors.black26),

                    _priceRow("Total", "₹$totalAmount", bold: true),

                    const SizedBox(height: 20),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _black,
                        foregroundColor: _white,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {},
                      child: Text(
                        "Download Invoice",
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------------- UI HELPERS -----------------------

  String _month(int m) {
    const list = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    return list[m - 1];
  }
}

// ---------------- Helpers ----------------

Widget _sectionTitle(String title) {
  return Text(
    title,
    style: GoogleFonts.montserrat(
      fontSize: 20,
      fontWeight: FontWeight.w700,
    ),
  );
}

Widget _whiteCard({required Widget child}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      color: _white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.shade300,
          blurRadius: 15,
          spreadRadius: 2,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: child,
  );
}

Widget _timeline(String title, String date, bool active) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 22),
    child: Row(
      children: [
        Column(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: active ? _gold : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 2,
              height: 40,
              color: Colors.grey.shade300,
            )
          ],
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              date,
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ],
        )
      ],
    ),
  );
}

Widget _priceRow(String label, String value, {bool bold = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}
