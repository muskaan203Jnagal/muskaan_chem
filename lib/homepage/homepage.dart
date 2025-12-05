// lib/homepage/homepage.dart (CORRECTED)
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

// 1. FIX: Use a prefix for one import to resolve the ambiguous name conflict
import '../models/product.dart' as model; // Importing the model Product with a prefix
import '../product_page/product_page.dart'; // This file also defines a Product class/widget

class HomePage extends StatelessWidget {
  // FIX 2: Remove 'const' from the constructor because of the non-constant field below
  HomePage({super.key});

  // Firestore references cannot be constant, so 'final' is correct.
  final CollectionReference productsCollection = 
      FirebaseFirestore.instance.collection('products');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          '🔥 Supplement Shop', 
          style: GoogleFonts.montserrat(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.white,
        centerTitle: false,
        elevation: 1,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // FIX 3: Removed the 'const' keyword causing 'const_eval_method_invocation'
        stream: productsCollection.where('status', isEqualTo: 'active').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error fetching products: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No active products found.'));
          }

          final products = snapshot.data!.docs.map((doc) {
            // FIX 1: Use the prefixed Product model: model.Product
            return model.Product.fromFirestore(doc);
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: GridView.builder(
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300,
                childAspectRatio: 0.65,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemBuilder: (context, index) {
                final product = products[index];
                return _ProductGridItem(product: product);
              },
            ),
          );
        },
      ),
    );
  }
}

// Product card with improved design and navigation
class _ProductGridItem extends StatelessWidget {
  // FIX 1: Use the prefixed Product model: model.Product
  final model.Product product; 
  // Removed 'const' because it holds a non-const field ('product')
  const _ProductGridItem({required this.product});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductPage(productId: product.id),
            // FIX 4: The error was in the line above. 
            // The parameter name 'productId' is correct, but the error indicates 
            // that the ProductPage class in your environment didn't have a 
            // required named parameter 'productId' in its constructor.
            // Assuming your ProductPage now looks like:
            // class ProductPage extends StatefulWidget {
            //   final String productId;
            //   const ProductPage({super.key, required this.productId}); 
            //   ...
            // }
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3), 
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Product Image
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Image.network(
                  product.mainImageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                    );
                  },
                ),
              ),
            ),
            
            // Product Info
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      product.name,
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.description,
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: GoogleFonts.montserrat(
                        color: Colors.redAccent, 
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Add to Cart Button (UI only)
                    SizedBox(
                      width: double.infinity,
                      height: 38,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Added ${product.name} to cart!'),
                              duration: const Duration(milliseconds: 800),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Add to Cart',
                          style: GoogleFonts.montserrat(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}