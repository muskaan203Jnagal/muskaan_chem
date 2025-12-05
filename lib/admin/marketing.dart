// ============================================================================
// lib/admin/marketing.dart (REDESIGNED LAYOUT)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:math';

// Collection name
const String _couponCollectionName = 'coupons';

/// Model representing a Firestore Coupon document
class CouponModel {
  final String id;
  final String code;
  final String type;
  final double value;
  final double minPurchase;
  final int maxUses;
  final int usesCount;
  final Timestamp validFrom;
  final Timestamp validUntil;
  final bool isActive;

  CouponModel({
    required this.id,
    required this.code,
    required this.type,
    required this.value,
    required this.minPurchase,
    required this.maxUses,
    required this.usesCount,
    required this.validFrom,
    required this.validUntil,
    required this.isActive,
  });

  factory CouponModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CouponModel(
      id: doc.id,
      code: data['code'] ?? 'N/A',
      type: data['type'] ?? 'fixed',
      value: (data['value'] is int) ? (data['value'] as int).toDouble() : data['value'] as double? ?? 0.0,
      minPurchase: (data['minPurchase'] is int) ? (data['minPurchase'] as int).toDouble() : data['minPurchase'] as double? ?? 0.0,
      maxUses: data['maxUses'] ?? 0,
      usesCount: data['usesCount'] ?? 0,
      validFrom: data['validFrom'] as Timestamp? ?? Timestamp.now(),
      validUntil: data['validUntil'] as Timestamp? ?? Timestamp.now(),
      isActive: data['isActive'] ?? false,
    );
  }
}

class MarketingPage extends StatefulWidget {
  const MarketingPage({Key? key}) : super(key: key);

  @override
  State<MarketingPage> createState() => _MarketingPageState();
}

class _MarketingPageState extends State<MarketingPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<CouponModel> _coupons = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCoupons();
  }

  // --- Data Fetching & Actions (Omitted for brevity, unchanged from previous fix) ---

  Future<void> _fetchCoupons() async {
    setState(() { _isLoading = true; });
    try {
      final snapshot = await _firestore
          .collection(_couponCollectionName)
          .orderBy('createdAt', descending: true)
          .get();
      setState(() {
        _coupons = snapshot.docs.map((doc) => CouponModel.fromDocument(doc)).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching coupons: $e');
      setState(() { _isLoading = false; });
    }
  }

  Future<void> _toggleStatus(CouponModel coupon) async {
    try {
      await _firestore.collection(_couponCollectionName).doc(coupon.id).update({
        'isActive': !coupon.isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      _fetchCoupons();
    } catch (e) {
      print('Error toggling status: $e');
    }
  }

  void _editCoupon(CouponModel coupon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Editing coupon: ${coupon.code}')),
    );
  }
  
  Future<void> _deleteCoupon(CouponModel coupon) async {
    try {
      await _firestore.collection(_couponCollectionName).doc(coupon.id).delete();
      _fetchCoupons();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleted coupon: ${coupon.code}')),
      );
    } catch (e) {
      print('Error deleting coupon: $e');
    }
  }

  void _showCouponSchemaDialog() {
    // ... (Schema dialog implementation)
     showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Firestore Coupon Schema'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Collection: coupons', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildSchemaRow('code', 'String', 'Unique coupon code.'),
              _buildSchemaRow('type', 'String', 'Discount type: "percentage" or "fixed".'),
              _buildSchemaRow('value', 'Number', 'Discount amount (e.g., 0.10 or 15.00).'),
              _buildSchemaRow('minPurchase', 'Number', 'Minimum order value.'),
              _buildSchemaRow('maxUses', 'Number', 'Total usage limit.'),
              _buildSchemaRow('usesCount', 'Number', 'Current usage count.'),
              _buildSchemaRow('validFrom', 'Timestamp', 'Start date/time.'),
              _buildSchemaRow('validUntil', 'Timestamp', 'End date/time (expiry).'),
              _buildSchemaRow('isActive', 'Boolean', 'Manually enabled status.'),
              _buildSchemaRow('createdAt', 'Timestamp', 'Creation date.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildSchemaRow(String field, String type, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(field, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
              const SizedBox(width: 8),
              Text('($type)', style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12)),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(description, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ),
        ],
      ),
    );
  }


  // --- UI Builders ---

  // FIX: Switched from GridView to a constrained Row for a compact stat bar
  Widget _buildStatsRow(BuildContext context) {
    final activeCount = _coupons.where((c) => c.isActive).length;
    final usedCount = _coupons.fold<int>(0, (sum, c) => sum + c.usesCount);

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 800), // Max width for the stat bar
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: _buildStatCard(Icons.local_offer, 'Total Coupons', _coupons.length.toString(), Colors.blue)),
          const SizedBox(width: 16),
          Expanded(child: _buildStatCard(Icons.check_circle, 'Active Coupons', activeCount.toString(), Colors.green)),
          const SizedBox(width: 16),
          Expanded(child: _buildStatCard(Icons.bar_chart, 'Total Times Used', usedCount.toString(), Colors.orange)),
        ],
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String title, String value, Color color) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                Icon(icon, color: color.withOpacity(0.7), size: 18),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCouponTable() {
    if (_isLoading) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(32.0),
        child: CircularProgressIndicator(),
      ));
    }
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Existing Coupons', style: Theme.of(context).textTheme.titleLarge),
          ),
          const Divider(height: 1),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              // Data table implementation remains the same
              columns: const [
                DataColumn(label: Text('Code', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Discount')),
                DataColumn(label: Text('Min. Purchase')),
                DataColumn(label: Text('Valid Until')),
                DataColumn(label: Text('Usage (Used/Max)')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Actions')),
              ],
              rows: _coupons.map((coupon) {
                final discountText = coupon.type == 'percentage'
                    ? '${(coupon.value * 100).toStringAsFixed(0)}%'
                    : '\$${coupon.value.toStringAsFixed(2)} Fixed';
                
                final statusColor = coupon.isActive ? Colors.green : Colors.red;

                return DataRow(cells: [
                  DataCell(Text(coupon.code, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
                  DataCell(Text(discountText)),
                  DataCell(Text('\$${coupon.minPurchase.toStringAsFixed(2)}')),
                  DataCell(Text(DateFormat('MMM dd, yyyy').format(coupon.validUntil.toDate()))),
                  DataCell(Text('${coupon.usesCount}/${coupon.maxUses == 0 ? '∞' : coupon.maxUses}')),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        coupon.isActive ? 'Active' : 'Disabled',
                        style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Tooltip(message: 'Edit', child: IconButton(icon: const Icon(Icons.edit, color: Colors.orange, size: 20), onPressed: () => _editCoupon(coupon))),
                        Tooltip(message: coupon.isActive ? 'Deactivate' : 'Activate', child: IconButton(icon: Icon(coupon.isActive ? Icons.toggle_on : Icons.toggle_off, color: statusColor, size: 20), onPressed: () => _toggleStatus(coupon))),
                        Tooltip(message: 'Delete', child: IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 20), onPressed: () => _deleteCoupon(coupon))),
                      ],
                    ),
                  ),
                ]);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Marketing (Coupons Generation)', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        actions: [
          TextButton.icon(
            onPressed: _showCouponSchemaDialog,
            icon: const Icon(Icons.description, color: Colors.blue),
            label: const Text('Schema Docs', style: TextStyle(color: Colors.blue)),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Compact Stat Row
            _buildStatsRow(context),
            const SizedBox(height: 32),

            // 2. Main Content (Two Columns)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column: Coupon Table (Takes up most space)
                Expanded(
                  flex: 3,
                  child: _buildCouponTable(),
                ),
                const SizedBox(width: 24),

                // Right Column: Coupon Creation Form (Constrained to a fixed width)
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 350), 
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Create New Coupon', style: Theme.of(context).textTheme.titleLarge),
                      const Divider(),
                      CouponCreationForm(onCouponCreated: _fetchCoupons),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// CouponCreationForm Widget (Made independent and compact)
// ============================================================================

class CouponCreationForm extends StatefulWidget {
  final VoidCallback onCouponCreated;
  const CouponCreationForm({Key? key, required this.onCouponCreated}) : super(key: key);

  @override
  State<CouponCreationForm> createState() => _CouponCreationFormState();
}

class _CouponCreationFormState extends State<CouponCreationForm> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _codeController = TextEditingController();

  String _couponType = 'fixed';
  double _value = 0.0;
  double _minPurchase = 0.0;
  int _maxUses = 0;
  DateTime _validUntil = DateTime.now().add(const Duration(days: 30));
  bool _isSaving = false;

  String _generateRandomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random random = Random();
    return String.fromCharCodes(Iterable.generate(8, 
        (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }

  Future<void> _submitForm() async {
    // ... (Submission logic remains the same)
    if (_formKey.currentState!.validate()) {
      setState(() { _isSaving = true; });

      final code = _codeController.text.toUpperCase().trim().isEmpty 
          ? _generateRandomCode() 
          : _codeController.text.toUpperCase().trim();

      try {
        final existing = await _firestore.collection(_couponCollectionName).where('code', isEqualTo: code).limit(1).get();
        if (existing.docs.isNotEmpty) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Coupon code already exists. Please choose a different one.')),
          );
          setState(() { _isSaving = false; });
          return;
        }

        await _firestore.collection(_couponCollectionName).add({
          'code': code,
          'type': _couponType,
          'value': _value,
          'minPurchase': _minPurchase,
          'maxUses': _maxUses,
          'usesCount': 0,
          'validFrom': Timestamp.now(),
          'validUntil': Timestamp.fromDate(_validUntil),
          'isActive': true, 
          'creatorId': 'admin_user_id',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        _formKey.currentState!.reset();
        _codeController.clear();
        setState(() {
          _couponType = 'fixed';
          _value = 0.0;
          _minPurchase = 0.0;
          _maxUses = 0;
          _validUntil = DateTime.now().add(const Duration(days: 30));
        });

        widget.onCouponCreated();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Coupon $code created successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create coupon: $e')),
        );
      } finally {
        setState(() { _isSaving = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Compacted padding
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Input fields stacked vertically in this side column
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Coupon Code (Optional)',
                  hintText: 'e.g., BLACKFRIDAY',
                ),
                validator: (value) => (value ?? '').contains(RegExp(r'[!@#$%^&*()]')) ? 'Invalid characters.' : null,
                onChanged: (value) => _codeController.value = _codeController.value.copyWith(text: value.toUpperCase()),
              ),
              const SizedBox(height: 10), // Reduced spacing
              
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Discount Type'),
                value: _couponType,
                items: const [
                  DropdownMenuItem(value: 'fixed', child: Text('Fixed Amount (\$)')),
                  DropdownMenuItem(value: 'percentage', child: Text('Percentage (%)')),
                ],
                onChanged: (String? newValue) {
                  setState(() {
                    _couponType = newValue!;
                  });
                },
              ),
              const SizedBox(height: 10),

              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Discount Value',
                  prefixText: _couponType == 'fixed' ? '\$' : '',
                  suffixText: _couponType == 'percentage' ? '%' : '',
                ),
                validator: (value) {
                  final val = double.tryParse(value ?? '');
                  if (val == null || val <= 0) return 'Enter a valid value.';
                  if (_couponType == 'percentage' && val > 100) return 'Max 100% discount.';
                  _value = val;
                  return null;
                },
              ),
              const SizedBox(height: 10),

              TextFormField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Minimum Purchase (\$)'),
                initialValue: '0.00',
                validator: (value) {
                  final val = double.tryParse(value ?? '');
                  if (val == null || val < 0) return 'Enter a valid amount.';
                  _minPurchase = val;
                  return null;
                },
              ),
              const SizedBox(height: 10),

              TextFormField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Max Uses (0 for unlimited)',
                  hintText: 'e.g., 50',
                ),
                initialValue: '0',
                validator: (value) {
                  final val = int.tryParse(value ?? '');
                  if (val == null || val < 0) return 'Enter a valid number.';
                  _maxUses = val;
                  return null;
                },
              ),
              const SizedBox(height: 10),
              
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _validUntil,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                  );
                  if (date != null) {
                    setState(() {
                      _validUntil = DateTime(date.year, date.month, date.day, 23, 59, 59);
                    });
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Valid Until',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(DateFormat('MMM dd, yyyy').format(_validUntil)),
                ),
              ),

              const SizedBox(height: 20), 

              Center(
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _submitForm,
                  icon: _isSaving 
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) 
                      : const Icon(Icons.add),
                  label: Text(_isSaving ? 'Creating...' : 'Create Coupon'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}