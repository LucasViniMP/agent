import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../models/staff_login.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _confirmExit(context);
      },
      child: Scaffold(
        backgroundColor: AppTheme.charcoal,
        body: Stack(
          children: [
            // ── Padrão de fundo decorativo ──────────────────────────
            Positioned.fill(
              child: CustomPaint(painter: _DiamondPatternPainter()),
            ),

            // ── Gradiente de vinheta ─────────────────────────────────
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.2,
                    colors: [
                      Color(0x00000000),
                      Color(0xCC101417),
                    ],
                  ),
                ),
              ),
            ),

            // ── Conteúdo principal ───────────────────────────────────
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo
                        _RestaurantLogo()
                            .animate()
                            .fadeIn(duration: 600.ms)
                            .scale(
                              begin: const Offset(0.8, 0.8),
                              duration: 600.ms,
                              curve: Curves.easeOutBack,
                            ),

                        const SizedBox(height: 28),

                        // Nome do app
                        Text(
                          'MesaMestre',
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 52,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                            height: 1,
                            color: AppTheme.cream,
                          ),
                        )
                            .animate()
                            .fadeIn(delay: 200.ms, duration: 500.ms)
                            .slideY(begin: 0.2, end: 0),

                        const SizedBox(height: 10),

                        // Divisor cobre
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                                width: 32, height: 1, color: AppTheme.copper),
                            const SizedBox(width: 12),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.copper,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                                width: 32, height: 1, color: AppTheme.copper),
                          ],
                        ).animate().fadeIn(delay: 350.ms, duration: 400.ms),

                        const SizedBox(height: 10),

                        Text(
                          'GESTÃO PROFISSIONAL DE RESTAURANTES',
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 3,
                            color: AppTheme.textMuted,
                          ),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(delay: 400.ms, duration: 400.ms),

                        const SizedBox(height: 64),

                        // Título seção
                        Text(
                          'Selecione seu perfil',
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textLight,
                            letterSpacing: 0.5,
                          ),
                        ).animate().fadeIn(delay: 500.ms, duration: 400.ms),

                        const SizedBox(height: 24),

                        // Role Cards
                        LayoutBuilder(builder: (context, constraints) {
                          final compact = constraints.maxWidth < 420;
                          final gap = compact ? 8.0 : 14.0;

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: staffLogins
                                .asMap()
                                .entries
                                .map((e) => Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          left: e.key > 0 ? gap : 0,
                                        ),
                                        child: _RoleCard(
                                          login: e.value,
                                          animIndex: e.key,
                                          compact: compact,
                                        ),
                                      ),
                                    ))
                                .toList(),
                          );
                        }),

                        const SizedBox(height: 56),

                        // Versão
                        GestureDetector(
                          onLongPress: () => _showServerConfig(context),
                          child: Text(
                            'v1.0.0',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.5,
                              color: AppTheme.charcoal3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmExit(BuildContext context) async {
    FocusManager.instance.primaryFocus?.unfocus();

    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppTheme.charcoal2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppTheme.charcoal3, width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sair do aplicativo?',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.cream,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Voce realmente deseja sair do aplicativo?',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppTheme.textLight,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: Text(
                      'CANCELAR',
                      style: GoogleFonts.inter(
                        color: AppTheme.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.wine,
                      foregroundColor: AppTheme.cream,
                    ),
                    child: const Text('SIM'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (shouldExit == true) {
      SystemNavigator.pop();
    }
  }

  void _showServerConfig(BuildContext context) {
    final controller = TextEditingController(text: 'http://localhost:3001/api');

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppTheme.charcoal2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppTheme.charcoal3, width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Configuração do Servidor',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.cream,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'URL DA API',
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                style: GoogleFonts.inter(fontSize: 13, color: AppTheme.cream),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(
                      'CANCELAR',
                      style: GoogleFonts.inter(
                        color: AppTheme.textMuted,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () async {
                      await context.read<AppProvider>().init();
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    child: const Text('SALVAR'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Logo do restaurante ──────────────────────────────────────────
class _RestaurantLogo extends StatelessWidget {
  const _RestaurantLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppTheme.copperGradient,
        boxShadow: AppTheme.copperGlow,
      ),
      alignment: Alignment.center,
      child: Text(
        'MM',
        style: GoogleFonts.cormorantGaramond(
          color: AppTheme.charcoal,
          fontSize: 30,
          fontWeight: FontWeight.w700,
          fontStyle: FontStyle.italic,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

// ── Card de seleção de papel ─────────────────────────────────────
class _RoleCard extends StatefulWidget {
  final StaffLogin login;
  final int animIndex;
  final bool compact;

  const _RoleCard({
    required this.login,
    this.animIndex = 0,
    this.compact = false,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> {
  bool _hovered = false;

  IconData get _icon {
    switch (widget.login.role) {
      case AppRole.waiter:
        return Icons.room_service_outlined;
      case AppRole.kitchen:
        return Icons.soup_kitchen_outlined;
      case AppRole.counter:
        return Icons.point_of_sale_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: [
        FadeEffect(duration: 400.ms, delay: (400 + widget.animIndex * 100).ms),
        SlideEffect(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
          duration: 400.ms,
          delay: (400 + widget.animIndex * 100).ms,
          curve: Curves.easeOutCubic,
        ),
      ],
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: () =>
              context.read<AppProvider>().selectRole(widget.login.role),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              vertical: widget.compact ? 18 : 24,
              horizontal: widget.compact ? 8 : 14,
            ),
            decoration: BoxDecoration(
              color: _hovered
                  ? AppTheme.copper.withValues(alpha: 0.12)
                  : AppTheme.charcoal2,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _hovered ? AppTheme.copper : AppTheme.charcoal3,
                width: 1.5,
              ),
              boxShadow: _hovered ? AppTheme.copperGlow : AppTheme.subtleShadow,
            ),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.all(widget.compact ? 11 : 14),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _hovered
                        ? AppTheme.copper.withValues(alpha: 0.2)
                        : AppTheme.charcoal3.withValues(alpha: 0.4),
                  ),
                  child: Icon(
                    _icon,
                    size: widget.compact ? 24 : 28,
                    color: _hovered ? AppTheme.copper : AppTheme.textMuted,
                  ),
                ),
                SizedBox(height: widget.compact ? 12 : 16),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    widget.login.role.label,
                    maxLines: 1,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: widget.compact ? 16 : 18,
                      fontWeight: FontWeight.w700,
                      color: _hovered ? AppTheme.copper : AppTheme.cream,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                SizedBox(height: widget.compact ? 8 : 10),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: 2,
                  width: _hovered ? 40 : 16,
                  decoration: BoxDecoration(
                    color: _hovered ? AppTheme.copper : AppTheme.charcoal3,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Pintor do padrão de losangos decorativos ──────────────────────
class _DiamondPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x082DD4BF)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    const spacing = 40.0;
    for (double x = -spacing; x < size.width + spacing; x += spacing) {
      for (double y = -spacing; y < size.height + spacing; y += spacing) {
        final path = Path()
          ..moveTo(x, y - 14)
          ..lineTo(x + 14, y)
          ..lineTo(x, y + 14)
          ..lineTo(x - 14, y)
          ..close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DiamondPatternPainter oldDelegate) => false;
}
