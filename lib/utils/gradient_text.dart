import 'package:flutter/material.dart';

class GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final LinearGradient gradient;
  final TextAlign? textAlign;

  const GradientText(
      this.text, {
        super.key,
        required this.style,
        required this.gradient,
        this.textAlign,
      });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        text,
        style: style.copyWith(color: Colors.white,), // The color here doesn't matter; it's overwritten by the gradient
        textAlign: textAlign,
      ),
    );
  }
}