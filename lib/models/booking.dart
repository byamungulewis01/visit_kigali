import 'package:intl/intl.dart';

class Booking {
  final int? id;
  final int touristId;
  final DateTime bookingDate;
  final String? comment;
  final int placeId;

  Booking({
    this.id,
    required this.touristId,
    required this.bookingDate,
    this.comment,
    required this.placeId,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      touristId: json['tourist_id'],
      bookingDate: DateTime.parse(json['booking_date']),
      comment: json['comment'],
      placeId: json['place_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tourist_id': touristId,
      'booking_date': DateFormat('yyyy-MM-dd').format(bookingDate),
      'comment': comment,
      'place_id': placeId,
    };
  }
}