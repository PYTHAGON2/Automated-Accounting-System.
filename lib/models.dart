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
}
