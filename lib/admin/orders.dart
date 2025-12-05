// ============================================================================
// lib/admin/orders.dart (FULLY UPDATED - V14: Adds Revenue Aggregation Logic)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// --- Data Models (Helpers) ---

class Product {
  final String id;
  final String name;
  final double price;
  final int stock; 

  Product({required this.id, required this.name, required this.price, required this.stock});

  static Product fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? 'No Name',
      price: (data['price'] ?? 0.0).toDouble(),
      stock: (data['stock'] ?? 0), 
    );
  }

  // Helper to create a simplified item map for the editable list
  Map<String, dynamic> toOrderItem(int quantity) {
    return {
      'productId': id,
      'name': name,
      'price': price, // Denormalized price at the time of order
      'quantity': quantity,
    };
  }
}

class UserItem {
  final String id;
  final String name;
  final String email;

  UserItem({required this.id, required this.name, required this.email});

  static UserItem fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserItem(
      id: doc.id,
      name: data['name'] ?? 'User Name Missing',
      email: data['email'] ?? 'No Email',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// ----------------------------------------------------------------------------
// --- Main Orders Page Widget (Unchanged) ---
// ----------------------------------------------------------------------------

class OrdersPage extends StatelessWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders Management'),
        elevation: 1,
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const OrdersSchemaPage()),
            ),
            icon: const Icon(Icons.description, size: 18),
            label: const Text('DB Schema Docs'),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0, left: 8.0),
            child: ElevatedButton.icon(
              onPressed: () => _showCreateOrderDialog(context),
              icon: const Icon(Icons.add_shopping_cart),
              label: const Text('Create Order Manually'),
            ),
          ),
        ],
      ),
      body: _OrderList(),
    );
  }

  void _showCreateOrderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const _CreateOrderDialog();
      },
    );
  }
}

// ----------------------------------------------------------------------------
// --- Dedicated DB Schema Documentation Page (Unchanged) ---
// ----------------------------------------------------------------------------
class OrdersSchemaPage extends StatelessWidget {
  const OrdersSchemaPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders Database Schema'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Orders Collection Schema Details', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Divider(),
            Text('This schema uses denormalization to ensure order totals and product prices remain historically accurate, even if the user or product details change.', style: TextStyle(fontStyle: FontStyle.italic)),
            SizedBox(height: 16),
            Text('Collection: orders', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 8),
            ListTile(title: Text('userId (string)'), subtitle: Text('The ID of the user associated with the order.')),
            ListTile(title: Text('userName, userEmail (string)'), subtitle: Text('Cached user details for easy display.')),
            ListTile(title: Text('orderDate (timestamp)'), subtitle: Text('Time the order was created.')),
            ListTile(title: Text('status (string)'), subtitle: Text('Fulfillment status (e.g., "Processing", "Shipped").')),
            ListTile(title: Text('paymentConfirmed (bool)'), subtitle: Text('True if payment has been received and confirmed.')),
            ListTile(title: Text('paymentMode (string)'), subtitle: Text('How the payment was made.')),
            ListTile(title: Text('shippingAddress (Map)'), subtitle: Text('Full billing/shipping address details.')),
            ListTile(title: Text('totalAmount (number)'), subtitle: Text('The final calculated total price.')),
            ListTile(title: Text('items (Array of Maps)'), subtitle: Text('List of products in the order.')),
            ListTile(title: Text('totalItemsSold (number)'), subtitle: Text('NEW: Total quantity of items in the order.')),
            ListTile(title: Text('revenueCounted (bool)'), subtitle: Text('NEW: True if this order\'s revenue has been added to the daily aggregate.')),
            SizedBox(height: 24),
            Text('items[].price is crucial: it MUST be the price at the time of order creation (denormalized).',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------------
// --- Order List Widget (Page Search - Unchanged) ---
// ----------------------------------------------------------------------------

class _OrderList extends StatefulWidget {
  @override
  State<_OrderList> createState() => _OrderListState();
}

class _OrderListState extends State<_OrderList> {
  String? _searchQuery = ''; 

  void _showOrderDetailsDialog(BuildContext context, String orderId) {
    showDialog(
      context: context,
      builder: (context) {
        return _OrderDetailsDialog(orderId: orderId);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar for Orders
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search Orders by User Name, ID, or Status...',
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Colors.blueGrey),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),
          ),
        ),
        
        // Order Stream List
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('orders')
                .orderBy('orderDate', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No orders found.'));
              }

              final allOrders = snapshot.data!.docs;
              final safeSearchQuery = _searchQuery ?? ''; 

              final filteredOrders = allOrders.where((doc) {
                if (safeSearchQuery.isEmpty) return true;
                
                final data = doc.data() as Map<String, dynamic>;
                final userName = (data['userName'] ?? '').toLowerCase();
                final status = (data['status'] ?? '').toLowerCase();
                final orderId = doc.id.toLowerCase();

                return userName.contains(safeSearchQuery) ||
                       status.contains(safeSearchQuery) ||
                       orderId.contains(safeSearchQuery);
              }).toList();

              if (filteredOrders.isEmpty) {
                return Center(child: Text('No orders match "$safeSearchQuery".'));
              }

              return ListView.builder(
                itemCount: filteredOrders.length,
                itemBuilder: (context, index) {
                  final doc = filteredOrders[index];
                  final data = doc.data() as Map<String, dynamic>;
                  
                  final totalAmount = data['totalAmount']?.toStringAsFixed(2) ?? 'N/A';
                  final status = data['status'] ?? 'Unknown';
                  final paymentConfirmed = data['paymentConfirmed'] == true;
                  final paymentMode = data['paymentMode'] ?? 'N/A';
                  final itemsCount = List<Map<String, dynamic>>.from(data['items'] ?? []).length;
                  
                  final shippingAddress = data['shippingAddress'] as Map<String, dynamic>?;
                  final shippingCity = shippingAddress?['city'] ?? 'N/A';
                  final shippingState = shippingAddress?['state'] ?? 'N/A';


                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    elevation: 1,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: paymentConfirmed ? Colors.green[600] : Colors.orange[600],
                        child: Text(data['status'][0], style: const TextStyle(color: Colors.white)),
                      ),
                      title: Text(
                        'Order #${doc.id.substring(0, 8)} - ${data['userName']}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Fulfillment: $status | Payment: ${paymentConfirmed ? 'Confirmed' : 'Pending'} ($paymentMode)'),
                          Text('Ship To: $shippingCity, $shippingState', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('\$$totalAmount', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('${itemsCount} items', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                      onTap: () {
                        _showOrderDetailsDialog(context, doc.id); 
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}


// ----------------------------------------------------------------------------
// --- Order Details/Edit Dialog (UPDATED for Revenue Aggregation) ---
// ----------------------------------------------------------------------------

class _OrderDetailsDialog extends StatefulWidget {
  final String orderId;

  const _OrderDetailsDialog({Key? key, required this.orderId}) : super(key: key);

  @override
  State<_OrderDetailsDialog> createState() => __OrderDetailsDialogState();
}

class __OrderDetailsDialogState extends State<_OrderDetailsDialog> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DocumentSnapshot? _orderSnapshot;
  
  // Editable State
  String _currentStatus = '';
  bool _paymentConfirmed = false;
  List<Map<String, dynamic>> _editableItems = [];
  
  // Original Data (used for calculating stock difference and validation)
  List<Map<String, dynamic>> _originalItems = [];
  double get _currentTotal => _editableItems.fold(0.0, (sum, item) => sum + (item['price'] * item['quantity']));

  final List<String> _statusOptions = ['Processing', 'Shipped', 'Delivered', 'Canceled', 'Refunded'];
  
  // New: Stream for all products to enable real-time stock checks
  Stream<QuerySnapshot> get _productsStream => _firestore.collection('products').snapshots();

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    // Only fetch the order snapshot
    final orderSnapshot = await _firestore.collection('orders').doc(widget.orderId).get();
    
    if (mounted) {
      setState(() {
        _orderSnapshot = orderSnapshot;
        
        final data = orderSnapshot.data() as Map<String, dynamic>?;
        if (data != null) {
          _currentStatus = data['status'] ?? 'Processing';
          _paymentConfirmed = data['paymentConfirmed'] ?? false;
          
          final items = List<Map<String, dynamic>>.from(data['items'] ?? []);
          _originalItems = List.from(items); // Deep copy of original items
          _editableItems = List.from(items); // Deep copy for editing
        }
      });
    }
  }
  
  // Helper to calculate total quantity of items in an item list
  int _calculateTotalItems(List<Map<String, dynamic>> items) {
    return items.fold(0, (sum, item) => sum + (item['quantity'] as int));
  }
  
  // Helper to get the quantity of a product in the order BEFORE any edits.
  int _getOriginalQuantity(String productId) {
    final index = _originalItems.indexWhere((i) => i['productId'] == productId);
    return index != -1 ? _originalItems[index]['quantity'] as int : 0;
  }

  // Helper to get the current quantity of a product in the edited order.
  int _getEditableQuantity(String productId) {
    final index = _editableItems.indexWhere((i) => i['productId'] == productId);
    return index != -1 ? _editableItems[index]['quantity'] as int : 0;
  }
  
  // Calculates the client-side stock based on current DB stock + order adjustments
  int _getVirtualStock(String productId, Product liveProduct) {
    final originalQuantityReserved = _getOriginalQuantity(productId);
    final currentQuantityInOrder = _getEditableQuantity(productId);
    
    final stockChange = originalQuantityReserved - currentQuantityInOrder; 
    
    return liveProduct.stock + stockChange;
  }
  
  // New signature includes the LIVE stock of the product
  void _modifyItemQuantity(int index, int change, int liveProductStock) {
    final item = _editableItems[index];
    final currentQuantityInOrder = item['quantity'] as int;
    final productId = item['productId'] as String;
    
    final newQuantity = currentQuantityInOrder + change;

    // 1. Cannot decrease past 0
    if (newQuantity < 0) return;

    // 2. Stock Check for INCREMENT (change > 0)
    if (change > 0) {
      final originalQuantityReserved = _getOriginalQuantity(productId);
      
      // Calculate the net quantity change vs. the original order quantity.
      final requiredAdditionalStock = newQuantity - originalQuantityReserved;
      
      if (requiredAdditionalStock > liveProductStock) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot increase quantity. Insufficient remaining stock.')),
        );
        return;
      }
    }

    // STATE UPDATE: This rebuilds the StreamBuilder content, updating the Virtual Stock display immediately.
    setState(() {
      if (newQuantity == 0) {
        _editableItems.removeAt(index);
      } else {
        _editableItems[index]['quantity'] = newQuantity;
      }
    });
  }
  
  void _addNewProduct(Product product) {
    final existingIndex = _editableItems.indexWhere((item) => item['productId'] == product.id);
    final virtualStock = _getVirtualStock(product.id, product);

    if (existingIndex != -1) {
      // If already in order, check stock and increment
      _modifyItemQuantity(existingIndex, 1, product.stock);
    } else {
      // New product logic 
      if (virtualStock > 0) {
        setState(() {
          _editableItems.add(product.toOrderItem(1));
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${product.name} is out of stock.')),
        );
      }
    }
  }
  
  Future<void> _saveOrderChanges() async {
    if (_orderSnapshot == null) return;
    final data = _orderSnapshot!.data() as Map<String, dynamic>;

    // --- 1. Calculate stock adjustments (same as before) ---
    final Map<String, int> stockAdjustments = {};
    for (final item in _originalItems) {
      stockAdjustments[item['productId']] = item['quantity'] as int;
    }
    for (final item in _editableItems) {
      final productId = item['productId'];
      final newQuantity = item['quantity'] as int;
      final currentAdjustment = stockAdjustments[productId] ?? 0;
      stockAdjustments[productId] = currentAdjustment - newQuantity;
    }
    
    // --- 2. Calculate Revenue & Item Changes for Aggregation ---
    final originalRevenueCounted = data['revenueCounted'] ?? false;
    final originalTotal = (data['totalAmount'] ?? 0.0).toDouble();
    final originalTotalItems = data['totalItemsSold'] ?? _calculateTotalItems(_originalItems);
    
    final newTotalItems = _calculateTotalItems(_editableItems);
    final revenueChange = _currentTotal - originalTotal;
    final itemsChange = newTotalItems - originalTotalItems;
    
    final todayId = 'daily_' + DateTime.now().toIso8601String().substring(0, 10);
    final earningsRef = _firestore.collection('earnings').doc(todayId);
    
    // Initialize updates for the order document
    final orderUpdates = <String, dynamic>{
      'status': _currentStatus,
      'paymentConfirmed': _paymentConfirmed,
      'items': _editableItems,
      'totalAmount': _currentTotal,
      'totalItemsSold': newTotalItems,
      'revenueCounted': originalRevenueCounted, // Maintain old state by default
    };

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(children: [CircularProgressIndicator(), SizedBox(width: 20), Text("Saving Order Changes...")]),
      ),
    );

    try {
      await _firestore.runTransaction((transaction) async {
        
        // A. Validate and Update Stock (same as before)
        for (final entry in stockAdjustments.entries) {
          final productId = entry.key;
          final stockChange = entry.value; 
          
          if (stockChange == 0) continue; 

          final productRef = _firestore.collection('products').doc(productId);
          final productSnapshot = await transaction.get(productRef);
          
          if (!productSnapshot.exists) {
            throw Exception('Product $productId not found.');
          }
          
          final currentStock = (productSnapshot.data()?['stock'] ?? 0) as int;

          if (currentStock + stockChange < 0) {
            throw Exception('Insufficient stock for ${productSnapshot.data()?['name']}. Cannot fulfill requested change in transaction.');
          }

          transaction.update(productRef, {'stock': FieldValue.increment(stockChange.toDouble())});
        }
        
        // B. Update Earnings Aggregation (NEW LOGIC)
        if (_paymentConfirmed) {
            if (originalRevenueCounted) {
                // Case 1: Already paid & counted. Adjust by the difference in amount/items.
                if (revenueChange != 0 || itemsChange != 0) {
                    transaction.set(
                        earningsRef,
                        {
                            'date': FieldValue.serverTimestamp(),
                            'periodType': 'daily',
                            'totalRevenue': FieldValue.increment(revenueChange),
                            'totalItemsSold': FieldValue.increment(itemsChange),
                        },
                        SetOptions(merge: true),
                    );
                }
            } else {
                // Case 2: Payment is now confirmed for the first time. Count FULL revenue.
                transaction.set(
                    earningsRef,
                    {
                        'date': FieldValue.serverTimestamp(),
                        'periodType': 'daily',
                        'totalRevenue': FieldValue.increment(_currentTotal),
                        'totalOrders': FieldValue.increment(1),
                        'totalItemsSold': FieldValue.increment(newTotalItems),
                    },
                    SetOptions(merge: true),
                );
                
                // Mark the order as counted for next time
                orderUpdates['revenueCounted'] = true;
            }
        } else if (originalRevenueCounted) {
            // Case 3: Payment UN-confirmed (e.g., refunded) and revenue was already counted. Reverse previous count.
            transaction.set(
                earningsRef,
                {
                    'date': FieldValue.serverTimestamp(),
                    'periodType': 'daily',
                    'totalRevenue': FieldValue.increment(-originalTotal), 
                    'totalOrders': FieldValue.increment(-1), 
                    'totalItemsSold': FieldValue.increment(-originalTotalItems),
                },
                SetOptions(merge: true),
            );
            
            // Mark the order as uncounted
            orderUpdates['revenueCounted'] = false;
        }

        // C. Update Order Document
        await transaction.update(_firestore.collection('orders').doc(widget.orderId), orderUpdates);
      });

      // 3. Close loading dialog, then show success
      if (mounted) Navigator.of(context).pop(); 
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order, Inventory, and Earnings updated successfully!')),
      );
      
      // Re-fetch only order data to update UI with new original items and total
      await _fetchInitialData();

    } catch (e) {
      if (mounted) Navigator.of(context).pop(); 
      
      String errorMessage = 'Transaction failed. Check product inventory and try again.';
      if (e.toString().contains('Exception:')) {
          errorMessage = e.toString().split(':').last.trim();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save changes: $errorMessage'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // _deleteOrder is kept simple: reverse stock, do not touch earnings (assume manual earnings fix for deletion/refund)
  // For a full system, _deleteOrder would also require reversing the revenue count if revenueCounted was true.
  Future<void> _deleteOrder() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete Order #${widget.orderId.substring(0, 8)}? This action is irreversible and will attempt to reverse stock. You must manually verify if earnings reversal is needed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;

    if (!confirmed) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(children: [CircularProgressIndicator(), SizedBox(width: 20), Text("Deleting and Reversing Stock...")]),
      ),
    );

    try {
      await _firestore.runTransaction((transaction) async {
        final orderRef = _firestore.collection('orders').doc(widget.orderId);
        final orderDoc = await transaction.get(orderRef);
        final data = orderDoc.data() as Map<String, dynamic>?;
        if (data == null) throw Exception('Order not found.');

        // Reverse stock by incrementing by original order quantity
        final items = List<Map<String, dynamic>>.from(data['items'] ?? []);
        for (final item in items) {
          final productRef = _firestore.collection('products').doc(item['productId']);
          transaction.update(productRef, {'stock': FieldValue.increment(item['quantity'].toDouble())});
        }
        
        // Delete the order document
        transaction.delete(orderRef);
      });

      if (mounted) Navigator.of(context).pop(); 
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order deleted and stock reversed successfully!')),
      );
      if (mounted) Navigator.of(context).pop(); 
    } catch (e) {
      if (mounted) Navigator.of(context).pop(); 
      
      String errorMessage = 'Deletion failed. Check product inventory and try again.';
      if (e.toString().contains('Exception:')) {
          errorMessage = e.toString().split(':').last.trim();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete/reverse stock: $errorMessage')),
      );
    }
  }

  void _sendOrderConfirmation() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order confirmation email queued for sending.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_orderSnapshot == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final data = _orderSnapshot!.data() as Map<String, dynamic>?;

    if (data == null) {
      return AlertDialog(title: const Text('Error'), content: Text('Order ${widget.orderId} not found.'));
    }
    
    final totalAmount = _currentTotal.toStringAsFixed(2);
    final address = Map<String, dynamic>.from(data['shippingAddress'] ?? {});

    return AlertDialog(
      title: Text('Edit Order - #${widget.orderId.substring(0, 8)}'),
      content: SizedBox(
        width: 800,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- Order Summary ---
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  title: Text('Customer: ${data['userName']} (${data['userEmail']})', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Order Date: ${(data['orderDate'] as Timestamp).toDate().toString().substring(0, 16)}'),
                  trailing: Text('Total: \$$totalAmount', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo, fontSize: 18)),
                ),
              ),

              // --- Edit Status & Payment ---
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('1. Order Fulfillment Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const Divider(),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(labelText: 'Fulfillment Status'),
                              value: _currentStatus,
                              items: _statusOptions.map((status) => DropdownMenuItem(value: status, child: Text(status))).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _currentStatus = val);
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CheckboxListTile(
                              title: Text('Payment Confirmed (${data['paymentMode']})'),
                              value: _paymentConfirmed,
                              onChanged: (val) {
                                if (val != null) setState(() => _paymentConfirmed = val);
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              // --- Edit Order Contents (Products) ---
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('2. Edit Order Contents (Products & Quantities)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const Divider(),
                      
                      // StreamBuilder for real-time product list
                      StreamBuilder<QuerySnapshot>(
                        stream: _productsStream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Text('Error loading products: ${snapshot.error}');
                          }
                          
                          // Map products for easy lookup
                          final allProductsMap = {
                            for (var doc in snapshot.data!.docs)
                              doc.id: Product.fromFirestore(doc)
                          };
                          
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Current Items in Order List
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _editableItems.length,
                                itemBuilder: (context, index) {
                                  final item = _editableItems[index];
                                  final productId = item['productId'] as String;
                                  final currentQuantity = item['quantity'] as int;
                                  
                                  final liveProduct = allProductsMap[productId];
                                  if (liveProduct == null) return const SizedBox.shrink(); // Hide if product doesn't exist anymore
                                  
                                  final liveProductStock = liveProduct.stock;
                                  final originalQuantity = _getOriginalQuantity(productId);
                                  
                                  // Use the new helper to get the real-time stock feedback for the user
                                  final virtualStock = _getVirtualStock(productId, liveProduct);
                                  
                                  // Determine if we can increment (needs to be checked against the *live* stock for the final commit)
                                  final stockNeededForNextIncrement = (currentQuantity + 1) - originalQuantity;
                                  final canIncrement = liveProductStock >= stockNeededForNextIncrement;

                                  return ListTile(
                                    title: Text('${item['name']}'),
                                    // Display the Virtual Stock
                                    subtitle: Text('Price: \$${item['price'].toStringAsFixed(2)} | Current Qty: $currentQuantity | Virtual Stock: $virtualStock'),
                                    trailing: SizedBox(
                                      width: 120,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                            // Pass the live product stock to the modify function
                                            onPressed: () => _modifyItemQuantity(index, -1, liveProductStock), 
                                          ),
                                          Text(currentQuantity.toString()),
                                          IconButton(
                                            icon: Icon(Icons.add_circle_outline, color: canIncrement ? Colors.green : Colors.grey),
                                            // Pass the live product stock to the modify function
                                            onPressed: canIncrement ? () => _modifyItemQuantity(index, 1, liveProductStock) : null,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              
                              const Divider(height: 20),
                              
                              // Add Product Dropdown
                              DropdownButtonFormField<Product>(
                                decoration: const InputDecoration(labelText: 'Add Product to Order'),
                                items: allProductsMap.values.where((p) {
                                  // Filter to only show products where the calculated Virtual Stock is > 0
                                  final virtualStock = _getVirtualStock(p.id, p);
                                  return virtualStock > 0;
                                  
                                }).map((product) {
                                  // Recalculate virtual stock for display in the dropdown list
                                  final virtualStock = _getVirtualStock(product.id, product);
                                  
                                  return DropdownMenuItem(
                                    value: product,
                                    // Display the Virtual Stock
                                    child: Text('${product.name} (\$${product.price.toStringAsFixed(2)}) - Virtual Stock: $virtualStock'),
                                  );
                                }).toList(),
                                onChanged: (product) {
                                  if (product != null) _addNewProduct(product);
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // --- Shipping Address (Unchanged) ---
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('3. Shipping Address', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const Divider(),
                      Text('${address['firstName'] ?? ''} ${address['lastName'] ?? ''}'),
                      Text(address['addressLine'] ?? 'N/A'),
                      Text('${address['city'] ?? ''}, ${address['state'] ?? ''} - ${address['zip'] ?? ''}'),
                      Text('${address['country'] ?? ''} | Phone: ${address['phone'] ?? ''}'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton.icon(
          onPressed: _sendOrderConfirmation,
          icon: const Icon(Icons.mail_outline),
          label: const Text('Send Confirmation'),
        ),
        TextButton.icon(
          onPressed: _deleteOrder,
          icon: const Icon(Icons.delete, color: Colors.red),
          label: const Text('Delete Order', style: TextStyle(color: Colors.red)),
        ),
        ElevatedButton.icon(
          onPressed: _saveOrderChanges,
          icon: const Icon(Icons.save),
          label: const Text('Save All Changes'),
        ),
      ],
    );
  }
}

// ----------------------------------------------------------------------------
// --- Create Order Dialog (UPDATED for Revenue Aggregation) ---
// ----------------------------------------------------------------------------

class _CreateOrderDialog extends StatefulWidget {
  const _CreateOrderDialog({Key? key}) : super(key: key);

  @override
  State<_CreateOrderDialog> createState() => __CreateOrderDialogState();
}

class __CreateOrderDialogState extends State<_CreateOrderDialog> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserItem? _selectedUser;
  // _orderItems: [{'product': Product, 'quantity': int}]
  final List<Map<String, dynamic>> _orderItems = []; 
  String _paymentMode = 'Manual';
  bool _paymentConfirmed = true; // Assume manual orders are confirmed by default

  String? _searchQuery = ''; 
  List<UserItem> _allUsers = [];
  final _searchController = TextEditingController();

  final Map<String, String> _billingAddress = {
    'firstName': '', 'lastName': '', 'phone': '', 'country': 'India', 
    'addressLine': '', 'city': '', 'state': '', 'zip': '',
  };
  
  @override
  void initState() {
    super.initState();
    _fetchUsers().then((users) {
      if (mounted) {
        setState(() {
          _allUsers = users;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  double get _currentTotal {
    return _orderItems.fold(0.0, (sum, item) {
      final product = item['product'] as Product;
      final quantity = item['quantity'] as int;
      return sum + (product.price * quantity);
    });
  }
  
  // Helper to calculate total quantity of items in an item list
  int _calculateTotalItems(List<Map<String, dynamic>> items) {
    return items.fold(0, (sum, item) => sum + (item['quantity'] as int));
  }

  Future<List<UserItem>> _fetchUsers() async {
    final snapshot = await _firestore.collection('users').get();
    return snapshot.docs.map((doc) => UserItem.fromFirestore(doc)).toList();
  }

  List<UserItem> get _filteredUsers {
    final query = _searchQuery ?? ''; 
    
    if (query.isEmpty) {
      return []; 
    }
    return _allUsers.where((user) {
      final lowerQuery = query.toLowerCase();
      return user.name.toLowerCase().contains(lowerQuery) ||
             user.email.toLowerCase().contains(lowerQuery) ||
             user.id.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  Future<List<Product>> _fetchProducts() async {
    final snapshot = await _firestore.collection('products').get();
    return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
  }

  void _addProduct(Product product) {
    final existingItemIndex = _orderItems.indexWhere(
        (item) => (item['product'] as Product).id == product.id);

    final currentQuantity = existingItemIndex != -1 
        ? _orderItems[existingItemIndex]['quantity'] as int 
        : 0;

    // Check against the actual committed DB stock
    if (currentQuantity < product.stock) {
      if (existingItemIndex != -1) {
        setState(() {
          _orderItems[existingItemIndex]['quantity'] += 1;
        });
      } else {
        setState(() {
          _orderItems.add({'product': product, 'quantity': 1});
        });
      }
    } else {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot add more ${product.name}. Stock limit (${product.stock}) reached!')),
      );
    }
  }

  Future<void> _submitOrder() async {
    if (_selectedUser == null || _orderItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a user and add products.')),
      );
      return;
    }

    if (_billingAddress.values.any((val) => val.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all address details.')),
      );
      return;
    }


    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text("Processing Order..."),
          ],
        ),
      ),
    );

    try {
      final totalAmount = _currentTotal;
      final totalItemsSold = _calculateTotalItems(_orderItems);

      final firestoreItems = _orderItems.map((item) {
        final product = item['product'] as Product;
        return {
          'productId': product.id,
          'name': product.name,
          'price': product.price, 
          'quantity': item['quantity'],
        };
      }).toList();

      await _firestore.runTransaction((transaction) async {
        
        // A. Validate and Deduct Stock
        for (final item in _orderItems) {
          final product = item['product'] as Product;
          final quantity = item['quantity'] as int;
          
          final productRef = _firestore.collection('products').doc(product.id);
          final productSnapshot = await transaction.get(productRef); 
          final currentStock = (productSnapshot.data()?['stock'] ?? 0) as int;

          if (currentStock < quantity) {
            throw Exception('Insufficient stock for ${product.name}. Current stock: $currentStock');
          }
        }
        
        for (final item in _orderItems) {
          final product = item['product'] as Product;
          final quantity = item['quantity'] as int;

          final productRef = _firestore.collection('products').doc(product.id);
          transaction.update(productRef, {'stock': FieldValue.increment(-quantity)});
        }
        
        // B. Update Earnings Aggregation (NEW LOGIC)
        if (_paymentConfirmed) {
            final todayId = 'daily_' + DateTime.now().toIso8601String().substring(0, 10);
            final earningsRef = _firestore.collection('earnings').doc(todayId);

            transaction.set(
                earningsRef,
                {
                    'date': FieldValue.serverTimestamp(),
                    'periodType': 'daily',
                    'totalRevenue': FieldValue.increment(totalAmount),
                    'totalOrders': FieldValue.increment(1),
                    'totalItemsSold': FieldValue.increment(totalItemsSold),
                },
                SetOptions(merge: true),
            );
        }

        // C. Create Order Document (NEW FIELDS ADDED)
        await _firestore.collection('orders').add({
          'userId': _selectedUser!.id,
          'userName': _selectedUser!.name,
          'userEmail': _selectedUser!.email,
          'orderDate': FieldValue.serverTimestamp(),
          'status': 'Processing', 
          'paymentConfirmed': _paymentConfirmed,
          'paymentMode': _paymentMode,
          'shippingAddress': _billingAddress, 
          'totalAmount': totalAmount,
          'items': firestoreItems,
          'totalItemsSold': totalItemsSold, // NEW
          'revenueCounted': _paymentConfirmed, // NEW: If paid now, it's counted
        });
      });

      if (mounted) Navigator.of(context).pop(); 
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order created and inventory/earnings updated successfully!')),
      );
      if (mounted) Navigator.of(context).pop(); 
    } catch (e) {
      if (mounted) Navigator.of(context).pop(); 
      
      String errorMessage = 'Transaction failed. Check product inventory and try again.';
      if (e.toString().contains('Exception:')) {
          errorMessage = e.toString().split(':').last.trim();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create order: $errorMessage'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Manual Order'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 800, 
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. User Selection (Search) ---
              Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('1. Select User', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const Divider(),
                      
                      if (_selectedUser != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            'Selected: ${_selectedUser!.name} (${_selectedUser!.email})',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                          ),
                        ),
                      
                      TextFormField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          labelText: 'Search User by Name, Email, or ID*',
                          suffixIcon: Icon(Icons.search),
                        ),
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                      ),

                      if ((_searchQuery ?? '').isNotEmpty && _filteredUsers.isNotEmpty)
                        Container(
                          height: 150, 
                          margin: const EdgeInsets.only(top: 8.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: ListView.builder(
                            itemCount: _filteredUsers.length,
                            itemBuilder: (context, index) {
                              final user = _filteredUsers[index];
                              return ListTile(
                                visualDensity: VisualDensity.compact,
                                leading: const Icon(Icons.person, color: Colors.grey),
                                title: Text(user.name, style: TextStyle(fontWeight: FontWeight.w500)),
                                subtitle: Text(user.email),
                                trailing: _selectedUser?.id == user.id ? const Icon(Icons.check_circle, color: Colors.green) : null,
                                onTap: () {
                                  setState(() {
                                    _selectedUser = user;
                                    _searchQuery = ''; 
                                    _searchController.clear();
                                  });
                                },
                              );
                            },
                          ),
                        )
                      else if ((_searchQuery ?? '').isNotEmpty && _filteredUsers.isEmpty && _allUsers.isNotEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text('No users found matching your search.', style: TextStyle(color: Colors.red)),
                        ),
                    ],
                  ),
                ),
              ),

              // --- 2. Address Details ---
              Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('2. Billing/Shipping Address Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const Divider(),
                      
                      Wrap(
                        spacing: 16.0,
                        runSpacing: 8.0,
                        children: [
                          SizedBox(
                            width: 350,
                            child: TextFormField(
                              initialValue: _billingAddress['firstName'],
                              decoration: const InputDecoration(labelText: 'First name*'),
                              onChanged: (val) => _billingAddress['firstName'] = val,
                            ),
                          ),
                          SizedBox(
                            width: 350,
                            child: TextFormField(
                              initialValue: _billingAddress['lastName'],
                              decoration: const InputDecoration(labelText: 'Last name*'),
                              onChanged: (val) => _billingAddress['lastName'] = val,
                            ),
                          ),
                          SizedBox(
                            width: 350,
                            child: TextFormField(
                              initialValue: _billingAddress['phone'],
                              decoration: const InputDecoration(labelText: 'Phone*'),
                              keyboardType: TextInputType.phone,
                              onChanged: (val) => _billingAddress['phone'] = val,
                            ),
                          ),
                          SizedBox(
                            width: 350,
                            child: TextFormField(
                              initialValue: _billingAddress['country'],
                              decoration: const InputDecoration(labelText: 'Country/Region*'),
                              onChanged: (val) => _billingAddress['country'] = val,
                            ),
                          ),
                          SizedBox(
                            width: 720,
                            child: TextFormField(
                              initialValue: _billingAddress['addressLine'],
                              decoration: const InputDecoration(labelText: 'Address*'),
                              onChanged: (val) => _billingAddress['addressLine'] = val,
                            ),
                          ),
                          SizedBox(
                            width: 350,
                            child: TextFormField(
                              initialValue: _billingAddress['city'],
                              decoration: const InputDecoration(labelText: 'City*'),
                              onChanged: (val) => _billingAddress['city'] = val,
                            ),
                          ),
                          SizedBox(
                            width: 350,
                            child: TextFormField(
                              initialValue: _billingAddress['state'],
                              decoration: const InputDecoration(labelText: 'Region (State)*'),
                              onChanged: (val) => _billingAddress['state'] = val,
                            ),
                          ),
                          SizedBox(
                            width: 350,
                            child: TextFormField(
                              initialValue: _billingAddress['zip'],
                              decoration: const InputDecoration(labelText: 'Zip / Postal code*'),
                              onChanged: (val) => _billingAddress['zip'] = val,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // --- 3. Payment & Products ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('3. Payment Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const Divider(),
                            DropdownButtonFormField<String>(
                              decoration: const InputDecoration(labelText: 'Payment Mode'),
                              value: _paymentMode,
                              items: ['UPI', 'Debit/Credit Card', 'Manual', 'COD', 'Net Banking']
                                  .map((mode) => DropdownMenuItem(value: mode, child: Text(mode))).toList(),
                              onChanged: (val) => setState(() => _paymentMode = val!),
                            ),
                            const SizedBox(height: 10),
                            CheckboxListTile(
                              title: const Text('Payment Confirmed?'),
                              value: _paymentConfirmed,
                              onChanged: (val) => setState(() => _paymentConfirmed = val!),
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('4. Add Products', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const Divider(),
                            FutureBuilder<List<Product>>(
                              future: _fetchProducts(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: LinearProgressIndicator());
                                }
                                if (snapshot.hasError || !snapshot.hasData) {
                                  return const Text('Could not load products.');
                                }

                                return SizedBox(
                                  height: 200,
                                  child: ListView(
                                    shrinkWrap: true,
                                    children: snapshot.data!.map((product) {
                                      final inCartCount = _orderItems.firstWhere(
                                        (item) => (item['product'] as Product).id == product.id,
                                        orElse: () => {'quantity': 0})['quantity'] as int;
                                      
                                      // Calculate Virtual Stock: Live Stock - Quantity already reserved in this dialog
                                      final virtualStock = product.stock - inCartCount; 

                                      return ListTile(
                                        visualDensity: VisualDensity.compact,
                                        title: Text(product.name),
                                        // Display the Virtual Stock for real-time feedback
                                        subtitle: Text('\$${product.price.toStringAsFixed(2)} | Virtual Stock: $virtualStock'),
                                        trailing: IconButton(
                                          // Button color and press are dependent on the Virtual Stock
                                          icon: Icon(Icons.add_circle, color: virtualStock > 0 ? Colors.green : Colors.grey),
                                          onPressed: virtualStock > 0 ? () => _addProduct(product) : null,
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),

              // --- 5. Order Summary ---
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('5. Order Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const Divider(),
                      if (_orderItems.isEmpty)
                        const Text('No products added.')
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _orderItems.map((item) {
                            final product = item['product'] as Product;
                            final quantity = item['quantity'] as int;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('$quantity x ${product.name}', style: const TextStyle(fontWeight: FontWeight.w500)),
                                  Row(
                                    children: [
                                      Text('\$${(product.price * quantity).toStringAsFixed(2)}'),
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle_outline, size: 18),
                                        onPressed: () {
                                          setState(() {
                                            if (quantity > 1) {
                                              item['quantity'] -= 1;
                                            } else {
                                              _orderItems.remove(item);
                                            }
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('TOTAL PRICE:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue)),
                          Text('\$${_currentTotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            if (mounted) Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          onPressed: _submitOrder,
          child: const Text('Create Order'),
        ),
      ],
    );
  }
}