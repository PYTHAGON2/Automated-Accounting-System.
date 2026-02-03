enum TransactionType { income, expense }

class User {
  final String username;
  final String password;
  final String name;
  final String email;
  final String joinDate;

  User({
    required this.username,
    required this.password,
    required this.name,
    required this.email,
    required this.joinDate,
  });
}

class Admin {
  final String username;
  final String password;
  final String name;

  Admin({
    required this.username,
    required this.password,
    required this.name,
  });
}

class Transaction {
  final String id;
  final String user;
  final TransactionType type;
  final double amount;
  final String category;
  final String description;
  final String date;
  final DateTime timestamp;

  Transaction({
    required this.id,
    required this.user,
    required this.type,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
    required this.timestamp,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'user': user,
      'type': type == TransactionType.income ? 'income' : 'expense',
      'amount': amount,
      'category': category,
      'description': description,
      'date': date,
      'timestamp': timestamp,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'user_email': user,
      'type': type == TransactionType.income ? 'income' : 'expense',
      'amount': amount,
      'category': category,
      'description': description,
      'date': date,
      // Supabase expects ISO8601 for timestamptz
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Transaction.fromFirestore(String id, Map<String, dynamic> data) {
    return Transaction(
      id: id,
      user: data['user'] ?? '',
      type: data['type'] == 'income' ? TransactionType.income : TransactionType.expense,
      amount: (data['amount'] ?? 0).toDouble(),
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      date: data['date'] ?? '',
      timestamp: (data['timestamp'] as dynamic).toDate(),
    );
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id']?.toString() ?? '',
      user: json['user_email'] ?? '',
      type: json['type'] == 'income' ? TransactionType.income : TransactionType.expense,
      amount: (json['amount'] ?? 0).toDouble(),
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      date: json['date'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
