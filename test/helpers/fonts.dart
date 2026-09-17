import 'dart:io';

import 'package:flutter/services.dart';

/// Loads the app's real fonts (plus MaterialIcons) so widget and golden
/// tests render actual glyphs instead of tofu. Call once in setUpAll.
Future<void> loadTestFonts() async {
  final fonts = <String, List<String>>{
    'Oxanium': [
      'assets/fonts/Oxanium-400.ttf',
      'assets/fonts/Oxanium-600.ttf',
      'assets/fonts/Oxanium-800.ttf',
    ],
    'ShareTechMono': ['assets/fonts/ShareTechMono-Regular.ttf'],
    'MaterialIcons': [
      '${_flutterRoot()}/bin/cache/artifacts/material_fonts/'
          'MaterialIcons-Regular.otf',
    ],
  };
  for (final entry in fonts.entries) {
    final loader = FontLoader(entry.key);
    for (final path in entry.value) {
      final bytes = await File(path).readAsBytes();
      loader.addFont(Future.value(ByteData.sublistView(bytes)));
    }
    await loader.load();
  }
}

String _flutterRoot() {
  final which = Process.runSync('which', ['flutter']).stdout as String;
  return File(which.trim()).resolveSymbolicLinksSync().replaceAll(
        RegExp(r'/bin/flutter$'),
        '',
      );
}
