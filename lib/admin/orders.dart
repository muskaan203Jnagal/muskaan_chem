// ============================================================================
// lib/admin/orders.dart (FULLY UPDATED - V7: Fixes TypeError using Null Safety)
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
// --- Main Orders Page Widget ---
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
// --- Order List Widget (Page Search) ---
// ----------------------------------------------------------------------------

class _OrderList extends StatefulWidget {
  @override
  State<_OrderList> createState() => _OrderListState();
}

class _OrderListState extends State<_OrderList> {
  // FIX: Make search query nullable but initialized for extra safety against JS errors
  String? _searchQuery = ''; 

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

              // Local Filtering Logic
              final allOrders = snapshot.data!.docs;
              // FIX: Use null coalescing on _searchQuery
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
                        // TODO: Implement a detail view for the order
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
// --- Create Order Dialog (User Search) ---
// ----------------------------------------------------------------------------

class _CreateOrderDialog extends StatefulWidget {
  const _CreateOrderDialog({Key? key}) : super(key: key);

  @override
  State<_CreateOrderDialog> createState() => __CreateOrderDialogState();
}

class __CreateOrderDialogState extends State<_CreateOrderDialog> {
  UserItem? _selectedUser;
  final List<Map<String, dynamic>> _orderItems = []; 
  String _paymentMode = 'Manual';
  bool _paymentConfirmed = true;

  // FIX: Make search query nullable but initialized for extra safety
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

  Future<List<UserItem>> _fetchUsers() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    return snapshot.docs.map((doc) => UserItem.fromFirestore(doc)).toList();
  }

  List<UserItem> get _filteredUsers {
    // FIX: Use null coalescing on _searchQuery
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
    final snapshot = await FirebaseFirestore.instance.collection('products').get();
    return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
  }

  void _addProduct(Product product) {
    final existingItem = _orderItems.firstWhere(
        (item) => (item['product'] as Product).id == product.id,
        orElse: () => {'quantity': 0});
    
    if ((existingItem['quantity'] as int) < product.stock) {
      final existingItemIndex = _orderItems.indexWhere(
          (item) => (item['product'] as Product).id == product.id);

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

      final firestoreItems = _orderItems.map((item) {
        final product = item['product'] as Product;
        return {
          'productId': product.id,
          'name': product.name,
          'price': product.price, 
          'quantity': item['quantity'],
        };
      }).toList();

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        
        for (final item in _orderItems) {
          final product = item['product'] as Product;
          final quantity = item['quantity'] as int;
          
          final productRef = FirebaseFirestore.instance.collection('products').doc(product.id);
          final productSnapshot = await transaction.get(productRef); 
          final currentStock = (productSnapshot.data()?['stock'] ?? 0) as int;

          if (currentStock < quantity) {
            throw Exception('Insufficient stock for ${product.name}. Current stock: $currentStock');
          }
        }
        
        for (final item in _orderItems) {
          final product = item['product'] as Product;
          final quantity = item['quantity'] as int;

          final productRef = FirebaseFirestore.instance.collection('products').doc(product.id);
          transaction.update(productRef, {'stock': FieldValue.increment(-quantity)});
        }
        
        await FirebaseFirestore.instance.collection('orders').add({
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
        });
      });

      if (mounted) Navigator.of(context).pop(); 
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order created and inventory updated successfully!')),
      );
      if (mounted) Navigator.of(context).pop(); 
    } catch (e) {
      if (mounted) Navigator.of(context).pop(); 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create order: ${e.toString().split(':').last.trim()}'),
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

                      // FIX: Use null coalescing on _searchQuery for safe check
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

              // --- 2. Address Details (Unchanged) ---
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

              // --- 3. Payment & Products (Unchanged) ---
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
                                      
                                      return ListTile(
                                        visualDensity: VisualDensity.compact,
                                        title: Text(product.name),
                                        subtitle: Text('\$${product.price.toStringAsFixed(2)} | Stock: ${product.stock}'),
                                        trailing: IconButton(
                                          icon: Icon(Icons.add_circle, color: inCartCount < product.stock ? Colors.green : Colors.grey),
                                          onPressed: () => _addProduct(product),
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

              // --- 5. Order Summary (Unchanged) ---
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