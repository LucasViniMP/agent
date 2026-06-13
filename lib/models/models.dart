enum OrderStatus {
  pending('PENDING'),
  preparing('PREPARING'),
  ready('READY'),
  delivered('DELIVERED'),
  canceled('CANCELED');

  final String value;
  const OrderStatus(this.value);

  static OrderStatus fromString(String s) =>
      OrderStatus.values.firstWhere((e) => e.value == s.toUpperCase(),
          orElse: () => OrderStatus.pending);
}

enum OrderSource {
  waiter('WAITER'),
  counter('COUNTER'),
  online('ONLINE');

  final String value;
  const OrderSource(this.value);

  static OrderSource fromString(String s) =>
      OrderSource.values.firstWhere((e) => e.value == s.toUpperCase(),
          orElse: () => OrderSource.counter);

  String get label {
    switch (this) {
      case OrderSource.waiter:
        return 'Garcom';
      case OrderSource.counter:
        return 'Balcao';
      case OrderSource.online:
        return 'Online';
    }
  }
}

enum PaymentStatus {
  pending('PENDING'),
  paid('PAID'),
  failed('FAILED'),
  refunded('REFUNDED');

  final String value;
  const PaymentStatus(this.value);

  static PaymentStatus fromString(String s) =>
      PaymentStatus.values.firstWhere((e) => e.value == s.toUpperCase(),
          orElse: () => PaymentStatus.pending);

  String get label {
    switch (this) {
      case PaymentStatus.pending:
        return 'Pendente';
      case PaymentStatus.paid:
        return 'Pago';
      case PaymentStatus.failed:
        return 'Falhou';
      case PaymentStatus.refunded:
        return 'Estornado';
    }
  }
}

enum TableStatus {
  free('FREE'),
  occupied('OCCUPIED'),
  reserved('RESERVED');

  final String value;
  const TableStatus(this.value);

  static TableStatus fromString(String s) =>
      TableStatus.values.firstWhere((e) => e.value == s.toUpperCase(),
          orElse: () => TableStatus.free);
}

enum EmployeeRole {
  admin('ADMIN'),
  waiter('WAITER'),
  kitchen('KITCHEN'),
  counter('COUNTER');

  final String value;
  const EmployeeRole(this.value);

  static EmployeeRole fromString(String s) =>
      EmployeeRole.values.firstWhere((e) => e.value == s.toUpperCase(),
          orElse: () => EmployeeRole.waiter);
}

class Category {
  final String id;
  final String name;

  const Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) =>
      Category(id: json['id'], name: json['name']);

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

class Product {
  final String id;
  final String name;
  final String? description;
  final double price;
  final Category category;

  const Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        price: double.tryParse(json['price'].toString()) ?? 0.0,
        category: Category.fromJson(json['category']),
      );
}

class RestaurantTable {
  final String id;
  final String number;
  final TableStatus status;
  final int capacity;

  const RestaurantTable({
    required this.id,
    required this.number,
    required this.status,
    required this.capacity,
  });

  factory RestaurantTable.fromJson(Map<String, dynamic> json) =>
      RestaurantTable(
        id: json['id'],
        number: json['number'].toString(),
        status: TableStatus.fromString(json['status'] ?? 'FREE'),
        capacity: int.tryParse(json['capacity'].toString()) ?? 4,
      );

  RestaurantTable copyWith({TableStatus? status}) => RestaurantTable(
        id: id,
        number: number,
        status: status ?? this.status,
        capacity: capacity,
      );
}

class OrderItem {
  final String id;
  final int quantity;
  final Product product;

  const OrderItem({
    required this.id,
    required this.quantity,
    required this.product,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        id: json['id'],
        quantity: json['quantity'],
        product: Product.fromJson(json['product']),
      );

  double get subtotal => product.price * quantity;
}

class DeliveryAddress {
  final String customerName;
  final String phone;
  final String street;
  final String number;
  final String neighborhood;
  final String? complement;
  final String? reference;
  final double? latitude;
  final double? longitude;

  const DeliveryAddress({
    required this.customerName,
    required this.phone,
    required this.street,
    required this.number,
    required this.neighborhood,
    this.complement,
    this.reference,
    this.latitude,
    this.longitude,
  });

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) => DeliveryAddress(
        customerName: json['customerName'] ?? '',
        phone: json['phone'] ?? '',
        street: json['street'] ?? '',
        number: json['number'] ?? '',
        neighborhood: json['neighborhood'] ?? '',
        complement: json['complement'],
        reference: json['reference'],
        latitude: double.tryParse(json['latitude']?.toString() ?? ''),
        longitude: double.tryParse(json['longitude']?.toString() ?? ''),
      );

  Map<String, dynamic> toJson() => {
        'customerName': customerName,
        'phone': phone,
        'street': street,
        'number': number,
        'neighborhood': neighborhood,
        'complement': complement,
        'reference': reference,
        'latitude': latitude,
        'longitude': longitude,
      };

  String get shortAddress => '$street, $number';

  String get fullAddress {
    final parts = <String>[
      '$street, $number',
      neighborhood,
      if ((complement ?? '').trim().isNotEmpty) complement!.trim(),
      if ((reference ?? '').trim().isNotEmpty) 'Ref: ${reference!.trim()}',
    ];
    return parts.join(' • ');
  }

  bool get hasCoordinates => latitude != null && longitude != null;
}

class Order {
  final String id;
  final String displayId;
  final OrderType type;
  final OrderSource source;
  final PaymentStatus paymentStatus;
  final String? tableId;
  final RestaurantTable? table;
  final DeliveryAddress? deliveryAddress;
  final OrderStatus status;
  final List<OrderItem> items;
  final String? observations;
  final DateTime createdAt;
  final DateTime? paidAt;

  const Order({
    required this.id,
    required this.displayId,
    required this.type,
    this.source = OrderSource.counter,
    this.paymentStatus = PaymentStatus.pending,
    this.tableId,
    this.table,
    this.deliveryAddress,
    required this.status,
    required this.items,
    this.observations,
    required this.createdAt,
    this.paidAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'],
        displayId: json['displayId'] ?? '',
        type: OrderType.fromString(json['type'] ?? 'TABLE'),
        source: OrderSource.fromString(json['source'] ?? 'COUNTER'),
        paymentStatus:
            PaymentStatus.fromString(json['paymentStatus'] ?? 'PENDING'),
        tableId: json['tableId'],
        table: json['table'] != null
            ? RestaurantTable.fromJson(json['table'])
            : null,
        deliveryAddress: json['deliveryAddress'] != null
            ? DeliveryAddress.fromJson(json['deliveryAddress'])
            : null,
        status: OrderStatus.fromString(json['status'] ?? 'PENDING'),
        items: (json['items'] as List<dynamic>? ?? [])
            .map((i) => OrderItem.fromJson(i))
            .toList(),
        observations: json['observations'],
        createdAt: _parseDate(json['createdAt']) ?? DateTime.now(),
        paidAt: _parseDate(json['paidAt']),
      );

  double get total =>
      items.fold(0, (sum, item) => sum + item.subtotal);

  bool get isDelivery => type == OrderType.delivery;

  bool get isOnline => source == OrderSource.online;

  bool get isPaid => paymentStatus == PaymentStatus.paid;

  String get timeLabel {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}min';
    return '${diff.inHours}h ${diff.inMinutes % 60}min';
  }

  Order copyWith({OrderStatus? status}) => Order(
        id: id,
        displayId: displayId,
        type: type,
        source: source,
        paymentStatus: paymentStatus,
        tableId: tableId,
        table: table,
        deliveryAddress: deliveryAddress,
        status: status ?? this.status,
        items: items,
        observations: observations,
        createdAt: createdAt,
        paidAt: paidAt,
      );
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);

  try {
    final dynamic date = value.toDate();
    if (date is DateTime) return date;
  } catch (_) {}

  return null;
}

class Employee {
  final String id;
  final String name;
  final String email;
  final EmployeeRole role;

  const Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory Employee.fromJson(Map<String, dynamic> json) => Employee(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        role: EmployeeRole.fromString(json['role'] ?? 'WAITER'),
      );

  String get roleLabel {
    switch (role) {
      case EmployeeRole.admin:
        return 'Administrador';
      case EmployeeRole.kitchen:
        return 'Cozinheiro';
      case EmployeeRole.counter:
        return 'Balconista';
      case EmployeeRole.waiter:
        return 'Garçom';
    }
  }
}

enum OrderType {
  table('TABLE'),
  delivery('DELIVERY');

  final String value;
  const OrderType(this.value);

  static OrderType fromString(String s) =>
      OrderType.values.firstWhere((e) => e.value == s.toUpperCase(),
          orElse: () => OrderType.table);

  String get label {
    switch (this) {
      case OrderType.table:
        return 'Mesa';
      case OrderType.delivery:
        return 'Entrega';
    }
  }
}

enum AppRole {
  kitchen,
  counter,
  waiter;

  String get label {
    switch (this) {
      case AppRole.kitchen:
        return 'Cozinha';
      case AppRole.counter:
        return 'Balcão';
      case AppRole.waiter:
        return 'Garçom';
    }
  }
}
