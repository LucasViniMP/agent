import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class SeedService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> seedDatabase() async {
    try {
      final List<Map<String, dynamic>> tables = [
        {'number': '02', 'status': 'FREE', 'capacity': 2},
        {'number': '03', 'status': 'FREE', 'capacity': 4},
        {'number': '04', 'status': 'FREE', 'capacity': 6},
        {'number': '05', 'status': 'FREE', 'capacity': 8},
      ];

      for (var t in tables) {
        await _db.collection('tables').add(t);
      }

      final catLanches = await _db.collection('categories').add({'name': 'Lanches'});
      final catPorcoes = await _db.collection('categories').add({'name': 'Porções'});
      final catSobremesas = await _db.collection('categories').add({'name': 'Sobremesas'});

      final List<Map<String, dynamic>> products = [
        {
          'name': 'X-Burguer',
          'description': 'Pão, carne 150g e queijo',
          'price': 22.90,
          'category': {'id': catLanches.id, 'name': 'Lanches'}
        },
        {
          'name': 'X-Bacon',
          'description': 'Pão, carne 150g, queijo e muito bacon',
          'price': 28.90,
          'category': {'id': catLanches.id, 'name': 'Lanches'}
        },
        {
          'name': 'Batata Frita',
          'description': 'Porção 500g',
          'price': 35.00,
          'category': {'id': catPorcoes.id, 'name': 'Porções'}
        },
        {
          'name': 'Frango a Passarinho',
          'description': 'Porção 800g com alho',
          'price': 45.00,
          'category': {'id': catPorcoes.id, 'name': 'Porções'}
        },
        {
          'name': 'Pudim',
          'description': 'Fatia deliciosa de pudim de leite condensado',
          'price': 12.00,
          'category': {'id': catSobremesas.id, 'name': 'Sobremesas'}
        },
        {
          'name': 'Sorvete',
          'description': '2 bolas (morango ou chocolate)',
          'price': 15.50,
          'category': {'id': catSobremesas.id, 'name': 'Sobremesas'}
        },
      ];

      for (var p in products) {
        await _db.collection('products').add(p);
      }
      
      debugPrint('Database seeded successfully!');
    } catch (e) {
      debugPrint('Error seeding database: $e');
    }
  }
}
