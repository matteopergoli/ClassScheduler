// One-off asset generator. Not a real test — run explicitly:
//   flutter test test/generate_icon.dart
// Produces:
//   assets/icon/app_icon.png            1024 opaque  — iOS + legacy Android launcher
//   assets/icon/app_icon_foreground.png 1024 transp. — Android adaptive foreground
//   assets/icon/app_icon_background.png 1024 opaque  — Android adaptive background
//   assets/icon/splash_logo.png         1152 transp. — native splash
//   store/play_icon_512.png             512  opaque  — Play Store listing icon
//   store/feature_graphic.png           1024x500     — Play Store feature graphic
//
// Design: brand gradient #6C63FF -> #A78BFA, a white "timetable" panel with a
// 3x4 grid, four cells filled with the app's subject-palette colours forming a
// descending staircase (= an organised, generated schedule).

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FontLoader;
import 'package:flutter_test/flutter_test.dart';

const _violet = Color(0xFF6C63FF);
const _violetLight = Color(0xFFA78BFA);
const _amber = Color(0xFFF59E0B);
const _emerald = Color(0xFF10B981);
const _blue = Color(0xFF3B82F6);

// ── Shared: the white timetable panel with coloured "lessons" ────────────────
void _paintPanel(Canvas canvas, Rect panel, {bool shadow = true}) {
  final rrect =
      RRect.fromRectAndRadius(panel, Radius.circular(panel.width * 0.14));
  if (shadow) {
    canvas.drawRRect(
      rrect.shift(Offset(0, panel.width * 0.012)),
      Paint()
        ..color = const Color(0x33000000)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, panel.width * 0.02),
    );
  }
  canvas.drawRRect(rrect, Paint()..color = Colors.white);

  const cols = 3, rows = 4;
  final pad = panel.width * 0.13;
  final grid = Rect.fromLTWH(panel.left + pad, panel.top + pad,
      panel.width - pad * 2, panel.height - pad * 2);
  final gap = panel.width * 0.055;
  final cw = (grid.width - gap * (cols - 1)) / cols;
  final ch = (grid.height - gap * (rows - 1)) / rows;
  final radius = Radius.circular(cw * 0.22);
  Rect cell(int c, int r) =>
      Rect.fromLTWH(grid.left + c * (cw + gap), grid.top + r * (ch + gap), cw, ch);

  final empty = Paint()..color = const Color(0xFFEDEEFB);
  for (var r = 0; r < rows; r++) {
    for (var c = 0; c < cols; c++) {
      canvas.drawRRect(RRect.fromRectAndRadius(cell(c, r), radius), empty);
    }
  }
  for (final e in <MapEntry<List<int>, Color>>[
    MapEntry([0, 0], _violet),
    MapEntry([1, 1], _amber),
    MapEntry([2, 2], _emerald),
    MapEntry([1, 3], _blue),
  ]) {
    canvas.drawRRect(RRect.fromRectAndRadius(cell(e.key[0], e.key[1]), radius),
        Paint()..color = e.value);
  }
}

void _paintGradient(Canvas canvas, Rect rect) {
  canvas.drawRect(
    rect,
    Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [_violet, _violetLight],
      ).createShader(rect),
  );
}

// ── App icon (square) ───────────────────────────────────────────────────────
enum _Mode { full, foreground, background, splash }

void _paintIcon(Canvas canvas, double size, _Mode mode) {
  final rect = Rect.fromLTWH(0, 0, size, size);
  final hasBg = mode == _Mode.full || mode == _Mode.background;
  if (hasBg) _paintGradient(canvas, rect);
  if (mode == _Mode.background) return;

  final frac = switch (mode) {
    _Mode.full => 0.62,
    _Mode.splash => 0.56,
    _ => 0.50,
  };
  final p = size * frac;
  _paintPanel(canvas, Rect.fromLTWH((size - p) / 2, (size - p) / 2, p, p),
      shadow: mode == _Mode.full || mode == _Mode.splash);
}

// ── Feature graphic (1024x500) ─────────────────────────────────────────────
void _paintFeature(Canvas canvas, double w, double h, String fontFamily) {
  final rect = Rect.fromLTWH(0, 0, w, h);
  _paintGradient(canvas, rect);

  // Timetable panel on the right, partly bled off the edge for depth.
  final panelSize = h * 0.82;
  _paintPanel(
    canvas,
    Rect.fromLTWH(w - panelSize * 0.78, (h - panelSize) / 2, panelSize, panelSize),
  );

  // Title + tagline on the left.
  void text(String s, double size, FontWeight weight, Color color, double dy) {
    final tp = TextPainter(
      text: TextSpan(
        text: s,
        style: TextStyle(
          fontFamily: fontFamily,
          fontSize: size,
          fontWeight: weight,
          color: color,
          height: 1.15,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 2,
    )..layout(maxWidth: w * 0.60);
    tp.paint(canvas, Offset(w * 0.07, dy));
  }

  text('ClassScheduler', 74, FontWeight.w800, Colors.white, h * 0.30);
  text("L'orario scolastico,\ngenerato in automatico", 30, FontWeight.w400,
      Colors.white.withValues(alpha: 0.92), h * 0.52);
}

// ── IO ─────────────────────────────────────────────────────────────────────
Future<void> _save(String path, int w, int h, void Function(Canvas) paint) async {
  final recorder = ui.PictureRecorder();
  paint(Canvas(recorder));
  final image = await recorder.endRecording().toImage(w, h);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  final f = File(path)..parent.createSync(recursive: true);
  f.writeAsBytesSync(Uint8List.view(bytes!.buffer));
  // ignore: avoid_print
  print('wrote $path (${bytes.lengthInBytes} bytes)');
}

Future<String> _loadRoboto() async {
  const base =
      r'C:\Users\pergo\Documents\flutter\bin\cache\artifacts\material_fonts';
  final loader = FontLoader('Roboto');
  for (final file in ['roboto-regular.ttf', 'roboto-bold.ttf', 'roboto-black.ttf']) {
    final data = File('$base\\$file').readAsBytesSync();
    loader.addFont(
        Future.value(ByteData.view(Uint8List.fromList(data).buffer)));
  }
  await loader.load();
  return 'Roboto';
}

void main() {
  testWidgets('generate icons + store assets', (tester) async {
    await tester.runAsync(() async {
      await _save('assets/icon/app_icon.png', 1024, 1024,
          (c) => _paintIcon(c, 1024, _Mode.full));
      await _save('assets/icon/app_icon_foreground.png', 1024, 1024,
          (c) => _paintIcon(c, 1024, _Mode.foreground));
      await _save('assets/icon/app_icon_background.png', 1024, 1024,
          (c) => _paintIcon(c, 1024, _Mode.background));
      await _save('assets/icon/splash_logo.png', 1152, 1152,
          (c) => _paintIcon(c, 1152, _Mode.splash));
      await _save('store/play_icon_512.png', 512, 512,
          (c) => _paintIcon(c, 512, _Mode.full));

      final family = await _loadRoboto();
      await _save('store/feature_graphic.png', 1024, 500,
          (c) => _paintFeature(c, 1024, 500, family));
    });
  });
}
