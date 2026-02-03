import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'dart:async';
import 'models.dart';

class AppState extends ChangeNotifier {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  User? _currentUser;
  Admin? _currentAdmin;
  String? _currentRole;
  List<Transaction> _transactions = [];
  StreamSubscription? _transactionSubscription;

  User? get currentUser => _currentUser;
  Admin? get currentAdmin => _currentAdmin;
  String? get currentRole => _currentRole;
  List<Transaction> get transactions => List.unmodifiable(_transactions);

  final List<String> incomeCategories = ['Salary', 'Freelance', 'Investment', 'Business', 'Gift', 'Other Income'];
  final List<String> expenseCategories = ['Food', 'Transportation', 'Housing', 'Utilities', 'Entertainment', 'Healthcare', 'Shopping', 'Education', 'Other Expense'];

  AppState() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(auth.User? firebaseUser) async {
    if (firebaseUser == null) {
      _currentUser = null;
      _currentRole = null;
      _transactions = [];
      _transactionSubscription?.cancel();
    } else {
      _currentUser = User(
        username: firebaseUser.email ?? firebaseUser.uid,
        password: '', 
        name: firebaseUser.displayName ?? firebaseUser.email?.split('@')[0] ?? 'User',
        email: firebaseUser.email ?? '',
        joinDate: firebaseUser.metadata.creationTime != null 
          ? DateFormat('yyyy-MM-dd').format(firebaseUser.metadata.creationTime!) 
          : DateFormat('yyyy-MM-dd').format(DateTime.now()),
      );
      _currentRole = 'user';
      _listenToTransactions();
    }
    notifyListeners();
  }

  void _listenToTransactions() {
    _transactionSubscription?.cancel();
    
    Query query = _firestore.collection('transactions');
    if (_currentRole != 'admin') {
      query = query.where('user', isEqualTo: _currentUser?.username);
    }

    _transactionSubscription = query.snapshots().listen((snapshot) {
      _transactions = snapshot.docs.map((doc) {
        return Transaction.fromFirestore(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
      _transactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      notifyListeners();
    });
  }

  // Auth Functions
  Future<String?> signup(String name, String email, String username, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.updateDisplayName(name);
      return null;
    } on auth.FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on auth.FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  void adminLogin(String username, String password) {
    _currentAdmin = Admin(
      username: username,
      password: password,
      name: '${username[0].toUpperCase()}${username.substring(1)} (Admin)',
    );
    _currentRole = 'admin';
    _listenToTransactions();
    notifyListeners();
  }

  Future<void> logout() async {
    await _auth.signOut();
    _currentAdmin = null;
    _currentRole = null;
    notifyListeners();
  }

  // Transaction Functions
  Future<void> addTransaction(TransactionType type, double amount, String category, String description) async {
    if (_currentUser == null) return;

    final transaction = Transaction(
      id: '', 
      user: _currentUser!.username,
      type: type,
      amount: amount,
      category: category,
      description: description,
      date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      timestamp: DateTime.now(),
    );

    await _firestore.collection('transactions').add(transaction.toFirestore());
  }

  // Stats
  double get totalIncome => _transactions
      .where((t) => (_currentRole == 'admin' || t.user == _currentUser?.username) && t.type == TransactionType.income)
      .fold(0.0, (previousValue, t) => previousValue + t.amount);

  double get totalExpenses => _transactions
      .where((t) => (_currentRole == 'admin' || t.user == _currentUser?.username) && t.type == TransactionType.expense)
      .fold(0.0, (previousValue, t) => previousValue + t.amount);

  double get netBalance => totalIncome - totalExpenses;

  // Admin Stats
  int get totalUsersCount => _transactions.map((t) => t.user).toSet().length;
  int get totalTransactionsCount => _transactions.length;
  double get systemTotalBalance => totalIncome - totalExpenses;

  List<Transaction> getFilteredTransactions({String? userFilter, TransactionType? typeFilter}) {
    return _transactions.where((t) {
      final userMatch = userFilter == null || userFilter.isEmpty || t.user == userFilter;
      final typeMatch = typeFilter == null || t.type == typeFilter;
      return userMatch && typeMatch;
    }).toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  List<String> get allUserEmails => _transactions.map((t) => t.user).toSet().toList().cast<String>();

  @override
  void dispose() {
    _transactionSubscription?.cancel();
    super.dispose();
  }
}
