// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:html' as html;

Future<bool> loadGoogleMapsForWeb(String apiKey) async {
  if (html.window.document.getElementById('google-maps-js') != null) {
    return true;
  }

  final completer = Completer<bool>();
  final script = html.ScriptElement()
    ..id = 'google-maps-js'
    ..async = true
    ..defer = true
    ..src =
        'https://maps.googleapis.com/maps/api/js?key=$apiKey&v=weekly&loading=async&libraries=maps';

  script.onError.listen((_) {
    if (!completer.isCompleted) {
      completer.complete(false);
    }
  });

  script.onLoad.listen((_) {
    if (!completer.isCompleted) {
      completer.complete(true);
    }
  });

  html.document.head!.append(script);

  final loaded = await completer.future.timeout(
    const Duration(seconds: 15),
    onTimeout: () => false,
  );

  if (loaded) {
    // Wait for the Maps API to fully initialize all constants
    // including MapTypeId.ROADMAP (needed by google_maps_flutter_web)
    // Demo API tier requires longer initialization time
    await Future.delayed(const Duration(seconds: 5));
  }

  return loaded;
}