// lib/client-suite/my-addresses.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../header.dart'; // AppScaffold
import '../footer.dart'; // Footer included by pages
import 'widgets/top_banner_tabs.dart';

const Color _black = Colors.black;
const Color _white = Colors.white;
const Color _gold = Color(0xFFC9A34E);
const double _maxWidth = 1000;

/// ---------------------------------------------------------------------------
/// ADDRESS MODEL
/// ---------------------------------------------------------------------------
class AddressModel {
  final String id;
  String firstName;
  String lastName;
  String line1;
  String? line2;
  String city;
  String state;
  String country;
  String postalCode;
  String phone;
  bool isDefault;
  Timestamp? createdAt;

  AddressModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.line1,
    this.line2,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    required this.phone,
    required this.isDefault,
    this.createdAt,
  });

  factory AddressModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AddressModel(
      id: doc.id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      line1: data['line1'] ?? '',
      line2: data['line2'] ?? null,
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      country: data['country'] ?? '',
      postalCode: data['postalCode'] ?? '',
      phone: data['phone'] ?? '',
      isDefault: data['isDefault'] ?? false,
      createdAt: data['createdAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "firstName": firstName,
      "lastName": lastName,
      "line1": line1,
      "line2": line2 ?? "",
      "city": city,
      "state": state,
      "country": country,
      "postalCode": postalCode,
      "phone": phone,
      "isDefault": isDefault,
      "createdAt": createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}

/// ---------------------------------------------------------------------------
/// MAIN PAGE
/// ---------------------------------------------------------------------------
class MyAddressesPage extends StatefulWidget {
  const MyAddressesPage({Key? key}) : super(key: key);

  @override
  State<MyAddressesPage> createState() => _MyAddressesPageState();
}

class _MyAddressesPageState extends State<MyAddressesPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  late String _uid;
  bool _loadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = _auth.currentUser;
    if (user == null) {
      setState(() => _loadingUser = false);
      return;
    }
    _uid = user.uid;
    setState(() => _loadingUser = false);
  }

  CollectionReference<Map<String, dynamic>> _addressesRef() {
    return _db.collection("users").doc(_uid).collection("addresses");
  }

  Future<void> _deleteAddressFromFirestore(String id) async {
    await _addressesRef().doc(id).delete();
  }

  Future<void> _setDefaultAddress(String id) async {
    final batch = _db.batch();
    final snap = await _addressesRef().get();

    for (var d in snap.docs) {
      batch.update(_addressesRef().doc(d.id), {"isDefault": d.id == id});
    }
    await batch.commit();
  }

  /// -----------------------------------------------------------------------
  /// FULL RESPONSIVE DIALOG (desktop + mobile)
  /// -----------------------------------------------------------------------
  Future<void> _openAddressDialog({AddressModel? editing}) async {
    final first = TextEditingController(text: editing?.firstName ?? "");
    final last = TextEditingController(text: editing?.lastName ?? "");
    final l1 = TextEditingController(text: editing?.line1 ?? "");
    final l2 = TextEditingController(text: editing?.line2 ?? "");
    final city = TextEditingController(text: editing?.city ?? "");
    final st = TextEditingController(text: editing?.state ?? "");
    final country = TextEditingController(text: editing?.country ?? "");
    final zip = TextEditingController(text: editing?.postalCode ?? "");
    final phone = TextEditingController(text: editing?.phone ?? "");
    bool isDefault = editing?.isDefault ?? false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final isMobile = MediaQuery.of(context).size.width < 500;

        final dialogWidth = isMobile
            ? MediaQuery.of(context).size.width * 0.95
            : 700.0;

        return Dialog(
          backgroundColor: _white,
          insetPadding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: dialogWidth),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // HEADER
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          editing == null ? "Add New Address" : "Edit Address",
                          style: GoogleFonts.montserrat(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: _black,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.close, color: _black, size: 22),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1, color: Colors.black12),

                // SCROLLABLE CONTENT
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: _buildAddressForm(
                      first,
                      last,
                      l1,
                      l2,
                      city,
                      st,
                      country,
                      zip,
                      phone,
                      () {
                        isDefault = !isDefault;
                        (context as Element).markNeedsBuild();
                      },
                      isDefault,
                    ),
                  ),
                ),

                // BOTTOM BUTTON
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(right: 20, bottom: 20),
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      if (!mounted) return;

                      await _saveAddress(
                        editing,
                        first,
                        last,
                        l1,
                        l2,
                        city,
                        st,
                        country,
                        zip,
                        phone,
                        isDefault,
                      );

                      if (mounted) Navigator.pop(context);
                    },

                    child: Text(
                      "Save Address",
                      style: GoogleFonts.montserrat(color: _white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// -----------------------------------------------------------------------
  /// SAVE ADDRESS LOGIC
  /// -----------------------------------------------------------------------
  Future<void> _saveAddress(
    AddressModel? editing,
    TextEditingController first,
    TextEditingController last,
    TextEditingController l1,
    TextEditingController l2,
    TextEditingController city,
    TextEditingController st,
    TextEditingController country,
    TextEditingController zip,
    TextEditingController phone,
    bool isDefault,
  ) async {
    if (first.text.trim().isEmpty ||
        l1.text.trim().isEmpty ||
        city.text.trim().isEmpty ||
        phone.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill required fields")),
      );
      return;
    }

    final data = AddressModel(
      id: editing?.id ?? "",
      firstName: first.text.trim(),
      lastName: last.text.trim(),
      line1: l1.text.trim(),
      line2: l2.text.trim().isEmpty ? null : l2.text.trim(),
      city: city.text.trim(),
      state: st.text.trim(),
      country: country.text.trim(),
      postalCode: zip.text.trim(),
      phone: phone.text.trim(),
      isDefault: isDefault,
      createdAt: editing?.createdAt,
    );

    if (editing == null) {
      final docRef = await _addressesRef().add(data.toMap());
      if (isDefault) await _setDefaultAddress(docRef.id);
    } else {
      await _addressesRef().doc(editing.id).update(data.toMap());
      if (isDefault) await _setDefaultAddress(editing.id);
    }
  }

  /// -----------------------------------------------------------------------
  /// UI: ADDRESS FORM (shared by dialog mobile + desktop)
  /// -----------------------------------------------------------------------
  Widget _buildAddressForm(
    TextEditingController first,
    TextEditingController last,
    TextEditingController l1,
    TextEditingController l2,
    TextEditingController city,
    TextEditingController st,
    TextEditingController country,
    TextEditingController zip,
    TextEditingController phone,
    VoidCallback toggleDefault,
    bool isDefault,
  ) {
    final wide = MediaQuery.of(context).size.width > 700;

    return Column(
      children: [
        wide
            ? Row(
                children: [
                  Expanded(child: _formInput("First Name", first)),
                  const SizedBox(width: 12),
                  Expanded(child: _formInput("Last Name", last)),
                ],
              )
            : Column(
                children: [
                  _formInput("First Name", first),
                  const SizedBox(height: 8),
                  _formInput("Last Name", last),
                ],
              ),

        const SizedBox(height: 12),

        _formInput("Address Line 1", l1),
        const SizedBox(height: 8),
        _formInput("Address Line 2 (optional)", l2),

        const SizedBox(height: 12),

        wide
            ? Row(
                children: [
                  Expanded(child: _formInput("City", city)),
                  const SizedBox(width: 12),
                  Expanded(child: _formInput("State / Region", st)),
                ],
              )
            : Column(
                children: [
                  _formInput("City", city),
                  const SizedBox(height: 8),
                  _formInput("State / Region", st),
                ],
              ),

        const SizedBox(height: 12),

        wide
            ? Row(
                children: [
                  Expanded(child: _countryDropdown("Country", country)),
                  const SizedBox(width: 12),
                  Expanded(child: _formInput("Zip / Postal Code", zip)),
                ],
              )
            : Column(
                children: [
                  _countryDropdown("Country", country),
                  const SizedBox(height: 8),
                  _formInput("Zip / Postal Code", zip),
                ],
              ),

        const SizedBox(height: 12),

        _formInput("Phone Number", phone),

        const SizedBox(height: 18),

        Row(
          children: [
            Checkbox(
              value: isDefault,
              activeColor: _black,
              onChanged: (_) => toggleDefault(),
            ),
            Text(
              "Make this my default address",
              style: GoogleFonts.montserrat(fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }

  /// -----------------------------------------------------------------------
  /// UI: TEXT FIELD
  /// -----------------------------------------------------------------------
  Widget _formInput(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: _black),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: _gold, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  /// -----------------------------------------------------------------------
  /// UI: COUNTRY DROPDOWN
  /// -----------------------------------------------------------------------
  Widget _countryDropdown(String label, TextEditingController controller) {
    final items = [
      "Select country",
      "India",
      "United States",
      "United Kingdom",
      "Canada",
      "Australia",
      "Germany",
      "France",
      "Italy",
      "Spain",
      "Netherlands",
      "Switzerland",
      "United Arab Emirates",
      "Saudi Arabia",
      "Singapore",
      "Malaysia",
      "New Zealand",
      "South Africa",
      "Japan",
      "China",
    ];
    final selected = controller.text.isEmpty
        ? "Select country"
        : controller.text;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField(
          value: selected,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: _black),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          items: items
              .map(
                (c) => DropdownMenuItem(
                  value: c,
                  child: Text(c, style: GoogleFonts.montserrat()),
                ),
              )
              .toList(),
          onChanged: (v) {
            if (v != null && v != "Select country") {
              controller.text = v as String;
            }
          },
        ),
      ],
    );
  }

  /// -----------------------------------------------------------------------
  /// MAIN BUILD (wrapped with AppScaffold so header + footer are consistent)
  /// -----------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    // Footer data same as homepage to keep consistency
    final social = [
      SocialLink(icon: FontAwesomeIcons.instagram, url: 'https://instagram.com'),
      SocialLink(icon: FontAwesomeIcons.facebookF, url: 'https://facebook.com'),
      SocialLink(icon: FontAwesomeIcons.twitter, url: 'https://twitter.com'),
    ];

    void homePage() {}
    void categoriesPage() {}
    void productDetailPage() {}
    void contactPage() {}

    final columns = [
      FooterColumn(title: 'QUICK LINKS', items: [
        FooterItem(label: 'Home', onTap: homePage),
        FooterItem(label: 'Categories', onTap: categoriesPage),
        FooterItem(label: 'Product Detail', onTap: productDetailPage),
        FooterItem(label: 'Contact Us', onTap: contactPage),
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

    final body = SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TopBannerTabs(active: AccountTab.addresses),

          // Main content area
          Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _maxWidth),
                child: _loadingUser
                    ? const Center(child: CircularProgressIndicator(color: _black))
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(width: 3, height: 24, color: _gold),
                              const SizedBox(width: 12),
                              Text(
                                "My Addresses",
                                style: GoogleFonts.montserrat(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          ElevatedButton(
                            onPressed: () => _openAddressDialog(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _black,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 12,
                              ),
                            ),
                            child: Text(
                              "Add New Address",
                              style: GoogleFonts.montserrat(
                                color: _white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          StreamBuilder<QuerySnapshot>(
                            stream: _addressesRef()
                                .orderBy('createdAt', descending: true)
                                .snapshots(),
                            builder: (context, snap) {
                              if (!snap.hasData) {
                                return const Center(
                                  child: CircularProgressIndicator(color: _black),
                                );
                              }

                              if (snap.data!.docs.isEmpty) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Text(
                                    "No address added yet.",
                                    style: GoogleFonts.montserrat(fontSize: 18),
                                  ),
                                );
                              }

                              final list = snap.data!.docs
                                  .map((d) => AddressModel.fromDoc(d))
                                  .toList();

                              return Column(
                                children: list.map((a) => _addressTile(a)).toList(),
                              );
                            },
                          ),

                          const SizedBox(height: 60),
                        ],
                      ),
              ),
            ),
          ),

          // Footer — keep consistent look with other pages
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
    );

    return AppScaffold(currentPage: 'ACCOUNT', body: body);
  }

  /// -----------------------------------------------------------------------
  /// ADDRESS TILE UI
  /// -----------------------------------------------------------------------
  Widget _addressTile(AddressModel a) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        border: Border.all(color: _black.withOpacity(0.6), width: 1),
        borderRadius: BorderRadius.circular(6),
        color: _white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "${a.firstName} ${a.lastName}",
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _black,
                  ),
                ),
              ),
              if (a.isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _gold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: _gold, width: 1),
                  ),
                  child: Text(
                    "DEFAULT",
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _gold,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 10),

          Text(a.line1, style: GoogleFonts.montserrat()),
          if (a.line2 != null && a.line2!.isNotEmpty)
            Text(a.line2!, style: GoogleFonts.montserrat()),

          Text("${a.city}, ${a.state}", style: GoogleFonts.montserrat()),
          Text(
            "${a.country} - ${a.postalCode}",
            style: GoogleFonts.montserrat(),
          ),
          const SizedBox(height: 4),
          Text("Phone: ${a.phone}", style: GoogleFonts.montserrat()),

          const SizedBox(height: 14),

          Row(
            children: [
              _actionButton(
                label: "Edit",
                onTap: () => _openAddressDialog(editing: a),
              ),
              const SizedBox(width: 14),

              _actionButton(
                label: "Remove",
                onTap: () => _deleteAddressFromFirestore(a.id),
              ),
              const SizedBox(width: 14),

              if (!a.isDefault)
                _actionButton(
                  label: "Make default",
                  onTap: () => _setDefaultAddress(a.id),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton({required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Text(
        label,
        style: GoogleFonts.montserrat(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: _black,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
