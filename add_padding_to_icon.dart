import 'dart:io';
import 'package:image/image.dart' as img;

void main() async {
  // Read the original logo
  final originalFile = File('assets/splash_logo.png');
  if (!originalFile.existsSync()) {
    print('Error: assets/splash_logo.png not found!');
    return;
  }

  final bytes = await originalFile.readAsBytes();
  final originalImage = img.decodeImage(bytes);

  if (originalImage == null) {
    print('Error: Could not decode image!');
    return;
  }

  // Create a new image with padding (20% padding on all sides)
  final originalSize = originalImage.width;
  final paddingPercent = 0.20; // 20% padding
  final newSize = (originalSize / (1 - 2 * paddingPercent)).round();
  final padding = ((newSize - originalSize) / 2).round();

  // Create black background
  final newImage = img.Image(width: newSize, height: newSize);
  img.fill(newImage, color: img.ColorRgb8(0, 0, 0));

  // Copy original image to center
  img.compositeImage(
    newImage,
    originalImage,
    dstX: padding,
    dstY: padding,
  );

  // Save the new icon
  final outputFile = File('assets/icon_with_padding.png');
  await outputFile.writeAsBytes(img.encodePng(newImage));

  print('✓ New icon created: assets/icon_with_padding.png');
  print('  Please update pubspec.yaml to use this new icon');
}
