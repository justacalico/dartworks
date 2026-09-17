import 'package:flutter/widgets.dart';

import 'meta/progress_store.dart';

/// Exposes app-wide services (save data) to the widget tree.
class AppScope extends InheritedWidget {
  const AppScope({super.key, required this.progress, required super.child});

  final ProgressStore progress;

  static ProgressStore progressOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.progress;

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      oldWidget.progress != progress;
}
