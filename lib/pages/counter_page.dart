import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/app_provider.dart';
import '../services/map_service.dart';
import '../theme/app_theme.dart';
import '../widgets/delivery_map_sheet.dart';
import '../widgets/widgets.dart';

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final pendingOrders = provider.pendingOrders;
    final readyOrders = provider.readyOrders;

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
            _CounterHeader(
              pendingCount: pendingOrders.length,
              readyCount: readyOrders.length,
              onCreateDelivery: () => _openDeliveryOrderSheet(context, provider),
            ),
            Expanded(
              child: _CounterBody(
                pendingOrders: pendingOrders,
                readyOrders: readyOrders,
                provider: provider,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDeliveryOrderSheet(BuildContext context, AppProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DeliveryOrderSheet(provider: provider),
    );
  }
}

// ─── Header ────────────────────────────────────────────────────────
class _CounterHeader extends StatelessWidget {
  final int pendingCount;
  final int readyCount;
  final VoidCallback onCreateDelivery;

  const _CounterHeader({
    required this.pendingCount,
    required this.readyCount,
    required this.onCreateDelivery,
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
          const Icon(Icons.point_of_sale_outlined,
              size: 20, color: AppTheme.copper),
          const SizedBox(width: 10),
          Text(
            'Balcão',
            style: GoogleFonts.cormorantGaramond(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.cream,
            ),
          ),
          const SizedBox(width: 14),
          // Badge de pendentes
          if (pendingCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.amber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppTheme.amber.withValues(alpha: 0.5), width: 1.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: AppTheme.amber),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$pendingCount pendentes',
                    style: GoogleFonts.inter(
                      color: AppTheme.amber,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          if (readyCount > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.sage.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.sage.withValues(alpha: 0.45),
                  width: 1.5,
                ),
              ),
              child: Text(
                '$readyCount prontos',
                style: GoogleFonts.inter(
                  color: AppTheme.sage,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          const Spacer(),
          BrutalIconButton(
            icon: Icons.delivery_dining_outlined,
            onTap: onCreateDelivery,
            filled: false,
          ),
        ],
      ),
    );
  }
}

// ─── Body ──────────────────────────────────────────────────────────
class _CounterBody extends StatelessWidget {
  final List<Order> pendingOrders;
  final List<Order> readyOrders;
  final AppProvider provider;

  const _CounterBody({
    required this.pendingOrders,
    required this.readyOrders,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppTheme.copper,
      backgroundColor: AppTheme.charcoal2,
      onRefresh: () => provider.refreshData(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // ── Seção Pendentes ──────────────────────────────────────
          if (pendingOrders.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: SectionLabel(
                  text: 'Aguardando Confirmação',
                  trailing: Text(
                    '${pendingOrders.length} pedido${pendingOrders.length > 1 ? 's' : ''}',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final order = pendingOrders[index];
                    return OrderCard(
                      order: order,
                      animIndex: index,
                      primaryLabel: 'ENCAMINHAR',
                      secondaryLabel: 'RECUSAR',
                      onMapTap: order.isDelivery && order.deliveryAddress != null
                          ? () => showDeliveryMapSheet(context, order: order)
                          : null,
                      onPrimary: () => provider.updateOrderStatus(
                        order.id,
                        OrderStatus.preparing.value,
                      ),
                      onSecondary: () => _confirmCancel(context, order),
                    );
                  },
                  childCount: pendingOrders.length,
                ),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 240,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  mainAxisExtent: _cardHeightForOrders(pendingOrders),
                ),
              ),
            ),
          ],

          if (readyOrders.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: SectionLabel(
                  text: 'Prontos para Entrega',
                  trailing: Text(
                    '${readyOrders.length} pedido${readyOrders.length > 1 ? 's' : ''}',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final order = readyOrders[index];
                    return OrderCard(
                      order: order,
                      animIndex: index,
                      primaryLabel: 'MARCAR ENTREGUE',
                      onMapTap: order.isDelivery && order.deliveryAddress != null
                          ? () => showDeliveryMapSheet(context, order: order)
                          : null,
                      onPrimary: () => provider.updateOrderStatus(
                        order.id,
                        OrderStatus.delivered.value,
                      ),
                    );
                  },
                  childCount: readyOrders.length,
                ),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 260,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  mainAxisExtent: _cardHeightForOrders(
                    readyOrders,
                    hasActions: true,
                  ),
                ),
              ),
            ),
          ],

          // ── Estado vazio ─────────────────────────────────────────
          if (pendingOrders.isEmpty && readyOrders.isEmpty)
            const SliverFillRemaining(
              child: EmptyState(
                message: 'Nenhum pedido no balcao',
                icon: Icons.delivery_dining_outlined,
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  double _cardHeightForOrders(
    List<Order> orders, {
    bool hasActions = true,
  }) {
    var height = hasActions ? 230.0 : 185.0;

    for (final order in orders) {
      final itemCount = order.items.length;
      final hasObservations = order.observations?.trim().isNotEmpty ?? false;
      final hasDeliveryInfo = order.deliveryAddress != null;
      final baseHeight = hasActions ? 198.0 : 150.0;
      final orderHeight = baseHeight +
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

  void _confirmCancel(BuildContext context, Order order) {
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
                'Recusar pedido?',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.cream,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                order.isDelivery
                    ? 'O pedido ${order.displayId} de entrega sera cancelado.'
                    : 'O pedido ${order.displayId} — Mesa ${order.table?.number ?? '--'} sera cancelado.',
                style:
                    GoogleFonts.inter(fontSize: 13, color: AppTheme.textLight),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text('VOLTAR',
                        style: GoogleFonts.inter(
                            color: AppTheme.textMuted,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                            letterSpacing: 1)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      provider.updateOrderStatus(
                        order.id,
                        OrderStatus.canceled.value,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.wine,
                        foregroundColor: AppTheme.cream),
                    child: const Text('CANCELAR PEDIDO'),
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

class _DeliveryOrderSheet extends StatefulWidget {
  final AppProvider provider;

  const _DeliveryOrderSheet({required this.provider});

  @override
  State<_DeliveryOrderSheet> createState() => _DeliveryOrderSheetState();
}

class _DeliveryOrderSheetState extends State<_DeliveryOrderSheet> {
  final Map<String, int> _cart = {};
  final _customerController = TextEditingController();
  final _phoneController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _complementController = TextEditingController();
  final _referenceController = TextEditingController();
  final _obsController = TextEditingController();

  bool _isSending = false;
  bool _isLocating = false;
  GeocodingResult? _geocodingResult;
  String _locationLabel = '';

  AppProvider get provider => widget.provider;

  @override
  void dispose() {
    _customerController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _neighborhoodController.dispose();
    _complementController.dispose();
    _referenceController.dispose();
    _obsController.dispose();
    super.dispose();
  }

  double get _total {
    var total = 0.0;
    for (final entry in _cart.entries) {
      final product = provider.products.firstWhere(
        (p) => p.id == entry.key,
        orElse: () => Product(
          id: '',
          name: '',
          price: 0,
          category: const Category(id: '', name: ''),
        ),
      );
      total += product.price * entry.value;
    }
    return total;
  }

  int _cartCount() => _cart.values.fold(0, (sum, qty) => sum + qty);

  void _add(Product product) {
    setState(() => _cart[product.id] = (_cart[product.id] ?? 0) + 1);
  }

  void _remove(Product product) {
    setState(() {
      final current = _cart[product.id] ?? 0;
      if (current > 1) {
        _cart[product.id] = current - 1;
      } else {
        _cart.remove(product.id);
      }
    });
  }

  String _buildQuery() {
    final parts = [
      _streetController.text.trim(),
      _numberController.text.trim(),
      _neighborhoodController.text.trim(),
      'Brasil',
    ].where((part) => part.isNotEmpty);
    return parts.join(', ');
  }

  Future<void> _locateOnMap() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final query = _buildQuery();

    if (query.replaceAll(', Brasil', '').trim().isEmpty) {
      _showSnack('Preencha rua, numero e bairro.', success: false);
      return;
    }

    setState(() {
      _isLocating = true;
      _locationLabel = '';
    });

    try {
      final result = await MapService.geocodeAddress(query);
      if (!mounted) return;

      setState(() {
        _isLocating = false;
        _geocodingResult = result;
        _locationLabel = result?.displayName ?? '';
      });

      if (result == null) {
        _showSnack('Endereco nao encontrado no mapa.', success: false);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLocating = false);
      _showSnack('Nao foi possivel localizar o endereco.', success: false);
    }
  }

  Future<void> _submit() async {
    if (_cart.isEmpty) {
      _showSnack('Adicione pelo menos um item ao pedido.', success: false);
      return;
    }

    if (_customerController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _streetController.text.trim().isEmpty ||
        _numberController.text.trim().isEmpty ||
        _neighborhoodController.text.trim().isEmpty) {
      _showSnack('Preencha os dados principais da entrega.', success: false);
      return;
    }

    if (_geocodingResult == null) {
      _showSnack('Localize o endereco no mapa antes de enviar.', success: false);
      return;
    }

    setState(() => _isSending = true);

    final items = _cart.entries
        .map((entry) => {
              'productId': entry.key,
              'quantity': entry.value,
            })
        .toList();

    final orderCode = DateTime.now().millisecondsSinceEpoch.toString();
    final success = await provider.createOrder(
      displayId: 'E-${orderCode.substring(orderCode.length - 4)}',
      orderType: OrderType.delivery,
      deliveryAddress: DeliveryAddress(
        customerName: _customerController.text.trim(),
        phone: _phoneController.text.trim(),
        street: _streetController.text.trim(),
        number: _numberController.text.trim(),
        neighborhood: _neighborhoodController.text.trim(),
        complement: _complementController.text.trim().isEmpty
            ? null
            : _complementController.text.trim(),
        reference: _referenceController.text.trim().isEmpty
            ? null
            : _referenceController.text.trim(),
        latitude: _geocodingResult!.latitude,
        longitude: _geocodingResult!.longitude,
      ),
      items: items,
      observations: _obsController.text,
    );

    if (!mounted) return;

    setState(() => _isSending = false);

    if (success) {
      Navigator.pop(context);
      _showSnack('Pedido de entrega enviado com sucesso.', success: true);
      return;
    }

    _showSnack(provider.dataError, success: false);
  }

  void _showSnack(String message, {required bool success}) {
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

  @override
  Widget build(BuildContext context) {
    final productsByCategory = provider.productsByCategory;
    final screenH = MediaQuery.of(context).size.height;

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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppTheme.charcoal3, width: 1.5),
              ),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nova Entrega',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.cream,
                      ),
                    ),
                    Text(
                      'PEDIDO COM MAPA',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                        color: AppTheme.copper,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                BrutalIconButton(
                  icon: Icons.close,
                  onTap: () => Navigator.pop(context),
                  filled: false,
                ),
              ],
            ),
          ),
          Expanded(
            child: productsByCategory.isEmpty
                ? Center(
                    child: Text(
                      'Carregando cardapio...',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 18,
                        color: AppTheme.textMuted,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _DeliverySectionTitle(title: 'Dados da entrega'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: BrutalTextField(
                              label: 'Cliente',
                              controller: _customerController,
                              hintText: 'Nome do cliente',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: BrutalTextField(
                              label: 'Telefone',
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              hintText: 'Contato',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: BrutalTextField(
                              label: 'Rua',
                              controller: _streetController,
                              hintText: 'Endereco',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: BrutalTextField(
                              label: 'Numero',
                              controller: _numberController,
                              hintText: 'N',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: BrutalTextField(
                              label: 'Bairro',
                              controller: _neighborhoodController,
                              hintText: 'Bairro',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: BrutalTextField(
                              label: 'Complemento',
                              controller: _complementController,
                              hintText: 'Opcional',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      BrutalTextField(
                        label: 'Referencia',
                        controller: _referenceController,
                        hintText: 'Ponto de referencia',
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: _isLocating ? null : _locateOnMap,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppTheme.charcoal3.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _geocodingResult != null
                                  ? AppTheme.sage.withValues(alpha: 0.55)
                                  : AppTheme.charcoal3,
                              width: 1.4,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: AppTheme.copper.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: _isLocating
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.2,
                                          color: AppTheme.copper,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.map_outlined,
                                        color: AppTheme.copper,
                                        size: 18,
                                      ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _geocodingResult == null
                                          ? 'Localizar endereco no mapa'
                                          : 'Endereco localizado',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: _geocodingResult == null
                                            ? AppTheme.cream
                                            : AppTheme.sage,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      _locationLabel.isEmpty
                                          ? 'Usa a API de mapa para salvar a localizacao da entrega.'
                                          : _locationLabel,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: AppTheme.textMuted,
                                        height: 1.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _DeliverySectionTitle(title: 'Itens do pedido'),
                      const SizedBox(height: 12),
                      ...productsByCategory.entries.map((entry) {
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
                                    ),
                                  ),
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
                                return _DeliveryProductItem(
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
                      }),
                    ],
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppTheme.charcoal2,
              border: Border(
                top: BorderSide(color: AppTheme.charcoal3, width: 1.5),
              ),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _obsController,
                  maxLines: 2,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppTheme.textLight,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Observacoes do pedido...',
                    hintStyle: GoogleFonts.inter(
                      color: AppTheme.charcoal3,
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
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
                    Expanded(
                      child: GestureDetector(
                        onTap: _cartCount() > 0 && !_isSending ? _submit : null,
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
                                      'ENVIAR ENTREGA',
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
                                        decoration: const BoxDecoration(
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

class _DeliverySectionTitle extends StatelessWidget {
  final String title;

  const _DeliverySectionTitle({required this.title});

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
          title.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: AppTheme.textMuted,
          ),
        ),
      ],
    );
  }
}

class _DeliveryProductItem extends StatelessWidget {
  final Product product;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _DeliveryProductItem({
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: selected ? AppTheme.cream : AppTheme.textLight,
                    ),
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
                    '-',
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
