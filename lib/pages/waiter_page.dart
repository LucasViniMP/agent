import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

class WaiterPage extends StatefulWidget {
  const WaiterPage({super.key});

  @override
  State<WaiterPage> createState() => _WaiterPageState();
}

class _WaiterPageState extends State<WaiterPage> {
  final Set<String> _selectedTableIds = {};
  bool _selectionMode = false;
  bool _isDeleting = false;

  void _toggleSelectionMode() {
    setState(() {
      _selectionMode = !_selectionMode;
      if (!_selectionMode) _selectedTableIds.clear();
    });
  }

  void _toggleTableSelection(RestaurantTable table) {
    setState(() {
      if (_selectedTableIds.contains(table.id)) {
        _selectedTableIds.remove(table.id);
      } else {
        _selectedTableIds.add(table.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final tables = provider.tables;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (_selectionMode) {
          _toggleSelectionMode();
          return;
        }
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
            _WaiterHeader(
              freeTables: provider.freeTables.length,
              occupiedTables: provider.occupiedTables.length,
              selectionMode: _selectionMode,
              selectedCount: _selectedTableIds.length,
              isDeleting: _isDeleting,
              onCreateTables: () => _showCreateTablesDialog(context),
              onToggleSelectionMode: _toggleSelectionMode,
              onDeleteSelected: () => _deleteSelectedTables(context),
            ),
            Expanded(
              child: _TableGrid(
                tables: tables,
                provider: provider,
                selectionMode: _selectionMode,
                selectedTableIds: _selectedTableIds,
                onToggleSelection: _toggleTableSelection,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCreateTablesDialog(BuildContext context) async {
    final quantity = await showDialog<int>(
      context: context,
      builder: (_) => const _CreateTablesDialog(),
    );

    if (quantity == null || !context.mounted) return;

    final provider = context.read<AppProvider>();
    final success = await provider.createTablesUpTo(quantity);

    if (!context.mounted) return;
    if (!success) {
      _showResultSnack(
        context,
        provider.dataError,
        success: false,
      );
    }
  }

  Future<void> _deleteSelectedTables(BuildContext context) async {
    if (_selectedTableIds.isEmpty) {
      _showResultSnack(
        context,
        'Selecione pelo menos uma mesa.',
        success: false,
      );
      return;
    }

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
                'Apagar mesas?',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.cream,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Voce selecionou ${_selectedTableIds.length} mesa${_selectedTableIds.length > 1 ? 's' : ''}.',
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

    if (confirmed != true || !context.mounted) return;

    setState(() => _isDeleting = true);
    final provider = context.read<AppProvider>();
    final success = await provider.deleteTables(Set.of(_selectedTableIds));

    if (!mounted) return;
    setState(() {
      _isDeleting = false;
      if (success) {
        _selectionMode = false;
        _selectedTableIds.clear();
      }
    });

    _showResultSnack(
      this.context,
      success ? 'Mesas apagadas.' : provider.dataError,
      success: success,
    );
  }

  void _showResultSnack(
    BuildContext context,
    String message, {
    required bool success,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(
            color: AppTheme.cream,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: success ? AppTheme.charcoal2 : AppTheme.wine,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

// ─── Header ────────────────────────────────────────────────────────
class _CreateTablesDialog extends StatefulWidget {
  const _CreateTablesDialog();

  @override
  State<_CreateTablesDialog> createState() => _CreateTablesDialogState();
}

class _CreateTablesDialogState extends State<_CreateTablesDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_submitted) return;
    _submitted = true;

    final quantity = int.tryParse(_controller.text.trim());
    FocusManager.instance.primaryFocus?.unfocus();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pop(quantity);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
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
              'Criar mesas',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.cream,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Digite a quantidade total de mesas.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppTheme.textLight,
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: AppTheme.cream,
                fontWeight: FontWeight.w600,
              ),
              decoration: const InputDecoration(
                hintText: 'Quantidade de mesas',
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
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
                  onPressed: _submit,
                  child: const Text('CRIAR'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WaiterHeader extends StatelessWidget {
  final int freeTables;
  final int occupiedTables;
  final bool selectionMode;
  final int selectedCount;
  final bool isDeleting;
  final VoidCallback onCreateTables;
  final VoidCallback onToggleSelectionMode;
  final VoidCallback onDeleteSelected;

  const _WaiterHeader({
    required this.freeTables,
    required this.occupiedTables,
    required this.selectionMode,
    required this.selectedCount,
    required this.isDeleting,
    required this.onCreateTables,
    required this.onToggleSelectionMode,
    required this.onDeleteSelected,
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
          Text(
            'Salão',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.cream,
            ),
          ),
          const Spacer(),
          if (selectionMode)
            Flexible(
              child: Text(
                '$selectedCount selecionada${selectedCount == 1 ? '' : 's'}',
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: GoogleFonts.inter(
                  color: AppTheme.copper,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          else ...[
            _TableStat(
              value: freeTables,
              label: 'LIVRES',
              color: AppTheme.sage,
            ),
            const SizedBox(width: 10),
            _TableStat(
              value: occupiedTables,
              label: 'OCUPADAS',
              color: AppTheme.copper,
            ),
          ],
          const SizedBox(width: 8),
          if (selectionMode) ...[
            BrutalIconButton(
              icon: Icons.delete_outline,
              onTap: isDeleting ? () {} : onDeleteSelected,
              filled: true,
              color: AppTheme.wine,
            ),
            const SizedBox(width: 8),
            BrutalIconButton(
              icon: Icons.close,
              onTap: isDeleting ? () {} : onToggleSelectionMode,
              filled: false,
            ),
          ] else ...[
            BrutalIconButton(
              icon: Icons.add,
              onTap: onCreateTables,
              filled: false,
            ),
            const SizedBox(width: 8),
            BrutalIconButton(
              icon: Icons.delete_outline,
              onTap: onToggleSelectionMode,
              filled: false,
              color: AppTheme.wine,
            ),
          ],
        ],
      ),
    );
  }
}

class _TableStat extends StatelessWidget {
  final int value;
  final String label;
  final Color color;

  const _TableStat({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$value',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 20,
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
              letterSpacing: 1.5,
              color: color.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Table Grid ────────────────────────────────────────────────────
class _TableGrid extends StatelessWidget {
  final List<RestaurantTable> tables;
  final AppProvider provider;
  final bool selectionMode;
  final Set<String> selectedTableIds;
  final ValueChanged<RestaurantTable> onToggleSelection;

  const _TableGrid({
    required this.tables,
    required this.provider,
    required this.selectionMode,
    required this.selectedTableIds,
    required this.onToggleSelection,
  });

  @override
  Widget build(BuildContext context) {
    if (tables.isEmpty) {
      return const EmptyState(
        message: 'Nenhuma mesa cadastrada',
        icon: Icons.table_restaurant_outlined,
      );
    }

    return RefreshIndicator(
      color: AppTheme.copper,
      backgroundColor: AppTheme.charcoal2,
      onRefresh: () => provider.refreshData(),
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 110,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: tables.length,
        itemBuilder: (context, index) {
          final table = tables[index];
          final selected = selectedTableIds.contains(table.id);

          return Stack(
            children: [
              Positioned.fill(
                child: TableCard(
                  table: table,
                  animIndex: index,
                  onTap: selectionMode
                      ? () => onToggleSelection(table)
                      : () => _openTableModal(context, table),
                ),
              ),
              if (selectionMode)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? AppTheme.copper : AppTheme.charcoal2,
                      border: Border.all(
                        color: selected ? AppTheme.copper : AppTheme.charcoal3,
                        width: 1.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      selected ? Icons.check : Icons.circle_outlined,
                      size: 14,
                      color: selected ? AppTheme.charcoal : AppTheme.textMuted,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _openTableModal(BuildContext context, RestaurantTable table) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _OrderModal(table: table, provider: provider),
    );
  }
}

// ─── Order Modal ───────────────────────────────────────────────────
class _OrderModal extends StatefulWidget {
  final RestaurantTable table;
  final AppProvider provider;

  const _OrderModal({required this.table, required this.provider});

  @override
  State<_OrderModal> createState() => _OrderModalState();
}

class _OrderModalState extends State<_OrderModal> {
  final Map<String, int> _cart = {};
  final _obsController = TextEditingController();
  bool _isSending = false;

  AppProvider get provider => widget.provider;
  RestaurantTable get table => widget.table;

  @override
  void dispose() {
    _obsController.dispose();
    super.dispose();
  }

  double get _total {
    double t = 0;
    for (final entry in _cart.entries) {
      final product = provider.products.firstWhere(
        (p) => p.id == entry.key,
        orElse: () => Product(
          id: '',
          name: '',
          price: 0,
          category: Category(id: '', name: ''),
        ),
      );
      t += product.price * entry.value;
    }
    return t;
  }

  int _cartCount() => _cart.values.fold(0, (a, b) => a + b);

  void _add(Product product) =>
      setState(() => _cart[product.id] = (_cart[product.id] ?? 0) + 1);

  void _remove(Product product) {
    setState(() {
      if ((_cart[product.id] ?? 0) > 1) {
        _cart[product.id] = _cart[product.id]! - 1;
      } else {
        _cart.remove(product.id);
      }
    });
  }

  Future<void> _sendOrder() async {
    if (_cart.isEmpty) return;
    setState(() => _isSending = true);

    final items = _cart.entries
        .map((e) => {'productId': e.key, 'quantity': e.value})
        .toList();

    final success = await provider.createOrder(
      displayId: 'M-${table.number}',
      tableId: table.id,
      items: items,
      observations: _obsController.text,
    );

    if (mounted) {
      setState(() => _isSending = false);
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline,
                    color: AppTheme.sage, size: 18),
                const SizedBox(width: 10),
                Text(
                  'Pedido enviado com sucesso!',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppTheme.cream,
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.charcoal2,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            margin: const EdgeInsets.all(16),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.dataError,
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600, fontSize: 13)),
            backgroundColor: AppTheme.wine,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  Future<void> _closeAccount() async {
    final confirmed = await showDialog<bool>(
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
                'Fechar conta?',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.cream,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Deseja fechar a conta da Mesa ${table.number}? Certifique-se que todos os pedidos foram entregues.',
                style:
                    GoogleFonts.inter(fontSize: 13, color: AppTheme.textLight),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: Text('CANCELAR',
                        style: GoogleFonts.inter(
                            color: AppTheme.textMuted,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                            letterSpacing: 1)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.wine,
                        foregroundColor: AppTheme.cream),
                    child: const Text('FECHAR CONTA'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true && mounted) {
      final success = await provider.closeTableAccount(table.id);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Conta fechada com sucesso.' : provider.dataError,
              style: GoogleFonts.inter(color: AppTheme.cream),
            ),
            backgroundColor: success ? AppTheme.charcoal2 : AppTheme.wine,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsByCategory = provider.productsByCategory;
    final screenH = MediaQuery.of(context).size.height;
    final occupied = table.status == TableStatus.occupied;

    return Container(
      height: screenH * 0.92,
      decoration: BoxDecoration(
        color: AppTheme.charcoal2,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: const Border(
          top: BorderSide(color: AppTheme.copper, width: 2),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.charcoal3,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Modal Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: AppTheme.charcoal3, width: 1.5)),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mesa ${table.number}',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.cream,
                      ),
                    ),
                    Text(
                      occupied ? 'OCUPADA' : 'LIVRE',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                        color: occupied ? AppTheme.copper : AppTheme.sage,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                if (occupied)
                  GestureDetector(
                    onTap: _closeAccount,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.wine.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppTheme.wine.withValues(alpha: 0.4),
                            width: 1.5),
                      ),
                      child: Text(
                        'FECHAR CONTA',
                        style: GoogleFonts.inter(
                          color: AppTheme.wine,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(width: 10),
                BrutalIconButton(
                  icon: Icons.close,
                  onTap: () => Navigator.pop(context),
                  filled: false,
                ),
              ],
            ),
          ),

          // Product List
          Expanded(
            child: productsByCategory.isEmpty
                ? Center(
                    child: Text(
                      'Carregando cardápio...',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 18,
                        color: AppTheme.textMuted,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: productsByCategory.entries.map((entry) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12, top: 8),
                            child: Row(
                              children: [
                                Container(
                                    width: 3,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: AppTheme.copper,
                                      borderRadius: BorderRadius.circular(2),
                                    )),
                                const SizedBox(width: 8),
                                Text(
                                  entry.key.toUpperCase(),
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 2,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: entry.value.length,
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 200,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 2.2,
                            ),
                            itemBuilder: (context, index) {
                              final product = entry.value[index];
                              final qty = _cart[product.id] ?? 0;
                              return _ProductItem(
                                product: product,
                                quantity: qty,
                                onAdd: () => _add(product),
                                onRemove: () => _remove(product),
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                        ],
                      );
                    }).toList(),
                  ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppTheme.charcoal2,
              border: Border(
                  top: BorderSide(color: AppTheme.charcoal3, width: 1.5)),
            ),
            child: Column(
              children: [
                // Observações
                TextField(
                  controller: _obsController,
                  maxLines: 2,
                  style: GoogleFonts.inter(
                      fontSize: 13, color: AppTheme.textLight),
                  decoration: InputDecoration(
                    hintText: 'Observações do pedido...',
                    hintStyle: GoogleFonts.inter(
                        color: AppTheme.charcoal3,
                        fontSize: 13,
                        fontStyle: FontStyle.italic),
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    // Total
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.charcoal3.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TOTAL',
                            style: GoogleFonts.inter(
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2,
                              color: AppTheme.textMuted,
                            ),
                          ),
                          Text(
                            'R\$ ${_total.toStringAsFixed(2)}',
                            style: GoogleFonts.cormorantGaramond(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.cream,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Botão enviar
                    Expanded(
                      child: GestureDetector(
                        onTap:
                            _cartCount() > 0 && !_isSending ? _sendOrder : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: _cartCount() > 0
                                ? AppTheme.copperGradient
                                : null,
                            color: _cartCount() > 0
                                ? null
                                : AppTheme.charcoal3.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: _isSending
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: AppTheme.charcoal,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.send_rounded,
                                      size: 16,
                                      color: _cartCount() > 0
                                          ? AppTheme.charcoal
                                          : AppTheme.textMuted,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'ENVIAR PEDIDO',
                                      style: GoogleFonts.inter(
                                        color: _cartCount() > 0
                                            ? AppTheme.charcoal
                                            : AppTheme.textMuted,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                    if (_cartCount() > 0) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        width: 22,
                                        height: 22,
                                        decoration: BoxDecoration(
                                          color: AppTheme.charcoal,
                                          shape: BoxShape.circle,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          '${_cartCount()}',
                                          style: GoogleFonts.inter(
                                            color: AppTheme.copper,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Product Item ──────────────────────────────────────────────────
class _ProductItem extends StatelessWidget {
  final Product product;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _ProductItem({
    required this.product,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final selected = quantity > 0;
    return GestureDetector(
      onTap: onAdd,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.copper.withValues(alpha: 0.15)
              : AppTheme.charcoal3.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? AppTheme.copper.withValues(alpha: 0.6)
                : AppTheme.charcoal3,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    product.name,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: selected ? AppTheme.cream : AppTheme.textLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'R\$ ${product.price.toStringAsFixed(2)}',
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      color: selected ? AppTheme.copper : AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            if (selected) ...[
              GestureDetector(
                onTap: onRemove,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: AppTheme.charcoal3,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '−',
                    style: GoogleFonts.inter(
                      color: AppTheme.textLight,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '$quantity',
                style: GoogleFonts.cormorantGaramond(
                  color: AppTheme.copper,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  height: 1,
                ),
              ),
              const SizedBox(width: 4),
            ] else
              Icon(Icons.add, size: 18, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }
}
