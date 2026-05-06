import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get googleMapsApiKey {
    try {
      final key = dotenv.env['GOOGLE_MAPS_API_KEY'];
      if (key == null || key.isEmpty || key == 'YOUR_API_KEY_HERE') {
        return '';
      }
      return key;
    } catch (_) {
      return '';
    }
  }
}
