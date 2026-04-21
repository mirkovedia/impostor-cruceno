import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CambaCharacter extends StatelessWidget {
  final double size;
  final bool animated;
  final bool suspicious;

  const CambaCharacter({
    super.key,
    this.size = 200,
    this.animated = true,
    this.suspicious = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget character = CustomPaint(
      size: Size(size, size * 1.3),
      painter: _CambaPainter(suspicious: suspicious),
    );

    if (animated) {
      character = character
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .moveY(
            begin: 0,
            end: -6,
            duration: 1200.ms,
            curve: Curves.easeInOut,
          );
    }

    return character;
  }
}

class _CambaPainter extends CustomPainter {
  final bool suspicious;

  _CambaPainter({this.suspicious = false});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;

    // Proporciones basadas en el tamaño total
    final headRadius = w * 0.22;
    final headCenterY = h * 0.35;

    _drawBody(canvas, cx, headCenterY, headRadius, w, h);
    _drawHead(canvas, cx, headCenterY, headRadius);
    _drawFace(canvas, cx, headCenterY, headRadius);
    _drawHat(canvas, cx, headCenterY, headRadius, w);
  }

  void _drawBody(
      Canvas canvas, double cx, double headY, double headR, double w, double h) {
    // Camisa blanca
    final shirtPaint = Paint()..color = const Color(0xFFF5F5F0);
    final shirtPath = Path();
    final shoulderY = headY + headR * 0.85;
    final bodyBottom = h * 0.92;
    final shoulderWidth = headR * 1.6;

    // Forma del torso
    shirtPath.moveTo(cx - shoulderWidth, shoulderY);
    shirtPath.quadraticBezierTo(
      cx - shoulderWidth * 1.3,
      shoulderY + (bodyBottom - shoulderY) * 0.3,
      cx - shoulderWidth * 1.1,
      bodyBottom,
    );
    shirtPath.lineTo(cx + shoulderWidth * 1.1, bodyBottom);
    shirtPath.quadraticBezierTo(
      cx + shoulderWidth * 1.3,
      shoulderY + (bodyBottom - shoulderY) * 0.3,
      cx + shoulderWidth, shoulderY,
    );
    shirtPath.close();
    canvas.drawPath(shirtPath, shirtPaint);

    // Borde de la camisa
    final shirtBorder = Paint()
      ..color = const Color(0xFFD0D0C8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(shirtPath, shirtBorder);

    // Cuello en V
    final collarPaint = Paint()
      ..color = const Color(0xFFD0D0C8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    final collarPath = Path();
    collarPath.moveTo(cx - headR * 0.35, shoulderY);
    collarPath.lineTo(cx, shoulderY + headR * 0.55);
    collarPath.lineTo(cx + headR * 0.35, shoulderY);
    canvas.drawPath(collarPath, collarPaint);

    // Brazos
    _drawArm(canvas, cx - shoulderWidth, shoulderY, -1, headR, bodyBottom);
    _drawArm(canvas, cx + shoulderWidth, shoulderY, 1, headR, bodyBottom);

    // Botones de la camisa
    final buttonPaint = Paint()..color = const Color(0xFFB0B0A8);
    for (var i = 0; i < 3; i++) {
      final by = shoulderY + headR * 0.7 + i * headR * 0.4;
      canvas.drawCircle(Offset(cx, by), 2.5, buttonPaint);
    }
  }

  void _drawArm(Canvas canvas, double startX, double startY, int side,
      double headR, double bodyBottom) {
    final armPaint = Paint()..color = const Color(0xFFF5F5F0);
    final armBorder = Paint()
      ..color = const Color(0xFFD0D0C8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final armPath = Path();
    final armEndX = startX + side * headR * 0.9;
    final armEndY = bodyBottom * 0.85;
    final armWidth = headR * 0.35;

    armPath.moveTo(startX, startY + headR * 0.15);
    armPath.quadraticBezierTo(
      startX + side * headR * 0.5,
      startY + headR * 0.4,
      armEndX,
      armEndY,
    );
    armPath.quadraticBezierTo(
      armEndX + side * armWidth * 0.3,
      armEndY + armWidth * 0.5,
      armEndX - side * armWidth * 0.2,
      armEndY + armWidth,
    );
    armPath.quadraticBezierTo(
      startX + side * headR * 0.2,
      startY + headR * 0.8,
      startX, startY + headR * 0.55,
    );
    armPath.close();
    canvas.drawPath(armPath, armPaint);
    canvas.drawPath(armPath, armBorder);

    // Mano
    final handPaint = Paint()..color = const Color(0xFFD4A574);
    canvas.drawCircle(
      Offset(armEndX, armEndY + armWidth * 0.3),
      armWidth * 0.5,
      handPaint,
    );
  }

  void _drawHead(Canvas canvas, double cx, double cy, double radius) {
    // Sombra suave
    final shadowPaint = Paint()
      ..color = const Color(0x22000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(Offset(cx, cy + 3), radius, shadowPaint);

    // Cara
    final skinPaint = Paint()..color = const Color(0xFFD4A574);
    canvas.drawCircle(Offset(cx, cy), radius, skinPaint);

    // Mejillas rosadas
    final cheekPaint = Paint()..color = const Color(0x33E8836B);
    canvas.drawCircle(
      Offset(cx - radius * 0.55, cy + radius * 0.2),
      radius * 0.2,
      cheekPaint,
    );
    canvas.drawCircle(
      Offset(cx + radius * 0.55, cy + radius * 0.2),
      radius * 0.2,
      cheekPaint,
    );
  }

  void _drawFace(Canvas canvas, double cx, double cy, double radius) {
    final eyePaint = Paint()..color = const Color(0xFF2D1810);
    final eyeWhitePaint = Paint()..color = Colors.white;
    final eyeShine = Paint()..color = const Color(0xCCFFFFFF);

    final eyeY = cy - radius * 0.08;
    final eyeSpacing = radius * 0.32;
    final eyeW = radius * 0.18;
    final eyeH = suspicious ? radius * 0.12 : radius * 0.2;

    // Ojos blancos
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - eyeSpacing, eyeY),
        width: eyeW * 2.2,
        height: eyeH * 2.2,
      ),
      eyeWhitePaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + eyeSpacing, eyeY),
        width: eyeW * 2.2,
        height: eyeH * 2.2,
      ),
      eyeWhitePaint,
    );

    // Pupilas
    final pupilOffsetX = suspicious ? eyeW * 0.3 : 0.0;
    canvas.drawCircle(
      Offset(cx - eyeSpacing + pupilOffsetX, eyeY),
      eyeW * 0.7,
      eyePaint,
    );
    canvas.drawCircle(
      Offset(cx + eyeSpacing + pupilOffsetX, eyeY),
      eyeW * 0.7,
      eyePaint,
    );

    // Brillo en ojos
    canvas.drawCircle(
      Offset(cx - eyeSpacing + pupilOffsetX + 2, eyeY - 2),
      eyeW * 0.25,
      eyeShine,
    );
    canvas.drawCircle(
      Offset(cx + eyeSpacing + pupilOffsetX + 2, eyeY - 2),
      eyeW * 0.25,
      eyeShine,
    );

    // Cejas
    if (suspicious) {
      final browPaint = Paint()
        ..color = const Color(0xFF3D2010)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;

      // Ceja izquierda (levantada)
      canvas.drawLine(
        Offset(cx - eyeSpacing - eyeW, eyeY - radius * 0.22),
        Offset(cx - eyeSpacing + eyeW, eyeY - radius * 0.28),
        browPaint,
      );
      // Ceja derecha (bajada, sospechosa)
      canvas.drawLine(
        Offset(cx + eyeSpacing - eyeW, eyeY - radius * 0.28),
        Offset(cx + eyeSpacing + eyeW, eyeY - radius * 0.18),
        browPaint,
      );
    }

    // Boca — sonrisa ladina
    final mouthPaint = Paint()
      ..color = const Color(0xFF8B4513)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final mouthPath = Path();
    final mouthY = cy + radius * 0.35;
    if (suspicious) {
      mouthPath.moveTo(cx - radius * 0.2, mouthY);
      mouthPath.quadraticBezierTo(
        cx, mouthY + radius * 0.08,
        cx + radius * 0.25, mouthY - radius * 0.05,
      );
    } else {
      mouthPath.moveTo(cx - radius * 0.22, mouthY);
      mouthPath.quadraticBezierTo(
        cx, mouthY + radius * 0.15,
        cx + radius * 0.22, mouthY,
      );
    }
    canvas.drawPath(mouthPath, mouthPaint);
  }

  void _drawHat(
      Canvas canvas, double cx, double cy, double radius, double totalW) {
    final hatBrown = const Color(0xFFD4A843);
    final hatDark = const Color(0xFFB8922E);
    final hatLight = const Color(0xFFE8C35A);

    // Ala del sombrero (parte de atras - sombra)
    final brimShadow = Paint()
      ..color = const Color(0x33000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, cy - radius * 0.45),
        width: radius * 3.0,
        height: radius * 0.6,
      ),
      brimShadow,
    );

    // Copa del sombrero
    final crownPath = Path();
    final crownTop = cy - radius * 1.35;
    final crownBottom = cy - radius * 0.55;
    final crownWidth = radius * 0.85;

    crownPath.moveTo(cx - crownWidth, crownBottom);
    crownPath.lineTo(cx - crownWidth * 0.8, crownTop + radius * 0.1);
    crownPath.quadraticBezierTo(
      cx, crownTop - radius * 0.05,
      cx + crownWidth * 0.8, crownTop + radius * 0.1,
    );
    crownPath.lineTo(cx + crownWidth, crownBottom);
    crownPath.close();

    final crownPaint = Paint()..color = hatBrown;
    canvas.drawPath(crownPath, crownPaint);

    // Textura del sombrero de paja (lineas horizontales)
    final strawPaint = Paint()
      ..color = hatDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    for (var i = 0; i < 6; i++) {
      final y = crownBottom - (crownBottom - crownTop) * i / 6;
      final xOffset = crownWidth * (1 - (i / 8));
      canvas.drawLine(
        Offset(cx - xOffset, y),
        Offset(cx + xOffset, y),
        strawPaint,
      );
    }

    // Cinta del sombrero
    final bandPaint = Paint()..color = const Color(0xFF1A1A1A);
    final bandRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx, crownBottom - radius * 0.08),
        width: crownWidth * 2.05,
        height: radius * 0.14,
      ),
      const Radius.circular(2),
    );
    canvas.drawRRect(bandRect, bandPaint);

    // Ala del sombrero (brim)
    final brimPath = Path();
    final brimY = cy - radius * 0.5;

    brimPath.moveTo(cx - radius * 1.5, brimY + radius * 0.08);
    brimPath.quadraticBezierTo(
      cx - radius * 0.8, brimY + radius * 0.18,
      cx, brimY + radius * 0.12,
    );
    brimPath.quadraticBezierTo(
      cx + radius * 0.8, brimY + radius * 0.18,
      cx + radius * 1.5, brimY + radius * 0.08,
    );
    brimPath.quadraticBezierTo(
      cx + radius * 0.8, brimY - radius * 0.12,
      cx, brimY - radius * 0.08,
    );
    brimPath.quadraticBezierTo(
      cx - radius * 0.8, brimY - radius * 0.12,
      cx - radius * 1.5, brimY + radius * 0.08,
    );
    brimPath.close();

    final brimPaint = Paint()..color = hatLight;
    canvas.drawPath(brimPath, brimPaint);

    // Textura en el ala
    final brimStraw = Paint()
      ..color = hatDark.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;
    for (var i = -3; i <= 3; i++) {
      final offsetX = i * radius * 0.35;
      canvas.drawLine(
        Offset(cx + offsetX - radius * 0.1, brimY - radius * 0.05),
        Offset(cx + offsetX + radius * 0.1, brimY + radius * 0.1),
        brimStraw,
      );
    }

    // Brillo en el ala
    final shinePaint = Paint()
      ..color = const Color(0x22FFFFFF)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - radius * 0.3, brimY),
        width: radius * 0.8,
        height: radius * 0.15,
      ),
      shinePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
