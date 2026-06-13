import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import '../models/models.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Stream<List<RestaurantTable>> streamTables() {
    return _db.collection('tables').snapshots().map((snapshot) {
      final list = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return RestaurantTable.fromJson(data);
      }).toList();

      list.sort((a, b) {
        final numA = int.tryParse(a.number);
        final numB = int.tryParse(b.number);
        if (numA != null && numB != null) return numA.compareTo(numB);
        if (numA != null) return -1;
        if (numB != null) return 1;
        return a.number.compareTo(b.number);
      });

      return list;
    });
  }

  static Future<void> updateTableStatus(String id, String status) async {
    await _db.collection('tables').doc(id).update({'status': status});
  }

  static Future<void> closeTableAccount(String tableId) async {
    await updateTableStatus(tableId, TableStatus.free.value);
  }

  static Future<void> addTable(RestaurantTable table) async {
    await _db.collection('tables').add(_tableToJson(table));
  }

  static Future<void> setTableNumber({
    required String number,
    int capacity = 4,
  }) async {
    await _db.collection('tables').doc(_tableDocId(number)).set({
      'number': number,
      'status': TableStatus.free.value,
      'capacity': capacity,
    });
  }

  static Future<void> deleteTable(String id) async {
    await _db.collection('tables').doc(id).delete();
  }

  static Stream<List<Order>> streamOrders() {
    return _db
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;

              if (data['createdAt'] is Timestamp) {
                data['createdAt'] =
                    (data['createdAt'] as Timestamp).toDate().toIso8601String();
              }

              return Order.fromJson(data);
            }).toList());
  }

  static Future<void> createOrder({
    required String displayId,
    String? tableId,
    RestaurantTable? table,
    OrderType orderType = OrderType.table,
    OrderSource source = OrderSource.counter,
    PaymentStatus paymentStatus = PaymentStatus.pending,
    DeliveryAddress? deliveryAddress,
    required List<Map<String, dynamic>> items,
    String observations = '',
  }) async {
    await _db.collection('orders').add({
      'displayId': displayId,
      'type': orderType.value,
      'source': source.value,
      'paymentStatus': paymentStatus.value,
      'tableId': tableId,
      'table': table != null ? _tableToJson(table) : null,
      'deliveryAddress': deliveryAddress?.toJson(),
      'items': items,
      'observations': observations,
      'status': OrderStatus.pending.value,
      'createdAt': FieldValue.serverTimestamp(),
      'paidAt': paymentStatus == PaymentStatus.paid
          ? FieldValue.serverTimestamp()
          : null,
    });

    if (tableId != null && orderType == OrderType.table) {
      await updateTableStatus(tableId, TableStatus.occupied.value);
    }
  }

  static Future<void> updateOrderStatus(String id, String status) async {
    await _db.collection('orders').doc(id).update({'status': status});
  }

  static Future<void> deleteOrder(String id) async {
    await _db.collection('orders').doc(id).delete();
  }

  static Stream<List<Product>> streamProducts() {
    return _db
        .collection('products')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return Product.fromJson(data);
            }).toList());
  }

  static Stream<List<Category>> streamCategories() {
    return _db
        .collection('categories')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return Category.fromJson(data);
            }).toList());
  }

  static Future<void> setEmployeePresence({
    required String uid,
    required String name,
    required String email,
    required EmployeeRole role,
    required bool isOnline,
  }) async {
    await _db.collection('presence').doc(uid).set({
      'name': name,
      'email': email,
      'role': role.value,
      'isOnline': isOnline,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Map<String, dynamic> _tableToJson(RestaurantTable t) => {
        'id': t.id,
        'number': t.number,
        'status': t.status.value,
        'capacity': t.capacity,
      };

  static String _tableDocId(String number) =>
      'table_${number.trim().padLeft(2, '0')}';
}
