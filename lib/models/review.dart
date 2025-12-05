// lib/models/review.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Review {
  final String id;
  final String name;       // Comes from Firestore 'proxyName'
  final String title;      // (Placeholder for now)
  final String country;    // (Placeholder for now)
  final double rating;     // Comes from Firestore 'rating'
  final String text;       // Comes from Firestore 'comment'
  final Timestamp createdAt; 

  // Calculated fields for the UI
  String get initials => name.isNotEmpty 
      ? name.trim().split(' ').map((l) => l.isNotEmpty ? l[0] : '').join().toUpperCase()
      : '??';

  String get date {
    // Format the date to match the 'MM/DD/YYYY' style in the design
    return DateFormat('MM/dd/yyyy').format(createdAt.toDate());
  }

  Review({
    required this.id,
    required this.name,
    required this.title,
    required this.country,
    required this.rating,
    required this.text,
    required this.createdAt,
  });

  factory Review.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    return Review(
      id: doc.id,
      name: data?['proxyName'] ?? 'Anonymous',
      text: data?['comment'] ?? 'No comment provided.',
      rating: (data?['rating'] is num) ? (data!['rating'] as num).toDouble() : 0.0,
      
      // Placeholders for fields not currently in your schema
      title: 'Verified Purchase', 
      country: 'United States',
      
      createdAt: data?['createdAt'] ?? Timestamp.now(), 
    );
  }
}