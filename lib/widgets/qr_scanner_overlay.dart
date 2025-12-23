import 'package:flutter/material.dart';

class QrScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;
  final double cutOutBottomOffset;

  const QrScannerOverlayShape({
    this.borderColor = Colors.red,
    this.borderWidth = 10.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
    this.cutOutBottomOffset = 0,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path _getRectPath(Rect rect) {
      return Path()
        ..addRect(rect);
    }

    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(_getRectPath(rect), Offset.zero)
      ..addRect(
        Rect.fromCenter(
          center: rect.center,
          width: cutOutSize,
          height: cutOutSize,
        ),
      );
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final borderWidthSize = width / 2;
    // final height = rect.height; // Unused
    final borderOffset = borderWidth / 2;
    final _borderLength = borderLength > cutOutSize / 2 + borderWidth * 2
        ? borderWidthSize / 2
        : borderLength;
    final _cutOutSize = cutOutSize < width ? cutOutSize : width - borderOffset;

    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    // final boxPaint = Paint() // Unused
    //   ..color = borderColor
    //   ..style = PaintingStyle.fill;

    final cutOutRect = Rect.fromCenter(
      center: rect.center,
      width: _cutOutSize,
      height: _cutOutSize,
    );

    canvas
      ..saveLayer(
        rect,
        backgroundPaint,
      )
      ..drawRect(
        rect,
        backgroundPaint,
      )
      ..drawRect(
        cutOutRect,
        Paint()..blendMode = BlendMode.clear,
      )
      ..restore();

    final path = Path()
      ..moveTo(cutOutRect.left, cutOutRect.top + _borderLength)
      ..lineTo(cutOutRect.left, cutOutRect.top + borderRadius)
      ..quadraticBezierTo(
        cutOutRect.left,
        cutOutRect.top,
        cutOutRect.left + borderRadius,
        cutOutRect.top,
      )
      ..lineTo(cutOutRect.left + _borderLength, cutOutRect.top)
      ..moveTo(cutOutRect.right, cutOutRect.top + _borderLength)
      ..lineTo(cutOutRect.right, cutOutRect.top + borderRadius)
      ..quadraticBezierTo(
        cutOutRect.right,
        cutOutRect.top,
        cutOutRect.right - borderRadius,
        cutOutRect.top,
      )
      ..lineTo(cutOutRect.right - _borderLength, cutOutRect.top)
      ..moveTo(cutOutRect.right, cutOutRect.bottom - _borderLength)
      ..lineTo(cutOutRect.right, cutOutRect.bottom - borderRadius)
      ..quadraticBezierTo(
        cutOutRect.right,
        cutOutRect.bottom,
        cutOutRect.right - borderRadius,
        cutOutRect.bottom,
      )
      ..lineTo(cutOutRect.right - _borderLength, cutOutRect.bottom)
      ..moveTo(cutOutRect.left, cutOutRect.bottom - _borderLength)
      ..lineTo(cutOutRect.left, cutOutRect.bottom - borderRadius)
      ..quadraticBezierTo(
        cutOutRect.left,
        cutOutRect.bottom,
        cutOutRect.left + borderRadius,
        cutOutRect.bottom,
      )
      ..lineTo(cutOutRect.left + _borderLength, cutOutRect.bottom);

    canvas.drawPath(path, borderPaint);
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth,
      overlayColor: overlayColor,
    );
  }
}
