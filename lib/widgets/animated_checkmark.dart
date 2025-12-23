import 'package:flutter/material.dart';

class AnimatedCheckmark extends StatelessWidget {
  final bool isSuccess;
  const AnimatedCheckmark({Key? key, required this.isSuccess}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isSuccess ? Colors.green[50] : Colors.red[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              size: 100,
              color: isSuccess ? Colors.green : Colors.red,
            ),
          ),
        );
      },
    );
  }
}
