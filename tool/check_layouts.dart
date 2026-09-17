// ignore_for_file: avoid_print

import 'dart:io';

/// Dev tool: validates every level map has uniform row widths and known
/// tile chars. Run: dart tool/check_layouts.dart
void main() {
  final dir = Directory('lib/src/data/levels');
  var failures = 0;
  for (final file in dir.listSync().whereType<File>()) {
    final lines = file.readAsLinesSync();
    final layout = <String>[];
    var inLayout = false;
    for (final line in lines) {
      if (line.contains('layout: [')) {
        inLayout = true;
        continue;
      }
      if (inLayout && line.trim().startsWith(']')) break;
      if (inLayout) {
        final match = RegExp("'([^']*)'").firstMatch(line);
        if (match != null) layout.add(match.group(1)!);
      }
    }
    if (layout.isEmpty) continue;
    final width = layout.first.length;
    final bad = <int>[];
    for (var i = 0; i < layout.length; i++) {
      if (layout[i].length != width) {
        bad.add(i);
        failures++;
      }
    }
    final name = file.uri.pathSegments.last;
    if (bad.isEmpty) {
      print('OK   $name (${width}x${layout.length})');
    } else {
      print('BAD  $name rows $bad (expected $width)');
      for (final i in bad) {
        print('     row $i len ${layout[i].length}: "${layout[i]}"');
      }
    }
  }
  exit(failures == 0 ? 0 : 1);
}
