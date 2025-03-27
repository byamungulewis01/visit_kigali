class Review {
  final String email;
  final String? name;
  final String content;
  final int rating;
  final int placeId;

  Review({
    required this.email,
    this.name,
    required this.content,
    required this.rating,
    required this.placeId,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      email: json['email'] ?? '',
      name: json['name'],
      content: json['content'] ?? '',
      rating: int.parse(json['rating'].toString()), // Convert rating to int safely
      placeId: int.parse(json['place_id'].toString()), // Convert place_id to int safely
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'content': content,
      'rating': rating,
      'place_id': placeId,
    };
  }
}