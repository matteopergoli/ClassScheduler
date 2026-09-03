// One-off asset generator. Not a real test — run explicitly:
//   flutter test test/generate_icon.dart
// Produces, under assets/icon/:
//   app_icon.png            1024 opaque   — iOS + legacy Android launcher
//   app_icon_foreground.png 1024 transp.  — Android adaptive foreground
//   app_icon_background.png 1024 opaque   — Android adaptive background
//   splash_logo.png         1152 transp.  — native splash (flutter_native_splash)
//
// Design: brand gradient #6C63FF -> #A78BFA, a white "timetable" panel with a
// 3x4 grid, four cells filled with the app's subject-palette colours forming a
// descending staircase (= an organised, generated schedule).

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _violet = Color(0xFF6C63FF);
const _violetLight = Color(0xFFA78BFA);
const _amber = Color(0xFFF59E0B);
const _emerald = Color(0xFF10B981);
const _blue = Color(0xFF3B82F6);

enum _Mode { full, foreground, background, splash }

void _paintIcon(Canvas canvas, double size, _Mode mode) {
  final rect = Rect.fromLTWH(0, 0, size, size);

  final hasBg = mode == _Mode.full || mode == _Mode.background;
  if (hasBg) {
    // Full-bleed square — the OS / launcher applies its own corner mask.
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [_violet, _violetLight],
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);
  }
  if (mode == _Mode.background) return;

  // White timetable panel. Sized per target: big on the full icon, smallest for
  // the Android adaptive foreground (safe zone), medium for the splash logo.
  final panelFraction = switch (mode) {
    _Mode.full => 0.62,
    _Mode.splash => 0.56,
    _ => 0.50,
  };
  final panelSize = size * panelFraction;
  final panelOffset = (size - panelSize) / 2;
  final panelRect =
      Rect.fromLTWH(panelOffset, panelOffset, panelSize, panelSize);
  final panelRRect =
      RRect.fromRectAndRadius(panelRect, Radius.circular(panelSize * 0.14));

  if (mode == _Mode.full || mode == _Mode.splash) {
    // soft shadow
    canvas.drawRRect(
      panelRRect.shift(Offset(0, size * 0.012)),
      Paint()
        ..color = const Color(0x33000000)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, size * 0.02),
    );
  }
  canvas.drawRRect(panelRRect, Paint()..color = Colors.white);

  // Grid inside the panel: 3 columns x 4 rows.
  const cols = 3;
  const rows = 4;
  final pad = panelSize * 0.13;
  final gridRect = Rect.fromLTWH(
    panelOffset + pad,
    panelOffset + pad,
    panelSize - pad * 2,
    panelSize - pad * 2,
  );
  final gap = panelSize * 0.055;
  final cellW = (gridRect.width - gap * (cols - 1)) / cols;
  final cellH = (gridRect.height - gap * (rows - 1)) / rows;
  final cellRadius = Radius.circular(cellW * 0.22);

  Rect cellAt(int c, int r) => Rect.fromLTWH(
        gridRect.left + c * (cellW + gap),
        gridRect.top + r * (cellH + gap),
        cellW,
        cellH,
      );

  final emptyPaint = Paint()..color = const Color(0xFFEDEEFB);
  for (var r = 0; r < rows; r++) {
    for (var c = 0; c < cols; c++) {
      canvas.drawRRect(
          RRect.fromRectAndRadius(cellAt(c, r), cellRadius), emptyPaint);
    }
  }

  // Filled "lessons": descending staircase + one extra.
  final filled = <MapEntry<List<int>, Color>>[
    MapEntry([0, 0], _violet),
    MapEntry([1, 1], _amber),
    MapEntry([2, 2], _emerald),
    MapEntry([1, 3], _blue),
  ];
  for (final e in filled) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(cellAt(e.key[0], e.key[1]), cellRadius),
      Paint()..color = e.value,
    );
  }
}

Future<void> _write(String path, int size, _Mode mode) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  _paintIcon(canvas, size.toDouble(), mode);
  final picture = recorder.endRecording();
  final image = await picture.toImage(size, size);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  final file = File(path);
  file.parent.createSync(recursive: true);
  file.writeAsBytesSync(Uint8List.view(bytes!.buffer));
  // ignore: avoid_print
  print('wrote $path (${bytes.lengthInBytes} bytes)');
}

void main() {
  testWidgets('generate app icons', (tester) async {
    await tester.runAsync(() async {
      await _write('assets/icon/app_icon.png', 1024, _Mode.full);
      await _write('assets/icon/app_icon_foreground.png', 1024, _Mode.foreground);
      await _write('assets/icon/app_icon_background.png', 1024, _Mode.background);
      await _write('assets/icon/splash_logo.png', 1152, _Mode.splash);
    });
  });
}
