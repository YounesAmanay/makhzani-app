import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/merchant.dart';
import '../models/product.dart';
import '../models/supplier.dart';
import '../models/purchase_order.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'makhzani.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE merchants(
        id TEXT PRIMARY KEY,
        business_name TEXT,
        owner_name TEXT,
        phone_number TEXT NOT NULL,
        email TEXT,
        address TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE suppliers(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        business_name TEXT,
        phone_number TEXT NOT NULL,
        email TEXT,
        address TEXT,
        is_active INTEGER DEFAULT 1,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE products(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        unit TEXT,
        sale_price REAL,
        purchase_price REAL,
        current_stock INTEGER DEFAULT 0,
        min_stock_level INTEGER,
        is_active INTEGER DEFAULT 1,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE purchase_orders(
        id TEXT PRIMARY KEY,
        order_number TEXT NOT NULL,
        supplier_id TEXT NOT NULL,
        notes TEXT,
        pdf_generated_at TEXT,
        sent_at TEXT,
        sent_via TEXT,
        is_active INTEGER DEFAULT 1,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE purchase_order_items(
        id TEXT PRIMARY KEY,
        purchase_order_id TEXT NOT NULL,
        product_id TEXT NOT NULL,
        product_name_snapshot TEXT,
        quantity INTEGER NOT NULL,
        unit_price REAL NOT NULL,
        total_price REAL NOT NULL,
        FOREIGN KEY (purchase_order_id) REFERENCES purchase_orders(id),
        FOREIGN KEY (product_id) REFERENCES products(id)
      )
    ''');
  }

  // Merchant operations
  Future<void> saveMerchant(Merchant merchant) async {
    final db = await database;
    await db.insert(
      'merchants',
      merchant.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Merchant?> getMerchant() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('merchants', limit: 1);

    if (maps.isNotEmpty) {
      return Merchant.fromJson(maps.first);
    }
    return null;
  }

  // Products operations
  Future<void> saveProducts(List<Product> products) async {
    final db = await database;
    final batch = db.batch();

    await db.delete('products');

    for (final product in products) {
      batch.insert('products', product.toJson());
    }

    await batch.commit();
  }

  Future<List<Product>> getProducts({String? search}) async {
    final db = await database;
    String whereClause = 'is_active = 1';
    List<dynamic> whereArgs = [];

    if (search != null && search.isNotEmpty) {
      whereClause += ' AND name LIKE ?';
      whereArgs.add('%$search%');
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: whereClause,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'name ASC',
    );

    return List.generate(maps.length, (i) => Product.fromJson(maps[i]));
  }

  Future<List<Product>> getLowStockProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT * FROM products
      WHERE is_active = 1
      AND min_stock_level IS NOT NULL
      AND current_stock <= min_stock_level
      ORDER BY name ASC
    ''');

    return List.generate(maps.length, (i) => Product.fromJson(maps[i]));
  }

  // Suppliers operations
  Future<void> saveSuppliers(List<Supplier> suppliers) async {
    final db = await database;
    final batch = db.batch();

    await db.delete('suppliers');

    for (final supplier in suppliers) {
      batch.insert('suppliers', supplier.toJson());
    }

    await batch.commit();
  }

  Future<List<Supplier>> getSuppliers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'suppliers',
      where: 'is_active = 1',
      orderBy: 'name ASC',
    );

    return List.generate(maps.length, (i) => Supplier.fromJson(maps[i]));
  }

  // Purchase Orders operations
  Future<void> savePurchaseOrders(List<PurchaseOrder> orders) async {
    final db = await database;
    final batch = db.batch();

    await db.delete('purchase_order_items');
    await db.delete('purchase_orders');

    for (final order in orders) {
      batch.insert('purchase_orders', {
        'id': order.id,
        'order_number': order.orderNumber,
        'supplier_id': order.supplierId,
        'notes': order.notes,
        'pdf_generated_at': order.pdfGeneratedAt?.toIso8601String(),
        'sent_at': order.sentAt?.toIso8601String(),
        'sent_via': order.sentVia,
        'is_active': order.isActive ? 1 : 0,
        'created_at': order.createdAt?.toIso8601String(),
        'updated_at': order.updatedAt?.toIso8601String(),
      });

      for (final item in order.items) {
        batch.insert('purchase_order_items', {
          'id': item.id,
          'purchase_order_id': order.id,
          'product_id': item.productId,
          'product_name_snapshot': item.productNameSnapshot,
          'quantity': item.quantity,
          'unit_price': item.unitPrice,
          'total_price': item.totalPrice,
        });
      }
    }

    await batch.commit();
  }

  Future<List<PurchaseOrder>> getPurchaseOrders({bool? sent}) async {
    final db = await database;
    String whereClause = 'is_active = 1';

    if (sent != null) {
      if (sent) {
        whereClause += ' AND sent_at IS NOT NULL';
      } else {
        whereClause += ' AND sent_at IS NULL';
      }
    }

    final List<Map<String, dynamic>> orderMaps = await db.query(
      'purchase_orders',
      where: whereClause,
      orderBy: 'created_at DESC',
    );

    List<PurchaseOrder> orders = [];

    for (final orderMap in orderMaps) {
      final itemMaps = await db.query(
        'purchase_order_items',
        where: 'purchase_order_id = ?',
        whereArgs: [orderMap['id']],
      );

      final items = itemMaps.map((itemMap) => PurchaseOrderItem.fromJson(itemMap)).toList();

      final order = PurchaseOrder(
        id: orderMap['id'],
        orderNumber: orderMap['order_number'],
        supplierId: orderMap['supplier_id'],
        items: items,
        notes: orderMap['notes'],
        pdfGeneratedAt: orderMap['pdf_generated_at'] != null
            ? DateTime.parse(orderMap['pdf_generated_at'])
            : null,
        sentAt: orderMap['sent_at'] != null ? DateTime.parse(orderMap['sent_at']) : null,
        sentVia: orderMap['sent_via'],
        isActive: orderMap['is_active'] == 1,
        createdAt: orderMap['created_at'] != null ? DateTime.parse(orderMap['created_at']) : null,
        updatedAt: orderMap['updated_at'] != null ? DateTime.parse(orderMap['updated_at']) : null,
      );

      orders.add(order);
    }

    return orders;
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('purchase_order_items');
    await db.delete('purchase_orders');
    await db.delete('products');
    await db.delete('suppliers');
    await db.delete('merchants');
  }
}