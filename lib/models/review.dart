// lib/models/review.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String name; 
  final String comment;
  final num rating;
  final String date;
  
  // Fields for design compatibility
  final String initials;
  final String title;
  final String country;
  final String productId;

  Review({
    required this.id,
    required this.name,
    required this.comment,
    required this.rating,
    required this.date,
    required this.initials,
    required this.title,
    required this.country,
    required this.productId,
  });

  factory Review.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception("Review data is null for ID: ${doc.id}");
    }

    final timestamp = data['createdAt'] as String? ?? '';
    final date = timestamp.split(' ')[0]; // Basic date extraction

    final proxyName = data['proxyName'] as String? ?? 'Anonymous';
    
    return Review(
      id: doc.id,
      name: proxyName,
      comment: data['comment'] as String? ?? 'No comment.',
      rating: data['rating'] as num? ?? 5,
      date: date,
      
      // Static/derived fields for design compatibility
      initials: proxyName.substring(0, 1).toUpperCase(),
      title: 'A Verified Purchase', 
      country: 'United States', // Static placeholder
      productId: data['productID'] as String? ?? '',
    );
  }
}