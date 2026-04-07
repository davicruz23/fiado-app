class Debt {
  final int? id;
  final int clientId;
  final double amount;
  final String? description;
  final String createdAt;
  final int isPaid;

  Debt({
    this.id,
    required this.clientId,
    required this.amount,
    this.description,
    required this.createdAt,
    this.isPaid = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'client_id': clientId,
      'amount': amount,
      'description': description,
      'created_at': createdAt,
      'is_paid': isPaid,
    };
  }

  factory Debt.fromMap(Map<String, dynamic> map) {
    return Debt(
      id: map['id'],
      clientId: map['client_id'],
      amount: map['amount'],
      description: map['description'],
      createdAt: map['created_at'],
      isPaid: map['is_paid'],
    );
  }
}
