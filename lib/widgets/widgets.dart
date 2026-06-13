import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

// ─── ORDER CARD (Cozinha / Caixa) ────────────────────────────────
Future<bool> showExitAccessDialog(
  BuildContext context, {
  required String roleLabel,
}) async {
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
              'Sair do acesso?',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.cream,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Deseja sair do acesso de $roleLabel?',
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

  return confirmed ?? false;
}

class OrderCard extends StatelessWidget {
  final Order order;
  final String? primaryLabel;
  final String? secondaryLabel;
  final VoidCallback? onPrimary;
  final VoidCallback? onSecondary;
  final VoidCallback? onMapTap;
  final bool dimmed;
  final int animIndex;

  const OrderCard({
    super.key,
    required this.order,
    this.primaryLabel,
    this.secondaryLabel,
    this.onPrimary,
    this.onSecondary,
    this.onMapTap,
    this.dimmed = false,
    this.animIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final observations = order.observations?.trim() ?? '';
    final address = order.deliveryAddress;
    final headerLabel = order.isOnline
        ? 'ONLINE'
        : order.isDelivery
            ? 'ENTREGA'
            : 'MESA ${order.table?.number ?? '--'}';

    return Animate(
      effects: [
        FadeEffect(duration: 300.ms, delay: (animIndex * 50).ms),
        SlideEffect(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
          duration: 300.ms,
          delay: (animIndex * 50).ms,
        ),
      ],
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: dimmed ? 0.4 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.charcoal2,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.charcoal3, width: 1.5),
            boxShadow: AppTheme.subtleShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header do card
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppTheme.charcoal3, width: 1.5),
                  ),
                ),
                child: Row(
                  children: [
                    // Número da mesa
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.copper.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: AppTheme.copper.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          headerLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                            color: AppTheme.copper,
                          ),
                        ),
                      ),
                    ),
                    if (order.isOnline) ...[
                      const SizedBox(width: 6),
                      _PaymentChip(status: order.paymentStatus),
                    ],
                    const SizedBox(width: 8),
                    Flexible(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: _StatusChip(status: order.status),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Lista de itens
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (address != null)
                        _DeliveryAddressPanel(
                          address: address,
                          onMapTap: onMapTap,
                        ),
                      ...order.items.map((item) => _OrderItemRow(item: item)),
                      if (observations.isNotEmpty)
                        _OrderObservation(text: observations),
                    ],
                  ),
                ),
              ),

              // Linha de total
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppTheme.charcoal3, width: 1.5),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      'TOTAL',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'R\$ ${order.total.toStringAsFixed(2)}',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.cream,
                      ),
                    ),
                  ],
                ),
              ),

              // Botões de ação
              if (primaryLabel != null || secondaryLabel != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Row(
                    children: [
                      if (secondaryLabel != null)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: _ActionButton(
                              label: secondaryLabel!,
                              onTap: onSecondary,
                              outlined: true,
                            ),
                          ),
                        ),
                      if (primaryLabel != null)
                        Expanded(
                          child: _ActionButton(
                            label: primaryLabel!,
                            onTap: onPrimary,
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentChip extends StatelessWidget {
  final PaymentStatus status;

  const _PaymentChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final paid = status == PaymentStatus.paid;
    final color = paid ? AppTheme.sage : AppTheme.amber;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.42)),
      ),
      child: Text(
        paid ? 'PAGO' : 'PAGAR',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.inter(
          fontSize: 8,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
          color: color,
        ),
      ),
    );
  }
}

class _DeliveryAddressPanel extends StatelessWidget {
  final DeliveryAddress address;
  final VoidCallback? onMapTap;

  const _DeliveryAddressPanel({
    required this.address,
    this.onMapTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.charcoal3.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.charcoal3, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.delivery_dining_outlined,
                size: 14,
                color: AppTheme.copper,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  address.customerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.cream,
                  ),
                ),
              ),
              if (onMapTap != null && address.hasCoordinates)
                GestureDetector(
                  onTap: onMapTap,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.copper.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.copper.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      'MAPA',
                      style: GoogleFonts.inter(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: AppTheme.copper,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            address.shortAddress,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.textLight,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            address.fullAddress,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppTheme.textMuted,
              height: 1.35,
            ),
          ),
          if (address.phone.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              address.phone,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppTheme.copperLight,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _OrderItemRow extends StatelessWidget {
  final OrderItem item;
  const _OrderItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppTheme.copper.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.center,
            child: Text(
              '${item.quantity}',
              style: GoogleFonts.inter(
                color: AppTheme.copper,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item.product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.textLight,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'R\$ ${item.subtotal.toStringAsFixed(2)}',
            maxLines: 1,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderObservation extends StatelessWidget {
  final String text;

  const _OrderObservation({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.copper.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.copper.withValues(alpha: 0.22)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.sticky_note_2_outlined,
                size: 13,
                color: AppTheme.copper.withValues(alpha: 0.85),
              ),
              const SizedBox(width: 6),
              Text(
                'OBS',
                style: GoogleFonts.inter(
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: AppTheme.copper,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            text,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppTheme.textLight,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final OrderStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.statusColor(status.value);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            AppTheme.statusLabel(status.value),
            style: GoogleFonts.inter(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── ACTION BUTTON (interno) ──────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool outlined;

  const _ActionButton({required this.label, this.onTap, this.outlined = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : AppTheme.copper,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: outlined ? AppTheme.charcoal3 : AppTheme.copper,
            width: 1.5,
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label.toUpperCase(),
            maxLines: 1,
            style: GoogleFonts.inter(
              color: outlined ? AppTheme.textMuted : AppTheme.charcoal,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── TABLE CARD (Garçom) ──────────────────────────────────────────
class TableCard extends StatelessWidget {
  final RestaurantTable table;
  final VoidCallback onTap;
  final int animIndex;

  const TableCard({
    super.key,
    required this.table,
    required this.onTap,
    this.animIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final occupied = table.status == TableStatus.occupied;
    final reserved = table.status == TableStatus.reserved;

    return Animate(
      effects: [
        FadeEffect(duration: 250.ms, delay: (animIndex * 40).ms),
        ScaleEffect(
          begin: const Offset(0.88, 0.88),
          end: const Offset(1, 1),
          duration: 300.ms,
          delay: (animIndex * 40).ms,
          curve: Curves.easeOutBack,
        ),
      ],
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          decoration: BoxDecoration(
            color: occupied
                ? AppTheme.copper.withValues(alpha: 0.12)
                : reserved
                    ? AppTheme.wine.withValues(alpha: 0.10)
                    : AppTheme.charcoal2,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: occupied
                  ? AppTheme.copper.withValues(alpha: 0.6)
                  : reserved
                      ? AppTheme.wine.withValues(alpha: 0.5)
                      : AppTheme.charcoal3,
              width: 1.5,
            ),
            boxShadow: occupied ? AppTheme.copperGlow : AppTheme.subtleShadow,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ícone de mesa
              Icon(
                Icons.table_restaurant_outlined,
                size: 26,
                color: occupied
                    ? AppTheme.copper
                    : reserved
                        ? AppTheme.wine
                        : AppTheme.charcoal3,
              ),
              const SizedBox(height: 8),
              // Número da mesa
              Text(
                table.number,
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: occupied
                      ? AppTheme.cream
                      : reserved
                          ? AppTheme.cream
                          : AppTheme.textMuted,
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: occupied
                      ? AppTheme.copper.withValues(alpha: 0.2)
                      : reserved
                          ? AppTheme.wine.withValues(alpha: 0.2)
                          : AppTheme.charcoal3.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  occupied
                      ? 'OCUPADA'
                      : reserved
                          ? 'RESERVADA'
                          : 'LIVRE',
                  style: GoogleFonts.inter(
                    fontSize: 7,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: occupied
                        ? AppTheme.copper
                        : reserved
                            ? AppTheme.wine
                            : AppTheme.textMuted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── STAT CARD ────────────────────────────────────────────────────
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color? accentColor;
  final IconData? icon;
  final int animIndex;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.accentColor,
    this.icon,
    this.animIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? AppTheme.copper;
    return Animate(
      effects: [
        FadeEffect(duration: 300.ms, delay: (animIndex * 80).ms),
        SlideEffect(
          begin: const Offset(0, 0.12),
          end: Offset.zero,
          duration: 350.ms,
          delay: (animIndex * 80).ms,
        ),
      ],
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.charcoal2,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.charcoal3, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 3,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                if (icon != null) ...[
                  const Spacer(),
                  Icon(icon, size: 16, color: accent.withValues(alpha: 0.6)),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: GoogleFonts.cormorantGaramond(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                letterSpacing: -1,
                height: 1,
                color: AppTheme.cream,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── SECTION LABEL ────────────────────────────────────────────────
class SectionLabel extends StatelessWidget {
  final String text;
  final Widget? trailing;

  const SectionLabel({super.key, required this.text, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: AppTheme.copper,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          text.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: AppTheme.textMuted,
          ),
        ),
        if (trailing != null) ...[const Spacer(), trailing!],
      ],
    );
  }
}

// ─── EMPTY STATE ──────────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;

  const EmptyState({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.charcoal2,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.charcoal3, width: 1.5),
            ),
            child: Icon(icon, size: 36, color: AppTheme.charcoal3),
          ),
          const SizedBox(height: 20),
          Text(
            message,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 18,
              color: AppTheme.textMuted,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}

// ─── BRUTAL TEXT FIELD (rebatizado) ──────────────────────────────
class BrutalTextField extends StatelessWidget {
  final String label;
  final bool obscureText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final int? maxLines;
  final String? hintText;

  const BrutalTextField({
    super.key,
    required this.label,
    this.obscureText = false,
    this.controller,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
            color: AppTheme.textMuted,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          maxLines: maxLines,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: AppTheme.cream,
          ),
          decoration: InputDecoration(
            hintText: hintText,
          ),
        ),
      ],
    );
  }
}

// ─── LOADING OVERLAY ──────────────────────────────────────────────
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.charcoal.withValues(alpha: 0.75),
      child: const Center(
        child: CircularProgressIndicator(
          color: AppTheme.copper,
          strokeWidth: 3,
        ),
      ),
    );
  }
}

// ─── ICON BUTTON TEMÁTICO ─────────────────────────────────────────
class BrutalIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;
  final Color? color;

  const BrutalIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.filled = true,
    this.color,
  });

  @override
  State<BrutalIconButton> createState() => _BrutalIconButtonState();
}

class _BrutalIconButtonState extends State<BrutalIconButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.color ?? AppTheme.copper;
    final bg = widget.filled
        ? (activeColor)
        : (_pressed ? activeColor.withValues(alpha: 0.12) : Colors.transparent);
    final fg = widget.filled ? AppTheme.charcoal : activeColor;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: widget.filled
              ? null
              : Border.all(color: AppTheme.charcoal3, width: 1.5),
        ),
        alignment: Alignment.center,
        child: Icon(widget.icon, color: fg, size: 18),
      ),
    );
  }
}
