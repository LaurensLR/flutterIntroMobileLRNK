import 'package:flutter/foundation.dart';

Future<bool> loadGoogleMapsForWeb(String apiKey) async {
  if (!kIsWeb || apiKey.isEmpty) {
    return true;
  }

  return loadGoogleMapsForWebImpl(apiKey);
}

Future<bool> loadGoogleMapsForWebImpl(String apiKey) async {
  throw UnimplementedError();
}