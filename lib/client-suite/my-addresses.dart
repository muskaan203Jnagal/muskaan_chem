// lib/client-suite/my_addresses.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddressModel {
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

  AddressModel({
    required this.firstName,
    required this.lastName,
    required this.line1,
    this.line2,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    required this.phone,
    this.isDefault = false,
  });
}

class MyAddressesPage extends StatefulWidget {
  const MyAddressesPage({Key? key}) : super(key: key);

  @override
  State<MyAddressesPage> createState() => _MyAddressesPageState();
}

class _MyAddressesPageState extends State<MyAddressesPage> {
  // Colors match account_settings.dart
  static const Color _black = Colors.black;
  static const Color _white = Colors.white;
  static const Color _gold = Color(0xFFC9A34E);
  static const double _maxWidth = 1000;

  // Temporary local storage for addresses
  final List<AddressModel> _addresses = [];

  // Helpers to open form (for add or edit)
  Future<void> _openAddressForm({AddressModel? editing, int? index}) async {
    final firstName = TextEditingController(text: editing?.firstName ?? "");
    final lastName = TextEditingController(text: editing?.lastName ?? "");
    final line1 = TextEditingController(text: editing?.line1 ?? "");
    final line2 = TextEditingController(text: editing?.line2 ?? "");
    final city = TextEditingController(text: editing?.city ?? "");
    final state = TextEditingController(text: editing?.state ?? "");
    final country = TextEditingController(text: editing?.country ?? "");
    final postalCode = TextEditingController(text: editing?.postalCode ?? "");
    final phone = TextEditingController(text: editing?.phone ?? "");
    bool isDefault = editing?.isDefault ?? false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final isWide = MediaQuery.of(context).size.width > 760;
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Container(
              color: _white,
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title + close
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          editing == null ? "Add New Address" : "Edit Address",
                          style: GoogleFonts.montserrat(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(Icons.close, size: 20),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Use a scrollable area for many fields
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 6),

                          // name row
                          isWide
                              ? Row(
                                  children: [
                                    Expanded(
                                      child: _inputField(
                                        label: "First Name",
                                        controller: firstName,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _inputField(
                                        label: "Last Name",
                                        controller: lastName,
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    _inputField(
                                      label: "First Name",
                                      controller: firstName,
                                    ),
                                    const SizedBox(height: 8),
                                    _inputField(
                                      label: "Last Name",
                                      controller: lastName,
                                    ),
                                  ],
                                ),
                          const SizedBox(height: 10),

                          // Address lines
                          _inputField(
                            label: "Address Line 1",
                            controller: line1,
                          ),
                          const SizedBox(height: 8),
                          _inputField(
                            label: "Address Line 2 (Optional)",
                            controller: line2,
                          ),
                          const SizedBox(height: 8),

                          // city/state row
                          isWide
                              ? Row(
                                  children: [
                                    Expanded(
                                      child: _inputField(
                                        label: "City",
                                        controller: city,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _inputField(
                                        label: "State / Region",
                                        controller: state,
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    _inputField(
                                      label: "City",
                                      controller: city,
                                    ),
                                    const SizedBox(height: 8),
                                    _inputField(
                                      label: "State / Region",
                                      controller: state,
                                    ),
                                  ],
                                ),
                          const SizedBox(height: 8),

                          // country / postal
                          isWide
                              ? Row(
                                  children: [
                                    Expanded(
                                      child: _selectCountry(
                                        label: "Country",
                                        controller: country,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _inputField(
                                        label: "Zip / Postal Code",
                                        controller: postalCode,
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    _selectCountry(
                                      label: "Country",
                                      controller: country,
                                    ),
                                    const SizedBox(height: 8),
                                    _inputField(
                                      label: "Zip / Postal Code",
                                      controller: postalCode,
                                    ),
                                  ],
                                ),
                          const SizedBox(height: 8),

                          // phone
                          _inputField(label: "Phone Number", controller: phone),
                          const SizedBox(height: 12),

                          // default checkbox
                          Row(
                            children: [
                              Checkbox(
                                value: isDefault,
                                activeColor: _black,
                                onChanged: (v) {
                                  setState(() => isDefault = v ?? false);
                                  // rebuild the dialog UI by using a StatefulBuilder
                                },
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "Make this my default address",
                                style: GoogleFonts.montserrat(fontSize: 13),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Actions row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: _black),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text("Cancel", style: GoogleFonts.montserrat()),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                        onPressed: () {
                          // Basic validation
                          if (firstName.text.trim().isEmpty ||
                              line1.text.trim().isEmpty ||
                              city.text.trim().isEmpty ||
                              phone.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  "Please fill the required fields",
                                ),
                                backgroundColor: _black,
                              ),
                            );
                            return;
                          }

                          // Save or update
                          final model = AddressModel(
                            firstName: firstName.text.trim(),
                            lastName: lastName.text.trim(),
                            line1: line1.text.trim(),
                            line2: line2.text.trim().isEmpty
                                ? null
                                : line2.text.trim(),
                            city: city.text.trim(),
                            state: state.text.trim(),
                            country: country.text.trim(),
                            postalCode: postalCode.text.trim(),
                            phone: phone.text.trim(),
                            isDefault: isDefault,
                          );

                          setState(() {
                            if (isDefault) {
                              // unset other defaults
                              for (var a in _addresses) {
                                a.isDefault = false;
                              }
                            }
                            if (editing != null && index != null) {
                              _addresses[index] = model;
                            } else {
                              _addresses.add(model);
                            }
                          });

                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "Save Address",
                          style: GoogleFonts.montserrat(
                            color: _white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // small input builder (focus gives gold border)
  Widget _inputField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.montserrat(fontSize: 13)),
        const SizedBox(height: 6),
        Focus(
          child: Builder(
            builder: (context) {
              final focused = Focus.of(context).hasFocus;
              return TextField(
                controller: controller,
                style: GoogleFonts.montserrat(),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: _black),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: _black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: _gold, width: 2),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // simple country dropdown (can be expanded)
  Widget _selectCountry({
    required String label,
    required TextEditingController controller,
  }) {
    final countries = [
      "India",
      "United States",
      "United Kingdom",
      "Select country",
    ];
    // try to keep current value
    final current = controller.text.isEmpty
        ? "Select country"
        : controller.text;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.montserrat(fontSize: 13)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            border: Border.all(color: _black),
            borderRadius: BorderRadius.circular(6),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: countries.contains(current) ? current : "Select country",
              items: countries
                  .map(
                    (c) => DropdownMenuItem<String>(
                      value: c,
                      child: Text(c, style: GoogleFonts.montserrat()),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                setState(() {
                  controller.text = v ?? "";
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  // Remove address
  void _removeAddress(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Remove address", style: GoogleFonts.montserrat()),
        content: Text(
          "Are you sure you want to remove this address?",
          style: GoogleFonts.montserrat(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Cancel", style: GoogleFonts.montserrat()),
          ),
          TextButton(
            onPressed: () {
              setState(() => _addresses.removeAt(index));
              Navigator.of(context).pop();
            },
            child: Text("Remove", style: GoogleFonts.montserrat(color: _black)),
          ),
        ],
      ),
    );
  }

  // UI for each address entry (matching screenshot)
  Widget _addressTile(AddressModel a, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${a.firstName} ${a.lastName}".trim(),
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 6),
        Text(a.line1, style: GoogleFonts.montserrat()),
        if (a.line2 != null && a.line2!.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(a.line2!, style: GoogleFonts.montserrat()),
        ],
        const SizedBox(height: 2),
        Text(
          "${a.city}, ${a.state}, ${a.country} ${a.postalCode}",
          style: GoogleFonts.montserrat(),
        ),
        const SizedBox(height: 6),
        Text(a.phone, style: GoogleFonts.montserrat()),
        const SizedBox(height: 8),
        Row(
          children: [
            InkWell(
              onTap: () => _openAddressForm(editing: a, index: index),
              child: Text(
                "Edit",
                style: GoogleFonts.montserrat(
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 18),
            InkWell(
              onTap: () => _removeAddress(index),
              child: Text(
                "Remove",
                style: GoogleFonts.montserrat(
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (a.isDefault) ...[
              const SizedBox(width: 18),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _gold),
                  color: _gold.withOpacity(0.08),
                ),
                child: Text(
                  "Default",
                  style: GoogleFonts.montserrat(fontSize: 12),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 18),
        Container(height: 1, color: _black.withOpacity(0.08)),
        const SizedBox(height: 18),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isWide = width > 760;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Heading + description (match styling)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
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
              const SizedBox(height: 8),
              Text(
                "Add and manage the addresses you use often.",
                style: GoogleFonts.montserrat(fontSize: 14),
              ),
              const SizedBox(height: 20),

              // Add new address button, aligned start
              Row(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () => _openAddressForm(),
                    child: Text(
                      "Add New Address",
                      style: GoogleFonts.montserrat(
                        color: _white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 26),

              // Either empty state or list
              if (_addresses.isEmpty) ...[
                const SizedBox(height: 30),
                Text(
                  "No address added yet",
                  style: GoogleFonts.montserrat(color: Colors.grey[700]),
                ),
              ] else ...[
                // Map addresses
                for (var i = 0; i < _addresses.length; i++)
                  _addressTile(_addresses[i], i),
              ],

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
