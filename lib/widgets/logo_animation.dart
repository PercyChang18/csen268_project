import 'package:flutter/material.dart';

class LogoAnimation extends StatefulWidget {
  const LogoAnimation({super.key});

  @override
  State<LogoAnimation> createState() => _LogoAnimationState();
}

class _LogoAnimationState extends State<LogoAnimation>
    with SingleTickerProviderStateMixin {
  final String _text = "FitStart";
  late AnimationController _controller;
  final List<Animation<double>> _characterWaveAnimations = [];
  final List<Animation<Color?>> _characterColorAnimations = [];

  // Configuration for the wave
  final double _waveAmplitude = 25.0;
  final Duration _charWaveDuration = Duration(milliseconds: 1500);
  final Duration _staggerDelay = Duration(milliseconds: 100);

  // Colors for the animation
  final Color _startColor = Color(0xFFFF9100);
  final Color _peakColor = Color(0x33FF9100);
  final Color _endColor = Color(0xFFFF9100);

  @override
  void initState() {
    super.initState();

    final totalDurationMs =
        (_text.length * _staggerDelay.inMilliseconds) +
        _charWaveDuration.inMilliseconds;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: totalDurationMs),
    );

    for (int i = 0; i < _text.length; i++) {
      final double beginInterval =
          (i * _staggerDelay.inMilliseconds) /
          _controller.duration!.inMilliseconds;
      final double endInterval =
          beginInterval +
          (_charWaveDuration.inMilliseconds /
              _controller.duration!.inMilliseconds);

      final double clampedBegin = beginInterval.clamp(0.0, 1.0);
      final double clampedEnd = endInterval.clamp(0.0, 1.0);

      _characterWaveAnimations.add(
        TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween<double>(begin: 0.0, end: -_waveAmplitude), // Up
            weight: 0.5,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: -_waveAmplitude, end: 0.0), // Down
            weight: 0.5,
          ),
        ]).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(
              clampedBegin,
              clampedEnd,
              curve: Curves.easeOutCubic,
            ),
          ),
        ),
      );

      _characterColorAnimations.add(
        TweenSequence<Color?>([
          TweenSequenceItem(
            tween: ColorTween(begin: _startColor, end: _peakColor),
            weight: 0.5,
          ),
          TweenSequenceItem(
            tween: ColorTween(begin: _peakColor, end: _endColor),
            weight: 0.5,
          ),
        ]).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(
              clampedBegin,
              clampedEnd,
              curve: Curves.easeOutCubic,
            ),
          ),
        ),
      );
    }

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_text.length, (index) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final double offsetY = _characterWaveAnimations[index].value;
              final Color? charColor = _characterColorAnimations[index].value;

              return Transform.translate(
                offset: Offset(0.0, offsetY),
                child: Text(
                  _text[index],
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    color: charColor,
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
