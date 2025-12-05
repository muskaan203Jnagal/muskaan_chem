import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// 💡 FIX: Import the shared Product model
import 'package:chem_revolutions/models/product.dart'; 
// 💡 NEW: Import the detailed product page
import 'package:chem_revolutions/product_page/product_page.dart'; 
// NOTE: You may need to change 'package:chem_revolutions' to your project's name.

// 1. Product Model class REMOVED from this file

// 2. HomePage Widget
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Reference the 'products' collection. Update this string if your collection name is different.
    final productsCollection = FirebaseFirestore.instance.collection('products');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Catalog'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Listen to real-time changes in the 'products' collection
        stream: productsCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error loading products: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No products found.'));
          }

          // Convert DocumentSnapshots into a list of Product objects
          // This now uses the shared Product.fromFirestore constructor
          final products = snapshot.data!.docs.map((doc) => Product.fromFirestore(doc)).toList();

          // Display products in a modern, responsive grid view
          return GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 300, // Max width per card
              childAspectRatio: 0.7, // Card height relative to width
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductCard(product: product);
            },
          );
        },
      ),
    );
  }
}

// 3. Product Card Widget (Modern Design)
class ProductCard extends StatelessWidget {
  final Product product;
  
  const ProductCard({
    super.key,
    required this.product,
  });

  // Wrap the card in an InkWell for tap functionality
  void _navigateToProductPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        // The Product object passed here is now the correct shared type
        builder: (context) => ProductPage(product: product), 
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 💡 CORS FIX: Apply CORS proxy to the image URL for loading in Flutter Web.
    final proxiedUrl = 'https://wsrv.nl/?url=${Uri.encodeComponent(product.mainImageUrl)}'; 

    return InkWell( // Wrap the whole card in InkWell
      onTap: () => _navigateToProductPage(context), // Handle the tap to navigate
      borderRadius: BorderRadius.circular(12), // Match the container's border radius
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  proxiedUrl, 
                  fit: BoxFit.cover,
                  width: double.infinity,
                  // Show a loading indicator while fetching the image
                  loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  // Show a fallback error message if loading fails
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image, size: 40, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('Image Unavailable', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            
            // Details Section
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Add to Cart Button (UI Only)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // UI only action as requested
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product.name} added to cart! (UI only action)'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                      label: const Text('Add to Cart'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        elevation: 3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}