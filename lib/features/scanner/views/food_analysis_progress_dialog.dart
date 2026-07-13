import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FoodAnalysisProgressDialog extends StatefulWidget {
  const FoodAnalysisProgressDialog({super.key});

  @override
  State<FoodAnalysisProgressDialog> createState() =>
      FoodAnalysisProgressDialogState();
}

class FoodAnalysisProgressDialogState
    extends State<FoodAnalysisProgressDialog>
    with SingleTickerProviderStateMixin {
  double _progress = 0.0;
  Timer? _timer;
  late AnimationController _pulseController;

  final List<String> _stages = [
    'Detecting food items...',
    'Estimating portions...',
    'Calculating calories...',
    'Analyzing nutrients...',
    'Preparing results...',
  ];
  int _currentStage = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _startProgress();
  }

  void _startProgress() {
    _timer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        // Fast at start, slow down as it approaches 90%
        if (_progress < 30) {
          _progress += 1.5 + Random().nextDouble() * 1.5;
        } else if (_progress < 60) {
          _progress += 0.8 + Random().nextDouble() * 1.0;
        } else if (_progress < 85) {
          _progress += 0.3 + Random().nextDouble() * 0.5;
        } else if (_progress < 92) {
          _progress += 0.1 + Random().nextDouble() * 0.2;
        }
        // Cap at 92% until actual completion
        _progress = _progress.clamp(0, 92);

        // Update stage text
        if (_progress < 20) {
          _currentStage = 0;
        } else if (_progress < 40) {
          _currentStage = 1;
        } else if (_progress < 60) {
          _currentStage = 2;
        } else if (_progress < 80) {
          _currentStage = 3;
        } else {
          _currentStage = 4;
        }
      });
    });
  }

  /// Call this to animate to 100% and then close
  void completeAndClose() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 20), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _progress += 3;
        if (_progress >= 100) {
          _progress = 100;
          timer.cancel();
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              Navigator.of(context).pop();
            }
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int progressInt = _progress.round();
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 36),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Circular progress indicator
              SizedBox(
                width: 130,
                height: 130,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background circle
                    SizedBox(
                      width: 130,
                      height: 130,
                      child: CircularProgressIndicator(
                        value: 1.0,
                        strokeWidth: 10,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.grey.shade200,
                        ),
                      ),
                    ),
                    // Progress circle
                    SizedBox(
                      width: 130,
                      height: 130,
                      child: CircularProgressIndicator(
                        value: _progress / 100,
                        strokeWidth: 10,
                        strokeCap: StrokeCap.round,
                        backgroundColor: Colors.transparent,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF00E3CC),
                        ),
                      ),
                    ),
                    // Percentage text
                    Text(
                      '$progressInt%',
                      style: GoogleFonts.lato(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1E2A3A),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              // Stage text
              Text(
                _stages[_currentStage],
                style: GoogleFonts.lato(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E2A3A),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'We\'ll notify you when the analysis is done',
                style: GoogleFonts.lato(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              // Food icon animation
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final scale =
                      1.0 + (_pulseController.value * 0.08);
                  return Transform.scale(
                    scale: scale,
                    child: Icon(
                      Icons.restaurant,
                      color: const Color(0xFF00E3CC).withOpacity(0.5),
                      size: 28,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
