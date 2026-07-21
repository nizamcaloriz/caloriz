import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
  );

  bool isScanned = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Barcode Scanner
          MobileScanner(
            controller: controller,
            onDetect: (BarcodeCapture capture) {
              if (isScanned) return;

              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final barcode = barcodes.first;
                if (barcode.rawValue != null) {
                  isScanned = true;
                  Get.back(result: barcode.rawValue);
                }
              }
            },
          ),

          // Scanning Frame Overlay
          _buildScanningFrame(),

          // Header with back button
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => controller.toggleTorch(),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.flash_on,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom instruction text
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Align barcode within the frame',
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanningFrame() {
    return Center(
      child: SizedBox(
        width: 320,
        height: 200,
        child: Stack(
          children: [
            // Corner brackets
            Positioned(
              top: 0,
              left: 0,
              child: _buildCornerBracket(isTopLeft: true),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: _buildCornerBracket(isTopRight: true),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: _buildCornerBracket(isBottomLeft: true),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: _buildCornerBracket(isBottomRight: true),
            ),
            // Scanning line animation
            const _ScanningLineAnimation(frameHeight: 200, frameWidth: 320),
          ],
        ),
      ),
    );
  }

  Widget _buildCornerBracket({
    bool isTopLeft = false,
    bool isTopRight = false,
    bool isBottomLeft = false,
    bool isBottomRight = false,
  }) {
    return SizedBox(
      width: 50,
      height: 50,
      child: CustomPaint(
        painter: CornerBracketPainter(
          isTopLeft: isTopLeft,
          isTopRight: isTopRight,
          isBottomLeft: isBottomLeft,
          isBottomRight: isBottomRight,
        ),
      ),
    );
  }
}

// Custom painter for corner brackets
class CornerBracketPainter extends CustomPainter {
  final bool isTopLeft;
  final bool isTopRight;
  final bool isBottomLeft;
  final bool isBottomRight;

  CornerBracketPainter({
    this.isTopLeft = false,
    this.isTopRight = false,
    this.isBottomLeft = false,
    this.isBottomRight = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    const radius = 15.0;
    const length = 35.0;

    if (isTopLeft) {
      path.moveTo(0, length);
      path.lineTo(0, radius);
      path.quadraticBezierTo(0, 0, radius, 0);
      path.lineTo(length, 0);
    } else if (isTopRight) {
      path.moveTo(size.width - length, 0);
      path.lineTo(size.width - radius, 0);
      path.quadraticBezierTo(size.width, 0, size.width, radius);
      path.lineTo(size.width, length);
    } else if (isBottomLeft) {
      path.moveTo(0, size.height - length);
      path.lineTo(0, size.height - radius);
      path.quadraticBezierTo(0, size.height, radius, size.height);
      path.lineTo(length, size.height);
    } else if (isBottomRight) {
      path.moveTo(size.width, size.height - length);
      path.lineTo(size.width, size.height - radius);
      path.quadraticBezierTo(
        size.width,
        size.height,
        size.width - radius,
        size.height,
      );
      path.lineTo(size.width - length, size.height);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Animated Scanning Line Widget
class _ScanningLineAnimation extends StatefulWidget {
  final double frameHeight;
  final double frameWidth;

  const _ScanningLineAnimation({
    required this.frameHeight,
    required this.frameWidth,
  });

  @override
  State<_ScanningLineAnimation> createState() => _ScanningLineAnimationState();
}

class _ScanningLineAnimationState extends State<_ScanningLineAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0,
      end: widget.frameHeight,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Positioned(
          top: _animation.value,
          left: 0,
          right: 0,
          child: Container(
            height: 3,
            decoration: BoxDecoration(
              color: const Color(0xFF00E3CC),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00E3CC).withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
