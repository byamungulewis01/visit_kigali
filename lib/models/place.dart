import 'dart:convert';
import 'review.dart';

class Place {
  final int id;
  final String name;
  final String category;
  final double price;
  final String shortDescription;
  final String image;
  final double rating;
  final List<Review> reviews;

  Place({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.shortDescription,
    required this.image,
    required this.rating,
    this.reviews = const [],
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      price: double.parse(json['price'].toString()),
      shortDescription: json['short_description'],
      image: json['image'],
      rating: double.parse(json['rating'].toString()),
      reviews: json['reviews'] != null
          ? List<Review>.from(
              json['reviews'].map((x) => Review.fromJson(x)))
          : [],
    );
  }
}