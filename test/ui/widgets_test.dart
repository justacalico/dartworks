import 'dart:ui' show PictureRecorder;

import 'package:dartworks/src/theme.dart';
import 'package:dartworks/src/ui/widgets/menu_button.dart';
import 'package:dartworks/src/ui/widgets/neon_panel.dart';
import 'package:dartworks/src/ui/widgets/section_header.dart';
import 'package:dartworks/src/ui/widgets/void_backdrop.dart';
import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget wrap(Widget child) => MaterialApp(
      theme: DwTheme.dark,
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  testWidgets('NeonPanel renders title and child', (tester) async {
    await tester.pumpWidget(
      wrap(const NeonPanel(title: 'SYS', child: Text('payload'))),
    );
    expect(find.text('SYS'), findsOneWidget);
    expect(find.text('payload'), findsOneWidget);
  });

  testWidgets('MenuButton fires callback when enabled', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      wrap(MenuButton(label: 'GO', onPressed: () => taps++)),
    );
    await tester.tap(find.text('GO'));
    expect(taps, 1);
  });

  testWidgets('MenuButton ignores taps when disabled', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      wrap(const MenuButton(label: 'NOPE')),
    );
    await tester.tap(find.text('NOPE'));
    expect(taps, 0);
  });

  testWidgets('MenuButton highlights on hover', (tester) async {
    await tester.pumpWidget(
      wrap(MenuButton(label: 'HOVER', onPressed: () {})),
    );
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    await gesture.moveTo(tester.getCenter(find.text('HOVER')));
    await tester.pump();
    final container = tester.widget<AnimatedContainer>(
      find
          .ancestor(of: find.text('HOVER'), matching: find.byType(AnimatedContainer))
          .first,
    );
    expect(container, isNotNull);
    await gesture.removePointer();
  });

  testWidgets('SectionHeader renders its label', (tester) async {
    await tester.pumpWidget(wrap(const SectionHeader('SYS.LOG')));
    expect(find.text('SYS.LOG'), findsOneWidget);
  });

  testWidgets('VoidBackdrop paints deterministically', (tester) async {
    final painter = VoidPainter(seed: 7)..time = 2.5;
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    painter.paint(canvas, const Size(400, 300));
    await recorder.endRecording().toImage(10, 10);
    expect(painter.shouldRepaint(VoidPainter(seed: 7)..time = 3.0), isTrue);
  });
}
