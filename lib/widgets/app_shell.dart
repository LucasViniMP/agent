import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../pages/kitchen_page.dart';
import '../pages/counter_page.dart';
import '../pages/waiter_page.dart';
import 'app_sidebar.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final role = provider.activeRole;

    return Scaffold(
      backgroundColor: AppTheme.charcoal,
      drawer: const AppSidebar(),
      body: SafeArea(
        child: Column(
          children: [
            _AppHeader(role: role),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _buildView(role, provider),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildView(AppRole? role, AppProvider provider) {
    if (provider.dataState == AppState.loading && provider.orders.isEmpty) {
      return Center(
        key: const ValueKey('loading'),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: AppTheme.copper,
              strokeWidth: 2.5,
            ),
            const SizedBox(height: 20),
            Text(
              'Carregando...',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 18,
                color: AppTheme.textMuted,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    switch (role) {
      case AppRole.kitchen:
        return const KitchenPage(key: ValueKey('kitchen'));
      case AppRole.counter:
        return const CounterPage(key: ValueKey('counter'));
      case AppRole.waiter:
        return const WaiterPage(key: ValueKey('waiter'));
      default:
        return const SizedBox.shrink();
    }
  }
}

// ─── App Header ────────────────────────────────────────────────────
class _AppHeader extends StatelessWidget {
  final AppRole? role;
  const _AppHeader({this.role});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppTheme.charcoal2,
        border: Border(
          bottom: BorderSide(color: AppTheme.charcoal3, width: 1.5),
        ),
      ),
      child: Row(
        children: [
          // Botão hamburguer
          Builder(
            builder: (ctx) => GestureDetector(
              onTap: () => Scaffold.of(ctx).openDrawer(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.copper.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppTheme.copper.withValues(alpha: 0.3), width: 1.5),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.menu_rounded,
                    color: AppTheme.copper, size: 20),
              ),
            ),
          ),

          const SizedBox(width: 14),

          // Logo + título da role
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                role?.label ?? 'MesaMestre',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.cream,
                  letterSpacing: 0.3,
                ),
              ),
              Text(
                'MESAMESTRE',
                style: GoogleFonts.inter(
                  fontSize: 7,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Badges por role
          if (role == AppRole.kitchen) ...[
            _HeaderBadge(
              count: provider.preparingOrders.length,
              label: 'PREPARO',
              color: AppTheme.preparing,
            ),
            const SizedBox(width: 8),
            _HeaderBadge(
              count: provider.readyOrders.length,
              label: 'PRONTOS',
              color: AppTheme.sage,
            ),
          ] else if (role == AppRole.counter) ...[
            _HeaderBadge(
              count: provider.pendingOrders.length,
              label: 'PENDENTES',
              color: AppTheme.amber,
            ),
            const SizedBox(width: 8),
            _HeaderBadge(
              count: provider.readyOrders.length,
              label: 'PRONTOS',
              color: AppTheme.sage,
            ),
          ] else if (role == AppRole.waiter) ...[
            _HeaderBadge(
              count: provider.freeTables.length,
              label: 'LIVRES',
              color: AppTheme.sage,
            ),
            const SizedBox(width: 8),
            _HeaderBadge(
              count: provider.occupiedTables.length,
              label: 'OCUPADAS',
              color: AppTheme.copper,
            ),
          ],

          const SizedBox(width: 8),
          _ConnectionDot(),
        ],
      ),
    );
  }
}

class _HeaderBadge extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const _HeaderBadge({
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$count',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
              height: 1,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 7,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: color.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Indicador de conexão pulsante ────────────────────────────────
class _ConnectionDot extends StatefulWidget {
  @override
  State<_ConnectionDot> createState() => _ConnectionDotState();
}

class _ConnectionDotState extends State<_ConnectionDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.sage.withValues(alpha: _animation.value),
          boxShadow: [
            BoxShadow(
              color: AppTheme.sage.withValues(alpha: _animation.value * 0.4),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}
