import 'dart:io';

import 'package:image/image.dart';

Future<void> main() async {
  final inputPath = 'assets/icon.png';
  final outputPath = 'assets/icon_foreground.png';
  final file = File(inputPath);
  if (!file.existsSync()) {
    stderr.writeln('Input icon not found at $inputPath');
    exit(1);
  }

  final original = decodeImage(await file.readAsBytes());
  if (original == null) {
    stderr.writeln('Could not decode $inputPath');
    exit(1);
  }

  const canvasSize = 512;
  const safeAreaRatio = 0.72; // leave margin so adaptive masks do not crop
  final target = Image(width: canvasSize, height: canvasSize, numChannels: 4);

  final maxWidth = (canvasSize * safeAreaRatio).round();
  final maxHeight = maxWidth;
  final scale = _min(maxWidth / original.width, maxHeight / original.height);
  final resized = copyResize(
    original,
    width: (original.width * scale).round(),
    height: (original.height * scale).round(),
    interpolation: Interpolation.cubic,
  );

  final offsetX = ((canvasSize - resized.width) / 2).round();
  final offsetY = ((canvasSize - resized.height) / 2).round();
  for (var y = 0; y < resized.height; y++) {
    for (var x = 0; x < resized.width; x++) {
      final pixel = resized.getPixel(x, y);
      target.setPixel(offsetX + x, offsetY + y, pixel);
    }
  }

  final outputFile = File(outputPath);
  await outputFile.writeAsBytes(encodePng(target));
  stdout.writeln('Wrote padded icon to $outputPath');
}

double _min(double a, double b) => a < b ? a : b;
