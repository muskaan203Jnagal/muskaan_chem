import 'package:cloud_firestore/cloud_firestore.dart';

// 1. Product Model (SINGLE SOURCE OF TRUTH)
class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String mainImageUrl;
  final Timestamp createdAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.mainImageUrl,
    required this.createdAt,
  });

  // Factory constructor to create a Product from a Firestore DocumentSnapshot
  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    
    final defaultPrice = 0.0;
    
    final priceValue = data?['price'];
    double parsedPrice;
    if (priceValue is num) {
      parsedPrice = priceValue.toDouble();
    } else {
      parsedPrice = defaultPrice;
    }

    return Product(
      id: doc.id,
      name: data?['name'] ?? 'Untitled Product',
      description: data?['description'] ?? 'No description available.',
      price: parsedPrice,
      mainImageUrl: data?['mainImageUrl'] is String && (data!['mainImageUrl'] as String).isNotEmpty
          ? data!['mainImageUrl'] as String
          : 'https://placehold.co/400x300/CCCCCC/000000?text=No+Image', // Placeholder image fallback
      createdAt: data?['createdAt'] ?? Timestamp.now(),
    );
  }
}