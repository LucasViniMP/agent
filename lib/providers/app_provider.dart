import 'dart:async';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/firestore_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/firebase_auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;

enum AppState { idle, loading, error }

class AppProvider extends ChangeNotifier with WidgetsBindingObserver {
  // ─── Auth State ───────────────────────────────────────────────
  bool _isAuthenticated = false;
  Employee? _currentUser;
  AppRole? _activeRole;
  String _authError = '';
  AppState _authState = AppState.idle;

  bool get isAuthenticated => _isAuthenticated;
  Employee? get currentUser => _currentUser;
  AppRole? get activeRole => _activeRole;
  String get authError => _authError;
  AppState get authState => _authState;

  // ─── Data State ───────────────────────────────────────────────
  List<Order> _orders = [];
  List<RestaurantTable> _tables = [];
  List<Product> _products = [];
  AppState _dataState = AppState.idle;
  String _dataError = '';

  List<Order> get orders => _orders;
  List<RestaurantTable> get tables => _tables;
  List<Product> get products => _products;
  AppState get dataState => _dataState;
  String get dataError => _dataError;

  // ─── Streams ──────────────────────────────────────────────────
  StreamSubscription? _ordersSub;
  StreamSubscription? _tablesSub;
  StreamSubscription? _productsSub;

  // ─── Computed ─────────────────────────────────────────────────
  List<Order> get pendingOrders =>
      _orders.where((o) => o.status == OrderStatus.pending).toList();

  List<Order> get preparingOrders =>
      _orders.where((o) => o.status == OrderStatus.preparing).toList();

  List<Order> get readyOrders =>
      _orders.where((o) => o.status == OrderStatus.ready).toList();

  List<Order> get deliveredOrders =>
      _orders.where((o) => o.status == OrderStatus.delivered).toList();

  List<RestaurantTable> get freeTables =>
      _tables.where((t) => t.status == TableStatus.free).toList();

  List<RestaurantTable> get occupiedTables =>
      _tables.where((t) => t.status == TableStatus.occupied).toList();

  // ─── Role Selection ───────────────────────────────────────────
  void selectRole(AppRole role) {
    _activeRole = role;
    notifyListeners();
  }

  void clearRole() {
    _activeRole = null;
    notifyListeners();
  }

  AppProvider() {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_currentUser != null) {
      if (state == AppLifecycleState.resumed) {
        FirestoreService.setEmployeePresence(
          uid: _currentUser!.id,
          name: _currentUser!.name,
          email: _currentUser!.email,
          role: _currentUser!.role,
          isOnline: true,
        );
      } else if (state == AppLifecycleState.paused ||
          state == AppLifecycleState.detached) {
        FirestoreService.setEmployeePresence(
          uid: _currentUser!.id,
          name: _currentUser!.name,
          email: _currentUser!.email,
          role: _currentUser!.role,
          isOnline: false,
        );
      }
    }
  }

  // ─── Init ─────────────────────────────────────────────────────
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedRole = prefs.getString('last_role');
    if (savedRole != null) {
      try {
        _activeRole = AppRole.values.firstWhere((r) => r.name == savedRole);
      } catch (_) {}
    }

    final firebaseUser = FirebaseAuthService.currentUser;

    if (firebaseUser != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get();
      if (!userDoc.exists) {
        await FirebaseAuthService.logout();
        _activeRole = null;
        return;
      }

      final data = userDoc.data()!;

      if (data['active'] == false) {
        await FirebaseAuthService.logout();
        _activeRole = null;
        return;
      }

      final userRole = EmployeeRole.fromString(data['role'] ?? 'WAITER');
      String userName = firebaseUser.displayName ?? 'Usuário';

      userName = data['name'] ?? userName;

      final appRole = _appRoleFromEmployeeRole(userRole);

      if (appRole == null) {
        await FirebaseAuthService.logout();
        _activeRole = null;
        return;
      }

      _activeRole = appRole;
      _isAuthenticated = true;

      _currentUser = Employee(
        id: firebaseUser.uid,
        name: userName,
        email: firebaseUser.email ?? data['email'] ?? '',
        role: userRole,
      );

      FirestoreService.setEmployeePresence(
        uid: _currentUser!.id,
        name: _currentUser!.name,
        email: _currentUser!.email,
        role: _currentUser!.role,
        isOnline: true,
      );

      _listenToData();
    }
  }

  // ─── Auth ─────────────────────────────────────────────────────
  Future<bool> login(String email, String password) async {
    _authState = AppState.loading;
    _authError = '';
    notifyListeners();

    try {
      final selectedRole = _activeRole;

      if (selectedRole == null) {
        _authState = AppState.error;
        _authError = 'Selecione um cargo antes de entrar.';
        notifyListeners();
        return false;
      }

      final credential = await FirebaseAuthService.login(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;

      if (firebaseUser == null) {
        throw Exception('Usuário inválido');
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get();
      if (!userDoc.exists) {
        await FirebaseAuthService.logout();
        _authState = AppState.error;
        _authError = 'Credenciais incorretas para este perfil.';
        notifyListeners();
        return false;
      }

      final data = userDoc.data()!;

      if (data['active'] == false) {
        await FirebaseAuthService.logout();
        _authState = AppState.error;
        _authError = 'Credenciais incorretas para este perfil.';
        notifyListeners();
        return false;
      }

      final userRole = EmployeeRole.fromString(data['role'] ?? 'WAITER');
      String userName = firebaseUser.displayName ?? 'Usuário';

      userName = data['name'] ?? userName;

      final selectedEmployeeRole =
          EmployeeRole.values.byName(selectedRole.name);

      if (userRole != selectedEmployeeRole) {
        await FirebaseAuthService.logout();
        _authState = AppState.error;
        _authError = 'Credenciais incorretas para este perfil.';
        notifyListeners();
        return false;
      }

      _currentUser = Employee(
        id: firebaseUser.uid,
        name: userName,
        email: firebaseUser.email ?? data['email'] ?? email,
        role: userRole,
      );

      FirestoreService.setEmployeePresence(
        uid: _currentUser!.id,
        name: _currentUser!.name,
        email: _currentUser!.email,
        role: _currentUser!.role,
        isOnline: true,
      );

      _isAuthenticated = true;
      _authState = AppState.idle;

      if (_activeRole != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('last_role', _activeRole!.name);
      }

      _listenToData();
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _authState = AppState.error;

      switch (e.code) {
        case 'user-not-found':
          _authError = 'Usuário não encontrado';
          break;
        case 'wrong-password':
          _authError = 'Senha incorreta';
          break;
        case 'invalid-email':
          _authError = 'Email inválido';
          break;
        case 'invalid-credential':
          _authError = 'Credenciais inválidas';
          break;
        default:
          _authError = e.message ?? 'Erro no login';
      }

      _authError = 'Credenciais incorretas para este perfil.';
      notifyListeners();
      return false;
    } catch (e) {
      _authState = AppState.error;
      _authError = 'Nao foi possivel entrar agora.';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    if (_currentUser != null) {
      await FirestoreService.setEmployeePresence(
        uid: _currentUser!.id,
        name: _currentUser!.name,
        email: _currentUser!.email,
        role: _currentUser!.role,
        isOnline: false,
      );
    }
    await FirebaseAuthService.logout();

    _ordersSub?.cancel();
    _tablesSub?.cancel();
    _productsSub?.cancel();

    _isAuthenticated = false;
    _currentUser = null;
    _activeRole = null;
    _orders = [];
    _tables = [];
    _products = [];

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('last_role');
    notifyListeners();
  }

  // ─── Data Loading ─────────────────────────────────────────────
  void _listenToData() {
    _dataState = AppState.loading;
    notifyListeners();

    _productsSub = FirestoreService.streamProducts().listen((data) {
      _products = data;
      _dataState = AppState.idle;
      notifyListeners();
    }, onError: (e) {
      _dataError = e.toString();
      _dataState = AppState.error;
      notifyListeners();
    });

    _tablesSub = FirestoreService.streamTables().listen((data) {
      _tables = data;
      notifyListeners();
    });

    _ordersSub = FirestoreService.streamOrders().listen((data) {
      _orders = data;
      notifyListeners();
    });
  }

  Future<void> refreshData() async {
    // In Firestore, data is real-time so manual refresh isn't needed,
    // but we can leave this here so UI components don't break.
  }

  Future<bool> createTablesUpTo(int quantity) async {
    if (quantity <= 0) {
      _dataError = 'Informe uma quantidade valida de mesas.';
      notifyListeners();
      return false;
    }

    try {
      final existingNumbers = _tables
          .map((table) => _numericTableNumber(table.number))
          .whereType<int>()
          .toSet();

      var created = 0;

      for (var number = 1; number <= quantity; number++) {
        if (existingNumbers.contains(number)) continue;

        await FirestoreService.setTableNumber(
          number: _formatTableNumber(number),
        );
        created++;
      }

      _dataError =
          created == 0 ? 'Todas as mesas dessa sequencia ja existem.' : '';
      notifyListeners();
      return created > 0;
    } catch (e) {
      _dataError = 'Nao foi possivel criar as mesas.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTables(Set<String> tableIds) async {
    if (tableIds.isEmpty) {
      _dataError = 'Selecione pelo menos uma mesa.';
      notifyListeners();
      return false;
    }

    try {
      for (final id in tableIds) {
        await FirestoreService.deleteTable(id);
      }

      _dataError = '';
      notifyListeners();
      return true;
    } catch (e) {
      _dataError = 'Nao foi possivel apagar as mesas.';
      notifyListeners();
      return false;
    }
  }

  int? _numericTableNumber(String number) {
    final normalized = number.trim();
    if (normalized.isEmpty) return null;
    return int.tryParse(normalized);
  }

  String _formatTableNumber(int number) {
    return number < 10 ? '0$number' : '$number';
  }

  AppRole? _appRoleFromEmployeeRole(EmployeeRole role) {
    switch (role) {
      case EmployeeRole.waiter:
        return AppRole.waiter;
      case EmployeeRole.counter:
        return AppRole.counter;
      case EmployeeRole.kitchen:
        return AppRole.kitchen;
      case EmployeeRole.admin:
        return null;
    }
  }

  // ─── Order Actions ────────────────────────────────────────────
  Future<void> updateOrderStatus(String orderId, String status) async {
    // Optimistic update
    _orders = _orders
        .map((o) => o.id == orderId
            ? o.copyWith(status: OrderStatus.fromString(status))
            : o)
        .toList();
    notifyListeners();

    try {
      await FirestoreService.updateOrderStatus(orderId, status);
    } catch (e) {
      _dataError = e.toString();
    }
    notifyListeners();
  }

  Future<bool> deleteReadyKitchenOrders() async {
    final orderIds = _orders
        .where((order) =>
            order.status == OrderStatus.ready ||
            order.status == OrderStatus.delivered)
        .map((order) => order.id)
        .toList();

    if (orderIds.isEmpty) return true;

    try {
      for (final id in orderIds) {
        await FirestoreService.deleteOrder(id);
      }

      _orders = _orders.where((order) => !orderIds.contains(order.id)).toList();
      _dataError = '';
      notifyListeners();
      return true;
    } catch (e) {
      _dataError = 'Nao foi possivel apagar os pedidos prontos.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> createOrder({
    required String displayId,
    String? tableId,
    OrderType orderType = OrderType.table,
    OrderSource? source,
    PaymentStatus paymentStatus = PaymentStatus.pending,
    DeliveryAddress? deliveryAddress,
    required List<Map<String, dynamic>> items,
    String observations = '',
  }) async {
    try {
      // Map simple items to full OrderItem JSON to save in Firestore
      final fullItems = items.map((i) {
        final p = _products.firstWhere((prod) => prod.id == i['productId']);
        return {
          'id': DateTime.now().millisecondsSinceEpoch.toString() + p.id,
          'quantity': i['quantity'],
          'product': {
            'id': p.id,
            'name': p.name,
            'description': p.description,
            'price': p.price,
            'category': {
              'id': p.category.id,
              'name': p.category.name,
            }
          }
        };
      }).toList();

      RestaurantTable? tableObj;
      if (tableId != null) {
        try {
          tableObj = _tables.firstWhere((t) => t.id == tableId);
        } catch (_) {}
      }

      await FirestoreService.createOrder(
        displayId: displayId,
        tableId: tableId,
        table: tableObj,
        orderType: orderType,
        source: source ?? _orderSourceForActiveRole(),
        paymentStatus: paymentStatus,
        deliveryAddress: deliveryAddress,
        items: fullItems,
        observations: observations.trim(),
      );
      return true;
    } catch (e) {
      _dataError = e.toString();
      return false;
    }
  }

  OrderSource _orderSourceForActiveRole() {
    switch (_activeRole) {
      case AppRole.waiter:
        return OrderSource.waiter;
      case AppRole.counter:
        return OrderSource.counter;
      case AppRole.kitchen:
      case null:
        return OrderSource.counter;
    }
  }

  Future<bool> closeTableAccount(String tableId) async {
    try {
      await FirestoreService.closeTableAccount(tableId);
      return true;
    } catch (e) {
      _dataError = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ─── Products grouped by category ─────────────────────────────
  Map<String, List<Product>> get productsByCategory {
    final map = <String, List<Product>>{};
    final seen = <String>{};

    for (final p in _products) {
      final key = _productKey(p);
      if (seen.contains(key)) continue;
      seen.add(key);
      map.putIfAbsent(p.category.name, () => []).add(p);
    }
    return map;
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
}
