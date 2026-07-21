import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:camera/camera.dart';
import '../controllers/scanner_controller.dart';

class ScannerView extends GetView<ScannerController> {
  const ScannerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          Obx(() {
            if (!controller.isInitialized.value ||
                controller.cameraController == null) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }
            return SizedBox.expand(
              child: CameraPreview(controller.cameraController!),
            );
          }),

          // Back Button - Top Left
          Positioned(
            top: 50,
            left: 20,
            child: SafeArea(
              top: false,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),

          // Scan Counter Badge - Top Right
          Positioned(
            top: 50,
            right: 20,
            child: Obx(() {
              if (controller.isPremium.value) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E3CC),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, color: Colors.white, size: 20),
                      SizedBox(width: 6),
                      Text(
                        'Premium',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: controller.remainingScans.value > 0 
                      ? Colors.green.withOpacity(0.9)
                      : Colors.red.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      controller.remainingScans.value > 0 
                          ? Icons.camera_alt 
                          : Icons.lock,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${controller.remainingScans.value} Scans',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),

          // Scanning Frame Overlay - only show for Food Scan and Bar Code modes
          Obx(
            () => controller.selectedMode.value != 2
                ? _buildScanningFrame()
                : const SizedBox(),
          ),

          // Bottom Controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomControls(),
          ),
        ],
      ),
    );
  }

  Widget _buildScanningFrame() {
    return Obx(() {
      // Different frame size for barcode mode
      final isBarcode = controller.selectedMode.value == 1;
      final frameWidth = isBarcode ? 320.0 : 280.0;
      final frameHeight = isBarcode ? 200.0 : 350.0;

      return Center(
        child: SizedBox(
          width: frameWidth,
          height: frameHeight,
          child: Stack(
            children: [
              // Corner brackets only (no full border)
              // Top Left
              Positioned(
                top: 0,
                left: 0,
                child: _buildCornerBracket(isTopLeft: true),
              ),
              // Top Right
              Positioned(
                top: 0,
                right: 0,
                child: _buildCornerBracket(isTopRight: true),
              ),
              // Bottom Left
              Positioned(
                bottom: 0,
                left: 0,
                child: _buildCornerBracket(isBottomLeft: true),
              ),
              // Bottom Right
              Positioned(
                bottom: 0,
                right: 0,
                child: _buildCornerBracket(isBottomRight: true),
              ),
              // Animated Scanning line for both modes
              _ScanningLineAnimation(
                frameHeight: frameHeight,
                frameWidth: frameWidth,
                isBarcode: isBarcode,
              ),
            ],
          ),
        ),
      );
    });
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

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.only(bottom: 50, top: 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Capture Button - Hide for Manual Click mode
          Obx(
            () => controller.selectedMode.value != 2
                ? GestureDetector(
                    onTap: () => controller.captureImage(),
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.9),
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Obx(
                        () => controller.isProcessing.value
                            ? const Padding(
                                padding: EdgeInsets.all(18),
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: Colors.grey,
                                ),
                              )
                            : const SizedBox(),
                      ),
                    ),
                  )
                : const SizedBox(),
          ),
          Obx(
            () => controller.selectedMode.value != 2
                ? const SizedBox(height: 30)
                : const SizedBox(),
          ),
          // Mode Selector - Pill shaped container
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2A3A).withOpacity(0.95),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Obx(
              () => Row(
                children: [
                  Expanded(child: _buildModeButton('Food Scan', 0)),
                  Expanded(child: _buildModeButton('Bar Code', 1)),
                  Expanded(child: _buildModeButton('Manual Click', 2)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(String label, int index) {
    final isSelected = controller.selectedMode.value == index;
    return GestureDetector(
      onTap: () => controller.selectMode(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8B1D1D) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.lato(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
          ),
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
  final bool isBarcode;

  const _ScanningLineAnimation({
    required this.frameHeight,
    required this.frameWidth,
    required this.isBarcode,
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
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _updateAnimation();
  }

  void _updateAnimation() {
    if (widget.isBarcode) {
      // Horizontal animation for barcode (left to right)
      _animation = Tween<double>(
        begin: 20,
        end: widget.frameWidth - 20,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    } else {
      // Vertical animation for food scan (top to bottom)
      _animation = Tween<double>(
        begin: 20,
        end: widget.frameHeight - 20,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    }
  }

  @override
  void didUpdateWidget(_ScanningLineAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.frameHeight != widget.frameHeight ||
        oldWidget.frameWidth != widget.frameWidth ||
        oldWidget.isBarcode != widget.isBarcode) {
      _updateAnimation();
    }
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
        if (widget.isBarcode) {
          // Vertical line moving left to right for barcode
          return Positioned(
            left: _animation.value,
            top: 10,
            bottom: 10,
            child: Container(
              width: 2,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.6),
                    blurRadius: 10,
                    spreadRadius: 3,
                  ),
                ],
              ),
            ),
          );
        } else {
          // Horizontal line moving top to bottom for food scan
          return Positioned(
            top: _animation.value,
            left: 10,
            right: 10,
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.6),
                    blurRadius: 10,
                    spreadRadius: 3,
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
