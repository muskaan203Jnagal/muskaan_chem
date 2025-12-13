// ============================================================================
// lib/admin/verification_codes.dart
// Admin: Generate & Manage Product Verification (Scratch) Codes
// ============================================================================

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class VerificationCodesPage extends StatefulWidget {
  const VerificationCodesPage({Key? key}) : super(key: key);

  @override
  State<VerificationCodesPage> createState() => _VerificationCodesPageState();
}

class _VerificationCodesPageState extends State<VerificationCodesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Generate State ---
  String? _selectedProductId;
  Map<String, dynamic>? _selectedProduct;
  final TextEditingController _qtyCtrl = TextEditingController(text: '10');
  bool _isGenerating = false;

  // --- Filter State ---
  String _statusFilter = 'all'; // all | unused | redeemed

  // --- Helpers ---
  String _generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = Random.secure();
    String part(int len) =>
        List.generate(len, (_) => chars[rand.nextInt(chars.length)]).join();
    return 'CRX-${part(4)}-${part(4)}';
  }

  Future<bool> _codeExists(String code) async {
    final snap = await _firestore
        .collection('verification_codes')
        .where('code', isEqualTo: code)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  Future<void> _generateCodes() async {
    if (_selectedProduct == null) return;

    final qty = int.tryParse(_qtyCtrl.text) ?? 0;
    if (qty <= 0 || qty > 1000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quantity must be between 1 and 1000')),
      );
      return;
    }

    setState(() => _isGenerating = true);

    final batch = _firestore.batch();
    int created = 0;

    try {
      while (created < qty) {
        final code = _generateCode();
        if (await _codeExists(code)) continue;

        final ref = _firestore.collection('verification_codes').doc();

        batch.set(ref, {
          'code': code,
          'productId': _selectedProductId,
          'productName': _selectedProduct!['name'],
          'sku': _selectedProduct!['sku'],
          'category': _selectedProduct!['category'],
          'isRedeemed': false,
          'redeemedAt': null,
          'createdAt': FieldValue.serverTimestamp(),
        });

        created++;
      }

      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Generated $created codes successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  Future<void> _copyAllUnusedCodes(List<QueryDocumentSnapshot> docs) async {
    final unused = docs
        .where((d) => d['isRedeemed'] == false)
        .map((d) => d['code'])
        .join('\n');

    if (unused.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No unused codes found')),
      );
      return;
    }

    await Clipboard.setData(ClipboardData(text: unused));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Copied ${unused.split('\n').length} codes')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Verification Codes'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: Column(
        children: [
          _buildGenerateCard(),
          _buildFilterBar(),
          Expanded(child: _buildCodesTable()),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // UI SECTIONS
  // ---------------------------------------------------------------------------

  Widget _buildGenerateCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(flex: 3, child: _buildProductDropdown()),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: _qtyCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: _isGenerating ? null : _generateCodes,
            icon: _isGenerating
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.qr_code_2),
            label: Text(_isGenerating ? 'Generating...' : 'Generate Codes'),
            style: ElevatedButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          DropdownButton<String>(
            value: _statusFilter,
            items: const [
              DropdownMenuItem(value: 'all', child: Text('All Codes')),
              DropdownMenuItem(value: 'unused', child: Text('Unused')),
              DropdownMenuItem(value: 'redeemed', child: Text('Redeemed')),
            ],
            onChanged: (v) => setState(() => _statusFilter = v!),
          ),
          const Spacer(),
          TextButton.icon(
            icon: const Icon(Icons.copy),
            label: const Text('Copy Unused Codes'),
            onPressed: () {}, // handled inside table
          ),
        ],
      ),
    );
  }

  Widget _buildProductDropdown() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('products')
          .where('status', isEqualTo: 'active')
          .snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) return const LinearProgressIndicator();

        final docs = snap.data!.docs;

        return DropdownButtonFormField<String>(
          value: _selectedProductId,
          decoration: const InputDecoration(
            labelText: 'Select Product',
            border: OutlineInputBorder(),
          ),
          items: docs.map((doc) {
            final d = doc.data() as Map<String, dynamic>;
            return DropdownMenuItem(
              value: doc.id,
              child: Text('${d['name']} (${d['sku']})'),
            );
          }).toList(),
          onChanged: (id) {
            setState(() {
              _selectedProductId = id;
              _selectedProduct =
                  docs.firstWhere((d) => d.id == id).data()
                      as Map<String, dynamic>;
            });
          },
        );
      },
    );
  }

  Widget _buildCodesTable() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('verification_codes')
          .orderBy('createdAt', descending: true)
          .limit(200)
          .snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        List<QueryDocumentSnapshot> docs = snap.data!.docs;

        // Apply filter
        docs = docs.where((doc) {
          final redeemed = doc['isRedeemed'] == true;
          if (_statusFilter == 'unused') return !redeemed;
          if (_statusFilter == 'redeemed') return redeemed;
          return true;
        }).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: DataTable(
            headingRowColor:
                MaterialStateProperty.all(Colors.grey[100]),
            columns: const [
              DataColumn(label: Text('Code')),
              DataColumn(label: Text('Product')),
              DataColumn(label: Text('SKU')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Created')),
            ],
            rows: docs.map((doc) {
              final d = doc.data() as Map<String, dynamic>;
              final redeemed = d['isRedeemed'] == true;

              return DataRow(cells: [
                DataCell(Row(
                  children: [
                    Expanded(
                      child: SelectableText(
                        d['code'],
                        style:
                            const TextStyle(fontFamily: 'monospace'),
                      ),
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.copy, size: 16),
                      tooltip: 'Copy code',
                      onPressed: () async {
                        await Clipboard.setData(
                            ClipboardData(text: d['code']));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Code copied')),
                        );
                      },
                    ),
                  ],
                )),
                DataCell(Text(d['productName'] ?? '--')),
                DataCell(Text(d['sku'] ?? '--')),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: redeemed
                          ? Colors.red[50]
                          : Colors.green[50],
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                    child: Text(
                      redeemed ? 'REDEEMED' : 'UNUSED',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: redeemed
                            ? Colors.red[700]
                            : Colors.green[700],
                      ),
                    ),
                  ),
                ),
                DataCell(Text(
                  (d['createdAt'] as Timestamp?) != null
                      ? (d['createdAt'] as Timestamp)
                          .toDate()
                          .toLocal()
                          .toString()
                          .split('.')
                          .first
                      : '--',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600]),
                )),
              ]);
            }).toList(),
          ),
        );
      },
    );
  }
}
