import 'package:flutter/material.dart';
import '../models/place.dart';
import '../services/api_service.dart';
import '../widgets/place_card.dart';

class PlaceListScreen extends StatefulWidget {
  const PlaceListScreen({Key? key}) : super(key: key);

  @override
  State<PlaceListScreen> createState() => _PlaceListScreenState();
}

class _PlaceListScreenState extends State<PlaceListScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Place>> _placesFuture;

  @override
  void initState() {
    super.initState();
    _placesFuture = _apiService.getPlaces();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visit Kigali'),
      ),
      body: FutureBuilder<List<Place>>(
        future: _placesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final places = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: places.length,
            itemBuilder: (context, index) {
              return PlaceCard(place: places[index]);
            },
          );
        },
      ),
    );
  }
}