// lib/client-suite/my-cart.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color _black = Colors.black;
const Color _white = Colors.white;
const Color _gold = Color(0xFFC9A34E);
const double _maxWidth = 1200.0;

class MyCartPage extends StatefulWidget {
  const MyCartPage({super.key});

  @override
  State<MyCartPage> createState() => _MyCartPageState();
}

class _MyCartPageState extends State<MyCartPage> {
  final List<_CartProduct> _items = [
    _CartProduct(
      id: 'p1',
      title: 'Vanilla Bliss Candle',
      price: 699,
      imageUrl: 'https://picsum.photos/seed/p1/400/400',
      qty: 1,
    ),
    _CartProduct(
      id: 'p2',
      title: 'Galaxy Resin Keychain',
      price: 299,
      imageUrl: 'https://picsum.photos/seed/p2/400/400',
      qty: 1,
    ),
  ];

  int shipping = 60;
  int discount = 100;

  int get subtotal => _items.fold<int>(0, (s, i) => s + i.price * i.qty);
  int get total => subtotal + shipping - discount;

  void _increase(_CartProduct p) {
    setState(() => p.qty++);
  }

  void _decrease(_CartProduct p) {
    if (p.qty > 1) setState(() => p.qty--);
  }

  void _remove(_CartProduct p) {
    setState(() => _items.removeWhere((it) => it.id == p.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxWidth),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// --- TITLE ---
                  Row(
                    children: [
                      Container(width: 3, height: 24, color: _gold),
                      const SizedBox(width: 12),
                      Text(
                        "My Cart",
                        style: GoogleFonts.montserrat(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: _black,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Review your items before checkout.",
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // GOLD LINE under the description (thin)
                  Divider(color: _gold, thickness: 0.5),

                  const SizedBox(height: 20),

                  /// --- DESKTOP / MOBILE LAYOUT ---
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final isDesktop = width >= 900;

                      if (isDesktop) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _itemsList(context, isDesktop)),
                            const SizedBox(width: 28),
                            SizedBox(
                              width: 380,
                              child: _OrderSummaryCard(
                                subtotal: subtotal,
                                shipping: shipping,
                                discount: discount,
                                total: total,
                                onCheckout: _onCheckout,
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _itemsList(context, isDesktop),
                            const SizedBox(height: 20),
                            _OrderSummaryCard(
                              subtotal: subtotal,
                              shipping: shipping,
                              discount: discount,
                              total: total,
                              onCheckout: _onCheckout,
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _itemsList(BuildContext context, bool isDesktop) {
    return Column(
      children: [
        for (var i = 0; i < _items.length; i++) ...[
          _CartItemRow(
            product: _items[i],
            onIncrease: () => _increase(_items[i]),
            onDecrease: () => _decrease(_items[i]),
            onRemove: () => _remove(_items[i]),
          ),

          // Divider BETWEEN items (offset so it starts after thumbnail)
          if (i != _items.length - 1)
            Padding(
              padding: const EdgeInsets.only(top: 18, bottom: 18),
              child: Row(
                children: [
                  const SizedBox(width: 96 + 18),
                  Expanded(child: Divider(color: _gold, thickness: 0.5)),
                ],
              ),
            ),

          // Divider AFTER the LAST item (golden line like UI)
          if (i == _items.length - 1)
            Padding(
              padding: const EdgeInsets.only(top: 18, bottom: 18),
              child: Row(
                children: [
                  const SizedBox(width: 96 + 18),
                  Expanded(
                    child: Divider(
                      color: _gold, // matching existing changes
                      thickness: 0.5,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }

  void _onCheckout() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Checkout Total: ₹$total")));
  }
}

/// --- PRODUCT MODEL ---
class _CartProduct {
  final String id;
  final String title;
  final String imageUrl;
  final int price;
  int qty;
  _CartProduct({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.price,
    this.qty = 1,
  });
}

/// --- CART ITEM ROW ---
class _CartItemRow extends StatelessWidget {
  final _CartProduct product;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  const _CartItemRow({
    super.key,
    required this.product,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 4 : 8, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// Thumbnail
          Container(
            width: isMobile ? 72 : 96,
            height: isMobile ? 72 : 96,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade100,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(product.imageUrl, fit: BoxFit.cover),
            ),
          ),

          const SizedBox(width: 18),

          /// Title + Price + Qty
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  style: GoogleFonts.montserrat(
                    fontSize: isMobile ? 15 : 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "₹${product.price}",
                  style: GoogleFonts.montserrat(
                    fontSize: isMobile ? 13 : 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                _CompactQuantitySelector(
                  qty: product.qty,
                  onIncrease: onIncrease,
                  onDecrease: onDecrease,
                ),
              ],
            ),
          ),

          /// Price + Remove aligned right
          SizedBox(
            width: isMobile ? 96 : 140,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "₹${product.price * product.qty}",
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: onRemove,
                  child: Text(
                    "Remove",
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// --- SMALL QTY SELECTOR ---
/// (reduced size per your request)
class _CompactQuantitySelector extends StatelessWidget {
  final int qty;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const _CompactQuantitySelector({
    super.key,
    required this.qty,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        color: Colors.white,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // minus
          InkWell(
            onTap: onDecrease,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 6,
                vertical: isMobile ? 4 : 5,
              ),
              child: Text("-", style: GoogleFonts.montserrat(fontSize: 12)),
            ),
          ),

          // qty
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              "$qty",
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // plus
          InkWell(
            onTap: onIncrease,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 6,
                vertical: isMobile ? 4 : 5,
              ),
              child: Text("+", style: GoogleFonts.montserrat(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}

/// --- ORDER SUMMARY CARD ---
class _OrderSummaryCard extends StatelessWidget {
  final int subtotal;
  final int shipping;
  final int discount;
  final int total;
  final VoidCallback onCheckout;

  const _OrderSummaryCard({
    super.key,
    required this.subtotal,
    required this.shipping,
    required this.discount,
    required this.total,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // MAIN CARD with GOLD TOP OUTLINE
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(12),

        // ⭐ EXACT SAME THIN ROUNDED GOLD BORDER AS YOUR UI ⭐
        border: const Border(
          top: BorderSide(
            color: _gold,
            width: 3, // thin + rounded corners applied automatically
          ),
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TITLE
            Text(
              "Order Summary",
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),

            // SUMMARY LINES
            _line("Subtotal", "₹$subtotal"),
            const SizedBox(height: 12),
            _line("Shipping", "₹$shipping"),
            const SizedBox(height: 12),
            _line("Discount", "-₹$discount"),

            const SizedBox(height: 14),
            Divider(color: _gold, thickness: 0.5),
            const SizedBox(height: 14),

            // TOTAL
            Text(
              "Total: ₹$total",
              style: GoogleFonts.montserrat(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 18),

            // CHECKOUT BUTTON WRAPPED IN OUTLINE + SHADOW CONTAINER
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),

                  // 🔥 THIN GOLD OUTLINE
                  border: Border.all(color: _gold, width: 1),

                  // 🔥 VERY SUBTLE SOFT SHADOW (exact to your UI)
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),

                child: ElevatedButton(
                  onPressed: onCheckout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _black,
                    elevation: 0, // shadow already applied above
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "Proceed to Checkout",
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white, // NO purple tint
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _line(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
