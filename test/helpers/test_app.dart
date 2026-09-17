import 'package:dartworks/src/app.dart';
import 'package:dartworks/src/meta/progress_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Builds a [DartworksApp] backed by mock SharedPreferences.
///
/// [seed] preloads save data: unlocked sandbox ids, completed levels,
/// found note ids and reclaimed item ids.
Future<SharedPrefsProgressStore> pumpApp(
  WidgetTester tester, {
  String initialRoute = '/',
  Set<String> unlocked = const {},
  Set<String> completed = const {},
  Set<String> notes = const {},
  Set<String> reclaimed = const {},
  Size size = const Size(1280, 800),
}) async {
  SharedPreferences.setMockInitialValues({
    'dw.unlocked': unlocked.toList(),
    'dw.completed': completed.toList(),
    'dw.notes': notes.toList(),
    'dw.reclaimed': reclaimed.toList(),
  });
  final prefs = await SharedPreferences.getInstance();
  final store = SharedPrefsProgressStore(prefs);

  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    DartworksApp(progress: store, initialRoute: initialRoute),
  );
  await tester.pump();
  return store;
}
