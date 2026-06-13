import 'dart:async';

import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';

enum CustomerState { idle, loading, error, sending, success }

class CustomerProvider extends ChangeNotifier {
  List<Product> _products = [];
  final Map<String, int> _cart = {};
  CustomerState _state = CustomerState.idle;
  String _error = '';
  String _lastOrderId = '';

  StreamSubscription? _productsSub;

  List<Product> get products => _products;
  Map<String, int> get cart => Map.unmodifiable(_cart);
  CustomerState get state => _state;
  String get error => _error;
  String get lastOrderId => _lastOrderId;

  int get itemCount => _cart.values.fold(0, (sum, qty) => sum + qty);

  int get menuItemCount => productsByCategory.values.fold(
        0,
        (sum, products) => sum + products.length,
      );

  double get total {
    var value = 0.0;
    for (final entry in _cart.entries) {
      final product = _productById(entry.key);
      if (product == null) continue;
      value += product.price * entry.value;
    }
    return value;
  }

  Map<String, List<Product>> get productsByCategory {
    final map = <String, List<Product>>{};
    final seen = <String>{};

    for (final product in _products) {
      final key = _productKey(product);
      if (seen.contains(key)) continue;
      seen.add(key);
      map.putIfAbsent(product.category.name, () => []).add(product);
    }

    return map;
  }

  Future<void> init() async {
    _state = CustomerState.loading;
    _error = '';
    notifyListeners();

    try {
      if (FirebaseAuthService.currentUser == null) {
        await FirebaseAuthService.signInAnonymously().timeout(
          const Duration(seconds: 4),
        );
      }
    } catch (_) {
      _error = '';
    }

    try {
      _productsSub = FirestoreService.streamProducts().listen((products) {
        _products = products;
        _state = CustomerState.idle;
        notifyListeners();
      }, onError: (e) {
        _state = CustomerState.error;
        _error =
            'Nao foi possivel carregar o cardapio. Verifique as regras do Firestore e o login anonimo.';
        notifyListeners();
      });
    } catch (_) {
      _state = CustomerState.error;
      _error =
          'Nao foi possivel iniciar o pedido online. Verifique as regras do Firestore e o login anonimo.';
      notifyListeners();
    }
  }

  void add(Product product) {
    _cart[product.id] = (_cart[product.id] ?? 0) + 1;
    _state = CustomerState.idle;
    notifyListeners();
  }

  void remove(Product product) {
    final current = _cart[product.id] ?? 0;
    if (current > 1) {
      _cart[product.id] = current - 1;
    } else {
      _cart.remove(product.id);
    }
    notifyListeners();
  }

  int quantityFor(Product product) => _cart[product.id] ?? 0;

  Future<bool> submitPaidOrder({
    required DeliveryAddress deliveryAddress,
    String observations = '',
    String paymentMethod = 'Pagamento online',
  }) async {
    if (_cart.isEmpty) {
      _error = 'Adicione pelo menos um item.';
      notifyListeners();
      return false;
    }

    _state = CustomerState.sending;
    _error = '';
    notifyListeners();

    try {
      final fullItems = <Map<String, dynamic>>[];
      var index = 0;

      for (final entry in _cart.entries) {
        final product = _productById(entry.key);
        if (product == null) continue;

        fullItems.add({
          'id':
              '${DateTime.now().microsecondsSinceEpoch}_${index}_${product.id}',
          'quantity': entry.value,
          'product': {
            'id': product.id,
            'name': product.name,
            'description': product.description,
            'price': product.price,
            'category': {
              'id': product.category.id,
              'name': product.category.name,
            }
          }
        });

        index++;
      }

      if (fullItems.isEmpty) {
        throw Exception('Carrinho invalido');
      }

      final code = DateTime.now().millisecondsSinceEpoch.toString();
      final displayId = 'ON-${code.substring(code.length - 5)}';
      final cleanObs = observations.trim();
      final onlineObservation = [
        'Pedido online - pagamento confirmado.',
        'Forma de pagamento: $paymentMethod.',
        if (cleanObs.isNotEmpty) cleanObs,
      ].join('\n');

      await FirestoreService.createOrder(
        displayId: displayId,
        orderType: OrderType.delivery,
        source: OrderSource.online,
        paymentStatus: PaymentStatus.paid,
        deliveryAddress: deliveryAddress,
        items: fullItems,
        observations: onlineObservation,
      );

      _cart.clear();
      _lastOrderId = displayId;
      _state = CustomerState.success;
      notifyListeners();
      return true;
    } catch (_) {
      _state = CustomerState.error;
      _error = 'Nao foi possivel enviar o pedido pago para o balcao.';
      notifyListeners();
      return false;
    }
  }

  void startNewOrder() {
    _lastOrderId = '';
    _error = '';
    _state = CustomerState.idle;
    notifyListeners();
  }

  Product? _productById(String id) {
    for (final product in _products) {
      if (product.id == id) return product;
    }
    return null;
  }

  String _productKey(Product product) {
    final name = product.name.trim().toLowerCase().replaceAll(
          RegExp(r'\s+'),
          ' ',
        );
    final category = product.category.name.trim().toLowerCase().replaceAll(
          RegExp(r'\s+'),
          ' ',
        );
    final price = product.price.toStringAsFixed(2);
    return '$name|$price|$category';
  }

  @override
  void dispose() {
    _productsSub?.cancel();
    super.dispose();
  }
}
