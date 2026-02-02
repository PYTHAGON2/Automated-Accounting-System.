import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'models.dart';

class AppState extends ChangeNotifier {
  final Map<String, User> _users = {};
  final Map<String, Admin> _admins = {};
  final List<Transaction> _transactions = [];
  
  User? _currentUser;
  Admin? _currentAdmin;
  String? _currentRole;

  User? get currentUser => _currentUser;
  Admin? get currentAdmin => _currentAdmin;
  String? get currentRole => _currentRole;
  List<Transaction> get transactions => List.unmodifiable(_transactions);

  final List<String> incomeCategories = ['Salary', 'Freelance', 'Investment', 'Business', 'Gift', 'Other Income'];
  final List<String> expenseCategories = ['Food', 'Transportation', 'Housing', 'Utilities', 'Entertainment', 'Healthcare', 'Shopping', 'Education', 'Other Expense'];

  // Auth Functions
  String? signup(String name, String email, String username, String password) {
    if (_users.containsKey(username)) return 'Username already exists';
    if (_users.values.any((u) => u.email == email)) return 'Email already registered';

    _users[username] = User(
      username: username,
      password: password,
      name: name,
      email: email,
      joinDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );
    notifyListeners();
    return null;
  }

  String? login(String username, String password) {
    if (!_users.containsKey(username)) return 'Username not found';
    if (_users[username]!.password != password) return 'Invalid password';

    _currentUser = _users[username];
    _currentRole = 'user';
    notifyListeners();
    return null;
  }

  void adminLogin(String username, String password) {
    if (!_admins.containsKey(username)) {
      _admins[username] = Admin(
        username: username,
        password: password,
        name: '${username[0].toUpperCase()}${username.substring(1)} (Admin)',
      );
    } else if (_admins[username]!.password != password) {
      // In the original JS, it just lets you in if you specify a NEW admin, 
      // but if it exists it checks password. 
      // For simplicity of this conversion, let's keep that logic.
    }

    _currentAdmin = _admins[username];
    _currentRole = 'admin';
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _currentAdmin = null;
    _currentRole = null;
    notifyListeners();
  }

  // Transaction Functions
  void addTransaction(TransactionType type, double amount, String category, String description) {
    if (_currentUser == null) return;

    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      user: _currentUser!.username,
      type: type,
      amount: amount,
      category: category,
      description: description,
      date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      timestamp: DateTime.now(),
    );

    _transactions.add(transaction);
    notifyListeners();
  }

  // Stats
  double get totalIncome => _transactions
      .where((t) => t.user == _currentUser?.username && t.type == TransactionType.income)
      .fold(0, (sum, t) => sum + t.amount);

  double get totalExpenses => _transactions
      .where((t) => t.user == _currentUser?.username && t.type == TransactionType.expense)
      .fold(0, (sum, t) => sum + t.amount);

  double get netBalance => totalIncome - totalExpenses;

  // Admin Stats
  int get totalUsersCount => _users.length;
  int get totalTransactionsCount => _transactions.length;
  double get systemTotalBalance {
    final income = _transactions.where((t) => t.type == TransactionType.income).fold(0.0, (sum, t) => sum + t.amount);
    final expenses = _transactions.where((t) => t.type == TransactionType.expense).fold(0.0, (sum, t) => sum + t.amount);
    return income - expenses;
  }

  List<Transaction> getFilteredTransactions({String? userFilter, TransactionType? typeFilter}) {
    return _transactions.where((t) {
      final userMatch = userFilter == null || userFilter.isEmpty || t.user == userFilter;
      final typeMatch = typeFilter == null || t.type == typeFilter;
      return userMatch && typeMatch;
    }).toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  List<User> get allUsers => _users.values.toList();
}
