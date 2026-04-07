class Payment {
  final int? id;
  final int clientId;
  final double amount;
  final String createdAt;

  Payment({
    this.id,
    required this.clientId,
    required this.amount,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'client_id': clientId,
      'amount': amount,
      'created_at': createdAt,
    };
  }

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'],
      clientId: map['client_id'],
      amount: map['amount'],
      createdAt: map['created_at'],
    );
  }
}
