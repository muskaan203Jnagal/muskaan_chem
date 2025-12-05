import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'cart_item.dart';
import 'dart:math' show sin,cos,sqrt;

enum PaymentMethod {
  creditCard,
  sezzle,
  afterpay,
  cashAppPay,
}

class CheckoutPage extends StatefulWidget {
  final List<CartItem> cartItems;
  final String currencyCode;

  const CheckoutPage({
    super.key,
    required this.cartItems,
    this.currencyCode = 'USD',
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  // contact / delivery
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _companyController = TextEditingController();
  final _addressController = TextEditingController();
  final _apartmentController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  final _phoneController = TextEditingController();

  final _discountController = TextEditingController();

  bool _saveInfo = false;
  bool _textOffers = false;
  bool _sameAsShipping = true;

  String _selectedCountry = 'India';
  String? _pointsDiscount;

  PaymentMethod _paymentMethod = PaymentMethod.afterpay;

  @override
  void dispose() {
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _companyController.dispose();
    _addressController.dispose();
    _apartmentController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _phoneController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  double get _subtotal {
    return widget.cartItems.fold(
      0.0,
      (sum, item) => sum + item.price * item.quantity,
    );
  }

  @override
  Widget build(BuildContext context) {
    final baseTheme = Theme.of(context);
    final textTheme = GoogleFonts.montserratTextTheme(baseTheme.textTheme);

    return Theme(
      data: baseTheme.copyWith(textTheme: textTheme),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F4F4),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 900;

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: HexBackground(
                    child: Row(
                      children: [
                        // LEFT: form
                        Expanded(
                          flex: 3,
                          child: Container(
                            color: Colors.white.withOpacity(0.92),
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 32,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildContactSection(),
                                  const SizedBox(height: 28),
                                  _buildDeliverySection(),
                                  const SizedBox(height: 28),
                                  _buildShippingMethodSection(),
                                  const SizedBox(height: 24),
                                  _buildRedeemPointsSection(),
                                  const SizedBox(height: 28),
                                  _buildPaymentSection(),
                                  const SizedBox(height: 28),
                                  _buildBillingAddressSection(),
                                  const SizedBox(height: 36),
                                  _buildBottomButtons(),
                                  const SizedBox(height: 20),
                                  _buildFooterLinks(),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // RIGHT: summary
                        if (isWide)
                          Container(
                            width: 410,
                            color: const Color(0xFFF7F7F7),
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 32,
                              ),
                              child: _buildSummaryPanel(),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ---------------- LEFT SIDE ----------------

  Widget _buildSectionTitle(String title, {Widget? trailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'Contact',
          trailing: TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 0),
            ),
            child: Text(
              'Sign in',
              style: GoogleFonts.montserrat(
                decoration: TextDecoration.underline,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _outlineField(
          controller: _emailController,
          hint: 'Email',
        ),
        const SizedBox(height: 8),
        _checkboxRow(
          value: _saveInfo,
          onChanged: (v) => setState(() => _saveInfo = v ?? false),
          label: 'Email me with news and offers',
        ),
      ],
    );
  }

  Widget _buildDeliverySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Delivery'),
        const SizedBox(height: 12),
        _dropdownField<String>(
          value: _selectedCountry,
          items: const ['India', 'United States', 'Canada'],
          onChanged: (v) => setState(() => _selectedCountry = v ?? 'India'),
          hint: 'Country/Region',
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _outlineField(
                controller: _firstNameController,
                hint: 'First name',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _outlineField(
                controller: _lastNameController,
                hint: 'Last name',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _outlineField(
          controller: _companyController,
          hint: 'Company (optional)',
        ),
        const SizedBox(height: 8),
        _outlineField(
          controller: _addressController,
          hint: 'Address',
          suffixIcon: const Icon(Icons.search, size: 18),
        ),
        const SizedBox(height: 8),
        _outlineField(
          controller: _apartmentController,
          hint: 'Apartment, suite, etc. (optional)',
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _outlineField(
                controller: _cityController,
                hint: 'City',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: _outlineField(
                controller: _stateController,
                hint: 'State',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: _outlineField(
                controller: _zipController,
                hint: 'PIN code',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _outlineField(
          controller: _phoneController,
          hint: 'Phone',
          suffixIcon: Tooltip(
            message: 'In case we need to contact you about your order.',
            child: const Icon(Icons.help_outline, size: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildShippingMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Shipping method',
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: Text(
            'Enter your shipping address to view available shipping methods.',
            style: GoogleFonts.montserrat(
              fontSize: 13,
              color: Colors.grey[800],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRedeemPointsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Redeem your Points',
            style: GoogleFonts.montserrat(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(
              style: GoogleFonts.montserrat(
                fontSize: 13,
                color: Colors.grey[800],
              ),
              children: [
                TextSpan(
                  text: 'Log in',
                  style: const TextStyle(
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const TextSpan(
                    text:
                        ' to view your points balance and discover rewards available for redemption.'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _dropdownField<String>(
            value: _pointsDiscount,
            items: const [
              '5% off',
              '10% off',
              'Free shipping',
            ],
            onChanged: (v) => setState(() => _pointsDiscount = v),
            hint: 'Select a discount',
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _pointsDiscount == null ? null : () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                disabledBackgroundColor: Colors.grey[400],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(
                'Redeem',
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment',
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'All transactions are secure and encrypted.',
          style: GoogleFonts.montserrat(
            fontSize: 13,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        _paymentTile(
          method: PaymentMethod.creditCard,
          title: 'Credit card',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _cardLogoBox('VISA'),
              const SizedBox(width: 4),
              _cardLogoBox('MC'),
              const SizedBox(width: 4),
              _cardLogoBox('DISC'),
              const SizedBox(width: 4),
              _cardLogoBox('+3'),
            ],
          ),
          expandedChild: _creditCardPlaceholder(),
        ),
        _paymentTile(
          method: PaymentMethod.sezzle,
          title: 'Buy Now, Pay Later with Sezzle',
          trailing: _pillLogo('SZ'),
        ),
        _paymentTile(
          method: PaymentMethod.afterpay,
          title: 'Afterpay',
          trailing: _pillLogo('AP'),
          expandedChild: _afterpayInfo(),
        ),
        _paymentTile(
          method: PaymentMethod.cashAppPay,
          title: 'Cash App Pay',
          trailing: _pillLogo('\$'),
        ),
      ],
    );
  }

  Widget _buildBillingAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Billing address',
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        _radioRow(
          value: true,
          groupValue: _sameAsShipping,
          label: 'Same as shipping address',
          onChanged: (v) => setState(() => _sameAsShipping = v),
        ),
        _radioRow(
          value: false,
          groupValue: _sameAsShipping,
          label: 'Use a different billing address',
          onChanged: (v) => setState(() => _sameAsShipping = v),
        ),
      ],
    );
  }

  Widget _buildBottomButtons() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.chevron_left),
              label: Text(
                'Return to cart',
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pay now clicked (demo UI).'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEB001B), // red like ref
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: Text(
                    'Pay now',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFooterLinks() {
    final style = GoogleFonts.montserrat(
      fontSize: 11,
      color: Colors.grey[700],
      decoration: TextDecoration.underline,
    );
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8),
      child: Wrap(
        spacing: 12,
        runSpacing: 4,
        children: [
          Text('Refund policy', style: style),
          Text('Shipping policy', style: style),
          Text('Terms of service', style: style),
          Text('Privacy policy', style: style),
          Text('Contact', style: style),
        ],
      ),
    );
  }

  // ---------------- RIGHT SIDE ----------------

  Widget _buildSummaryPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...widget.cartItems.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        item.imageUrl,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          item.quantity.toString(),
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      item.name,
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Text(
                  _formatMoney(item.price * item.quantity),
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
        _pointsBanner(),
        const SizedBox(height: 16),
        _discountInput(),
        const SizedBox(height: 20),
        _priceRow('Subtotal', _subtotal),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'Shipping',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(width: 4),
                Tooltip(
                  message: 'Shipping calculated at next step',
                  child: const Icon(Icons.help_outline, size: 16),
                ),
              ],
            ),
            Text(
              'Enter shipping address',
              style: GoogleFonts.montserrat(
                fontSize: 13,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Divider(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: Colors.grey[800],
              ),
            ),
            Row(
              children: [
                Text(
                  widget.currencyCode,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _formatMoney(_subtotal, showCode: false),
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            )
          ],
        ),
      ],
    );
  }

  Widget _pointsBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.card_giftcard_outlined, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Complete this purchase to earn up to 209 Points',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Use your Points to redeem a discount on your next order.',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _discountInput() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _discountController,
            decoration: InputDecoration(
              labelText: 'Discount code',
              labelStyle: GoogleFonts.montserrat(fontSize: 13),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          height: 46,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE5E5E5),
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: Text(
              'Apply',
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------- SMALL UI HELPERS ----------------

  Widget _outlineField({
    required TextEditingController controller,
    required String hint,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.montserrat(
          fontSize: 13,
          color: Colors.grey[600],
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black, width: 1.2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        suffixIcon: suffixIcon,
      ),
    );
  }

  Widget _checkboxRow({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String label,
  }) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          visualDensity: VisualDensity.compact,
        ),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.montserrat(fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _radioRow({
    required bool value,
    required bool groupValue,
    required String label,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Radio<bool>(
          value: value,
          groupValue: groupValue,
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
          visualDensity: VisualDensity.compact,
        ),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.montserrat(fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _dropdownField<T>({
    required T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required String hint,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.montserrat(
          fontSize: 13,
          color: Colors.grey[600],
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      items: items
          .map(
            (e) => DropdownMenuItem<T>(
              value: e,
              child: Text(
                e.toString(),
                style: GoogleFonts.montserrat(fontSize: 13),
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _paymentTile({
    required PaymentMethod method,
    required String title,
    Widget? trailing,
    Widget? expandedChild,
  }) {
    final bool selected = _paymentMethod == method;

    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: expandedChild == null
            ? BorderRadius.circular(10)
            : const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
        border: Border.all(
          color: selected ? Colors.black : const Color(0xFFDDDDDD),
          width: selected ? 1.3 : 1,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: expandedChild == null
                ? BorderRadius.circular(10)
                : const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
            onTap: () => setState(() => _paymentMethod = method),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (trailing != null) trailing,
                ],
              ),
            ),
          ),
          if (selected && expandedChild != null)
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFFDDDDDD)),
                ),
                color: Color(0xFFF9F9F9),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              child: expandedChild,
            ),
        ],
      ),
    );
  }

  Widget _cardLogoBox(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFDDDDDD)),
      ),
      child: Text(
        label,
        style: GoogleFonts.montserrat(
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _pillLogo(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE8FFF4),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        label,
        style: GoogleFonts.montserrat(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _creditCardPlaceholder() {
    return Container(
      height: 80,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDDDDDD)),
      ),
      child: Text(
        'Credit card form placeholder',
        style: GoogleFonts.montserrat(
          fontSize: 13,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _afterpayInfo() {
    return Column(
      children: [
        Container(
          height: 80,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFDDDDDD)),
          ),
          child: const Icon(Icons.open_in_new, size: 36),
        ),
        const SizedBox(height: 12),
        Text(
          'After clicking “Pay now”, you will be redirected to Afterpay to complete your purchase securely.',
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(
            fontSize: 12,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _priceRow(String label, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 13,
            color: Colors.grey[800],
          ),
        ),
        Text(
          _formatMoney(value),
          style: GoogleFonts.montserrat(
            fontSize: 13,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  String _formatMoney(double value, {bool showCode = true}) {
    return '\$${value.toStringAsFixed(2)}';
  }
}

/// ---------------- HEXAGON BACKGROUND ----------------

class HexBackground extends StatelessWidget {
  final Widget child;
  const HexBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: HexBackgroundPainter(),
      child: child,
    );
  }
}

class HexBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE9E9E9)
      ..strokeWidth = 0.6
      ..style = PaintingStyle.stroke;

    const double hexRadius = 28;
    final double hexWidth = hexRadius * 2;
    final double hexHeight = (sqrt(3) * hexRadius);
    final double vertSpacing = hexHeight;
    final double horizSpacing = hexWidth * 0.75;

    for (double y = -hexHeight;
        y < size.height + hexHeight;
        y += vertSpacing) {
      for (double x = -hexWidth;
          x < size.width + hexWidth;
          x += horizSpacing) {
        final offsetX = x + ((y ~/ vertSpacing) % 2 == 0 ? 0 : hexRadius * 0.75);
        _drawHexagon(canvas, paint, Offset(offsetX, y), hexRadius);
      }
    }
  }

  void _drawHexagon(Canvas canvas, Paint paint, Offset center, double r) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (60.0 * i - 30) * 3.1415926535 / 180.0;
      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
