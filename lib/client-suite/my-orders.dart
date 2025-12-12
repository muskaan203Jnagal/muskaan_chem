// lib/client-suite/my-orders.dart

import 'package:chem_revolutions/client-suite/my-order-details.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// HEADER + FOOTER + TAB BAR
import '/header.dart';
import '/footer.dart';
import 'widgets/top_banner_tabs.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

const Color _black = Colors.black;
const Color _white = Colors.white;
const Color _gold = Color(0xFFC9A34E);
const double _maxWidth = 1000;

class MyOrdersPage extends StatelessWidget {
  const MyOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return AppScaffold(
      currentPage: "PROFILE",
      body: SingleChildScrollView(
        child: Column(
          children: [
            // -------- PROFILE TABS --------
            const TopBannerTabs(active: AccountTab.orders),

            const SizedBox(height: 10),

            user == null
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Text(
                        "Please login to view your orders.",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  )
                : OrdersList(userId: user.uid),

            const SizedBox(height: 50),

            // -------- FOOTER --------
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    final social = [
      SocialLink(icon: FontAwesomeIcons.instagram, url: 'https://instagram.com'),
      SocialLink(icon: FontAwesomeIcons.facebookF, url: 'https://facebook.com'),
      SocialLink(icon: FontAwesomeIcons.twitter, url: 'https://twitter.com'),
    ];

    final columns = [
      FooterColumn(title: 'QUICK LINKS', items: [
        FooterItem(label: 'Home', url: "/"),
        FooterItem(label: 'Categories'),
        FooterItem(label: 'Product Detail'),
        FooterItem(label: 'Contact Us'),
      ]),
      FooterColumn(title: 'CUSTOMER SERVICE', items: [
        FooterItem(label: 'My Account'),
        FooterItem(label: 'Order Status'),
        FooterItem(label: 'Wishlist'),
      ]),
      FooterColumn(title: 'INFORMATION', items: [
        FooterItem(label: 'About Us'),
        FooterItem(label: 'Privacy Policy'),
        FooterItem(label: 'Data Collection'),
      ]),
      FooterColumn(title: 'POLICIES', items: [
        FooterItem(label: 'Privacy Policy'),
        FooterItem(label: 'Data Collection'),
        FooterItem(label: 'Terms & Conditions'),
      ]),
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
        copyright:
            "© 2025 ChemRevolutions.com. All rights reserved.",
      ),
    );
  }
}

class OrdersList extends StatelessWidget {
  final String userId;
  const OrdersList({super.key, required this.userId});

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case "delivered":
        return Colors.green;
      case "pending":
        return Colors.orange;
      case "processing":
        return Colors.blue;
      case "shipped":
        return Colors.blueAccent;
      case "canceled":
      case "cancelled":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Error loading orders"));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(40),
            child: Center(
              child: Text(
                "You have no orders yet.",
                style: TextStyle(fontSize: 18),
              ),
            ),
          );
        }

        final orders = snapshot.data!.docs;

        orders.sort((a, b) {
          final t1 = (a['orderDate'] as Timestamp).toDate();
          final t2 = (b['orderDate'] as Timestamp).toDate();
          return t2.compareTo(t1);
        });

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final data = orders[index].data() as Map<String, dynamic>;
                  final orderId = orders[index].id.substring(0, 8);
                  final orderDate =
                      (data['orderDate'] as Timestamp).toDate();
                  final formattedDate =
                      "${orderDate.day} ${_month(orderDate.month)} ${orderDate.year}";

                  final total = data['totalAmount'].toString();
                  final status = data['status'] ?? "Processing";
                  final itemsCount =
                      (data['items'] as List).length.toString();

                  return Container(
                    margin: const EdgeInsets.only(bottom: 25),
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Order #$orderId",
                              style: GoogleFonts.montserrat(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: _statusColor(status),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                status,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 14),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        Text(
                          "Placed on: $formattedDate  ·  Total: ₹$total  ·  Items: $itemsCount",
                          style: GoogleFonts.montserrat(
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),

                        const SizedBox(height: 18),

                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    OrderDetailsPage(orderId: orders[index].id),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _black,
                            foregroundColor: _white,
                          ),
                          child: const Text("View Details"),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  String _month(int m) {
    const months = [
      "", "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return months[m];
  }
}
