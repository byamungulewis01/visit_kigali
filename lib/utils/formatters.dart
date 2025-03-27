import 'package:intl/intl.dart';
import 'constant.dart';

class Formatters {
  static String formatPrice(double price) {
    final numberFormat = NumberFormat('#,##0', 'en_US');
    return '${numberFormat.format(price)} RWF';
  }

  static String getImageUrl(String imagePath) {
    // Replace with your Laravel backend URL
    const String baseUrl = "$backendUrl/storage";
    // Handle storage path
    // if (imagePath.startsWith('storage/')) {
    return '$baseUrl/$imagePath';
    // }
    // return imagePath;
  }
}
