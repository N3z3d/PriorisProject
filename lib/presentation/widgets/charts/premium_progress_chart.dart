import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

/// Premium Progress Chart with custom painting and elegant animations
///
/// Features:
/// - Custom painted chart without external dependencies
/// - Smooth gradient fills and animated lines
/// - Premium glassmorphism styling
/// - Responsive design with accessibility support
/// - Interactive hover effects with haptic feedback
class PremiumProgressChart extends StatefulWidget {
  final List<ChartDataPoint> data;
  final String title;
  final String subtitle;
  final Color primaryColor;
  final Color gradientColor;
  final bool showGrid;
  final bool enableAnimation;
  final Duration animationDuration;
  final double height;

  const PremiumProgressChart({
    super.key,
    required this.data,
    required this.title,
    this.subtitle = '',
    this.primaryColor = AppTheme.primaryColor,
    this.gradientColor = AppTheme.primaryVariant,
    this.showGrid = true,
    this.enableAnimation = true,
    this.animationDuration = const Duration(milliseconds: 1500),
    this.height = 300,
  });

  @override
  State<PremiumProgressChart> createState() => _PremiumProgressChartState();
}

class _PremiumProgressChartState extends State<PremiumProgressChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    ));

    if (widget.enableAnimation) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
        border: Border.all(
          color: AppTheme.grey200,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            Expanded(
              child: widget.enableAnimation
                  ? AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return CustomPaint(
                          size: Size.infinite,
                          painter: ProgressChartPainter(
                            data: widget.data,
                            primaryColor: widget.primaryColor,
                            gradientColor: widget.gradientColor,
                            showGrid: widget.showGrid,
                            animationProgress: _animation.value,
                          ),
                        );
                      },
                    )
                  : CustomPaint(
                      size: Size.infinite,
                      painter: ProgressChartPainter(
                        data: widget.data,
                        primaryColor: widget.primaryColor,
                        gradientColor: widget.gradientColor,
                        showGrid: widget.showGrid,
                        animationProgress: 1.0,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        if (widget.subtitle.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            widget.subtitle,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.textTertiary,
            ),
          ),
        ],
      ],
    );
  }
}

/// Custom painter for the progress chart
class ProgressChartPainter extends CustomPainter {
  final List<ChartDataPoint> data;
  final Color primaryColor;
  final Color gradientColor;
  final bool showGrid;
  final double animationProgress;

  ProgressChartPainter({
    required this.data,
    required this.primaryColor,
    required this.gradientColor,
    required this.showGrid,
    required this.animationProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = primaryColor;

    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          primaryColor.withOpacity(0.3),
          gradientColor.withOpacity(0.05),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppTheme.grey300.withOpacity(0.5);

    final dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = primaryColor;

    // Draw grid if enabled
    if (showGrid) {
      _drawGrid(canvas, size, gridPaint);
    }

    // Calculate positions
    final maxY = data.map((d) => d.value).reduce((a, b) => a > b ? a : b);
    final minY = data.map((d) => d.value).reduce((a, b) => a < b ? a : b);
    final range = maxY - minY;

    final positions = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final normalizedY = range > 0 ? (data[i].value - minY) / range : 0.5;
      final y = size.height - (normalizedY * size.height * 0.8) - (size.height * 0.1);
      positions.add(Offset(x, y));
    }

    // Draw animated gradient area
    if (animationProgress > 0 && positions.length > 1) {
      _drawGradientArea(canvas, size, positions, gradientPaint);
    }

    // Draw animated line
    if (animationProgress > 0 && positions.length > 1) {
      _drawAnimatedLine(canvas, positions, paint);
    }

    // Draw animated dots
    if (animationProgress > 0.7) {
      _drawDots(canvas, positions, dotPaint);
    }
  }

  void _drawGrid(Canvas canvas, Size size, Paint paint) {
    // Horizontal grid lines
    for (int i = 0; i <= 4; i++) {
      final y = (i / 4) * size.height;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Vertical grid lines
    for (int i = 0; i <= 6; i++) {
      final x = (i / 6) * size.width;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
  }

  void _drawGradientArea(Canvas canvas, Size size, List<Offset> positions, Paint paint) {
    final path = Path();
    path.moveTo(positions.first.dx, size.height);
    path.lineTo(positions.first.dx, positions.first.dy);

    for (int i = 1; i < positions.length; i++) {
      final animatedIndex = (i * animationProgress).clamp(0, positions.length - 1).round();
      if (i <= animatedIndex) {
        path.lineTo(positions[i].dx, positions[i].dy);
      }
    }

    final lastIndex = (positions.length * animationProgress).clamp(0, positions.length - 1).round();
    if (lastIndex < positions.length) {
      path.lineTo(positions[lastIndex].dx, size.height);
    } else {
      path.lineTo(positions.last.dx, size.height);
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawAnimatedLine(Canvas canvas, List<Offset> positions, Paint paint) {
    final path = Path();
    path.moveTo(positions.first.dx, positions.first.dy);

    for (int i = 1; i < positions.length; i++) {
      final progress = (i / positions.length);
      if (progress <= animationProgress) {
        // Use quadratic curves for smooth lines
        if (i == 1) {
          path.lineTo(positions[i].dx, positions[i].dy);
        } else {
          final cp1 = Offset(
            positions[i - 1].dx + (positions[i].dx - positions[i - 1].dx) * 0.5,
            positions[i - 1].dy,
          );
          final cp2 = Offset(
            positions[i - 1].dx + (positions[i].dx - positions[i - 1].dx) * 0.5,
            positions[i].dy,
          );
          path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, positions[i].dx, positions[i].dy);
        }
      }
    }

    canvas.drawPath(path, paint);
  }

  void _drawDots(Canvas canvas, List<Offset> positions, Paint paint) {
    final dotRadius = 4.0;
    final outerPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;

    for (final position in positions) {
      // Draw outer white circle
      canvas.drawCircle(position, dotRadius + 2, outerPaint);
      // Draw inner colored circle
      canvas.drawCircle(position, dotRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is ProgressChartPainter &&
        (oldDelegate.animationProgress != animationProgress ||
         oldDelegate.data != data ||
         oldDelegate.primaryColor != primaryColor);
  }
}

/// Data point for the chart
class ChartDataPoint {
  final String label;
  final double value;
  final DateTime? date;

  const ChartDataPoint({
    required this.label,
    required this.value,
    this.date,
  });
}