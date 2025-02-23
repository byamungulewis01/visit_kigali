import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/place.dart';
import '../models/booking.dart';
import '../models/review.dart';

class ApiService {
  Future<List<Place>> getPlaces() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/places'),
      headers: ApiConfig.headers,
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Place.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load places');
    }
  }

  Future<Place> getPlaceDetails(int id) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/places/$id'),
      headers: ApiConfig.headers,
    );

    if (response.statusCode == 200) {
      return Place.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load place details');
    }
  }

  Future<void> createBooking(Booking booking) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/booking/${booking.placeId}'),
      headers: ApiConfig.headers,
      body: json.encode(booking.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create booking');
    }
  }

  Future<void> createReview(Review review) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/review/${review.placeId}'),
      headers: ApiConfig.headers,
      body: json.encode(review.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create review');
    }
  }
}