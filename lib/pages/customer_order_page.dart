import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/customer_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

class CustomerOrderPage extends StatefulWidget {
  const CustomerOrderPage({super.key});

  @override
  State<CustomerOrderPage> createState() => _CustomerOrderPageState();
}

class _CustomerOrderPageState extends State<CustomerOrderPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _complementController = TextEditingController();
  final _referenceController = TextEditingController();
  final _obsController = TextEditingController();

  String _paymentMethod = 'Pix';

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _neighborhoodController.dispose();
    _complementController.dispose();
    _referenceController.dispose();
    _obsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CustomerProvider>();

    if (provider.state == CustomerState.success) {
      return _SuccessView(
        orderId: provider.lastOrderId,
        onNewOrder: () {
          _clearForm();
          provider.startNewOrder();
        },
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.charcoal,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              const _CustomerHeader(),
              Expanded(child: _buildContent(provider)),
              _CheckoutBar(
                total: provider.total,
                itemCount: provider.itemCount,
                isSending: provider.state == CustomerState.sending,
                onSubmit: () => _submit(provider),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(CustomerProvider provider) {
    if (provider.state == CustomerState.loading && provider.products.isEmpty) {
      return const LoadingOverlay();
    }

    if (provider.state == CustomerState.error && provider.products.isEmpty) {
      return _InlineError(message: provider.error);
    }

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
            child: SectionLabel(
              text: 'Cardapio',
              trailing: Text(
                '${provider.menuItemCount} itens',
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
        ...provider.productsByCategory.entries.expand((entry) {
          return [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
                child: _CategoryTitle(title: entry.key),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final product = entry.value[index];
                    return _ProductTile(
                      product: product,
                      quantity: provider.quantityFor(product),
                      onAdd: () => provider.add(product),
                      onRemove: () => provider.remove(product),
                    );
                  },
                  childCount: entry.value.length,
                ),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 280,
                  mainAxisExtent: 142,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
          ];
        }),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: SectionLabel(text: 'Entrega'),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _DeliveryForm(
              formKey: _formKey,
              nameController: _nameController,
              phoneController: _phoneController,
              streetController: _streetController,
              numberController: _numberController,
              neighborhoodController: _neighborhoodController,
              complementController: _complementController,
              referenceController: _referenceController,
              obsController: _obsController,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
            child: SectionLabel(text: 'Pagamento'),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _PaymentSelector(
              value: _paymentMethod,
              onChanged: (value) => setState(() => _paymentMethod = value),
            ),
          ),
        ),
        if (provider.cart.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
              child: _CartSummary(provider: provider),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  Future<void> _submit(CustomerProvider provider) async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (provider.itemCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicione pelo menos um item.')),
      );
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final address = DeliveryAddress(
      customerName: _nameController.text.trim(),
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
    );

    final success = await provider.submitPaidOrder(
      deliveryAddress: address,
      observations: _obsController.text,
      paymentMethod: _paymentMethod,
    );

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error)),
      );
    }
  }

  void _clearForm() {
    _nameController.clear();
    _phoneController.clear();
    _streetController.clear();
    _numberController.clear();
    _neighborhoodController.clear();
    _complementController.clear();
    _referenceController.clear();
    _obsController.clear();
    _paymentMethod = 'Pix';
  }
}

class _CustomerHeader extends StatelessWidget {
  const _CustomerHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      decoration: const BoxDecoration(
        color: AppTheme.charcoal2,
        border: Border(
          bottom: BorderSide(color: AppTheme.charcoal3, width: 1.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.copper.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.copper.withValues(alpha: 0.45),
                width: 1.4,
              ),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.restaurant_menu_outlined,
              color: AppTheme.copper,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MesaMestre Online',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.cream,
                  ),
                ),
                Text(
                  'Faca seu pedido para entrega',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.sage.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.sage.withValues(alpha: 0.45),
              ),
            ),
            child: Text(
              'ONLINE',
              style: GoogleFonts.inter(
                color: AppTheme.sage,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTitle extends StatelessWidget {
  final String title;

  const _CategoryTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
        color: AppTheme.copperLight,
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  final Product product;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _ProductTile({
    required this.product,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final selected = quantity > 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: selected
            ? AppTheme.copper.withValues(alpha: 0.14)
            : AppTheme.charcoal2,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: selected
              ? AppTheme.copper.withValues(alpha: 0.6)
              : AppTheme.charcoal3,
          width: 1.5,
        ),
        boxShadow: selected ? AppTheme.copperGlow : AppTheme.subtleShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.cream,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'R\$ ${product.price.toStringAsFixed(2)}',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.copperLight,
                  height: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              product.description?.trim().isNotEmpty == true
                  ? product.description!.trim()
                  : product.category.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppTheme.textMuted,
                height: 1.35,
              ),
            ),
          ),
          Row(
            children: [
              _RoundAction(icon: Icons.remove, onTap: quantity > 0 ? onRemove : null),
              const SizedBox(width: 10),
              SizedBox(
                width: 28,
                child: Text(
                  '$quantity',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: selected ? AppTheme.copperLight : AppTheme.textMuted,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _RoundAction(icon: Icons.add, onTap: onAdd, filled: true),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoundAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool filled;

  const _RoundAction({
    required this.icon,
    this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: filled && enabled
              ? AppTheme.copper
              : AppTheme.charcoal3.withValues(alpha: 0.24),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: enabled ? AppTheme.copper : AppTheme.charcoal3,
            width: 1.3,
          ),
        ),
        child: Icon(
          icon,
          size: 17,
          color: filled && enabled ? AppTheme.charcoal : AppTheme.textMuted,
        ),
      ),
    );
  }
}

class _DeliveryForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController streetController;
  final TextEditingController numberController;
  final TextEditingController neighborhoodController;
  final TextEditingController complementController;
  final TextEditingController referenceController;
  final TextEditingController obsController;

  const _DeliveryForm({
    required this.formKey,
    required this.nameController,
    required this.phoneController,
    required this.streetController,
    required this.numberController,
    required this.neighborhoodController,
    required this.complementController,
    required this.referenceController,
    required this.obsController,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          BrutalTextField(
            label: 'Nome',
            controller: nameController,
            hintText: 'Seu nome',
            validator: _required,
          ),
          const SizedBox(height: 12),
          BrutalTextField(
            label: 'Telefone',
            controller: phoneController,
            hintText: '(00) 00000-0000',
            keyboardType: TextInputType.phone,
            validator: _required,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: BrutalTextField(
                  label: 'Rua',
                  controller: streetController,
                  hintText: 'Endereco',
                  validator: _required,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BrutalTextField(
                  label: 'Numero',
                  controller: numberController,
                  hintText: 'N',
                  keyboardType: TextInputType.number,
                  validator: _required,
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
                  controller: neighborhoodController,
                  hintText: 'Bairro',
                  validator: _required,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BrutalTextField(
                  label: 'Complemento',
                  controller: complementController,
                  hintText: 'Opcional',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          BrutalTextField(
            label: 'Referencia',
            controller: referenceController,
            hintText: 'Ponto de referencia',
          ),
          const SizedBox(height: 12),
          BrutalTextField(
            label: 'Observacoes',
            controller: obsController,
            hintText: 'Ex: sem cebola, entregar na portaria...',
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  String? _required(String? value) {
    if ((value ?? '').trim().isEmpty) return 'Obrigatorio';
    return null;
  }
}

class _PaymentSelector extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _PaymentSelector({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const methods = ['Pix', 'Cartao', 'Carteira'];

    return Row(
      children: methods.map((method) {
        final selected = value == method;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: method == methods.last ? 0 : 8),
            child: GestureDetector(
              onTap: () => onChanged(method),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                height: 46,
                decoration: BoxDecoration(
                  color: selected
                      ? AppTheme.copper
                      : AppTheme.charcoal2,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: selected ? AppTheme.copper : AppTheme.charcoal3,
                    width: 1.4,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  method.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: selected ? AppTheme.charcoal : AppTheme.textLight,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _CartSummary extends StatelessWidget {
  final CustomerProvider provider;

  const _CartSummary({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.charcoal2,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.charcoal3, width: 1.5),
      ),
      child: Column(
        children: provider.cart.entries.map((entry) {
          final product = _productById(provider.products, entry.key);
          if (product == null) return const SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppTheme.copper.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${entry.value}',
                    style: GoogleFonts.inter(
                      color: AppTheme.copperLight,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: AppTheme.textLight,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'R\$ ${(product.price * entry.value).toStringAsFixed(2)}',
                  style: GoogleFonts.inter(
                    color: AppTheme.textMuted,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Product? _productById(List<Product> products, String id) {
    for (final product in products) {
      if (product.id == id) return product;
    }
    return null;
  }
}

class _CheckoutBar extends StatelessWidget {
  final double total;
  final int itemCount;
  final bool isSending;
  final VoidCallback onSubmit;

  const _CheckoutBar({
    required this.total,
    required this.itemCount,
    required this.isSending,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = itemCount > 0 && !isSending;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: AppTheme.charcoal2,
        border: Border(
          top: BorderSide(color: AppTheme.charcoal3, width: 1.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 118,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.charcoal3.withValues(alpha: 0.26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$itemCount item${itemCount == 1 ? '' : 's'}',
                  maxLines: 1,
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.3,
                    color: AppTheme.textMuted,
                  ),
                ),
                Text(
                  'R\$ ${total.toStringAsFixed(2)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.cream,
                    height: 1.05,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: enabled ? onSubmit : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                height: 60,
                decoration: BoxDecoration(
                  gradient: enabled ? AppTheme.copperGradient : null,
                  color: enabled
                      ? null
                      : AppTheme.charcoal3.withValues(alpha: 0.30),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: isSending
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: AppTheme.charcoal,
                          strokeWidth: 2.6,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.payments_outlined,
                            size: 18,
                            color: enabled
                                ? AppTheme.charcoal
                                : AppTheme.textMuted,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'PAGAR E ENVIAR',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              color: enabled
                                  ? AppTheme.charcoal
                                  : AppTheme.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.4,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  final String orderId;
  final VoidCallback onNewOrder;

  const _SuccessView({
    required this.orderId,
    required this.onNewOrder,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.charcoal,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppTheme.sage.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppTheme.sage.withValues(alpha: 0.55),
                      width: 1.6,
                    ),
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: AppTheme.sage,
                    size: 46,
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  'Pedido enviado',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cormorantGaramond(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.cream,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Pagamento confirmado. O pedido $orderId entrou no balcao.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textLight,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onNewOrder,
                    icon: const Icon(Icons.add_shopping_cart_outlined),
                    label: const Text('FAZER OUTRO PEDIDO'),
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

class _InlineError extends StatelessWidget {
  final String message;

  const _InlineError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: _ErrorBanner(message: message),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.wine.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.wine.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppTheme.wine, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(
                color: AppTheme.textLight,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
