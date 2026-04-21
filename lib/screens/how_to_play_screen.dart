import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants.dart';
import '../widgets/custom_button.dart';

/// Pantalla de tutorial con PageView de 6 pasos mejorada
/// con fondos coloreados y animaciones.
class HowToPlayScreen extends StatefulWidget {
  const HowToPlayScreen({super.key});

  @override
  State<HowToPlayScreen> createState() =>
      _HowToPlayScreenState();
}

class _HowToPlayScreenState
    extends State<HowToPlayScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<_TutorialStep> _steps = [
    _TutorialStep(
      icon: '👥',
      title: 'Agregar jugadores',
      description:
          'Agrega entre 3 y 12 jugadores. Cada uno '
          'tendra un turno para ver su palabra en secreto.',
      gradientColor: Color(0xFF1B5E20),
    ),
    _TutorialStep(
      icon: '📂',
      title: 'Elegir categorias',
      description:
          'Selecciona una o mas categorias de palabras. '
          'El juego elegira una palabra al azar de las '
          'categorias seleccionadas.',
      gradientColor: Color(0xFF0D47A1),
    ),
    _TutorialStep(
      icon: '🔒',
      title: 'Ver tu palabra en secreto',
      description:
          'Pasa el celular de uno en uno. Cada jugador '
          'toca la tarjeta para ver su palabra. '
          'El impostor no la conoce!',
      gradientColor: Color(0xFF4A148C),
    ),
    _TutorialStep(
      icon: '💬',
      title: 'Dar pistas con UNA palabra',
      description:
          'Se juegan varias rondas de pistas '
          '(por defecto 3). En cada ronda, cada jugador '
          'dice UNA sola palabra relacionada en voz alta.',
      gradientColor: Color(0xFFE65100),
    ),
    _TutorialStep(
      icon: '🗳️',
      title: 'Votar al impostor',
      description:
          'Despues de las rondas de pistas, todos votan '
          'a quien creen que es el impostor. '
          'Cuidado con las pistas muy obvias!',
      gradientColor: Color(0xFFB71C1C),
    ),
    _TutorialStep(
      icon: '🎉',
      title: 'Revelar resultado',
      description:
          'Se revela quien era el impostor. Si los '
          'civiles lo descubren, ganan! '
          'Si no, gana el impostor.',
      gradientColor: Color(0xFF1A237E),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
            color: AppColors.white),
          onPressed: () => Navigator.pop(context)),
        title: Text(AppStrings.howToPlay,
          style: GoogleFonts.poppins(
            color: AppColors.white,
            fontWeight: FontWeight.w600)),
      ),
      body: Column(children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: _steps.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              return _buildStepPage(
                _steps[index], index);
            },
          ),
        ),
        // Indicadores de pagina animados
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _steps.length, (i) => _buildDot(i)),
          ),
        ),
        // Boton de accion
        Padding(
          padding: const EdgeInsets.fromLTRB(32, 8, 32, 32),
          child: CustomButton(
            label: _currentPage < _steps.length - 1
                ? 'Siguiente' : 'Entendido',
            width: double.infinity,
            icon: _currentPage < _steps.length - 1
                ? Icons.arrow_forward_rounded
                : Icons.check_rounded,
            onPressed: _nextPage,
          ),
        ),
      ]),
    );
  }

  Widget _buildStepPage(_TutorialStep step, int index) {
    final isLast = index == _steps.length - 1;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Badge del paso con circulo verde
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: AppColors.green,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.green
                      .withValues(alpha: 0.3),
                  blurRadius: 12,
                  spreadRadius: 2),
              ]),
            child: Center(
              child: Text('${index + 1}',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white)),
            ),
          ).animate()
              .scale(duration: 400.ms,
                curve: Curves.elasticOut),
          const SizedBox(height: 24),
          // Emoji grande
          Text(step.icon,
            style: const TextStyle(fontSize: 72),
          ).animate(delay: 200.ms)
              .fadeIn(duration: 400.ms),
          const SizedBox(height: 24),
          // Contenedor con gradiente de fondo
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  step.gradientColor
                      .withValues(alpha: 0.2),
                  step.gradientColor
                      .withValues(alpha: 0.05),
                ]),
              borderRadius: BorderRadius.circular(
                AppDefaults.cardRadiusLarge),
              border: Border.all(
                color: step.gradientColor
                    .withValues(alpha: 0.3))),
            child: Column(children: [
              Text(step.title,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white),
                textAlign: TextAlign.center,
              ).animate(delay: 300.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.2, end: 0),
              const SizedBox(height: 12),
              Text(step.description,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.greyMedium,
                  height: 1.5),
                textAlign: TextAlign.center,
              ).animate(delay: 400.ms)
                  .fadeIn(duration: 400.ms),
            ]),
          ),
          // Animacion especial en ultima pagina
          if (isLast) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: List.generate(5, (i) => Text(
                '🎊',
                style: const TextStyle(fontSize: 24),
              ).animate(delay: Duration(
                    milliseconds: 500 + i * 150))
                  .fadeIn()
                  .slideY(
                    begin: 1.0, end: 0,
                    curve: Curves.bounceOut,
                    duration: 600.ms)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    final isActive = index == _currentPage;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 28 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.green
            : AppColors.greyLight,
        borderRadius: BorderRadius.circular(4)),
    );
  }
}

/// Modelo interno para cada paso del tutorial.
class _TutorialStep {
  final String icon;
  final String title;
  final String description;
  final Color gradientColor;

  const _TutorialStep({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradientColor,
  });
}
