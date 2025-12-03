// ============================================================================
// lib/admin/reviews_moderation.dart (FIXED: Local Sorting, No Index Needed)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:math';

// --- Firestore Collection Names ---
const String _productsCollection = 'products';
const String _reviewsCollection = 'reviews';
const String _usersCollection = 'users';

// --- Data Models ---

class ProductSummary {
  final String id;
  final String name;
  final int reviewCount;
  ProductSummary({required this.id, required this.name, required this.reviewCount});
}

class ReviewModel {
  final String id;
  final String productId;
  final String? userId; // Null for proxy reviews
  final String? proxyName; // Used if userId is null
  final int rating;
  final String comment;
  final Timestamp createdAt;
  
  // Transient field for display, fetched from users collection
  String reviewerName = 'Loading...'; 

  ReviewModel.fromDocument(DocumentSnapshot doc)
      : id = doc.id,
        productId = doc['productId'] ?? '',
        userId = doc['userId'],
        proxyName = doc['proxyName'],
        rating = doc['rating'] ?? 5,
        comment = doc.data().toString().contains('comment') ? doc['comment'] : '', // Safety check
        // Ensure graceful fallback if the timestamp is still pending
        createdAt = doc['createdAt'] as Timestamp? ?? Timestamp.now(); 
}

// --- Main Page Widget ---

class ReviewsModerationPage extends StatefulWidget {
  const ReviewsModerationPage({Key? key}) : super(key: key);

  @override
  State<ReviewsModerationPage> createState() => _ReviewsModerationPageState();
}

class _ReviewsModerationPageState extends State<ReviewsModerationPage> {
  String? _selectedProductId;
  String? _selectedProductName;
  int _productListKey = 0; 

  // --- Actions ---

  void _refreshProductList() {
    setState(() {
      _productListKey++;
    });
  }

  void _showReviewSchemaDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Firestore Review Schema'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Collection: products (Relevant Fields)', style: TextStyle(fontWeight: FontWeight.bold)),
              _buildSchemaRow('name', 'String', 'Product name.'),
              _buildSchemaRow('price', 'Number', 'Product price.'),
              const Divider(height: 20),
              const Text('Collection: users (Relevant Fields)', style: TextStyle(fontWeight: FontWeight.bold)),
              _buildSchemaRow('name', 'String', 'User\'s full name.'),
              _buildSchemaRow('email', 'String', 'User email.'),
              const Divider(height: 20),
              const Text('Collection: reviews', style: TextStyle(fontWeight: FontWeight.bold)),
              _buildSchemaRow('productId', 'String', 'ID of the reviewed product.'),
              _buildSchemaRow('userId', 'String | Null', 'ID of the reviewer (null for proxy reviews).'),
              _buildSchemaRow('proxyName', 'String | Null', 'Admin-entered reviewer name if userId is null.'),
              _buildSchemaRow('rating', 'Number', 'Rating from 1 to 5.'),
              _buildSchemaRow('comment', 'String', 'Review text.'),
              _buildSchemaRow('createdAt', 'Timestamp', 'Date/time of review.'),
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Review Moderation', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        actions: [
          TextButton.icon(
            onPressed: _showReviewSchemaDialog, 
            icon: const Icon(Icons.description, color: Colors.blue),
            label: const Text('Schema Docs', style: TextStyle(color: Colors.blue)),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Panel: Product List
          SizedBox(
            width: 350, 
            child: ProductListView(
              key: ValueKey(_productListKey), 
              onProductSelected: (id, name) {
                setState(() {
                  _selectedProductId = id;
                  _selectedProductName = name;
                });
              },
              selectedProductId: _selectedProductId,
            ),
          ),
          const VerticalDivider(width: 1),

          // Right Panel: Review Details
          Expanded(
            child: _selectedProductId == null
                ? const Center(
                    child: Text('Select a product to view reviews.', 
                      style: TextStyle(fontSize: 16, color: Colors.grey)),
                  )
                : ReviewDetailView(
                    productId: _selectedProductId!,
                    productName: _selectedProductName!,
                    onReviewAdded: _refreshProductList, 
                  ),
          ),
        ],
      ),
    );
  }
}

// --- Product List Component (Unchanged) ---

class ProductListView extends StatelessWidget {
  final Function(String id, String name) onProductSelected;
  final String? selectedProductId;
  const ProductListView({
    Key? key,
    required this.onProductSelected,
    this.selectedProductId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(_productsCollection).snapshots(),
      builder: (context, productSnapshot) {
        if (productSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!productSnapshot.hasData || productSnapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No products found.'));
        }

        final products = productSnapshot.data!.docs;
        
        return FutureBuilder<List<ProductSummary>>(
          future: _fetchReviewCounts(products),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData) {
              return const Center(child: Text('Error loading reviews.'));
            }

            final productSummaries = snapshot.data!;

            return ListView(
              padding: const EdgeInsets.all(8.0),
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 8.0, bottom: 8.0),
                  child: Text(
                    'Products (${products.length})', 
                    style: Theme.of(context).textTheme.titleLarge),
                ),
                ...productSummaries.map((summary) {
                  final isSelected = summary.id == selectedProductId;
                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    color: isSelected ? Colors.blue.shade50 : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: isSelected ? Colors.blue.shade300 : Colors.grey.shade200)
                    ),
                    child: ListTile(
                      dense: true,
                      title: Text(summary.name, 
                        style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: summary.reviewCount > 0 ? Colors.green.shade100 : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${summary.reviewCount}',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: summary.reviewCount > 0 ? Colors.green.shade900 : Colors.grey.shade600),
                        ),
                      ),
                      onTap: () => onProductSelected(summary.id, summary.name),
                    ),
                  );
                }).toList(),
              ],
            );
          },
        );
      },
    );
  }

  // Helper function to count reviews for each product
  Future<List<ProductSummary>> _fetchReviewCounts(List<QueryDocumentSnapshot> products) async {
    final summaries = <ProductSummary>[];
    for (var productDoc in products) {
      final reviewCountSnapshot = await FirebaseFirestore.instance
          .collection(_reviewsCollection)
          .where('productId', isEqualTo: productDoc.id)
          .count()
          .get();
      
      summaries.add(ProductSummary(
        id: productDoc.id,
        name: productDoc['name'] ?? 'Untitled Product',
        reviewCount: reviewCountSnapshot.count ?? 0,
      ));
    }
    return summaries;
  }
}

// --- Review Detail and Moderation Component (Modified Query and Sorting) ---

class ReviewDetailView extends StatefulWidget {
  final String productId;
  final String productName;
  final VoidCallback onReviewAdded; 
  
  const ReviewDetailView({
    Key? key,
    required this.productId,
    required this.productName,
    required this.onReviewAdded,
  }) : super(key: key);

  @override
  State<ReviewDetailView> createState() => _ReviewDetailViewState();
}

class _ReviewDetailViewState extends State<ReviewDetailView> {

  Future<String> _fetchReviewerName(String? userId, String? proxyName) async {
    if (proxyName != null && proxyName.isNotEmpty) {
      return proxyName; 
    }
    if (userId == null) {
      return 'Anonymous User';
    }
    try {
      final userDoc = await FirebaseFirestore.instance.collection(_usersCollection).doc(userId).get();
      final name = (userDoc.data() as Map<String, dynamic>?)?['name'];
      return name ?? 'User (ID: ${userId?.substring(0, 4)}...)';
    } catch (e) {
      return 'Error fetching user';
    }
  }

  Future<void> _deleteReview(String reviewId) async {
    await FirebaseFirestore.instance.collection(_reviewsCollection).doc(reviewId).delete();
    widget.onReviewAdded();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Review deleted successfully.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Reviews for: ${widget.productName}',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),

          // Proxy Review Form
          Text('Add Proxy Review (Admin)', style: Theme.of(context).textTheme.titleLarge),
          const Divider(),
          ProxyReviewForm(
            productId: widget.productId,
            onReviewAdded: widget.onReviewAdded, 
          ),
          const SizedBox(height: 30),

          // Existing Reviews List
          Text('Customer Reviews', style: Theme.of(context).textTheme.titleLarge),
          const Divider(),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection(_reviewsCollection)
                // 1. Only filter by productId (no index needed for a single filter)
                .where('productId', isEqualTo: widget.productId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('No reviews for this product yet.')));
              }

              // 2. Map documents to models
              final reviews = snapshot.data!.docs.map((doc) => ReviewModel.fromDocument(doc)).toList();
              
              // 3. SORT LOCALLY by createdAt in descending order (newest first)
              reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));


              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: reviews.length,
                itemBuilder: (context, index) {
                  final review = reviews[index];
                  
                  return FutureBuilder<String>(
                    future: _fetchReviewerName(review.userId, review.proxyName),
                    builder: (context, nameSnapshot) {
                      review.reviewerName = nameSnapshot.data ?? 'Loading...';

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.person, size: 18, color: Colors.blueGrey),
                                      const SizedBox(width: 8),
                                      Text(
                                        review.reviewerName,
                                        style: TextStyle(fontWeight: FontWeight.bold, color: review.userId == null ? Colors.deepOrange : Colors.black87),
                                      ),
                                      if (review.userId == null) 
                                        const Padding(
                                          padding: EdgeInsets.only(left: 8.0),
                                          child: Tooltip(message: 'Admin-added Review', child: Icon(Icons.admin_panel_settings, size: 16, color: Colors.deepOrange)),
                                        ),
                                    ],
                                  ),
                                  Text(
                                    DateFormat('MMM dd, yyyy').format(review.createdAt.toDate()),
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  // Simple star display
                                  ...List.generate(review.rating, (i) => const Icon(Icons.star, color: Colors.orange, size: 18)),
                                  ...List.generate(5 - review.rating, (i) => const Icon(Icons.star_border, color: Colors.orange, size: 18)),
                                  const SizedBox(width: 10),
                                  Text('${review.rating}/5', style: const TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(review.comment),
                              const Divider(height: 20),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: TextButton.icon(
                                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                  label: const Text('Delete Review', style: TextStyle(color: Colors.red)),
                                  onPressed: () => _deleteReview(review.id),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

// --- Proxy Review Form Component (Unchanged from previous fix) ---

class ProxyReviewForm extends StatefulWidget {
  final String productId;
  final VoidCallback onReviewAdded;
  const ProxyReviewForm({
    Key? key,
    required this.productId,
    required this.onReviewAdded,
  }) : super(key: key);

  @override
  State<ProxyReviewForm> createState() => _ProxyReviewFormState();
}

class _ProxyReviewFormState extends State<ProxyReviewForm> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  int _rating = 5;
  bool _isSaving = false;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() { _isSaving = true; });

      try {
        await _firestore.collection(_reviewsCollection).add({
          'productId': widget.productId,
          'userId': null, 
          'proxyName': _nameController.text.trim().isEmpty ? 'Admin Review' : _nameController.text.trim(),
          'rating': _rating,
          'comment': _commentController.text,
          'createdAt': FieldValue.serverTimestamp(), 
        });

        // Reset the form
        _formKey.currentState!.reset();
        _commentController.clear();
        _nameController.clear();
        setState(() {
          _rating = 5;
        });

        widget.onReviewAdded();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Proxy review added successfully.')),
        );

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add proxy review: $e')),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.deepOrange.shade100)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Proxy Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Proxy Reviewer Name',
                  hintText: 'e.g., Jane Doe, Verified Buyer',
                ),
              ),
              const SizedBox(height: 10),

              // Rating Selector
              Row(
                children: [
                  const Text('Rating:', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 10),
                  DropdownButton<int>(
                    value: _rating,
                    items: List.generate(5, (index) => index + 1)
                        .map((rating) => DropdownMenuItem(
                              value: rating,
                              child: Text('$rating Star${rating > 1 ? 's' : ''}'),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _rating = value!;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Comment
              TextFormField(
                controller: _commentController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Review Comment',
                  hintText: 'Enter the body of the review...',
                ),
                validator: (value) => value!.isEmpty ? 'Review comment cannot be empty.' : null,
              ),
              const SizedBox(height: 20),

              // Submit Button
              Center(
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _submitForm,
                  icon: _isSaving
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.rate_review),
                  label: Text(_isSaving ? 'Adding...' : 'Add Proxy Review'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
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