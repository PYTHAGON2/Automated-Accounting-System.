import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'models.dart';
import 'theme.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  TransactionType _type = TransactionType.income;
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedCategory;

  void _addTransaction() {
    if (_amountController.text.isEmpty || _selectedCategory == null || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid amount')));
      return;
    }

    context.read<AppState>().addTransaction(
      _type,
      amount,
      _selectedCategory!,
      _descriptionController.text,
    );

    _amountController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedCategory = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Transaction added!')));
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final categories = _type == TransactionType.income ? state.incomeCategories : state.expenseCategories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('👤 Personal Dashboard'),
        actions: [
          IconButton(onPressed: () => state.logout(), icon: const Icon(Icons.logout)),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome back, ${state.currentUser?.name}!', 
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              // Stats Grid
              LayoutBuilder(builder: (context, constraints) {
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: constraints.maxWidth > 600 ? 3 : 1,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: constraints.maxWidth > 600 ? 2 : 3,
                  children: [
                    _StatCard(title: '💚 Total Income', amount: state.totalIncome, gradient: AppColors.incomeGradient),
                    _StatCard(title: '💸 Total Expenses', amount: state.totalExpenses, gradient: AppColors.expenseGradient),
                    _StatCard(title: '💰 Net Balance', amount: state.netBalance, gradient: AppColors.primaryGradient),
                  ],
                );
              }),
              const SizedBox(height: 24),

              // Add Transaction Form
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('➕ Add New Transaction', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<TransactionType>(
                              initialValue: _type,
                              decoration: const InputDecoration(labelText: 'Type'),
                              items: const [
                                DropdownMenuItem<TransactionType>(value: TransactionType.income, child: Text('💚 Income')),
                                DropdownMenuItem<TransactionType>(value: TransactionType.expense, child: Text('💸 Expense')),
                              ],
                              onChanged: (v) => setState(() {
                                _type = v!;
                                _selectedCategory = null;
                              }),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: _amountController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'Amount', hintText: '0.00'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedCategory,
                              decoration: const InputDecoration(labelText: 'Category'),
                              items: categories.map((c) => DropdownMenuItem<String>(value: c, child: Text(c))).toList(),
                              onChanged: (v) => setState(() => _selectedCategory = v),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(labelText: 'Description', hintText: 'Enter transaction description...'),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _addTransaction,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          backgroundColor: const Color(0xFF667EEA),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Add Transaction'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Transactions Table
              Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                      ),
                      child: const Row(
                        children: [
                          Expanded(flex: 2, child: Text('Date', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                          Expanded(flex: 2, child: Text('Type', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                          Expanded(flex: 2, child: Text('Amount', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                          Expanded(flex: 3, child: Text('Description', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                          Expanded(flex: 2, child: Text('Category', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                        ],
                      ),
                    ),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.getFilteredTransactions().length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final tx = state.getFilteredTransactions()[index];
                        final isIncome = tx.type == TransactionType.income;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Expanded(flex: 2, child: Text(tx.date)),
                              Expanded(flex: 2, child: Text(tx.type.name.toUpperCase(), 
                                style: TextStyle(color: isIncome ? Colors.green : Colors.red, fontWeight: FontWeight.bold))),
                              Expanded(flex: 2, child: Text('\$${tx.amount.toStringAsFixed(2)}', 
                                style: TextStyle(color: isIncome ? Colors.green : Colors.red, fontWeight: FontWeight.bold))),
                              Expanded(flex: 3, child: Text(tx.description)),
                              Expanded(flex: 2, child: Text(tx.category)),
                            ],
                          ),
                        );
                      },
                    ),
                    if (state.getFilteredTransactions().isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(32),
                        child: Text('No transactions yet. Add your first transaction above!', 
                          textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final double amount;
  final Gradient gradient;

  const _StatCard({required this.title, required this.amount, required this.gradient});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
          Text('\$${amount.toStringAsFixed(2)}', 
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
