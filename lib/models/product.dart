// lib/models/product.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String subtitle; // Assuming this maps to description for now
  final List<String> imageUrls;
  final String mainImageUrl;
  final num price;
  final String description;
  final String status;
  final int stock;
  // Placeholder fields for design compatibility
  final double rating; 
  final int reviewCount;
  final List<String> benefits; 
  final double? subscriptionPrice;

  Product({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.imageUrls,
    required this.mainImageUrl,
    required this.price,
    required this.description,
    required this.status,
    required this.stock,
    // Static for MVP design
    this.rating = 5.0, 
    this.reviewCount = 0,
    this.benefits = const [],
    this.subscriptionPrice,
  });

  // Factory constructor to create a Product from a Firestore DocumentSnapshot
  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception("Product data is null for ID: ${doc.id}");
    }
    
    // Default values based on schema analysis
    final mainImageUrl = data['mainImageUrl'] as String? ?? '';
    final imageUrls = List<String>.from(data['imageUrls'] as List? ?? [mainImageUrl]);
    final description = data['description'] as String? ?? 'No description provided.';
    
    return Product(
      id: doc.id,
      name: data['name'] as String? ?? 'Unknown Product',
      subtitle: description, // Mapping description to subtitle for design compatibility
      imageUrls: imageUrls,
      mainImageUrl: mainImageUrl,
      price: data['price'] as num? ?? 0.00,
      description: description,
      status: data['status'] as String? ?? 'inactive',
      stock: data['stock'] as int? ?? 0,
      // Keeping these static for now as we don't calculate them here
      rating: 5.0, 
      reviewCount: 0,
      benefits: const [
        'Dynamically fetched description or benefit 1.',
        'Supports strength and performance (Placeholder).',
        'Check back for more details.',
      ],
      subscriptionPrice: (data['price'] as num? ?? 0) * 0.85, // 15% off
    );
  }
}