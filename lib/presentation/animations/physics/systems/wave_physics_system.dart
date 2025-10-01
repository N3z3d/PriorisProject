import 'dart:math';
import 'package:flutter/material.dart';
import '../interfaces/physics_system_interface.dart';
import '../configs/physics_configs.dart';

/// Wave Physics System implementing realistic wave mechanics
///
/// This system focuses on wave-based animations including:
/// - Sinusoidal wave functions (sine, cosine, square, triangle, sawtooth)
/// - Wave damping and amplitude decay
/// - Phase relationships and interference patterns
/// - Frequency-dependent wave behavior
///
/// Physics equations used:
/// - Simple harmonic motion: y = A * sin(ωt + φ)
/// - Damped oscillation: y = A * e^(-γt) * sin(ωt + φ)
/// - Angular frequency: ω = 2πf
/// - Wave energy: E ∝ A² (amplitude squared)
class WavePhysicsSystem
    implements IAnimatedPhysicsSystem, ICalculatablePhysicsSystem {

  static const String _systemId = 'wave_physics';
  static const String _systemName = 'Wave Physics System';

  bool _isActive = false;

  @override
  String get systemId => _systemId;

  @override
  String get systemName => _systemName;

  @override
  bool get isActive => _isActive;

  @override
  Future<void> initialize() async {
    if (_isActive) return;

    try {
      _isActive = true;
    } catch (e) {
      throw PhysicsSystemException(
        'Failed to initialize wave physics system: $e',
        _systemId,
        e,
      );
    }
  }

  @override
  Future<void> dispose() async {
    _isActive = false;
  }

  @override
  Widget createAnimation({
    required Widget child,
    required PhysicsAnimationConfig config,
  }) {
    if (!_isActive) {
      throw PhysicsSystemException(
        'Wave system not initialized',
        _systemId,
      );
    }

    if (config is! WavePhysicsConfig) {
      throw PhysicsSystemException(
        'Invalid config type for wave system. Expected WavePhysicsConfig.',
        _systemId,
      );
    }

    return _WaveAnimationWidget(
      config: config,
      system: this,
      child: child,
    );
  }

  @override
  PhysicsState calculateState({
    required double time,
    required PhysicsParameters parameters,
  }) {
    if (parameters is! WavePhysicsParameters) {
      throw PhysicsSystemException(
        'Invalid parameters type for wave system',
        _systemId,
      );
    }

    return _calculateWaveState(time, parameters);
  }

  @override
  void updateParameters(PhysicsParameters parameters) {
    if (parameters is! WavePhysicsParameters) {
      throw PhysicsSystemException(
        'Invalid parameters type for wave system',
        _systemId,
      );
    }

    _validateWaveParameters(parameters);
  }

  /// Calculate wave displacement based on wave function type
  double calculateWaveDisplacement({
    required double time,
    required double amplitude,
    required double frequency,
    required double phase,
    required double damping,
    required WaveType waveType,
  }) {
    final omega = 2 * pi * frequency; // Angular frequency
    final argument = omega * time + phase;
    final dampingFactor = exp(-damping * time);

    double waveValue;

    switch (waveType) {
      case WaveType.sine:
        waveValue = sin(argument);
        break;
      case WaveType.cosine:
        waveValue = cos(argument);
        break;
      case WaveType.square:
        waveValue = sin(argument) > 0 ? 1.0 : -1.0;
        break;
      case WaveType.triangle:
        waveValue = (2 / pi) * asin(sin(argument));
        break;
      case WaveType.sawtooth:
        final normalizedTime = (argument / (2 * pi)) % 1;
        waveValue = 2 * normalizedTime - 1;
        break;
    }

    return amplitude * dampingFactor * waveValue;
  }

  /// Calculate wave state with full physics
  PhysicsState _calculateWaveState(double time, WavePhysicsParameters params) {
    final amplitude = params.amplitude;
    final frequency = params.frequency;
    final phase = params.phase;
    final damping = params.damping;

    assert(amplitude >= 0, 'Amplitude must be non-negative');
    assert(frequency > 0, 'Frequency must be positive');
    assert(damping >= 0, 'Damping must be non-negative');

    final omega = 2 * pi * frequency;
    final argument = omega * time + phase;
    final dampingFactor = exp(-damping * time);

    // Calculate displacement (sine wave for position calculation)
    final displacement = amplitude * dampingFactor * sin(argument);

    // Calculate velocity (derivative of displacement)
    final velocity = amplitude * dampingFactor *
        (omega * cos(argument) - damping * sin(argument));

    // Calculate acceleration (derivative of velocity)
    final acceleration = amplitude * dampingFactor *
        (-(omega * omega + damping * damping) * sin(argument) - 2 * damping * omega * cos(argument));

    return PhysicsState(
      position: Offset(displacement, 0),
      velocity: Offset(velocity, 0),
      acceleration: Offset(acceleration, 0),
      rotation: 0,
      scale: 1.0 + displacement * 0.01, // Subtle scale variation
      time: time,
    );
  }

  void _validateWaveParameters(WavePhysicsParameters params) {
    if (params.amplitude < 0) {
      throw PhysicsSystemException('Amplitude must be non-negative', _systemId);
    }
    if (params.frequency <= 0) {
      throw PhysicsSystemException('Frequency must be positive', _systemId);
    }
    if (params.damping < 0) {
      throw PhysicsSystemException('Damping must be non-negative', _systemId);
    }
  }
}

/// Widget implementing wave animation with configurable wave functions
class _WaveAnimationWidget extends StatefulWidget {
  final WavePhysicsConfig config;
  final WavePhysicsSystem system;
  final Widget child;

  const _WaveAnimationWidget({
    required this.config,
    required this.system,
    required this.child,
  });

  @override
  State<_WaveAnimationWidget> createState() => _WaveAnimationWidgetState();
}

class _WaveAnimationWidgetState extends State<_WaveAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.config.duration,
      vsync: this,
    );

    _waveAnimation = Tween<double>(
      begin: 0,
      end: widget.config.duration.inMilliseconds / 1000.0,
    ).animate(_controller);

    if (widget.config.autoStart) {
      _controller.repeat();
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
      animation: _waveAnimation,
      builder: (context, child) {
        final currentTime = _waveAnimation.value;

        final displacement = widget.system.calculateWaveDisplacement(
          time: currentTime,
          amplitude: widget.config.amplitude,
          frequency: widget.config.frequency,
          phase: widget.config.phase,
          damping: widget.config.damping,
          waveType: widget.config.waveType,
        );

        return Transform.translate(
          offset: Offset(displacement, 0),
          child: widget.child,
        );
      },
    );
  }
}

/// Create remaining physics systems - simplified implementations for completion