import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'models.dart';
import 'theme.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String? _userFilter;
  TransactionType? _typeFilter;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final transactions = state.getFilteredTransactions(userFilter: _userFilter, typeFilter: _typeFilter);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🛡️ Admin Dashboard'),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Welcome back, Admin ${state.currentAdmin?.name}!', 
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  if (state.isSyncing)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    ),
                ],
              ),
              if (state.lastError != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(child: Text(state.lastError!, style: const TextStyle(color: Colors.red))),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              
              // Admin Stats Grid
              LayoutBuilder(builder: (context, constraints) {
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: constraints.maxWidth > 600 ? 3 : 1,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: constraints.maxWidth > 600 ? 2 : 3,
                  children: [
                    _AdminStatCard(title: '👥 Active Users', value: state.totalUsersCount.toString()),
                    _AdminStatCard(title: '📊 Total Transactions', value: state.totalTransactionsCount.toString()),
                    _AdminStatCard(title: '💰 System Balance', value: '\$${state.systemTotalBalance.toStringAsFixed(2)}'),
                  ],
                );
              }),
              const SizedBox(height: 24),

              // Filter Section
              Card(
                color: const Color(0xFFFFF5F5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFFF6B6B), width: 2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String?>(
                          initialValue: _userFilter,
                          decoration: const InputDecoration(labelText: 'Filter by User'),
                          items: [
                            const DropdownMenuItem<String?>(value: null, child: Text('All Users')),
                            ...state.allUserEmails.map((email) => DropdownMenuItem<String?>(value: email, child: Text(email))),
                          ],
                          onChanged: (v) => setState(() => _userFilter = v),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<TransactionType?>(
                          initialValue: _typeFilter,
                          decoration: const InputDecoration(labelText: 'Filter by Type'),
                          items: const [
                            DropdownMenuItem<TransactionType?>(value: null, child: Text('All Types')),
                            DropdownMenuItem<TransactionType?>(value: TransactionType.income, child: Text('Income Only')),
                            DropdownMenuItem<TransactionType?>(value: TransactionType.expense, child: Text('Expenses Only')),
                          ],
                          onChanged: (v) => setState(() => _typeFilter = v),
                        ),
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
                        gradient: AppColors.adminGradient,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                      ),
                      child: const Row(
                        children: [
                          Expanded(flex: 2, child: Text('Date', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                          Expanded(flex: 2, child: Text('User (Email)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
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
                      itemCount: transactions.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final tx = transactions[index];
                        final isIncome = tx.type == TransactionType.income;
                        final userName = tx.user;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Expanded(flex: 2, child: Text(tx.date)),
                              Expanded(flex: 2, child: Text(userName, style: const TextStyle(fontWeight: FontWeight.bold))),
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
                    if (transactions.isEmpty && !state.isSyncing)
                      Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          state.lastError != null 
                            ? 'Failed to fetch data. Check your Firebase permissions.'
                            : 'No transactions found matching the current filters.', 
                          textAlign: TextAlign.center, 
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    if (state.isSyncing && transactions.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: CircularProgressIndicator()),
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

class _AdminStatCard extends StatelessWidget {
  final String title;
  final String value;

  const _AdminStatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.adminGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
          Text(value, 
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
