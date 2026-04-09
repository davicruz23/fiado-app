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
      (
        SELECT COALESCE(SUM(amount), 0) 
        FROM debts 
        WHERE client_id = c.id AND is_paid = 0
      ) as total
    FROM clients c
    ORDER BY total DESC
  ''');

    return result;
  }

  // Future<List<Map<String, dynamic>>> findDebtsByClient(int clientId) async {
  //   final db = await DatabaseHelper.instance.database;

  //   return await db.query(
  //     'debts',
  //     where: 'client_id = ?',
  //     whereArgs: [clientId],
  //     orderBy: 'created_at DESC',
  //   );
  // }

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

  Future<void> markDebtAsPaid(int debtId) async {
    final db = await dbHelper.database;

    await db.update(
      'debts',
      {'is_paid': 1},
      where: 'id = ?',
      whereArgs: [debtId],
    );
  }

  Future<List<Map<String, dynamic>>> findPaidDebtsByClient(int clientId) async {
    final db = await dbHelper.database;

    return await db.query(
      'debts',
      where: 'client_id = ? AND is_paid = 1',
      whereArgs: [clientId],
      orderBy: 'created_at DESC',
    );
  }

  Future<List<Map<String, dynamic>>> findOpenDebtsByClient(int clientId) async {
    final db = await dbHelper.database;

    return await db.query(
      'debts',
      where: 'client_id = ? AND is_paid = 0',
      whereArgs: [clientId],
      orderBy: 'created_at DESC',
    );
  }

  Future<void> payDebt(int debtId, double paidAmount) async {
    final db = await dbHelper.database;

    final result = await db.query(
      'debts',
      where: 'id = ?',
      whereArgs: [debtId],
    );

    if (result.isEmpty) return;

    final currentAmount = (result.first['amount'] as num).toDouble();
    final safePaid = paidAmount > currentAmount ? currentAmount : paidAmount;
    final newAmount = currentAmount - safePaid;

    // Inserir registro na tabela de pagamentos
    await db.insert('payments', {
      'client_id': result.first['client_id'],
      'amount': safePaid,
      'created_at': DateTime.now().toIso8601String(),
    });

    if (newAmount <= 0) {
      await db.update(
        'debts',
        {'amount': 0, 'is_paid': 1},
        where: 'id = ?',
        whereArgs: [debtId],
      );
    } else {
      // pagamento parcial
      await db.update(
        'debts',
        {'amount': newAmount},
        where: 'id = ?',
        whereArgs: [debtId],
      );
    }
  }

  Future<List<Map<String, dynamic>>> findPaymentsByClient(int clientId) async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.query(
      'payments',
      where: 'client_id = ?',
      whereArgs: [clientId],
      orderBy: 'created_at DESC',
    );

    return result;
  }
}
