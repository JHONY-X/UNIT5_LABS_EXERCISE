import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../services/expenses_db.dart';
import '../services/prefs_service.dart';
import 'expense_editor.dart';
import 'settings_screen.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final ExpensesDb _db = ExpensesDb();
  final PrefsService _prefs = PrefsService();
  
  List<Expense> _expenses = [];
  double _monthTotal = 0.0;
  String _currencySymbol = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final now = DateTime.now();
    final total = await _db.getTotalByMonth(now.year, now.month);
    final expenses = await _db.getAll();
    
    setState(() {
      _monthTotal = total;
      _expenses = expenses;
      _currencySymbol = _prefs.getCurrency();
    });
  }

  void _navigateToAddEdit([Expense? expense]) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ExpenseEditor(expense: expense),
      ),
    );
    _loadData(); // Refresh after returning
  }

  void _navigateToSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SettingsScreen(),
      ),
    );
    _loadData(); // Refresh after returning (currency might have changed)
  }

  Future<void> _deleteExpense(Expense expense) async {
    if (expense.id != null) {
      await _db.delete(expense.id!);
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '$_currencySymbol ', decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Expenses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _navigateToSettings,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0),
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            child: Column(
              children: [
                const Text(
                  'This Month\'s Total',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Text(
                  currencyFormat.format(_monthTotal),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _expenses.isEmpty
                ? const Center(child: Text('No expenses recorded.'))
                : ListView.builder(
                    itemCount: _expenses.length,
                    itemBuilder: (context, index) {
                      final expense = _expenses[index];
                      DateTime? date;
                      try {
                        date = DateTime.parse(expense.date);
                      } catch (e) {
                        date = null;
                      }

                      return Dismissible(
                        key: ValueKey(expense.id),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => _deleteExpense(expense),
                        child: ListTile(
                          title: Text(expense.category),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(expense.note),
                              if (date != null)
                                Text(
                                  DateFormat.yMMMd().format(date),
                                  style: const TextStyle(fontSize: 12),
                                ),
                            ],
                          ),
                          trailing: Text(
                            currencyFormat.format(expense.amount),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          onTap: () => _navigateToAddEdit(expense),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddEdit(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
