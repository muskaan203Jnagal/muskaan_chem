import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({Key? key}) : super(key: key);

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // -- Filters & Search State --
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;
  String? _selectedStatus;
  RangeValues _priceRange = const RangeValues(0, 10000);
  bool _showFilters = false;

  // -- Pagination & Sorting State --
  int _rowsPerPage = 10;
  int _currentPage = 0;
  int _sortColumnIndex = 1; // Default sort by Name
  bool _sortAscending = true;

  // -- Bulk Selection State --
  final Set<String> _selectedIds = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // -- Logic Helpers --

  void _onSort<T>(Comparable<T> Function(Map<String, dynamic> d) getField, int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  void _handleSelectAll(bool? selected, List<DocumentSnapshot> pageDocs) {
    setState(() {
      if (selected == true) {
        _selectedIds.addAll(pageDocs.map((doc) => doc.id));
      } else {
        _selectedIds.clear();
      }
    });
  }

  Future<void> _performBulkDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete ${_selectedIds.length} Products?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final batch = _firestore.batch();
      for (var id in _selectedIds) {
        batch.delete(_firestore.collection('products').doc(id));
      }
      await batch.commit();
      setState(() => _selectedIds.clear());
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bulk delete successful')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          final allDocs = snapshot.data!.docs;
          
          // 1. Analytics Calculation
          final analytics = _calculateAnalytics(allDocs);

          // 2. Filter Data
          List<DocumentSnapshot> filteredDocs = allDocs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            
            // Search
            final matchesSearch = _searchQuery.isEmpty ||
                data['name'].toString().toLowerCase().contains(_searchQuery) ||
                data['sku'].toString().toLowerCase().contains(_searchQuery) ||
                (data['category'] ?? '').toString().toLowerCase().contains(_searchQuery);

            // Filters
            final matchesCategory = _selectedCategory == null || data['category'] == _selectedCategory;
            final matchesStatus = _selectedStatus == null || data['status'] == _selectedStatus;
            
            final price = (data['price'] as num?)?.toDouble() ?? 0.0;
            final matchesPrice = price >= _priceRange.start && price <= _priceRange.end;

            return matchesSearch && matchesCategory && matchesStatus && matchesPrice;
          }).toList();

          // 3. Sort Data
          filteredDocs.sort((a, b) {
            final da = a.data() as Map<String, dynamic>;
            final db = b.data() as Map<String, dynamic>;
            
            // Basic sort logic helpers
            int compareString(String field) => (da[field] ?? '').toString().compareTo((db[field] ?? '').toString());
            int compareNum(String field) => ((da[field] ?? 0) as num).compareTo((db[field] ?? 0) as num);

            int result;
            switch (_sortColumnIndex) {
              case 1: result = compareString('name'); break;
              case 2: result = compareString('sku'); break;
              case 3: result = compareString('category'); break;
              case 4: result = compareNum('price'); break;
              case 5: result = compareNum('stock'); break;
              case 6: result = compareString('status'); break;
              default: result = 0;
            }
            return _sortAscending ? result : -result;
          });

          // 4. Pagination Logic
          final int totalItems = filteredDocs.length;
          final int totalPages = (totalItems / _rowsPerPage).ceil();
          if (_currentPage >= totalPages && totalPages > 0) _currentPage = totalPages - 1;
          
          final int start = _currentPage * _rowsPerPage;
          final int end = (start + _rowsPerPage < totalItems) ? start + _rowsPerPage : totalItems;
          final pageDocs = totalItems > 0 ? filteredDocs.sublist(start, end) : <DocumentSnapshot>[];

          return Column(
            children: [
              // Analytics Section
              _buildAnalyticsSection(analytics),
              
              // Toolbar & Filters
              _buildToolbar(allDocs),
              
              // Bulk Actions Bar (Conditional)
              if (_selectedIds.isNotEmpty) _buildBulkActionBar(),

              // Main Table
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.grey[200]),
                    child: SizedBox(
                      width: double.infinity,
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
                        sortColumnIndex: _sortColumnIndex,
                        sortAscending: _sortAscending,
                        onSelectAll: (selected) => _handleSelectAll(selected, pageDocs),
                        columns: [
                          const DataColumn(label: Text('Img')),
                          DataColumn(label: const Text('Name'), onSort: (idx, asc) => _onSort((d) => d['name'], idx, asc)),
                          DataColumn(label: const Text('SKU'), onSort: (idx, asc) => _onSort((d) => d['sku'], idx, asc)),
                          DataColumn(label: const Text('Category'), onSort: (idx, asc) => _onSort((d) => d['category'], idx, asc)),
                          DataColumn(label: const Text('Price'), numeric: true, onSort: (idx, asc) => _onSort((d) => d['price'], idx, asc)),
                          DataColumn(label: const Text('Stock'), numeric: true, onSort: (idx, asc) => _onSort((d) => d['stock'], idx, asc)),
                          DataColumn(label: const Text('Status'), onSort: (idx, asc) => _onSort((d) => d['status'], idx, asc)),
                          const DataColumn(label: Text('Actions')),
                        ],
                        rows: pageDocs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          return DataRow(
                            selected: _selectedIds.contains(doc.id),
                            onSelectChanged: (selected) {
                              setState(() {
                                selected == true ? _selectedIds.add(doc.id) : _selectedIds.remove(doc.id);
                              });
                            },
                            cells: [
                              DataCell(_buildThumb(data['imageUrl'])),
                              DataCell(
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(data['name'] ?? 'No Name', style: const TextStyle(fontWeight: FontWeight.w600)),
                                    if (data['brand'] != null)
                                      Text(data['brand'], style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                                  ],
                                ),
                              ),
                              DataCell(Text(data['sku'] ?? '--', style: const TextStyle(fontFamily: 'monospace'))),
                              DataCell(_buildCategoryBadge(data['category'])),
                              DataCell(Text('\$${(data['price'] ?? 0).toStringAsFixed(2)}')),
                              DataCell(_buildStockIndicator(data['stock'] ?? 0)),
                              DataCell(_buildStatusChip(data['status'] ?? 'draft')),
                              DataCell(Row(
                                children: [
                                  IconButton(icon: const Icon(Icons.visibility, size: 18), onPressed: () => _showQuickView(doc.id, data)),
                                  IconButton(icon: const Icon(Icons.edit, size: 18, color: Colors.blue), onPressed: () => _showEditProductDialog(context, doc.id, data)),
                                  PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert, size: 18),
                                    onSelected: (value) {
                                      if (value == 'delete') _deleteProduct(context, doc.id);
                                      if (value == 'duplicate') _duplicateProduct(data);
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(value: 'duplicate', child: Text('Duplicate')),
                                      const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                                    ],
                                  ),
                                ],
                              )),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),

              // Pagination Footer
              _buildPaginationFooter(totalItems, start, end),
            ],
          );
        },
      ),
    );
  }

  // -- Widget Builders --

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Catalog / Products', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 2),
          Text('Manage inventory', style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
        ],
      ),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      elevation: 1,
      actions: [
        IconButton(
          icon: const Icon(Icons.description_outlined),
          tooltip: 'DB Schema',
          onPressed: () => _showSchemaDialog(context),
        ),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: ElevatedButton.icon(
            onPressed: () => _showAddProductDialog(context),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Product'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsSection(Map<String, int> stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          _buildStatCard('Total Products', stats['total'].toString(), Icons.inventory_2, Colors.blue),
          _buildStatCard('Active', stats['active'].toString(), Icons.check_circle, Colors.green),
          _buildStatCard('Low Stock', stats['lowStock'].toString(), Icons.warning, Colors.orange),
          _buildStatCard('Drafts', stats['draft'].toString(), Icons.edit_note, Colors.grey),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        elevation: 0,
        color: color.withOpacity(0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: color.withOpacity(0.1))),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 8),
                Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
              ]),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolbar(List<DocumentSnapshot> allDocs) {
    // Extract unique categories for filter
    final categories = allDocs
        .map((d) => (d.data() as Map)['category'] as String?)
        .where((c) => c != null)
        .toSet()
        .toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              // Search
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name, SKU, category...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    fillColor: Colors.grey[50],
                    filled: true,
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                ),
              ),
              const SizedBox(width: 16),
              // Filter Toggle
              OutlinedButton.icon(
                onPressed: () => setState(() => _showFilters = !_showFilters),
                icon: Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),
                label: const Text('Filters'),
              ),
            ],
          ),
          if (_showFilters) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                // Category Filter
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(labelText: 'Category', contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0), border: OutlineInputBorder()),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All Categories')),
                      ...categories.map((c) => DropdownMenuItem(value: c, child: Text(c!))),
                    ],
                    onChanged: (v) => setState(() => _selectedCategory = v),
                  ),
                ),
                const SizedBox(width: 16),
                // Status Filter
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(labelText: 'Status', contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0), border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('All Status')),
                      DropdownMenuItem(value: 'active', child: Text('Active')),
                      DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                      DropdownMenuItem(value: 'draft', child: Text('Draft')),
                    ],
                    onChanged: (v) => setState(() => _selectedStatus = v),
                  ),
                ),
                const SizedBox(width: 16),
                // Price Range
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Price: \$${_priceRange.start.round()} - \$${_priceRange.end.round()}', style: const TextStyle(fontSize: 12)),
                      RangeSlider(
                        values: _priceRange,
                        min: 0,
                        max: 10000,
                        divisions: 100,
                        labels: RangeLabels('\$${_priceRange.start.round()}', '\$${_priceRange.end.round()}'),
                        onChanged: (v) => setState(() => _priceRange = v),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildBulkActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.blue[50],
      child: Row(
        children: [
          Text('${_selectedIds.length} Selected', style: TextStyle(color: Colors.blue[900], fontWeight: FontWeight.bold)),
          const Spacer(),
          TextButton.icon(
            icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
            label: const Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: _performBulkDelete,
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            icon: Icon(Icons.close, size: 20, color: Colors.blue[900]),
            label: Text('Cancel', style: TextStyle(color: Colors.blue[900])),
            onPressed: () => setState(() => _selectedIds.clear()),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationFooter(int totalItems, int start, int end) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text('Rows per page:'),
          const SizedBox(width: 8),
          DropdownButton<int>(
            value: _rowsPerPage,
            underline: const SizedBox(),
            items: [10, 25, 50, 100].map((e) => DropdownMenuItem(value: e, child: Text('$e'))).toList(),
            onChanged: (v) => setState(() {
              _rowsPerPage = v!;
              _currentPage = 0;
            }),
          ),
          const SizedBox(width: 32),
          Text('${start + 1}-${end} of $totalItems'),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _currentPage > 0 ? () => setState(() => _currentPage--) : null,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: (end < totalItems) ? () => setState(() => _currentPage++) : null,
          ),
        ],
      ),
    );
  }

  // -- Visual Helpers --

  Widget _buildThumb(String? url) {
    if (url == null || url.isEmpty) {
      return Container(
        width: 40,
        height: 40,
        color: Colors.grey[200],
        child: const Icon(Icons.image, size: 20, color: Colors.grey),
      );
    }

    // 1. THE MAGIC FIX: Wrap the URL in a CORS proxy
    // This allows the browser to load images from Pinterest/Google/etc.
    final proxiedUrl = 'https://wsrv.nl/?url=${Uri.encodeComponent(url)}&w=100&h=100&fit=cover';

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          proxiedUrl, // Use the proxied URL here
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Center(child: Icon(Icons.broken_image, size: 16, color: Colors.grey));
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 2)));
          },
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(String? cat) {
    if (cat == null || cat.isEmpty) return const SizedBox();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(4)),
      child: Text(cat, style: TextStyle(fontSize: 11, color: Colors.grey[800])),
    );
  }

  Widget _buildStockIndicator(int stock) {
    Color color = Colors.green;
    String label = 'In Stock ($stock)';
    
    if (stock == 0) {
      color = Colors.red;
      label = 'Out of Stock';
    } else if (stock < 10) {
      color = Colors.orange;
      label = 'Low ($stock)';
    }

    return Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12));
  }

  Widget _buildStatusChip(String status) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case 'active': bgColor = Colors.green[50]!; textColor = Colors.green[700]!; break;
      case 'inactive': bgColor = Colors.red[50]!; textColor = Colors.red[700]!; break;
      case 'draft': bgColor = Colors.orange[50]!; textColor = Colors.orange[800]!; break;
      default: bgColor = Colors.grey[100]!; textColor = Colors.grey[700]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Text(status.toUpperCase(), style: TextStyle(fontSize: 10, color: textColor, fontWeight: FontWeight.bold)),
    );
  }

  // -- Actions & Dialogs --

  Map<String, int> _calculateAnalytics(List<DocumentSnapshot> docs) {
    int total = docs.length;
    int active = 0;
    int lowStock = 0;
    int draft = 0;

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['status'] == 'active') active++;
      if (data['status'] == 'draft') draft++;
      if ((data['stock'] ?? 0) < 10) lowStock++;
    }
    return {'total': total, 'active': active, 'lowStock': lowStock, 'draft': draft};
  }

  void _showAddProductDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => ProductFormDialog(
        title: 'Add New Product',
        onSave: (data) async {
          data['createdAt'] = FieldValue.serverTimestamp();
          data['updatedAt'] = FieldValue.serverTimestamp();
          data['salesCount'] = 0; // Init sales
          await _firestore.collection('products').add(data);
        },
      ),
    );
  }

  void _showEditProductDialog(BuildContext context, String id, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => ProductFormDialog(
        title: 'Edit Product',
        initialData: data,
        onSave: (updatedData) async {
          updatedData['updatedAt'] = FieldValue.serverTimestamp();
          await _firestore.collection('products').doc(id).update(updatedData);
        },
      ),
    );
  }

  void _duplicateProduct(Map<String, dynamic> data) async {
    Map<String, dynamic> copy = Map.from(data);
    copy['name'] = '${copy['name']} (Copy)';
    copy['sku'] = '${copy['sku']}-COPY'; // Avoid duplicate SKU collision
    copy['status'] = 'draft'; // Reset to draft
    copy['createdAt'] = FieldValue.serverTimestamp();
    copy['updatedAt'] = FieldValue.serverTimestamp();
    
    await _firestore.collection('products').add(copy);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product Duplicated')));
  }

  void _deleteProduct(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await _firestore.collection('products').doc(id).delete();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showQuickView(String id, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 700,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Quick View: ${data['sku']}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Side
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 200,
                      height: 200,
                      color: Colors.grey[100],
                      child: data['imageUrl'] != null 
                        ? Image.network(data['imageUrl'], fit: BoxFit.cover)
                        : const Icon(Icons.image, size: 50, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Details Side
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data['name'] ?? '', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        _buildStatusChip(data['status'] ?? 'draft'),
                        const SizedBox(height: 16),
                        Text(data['description'] ?? 'No description available.', style: TextStyle(color: Colors.grey[600])),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Price', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                Text('\$${data['price']}', style: TextStyle(fontSize: 20, color: Colors.blue[700], fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(width: 32),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Stock', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                Text('${data['stock']}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(width: 32),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Category', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                Text(data['category'] ?? '--', style: const TextStyle(fontSize: 16)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSchemaDialog(BuildContext context) {
    // Kept from your original code, simplified for brevity here
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(24),
          width: 800,
          height: 600,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('DB Schema', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))
              ]),
              const Divider(),
              const Expanded(
                child: SingleChildScrollView(
                  child: SelectableText('''
Collection: products
├── name (string)
├── description (string)
├── price (number)
├── stock (number)
├── sku (string) [Index Required]
├── category (string) [Index Required]
├── subCategory (string) - Optional
├── brand (string) - Optional
├── imageUrl (string)
├── status (string): 'active' | 'inactive' | 'draft'
├── salesCount (number)
├── createdAt (timestamp)
└── updatedAt (timestamp)
                  '''),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Updated Form Dialog to support optional category and new fields
class ProductFormDialog extends StatefulWidget {
  final String title;
  final Map<String, dynamic>? initialData;
  final Function(Map<String, dynamic>) onSave;

  const ProductFormDialog({Key? key, required this.title, this.initialData, required this.onSave}) : super(key: key);

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl, _descCtrl, _priceCtrl, _catCtrl, _imgCtrl, _stockCtrl, _skuCtrl, _brandCtrl;
  String _status = 'active';

  @override
  void initState() {
    super.initState();
    final d = widget.initialData ?? {};
    _nameCtrl = TextEditingController(text: d['name']);
    _descCtrl = TextEditingController(text: d['description']);
    _priceCtrl = TextEditingController(text: d['price']?.toString());
    _catCtrl = TextEditingController(text: d['category']);
    _imgCtrl = TextEditingController(text: d['imageUrl']);
    _stockCtrl = TextEditingController(text: d['stock']?.toString());
    _skuCtrl = TextEditingController(text: d['sku']);
    _brandCtrl = TextEditingController(text: d['brand']);
    _status = d['status'] ?? 'active';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(24),
        width: 650,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                // Row 1
                Row(children: [
                   Expanded(child: _buildField(_nameCtrl, 'Product Name', required: true)),
                   const SizedBox(width: 16),
                   Expanded(child: _buildField(_skuCtrl, 'SKU', required: true)),
                ]),
                const SizedBox(height: 16),
                // Row 2
                Row(children: [
                   Expanded(child: _buildField(_priceCtrl, 'Price', isNum: true)),
                   const SizedBox(width: 16),
                   Expanded(child: _buildField(_stockCtrl, 'Stock Qty', isNum: true)),
                ]),
                const SizedBox(height: 16),
                // Row 3
                Row(children: [
                   Expanded(child: _buildField(_catCtrl, 'Category (Optional)', required: false)),
                   const SizedBox(width: 16),
                   Expanded(child: _buildField(_brandCtrl, 'Brand (Optional)', required: false)),
                ]),
                const SizedBox(height: 16),
                _buildField(_imgCtrl, 'Image URL'),
                const SizedBox(height: 16),
                _buildField(_descCtrl, 'Description', lines: 3),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _status,
                  decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                  items: ['active', 'inactive', 'draft'].map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase()))).toList(),
                  onChanged: (v) => setState(() => _status = v!),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          widget.onSave({
                            'name': _nameCtrl.text,
                            'description': _descCtrl.text,
                            'price': double.tryParse(_priceCtrl.text) ?? 0.0,
                            'category': _catCtrl.text.isEmpty ? null : _catCtrl.text,
                            'brand': _brandCtrl.text.isEmpty ? null : _brandCtrl.text,
                            'imageUrl': _imgCtrl.text,
                            'stock': int.tryParse(_stockCtrl.text) ?? 0,
                            'sku': _skuCtrl.text,
                            'status': _status,
                          });
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
                      child: const Text('Save Product'),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, {bool required = true, bool isNum = false, int lines = 1}) {
    return TextFormField(
      controller: ctrl,
      maxLines: lines,
      keyboardType: isNum ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      validator: required ? (v) => v?.isEmpty ?? true ? 'Required' : null : null,
    );
  }
}