import '../database_helper.dart';

class ClientDebtDao {
  final dbHelper = DatabaseHelper.instance;

  Future<List<Map<String, dynamic>>> findClientsWithTotalDebt() async {
    final db = await dbHelper.database;

    final result = await db.rawQuery('''
      SELECT 
        c.id,
        c.name,
        c.phone,
        c.created_at,
        (SELECT COALESCE(SUM(amount), 0) FROM debts WHERE client_id = c.id)
        -
        (SELECT COALESCE(SUM(amount), 0) FROM payments WHERE client_id = c.id)
        as total
      FROM clients c
      ORDER BY total DESC
    ''');

    return result;
  }

  Future<List<Map<String, dynamic>>> findDebtsByClient(int clientId) async {
    final db = await DatabaseHelper.instance.database;

    return await db.query(
      'debts',
      where: 'client_id = ?',
      whereArgs: [clientId],
      orderBy: 'created_at DESC',
    );
  }

  Future<double> getTotalDebt(int clientId) async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.rawQuery(
      '''
    SELECT IFNULL(SUM(amount), 0) as total
    FROM debts
    WHERE client_id = ? AND is_paid = 0
  ''',
      [clientId],
    );

    return (result.first['total'] as num).toDouble();
  }

  Future<void> addDebt(int clientId, double amount) async {
    final db = await dbHelper.database;

    await db.insert('debts', {
      'client_id': clientId,
      'amount': amount,
      'created_at': DateTime.now().toIso8601String(),
      'is_paid': 0,
    });
  }
}
