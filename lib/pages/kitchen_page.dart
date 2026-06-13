import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

class KitchenPage extends StatefulWidget {
  const KitchenPage({super.key});

  @override
  State<KitchenPage> createState() => _KitchenPageState();
}

class _KitchenPageState extends State<KitchenPage> {
  KitchenMode _mode = KitchenMode.production;
  bool _isClearingReadyOrders = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final preparingOrders = provider.preparingOrders;
    final readyOrders = provider.readyOrders + provider.deliveredOrders;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final confirmed = await showExitAccessDialog(
          context,
          roleLabel: provider.activeRole?.label ?? 'acesso',
        );
        if (!confirmed || !context.mounted) return;
        await provider.logout();
      },
      child: Scaffold(
        backgroundColor: AppTheme.charcoal,
        body: Column(
          children: [
            _KitchenHeader(
              mode: _mode,
              preparingCount: preparingOrders.length,
              readyCount: readyOrders.length,
              onModeChange: (m) => setState(() => _mode = m),
              onClearReadyOrders: readyOrders.isEmpty
                  ? null
                  : () => _clearReadyOrders(context, provider),
              isClearingReadyOrders: _isClearingReadyOrders,
            ),
            Expanded(
              child: _mode == KitchenMode.production
                  ? _ProductionView(orders: preparingOrders, provider: provider)
                  : _HistoryView(orders: readyOrders),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _clearReadyOrders(
    BuildContext context,
    AppProvider provider,
  ) async {
    if (_isClearingReadyOrders) return;

    final confirmed = await showDialog<bool>(
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
                'Apagar prontos?',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.cream,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Isso remove todos os pedidos da aba Prontos.',
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
                      'VOLTAR',
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
                    child: const Text('APAGAR'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isClearingReadyOrders = true);
    final success = await provider.deleteReadyKitchenOrders();

    if (!mounted) return;
    setState(() => _isClearingReadyOrders = false);

    if (!success) {
      ScaffoldMessenger.of(this.context).showSnackBar(
        SnackBar(
          content: Text(
            provider.dataError,
            style: GoogleFonts.inter(
              color: AppTheme.cream,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: AppTheme.wine,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }
}

enum KitchenMode { production, history }

// ─── Header ────────────────────────────────────────────────────────
class _KitchenHeader extends StatelessWidget {
  final KitchenMode mode;
  final int preparingCount;
  final int readyCount;
  final ValueChanged<KitchenMode> onModeChange;
  final VoidCallback? onClearReadyOrders;
  final bool isClearingReadyOrders;

  const _KitchenHeader({
    required this.mode,
    required this.preparingCount,
    required this.readyCount,
    required this.onModeChange,
    required this.onClearReadyOrders,
    required this.isClearingReadyOrders,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: AppTheme.charcoal2,
        border: Border(
          bottom: BorderSide(color: AppTheme.charcoal3, width: 1.5),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.soup_kitchen_outlined,
              size: 20, color: AppTheme.copper),
          const SizedBox(width: 10),
          Text(
            'Cozinha',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.cream,
            ),
          ),
          const Spacer(),
          _ModeTab(
            label: '$preparingCount em Preparo',
            active: mode == KitchenMode.production,
            accentColor: AppTheme.preparing,
            onTap: () => onModeChange(KitchenMode.production),
          ),
          const SizedBox(width: 8),
          _ModeTab(
            label: '$readyCount Prontos',
            active: mode == KitchenMode.history,
            accentColor: AppTheme.sage,
            onTap: () => onModeChange(KitchenMode.history),
          ),
          const SizedBox(width: 8),
          if (mode == KitchenMode.history && onClearReadyOrders != null) ...[
            BrutalIconButton(
              icon: Icons.delete_outline,
              onTap: isClearingReadyOrders ? () {} : onClearReadyOrders!,
              filled: true,
              color: AppTheme.wine,
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  final Color accentColor;

  const _ModeTab({
    required this.label,
    required this.active,
    required this.onTap,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? accentColor.withValues(alpha: 0.15)
              : AppTheme.charcoal3.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active
                ? accentColor.withValues(alpha: 0.5)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: active ? accentColor : AppTheme.textMuted,
          ),
        ),
      ),
    );
  }
}

// ─── Production View ───────────────────────────────────────────────
class _ProductionView extends StatelessWidget {
  final List<Order> orders;
  final AppProvider provider;

  const _ProductionView({required this.orders, required this.provider});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const EmptyState(
        message: 'Nenhum pedido em preparo',
        icon: Icons.restaurant_outlined,
      );
    }

    return RefreshIndicator(
      color: AppTheme.copper,
      backgroundColor: AppTheme.charcoal2,
      onRefresh: () => provider.refreshData(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final order = orders[index];
                  return OrderCard(
                    order: order,
                    animIndex: index,
                    primaryLabel: 'MARCAR PRONTO',
                    onPrimary: () => provider.updateOrderStatus(
                      order.id,
                      OrderStatus.ready.value,
                    ),
                  );
                },
                childCount: orders.length,
              ),
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 280,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                mainAxisExtent: _cardHeightForOrders(
                  orders,
                  hasActions: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _cardHeightForOrders(List<Order> orders, {required bool hasActions}) {
    var height = hasActions ? 230.0 : 185.0;

    for (final order in orders) {
      final itemCount = order.items.length;
      final hasObservations = order.observations?.trim().isNotEmpty ?? false;
      final hasDeliveryInfo = order.deliveryAddress != null;
      final orderHeight = (hasActions ? 198.0 : 150.0) +
          (itemCount * 30.0) +
          (hasObservations ? 70.0 : 0.0) +
          (hasDeliveryInfo ? 95.0 : 0.0);

      if (orderHeight > height) height = orderHeight;
    }

    return height
        .clamp(
          hasActions ? 230.0 : 185.0,
          hasActions ? 430.0 : 360.0,
        )
        .toDouble();
  }
}

// ─── History View ──────────────────────────────────────────────────
class _HistoryView extends StatelessWidget {
  final List<Order> orders;

  const _HistoryView({required this.orders});

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const EmptyState(
        message: 'Nenhum pedido finalizado',
        icon: Icons.check_circle_outline,
      );
    }

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) => OrderCard(
                order: orders[index],
                animIndex: index,
                dimmed: true,
              ),
              childCount: orders.length,
            ),
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 260,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              mainAxisExtent: _cardHeightForOrders(
                orders,
                hasActions: false,
              ),
            ),
          ),
        ),
      ],
    );
  }

  double _cardHeightForOrders(List<Order> orders, {required bool hasActions}) {
    var height = hasActions ? 230.0 : 185.0;

    for (final order in orders) {
      final itemCount = order.items.length;
      final hasObservations = order.observations?.trim().isNotEmpty ?? false;
      final hasDeliveryInfo = order.deliveryAddress != null;
      final orderHeight = (hasActions ? 198.0 : 150.0) +
          (itemCount * 30.0) +
          (hasObservations ? 70.0 : 0.0) +
          (hasDeliveryInfo ? 95.0 : 0.0);

      if (orderHeight > height) height = orderHeight;
    }

    return height
        .clamp(
          hasActions ? 230.0 : 185.0,
          hasActions ? 430.0 : 360.0,
        )
        .toDouble();
  }
}
