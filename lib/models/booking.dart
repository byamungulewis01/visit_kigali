class Booking {
  final String name;
  final String email;
  final DateTime bookingDate;
  final String? comment;
  final int placeId;

  Booking({
    required this.name,
    required this.email,
    required this.bookingDate,
    this.comment,
    required this.placeId,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'booking_date': bookingDate.toIso8601String(),
      'comment': comment,
      'place_id': placeId,
    };
  }
}