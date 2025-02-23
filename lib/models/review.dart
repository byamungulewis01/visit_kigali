class Review {
  final String name;
  final String email;
  final String content;
  final int rating;
  final int placeId;

  Review({
    required this.name,
    required this.email,
    required this.content,
    required this.rating,
    required this.placeId,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      content: json['content'] ?? '',
      rating: int.parse(json['rating'].toString()), // Convert rating to int safely
      placeId: int.parse(json['place_id'].toString()), // Convert place_id to int safely
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'content': content,
      'rating': rating,
      'place_id': placeId,
    };
  }
}