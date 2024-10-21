import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/custom_drawer.dart';

class ExpenseScreen extends StatefulWidget {
  final int userId;
  final String firstName;
  final String lastName;

  ExpenseScreen(
      {required this.userId, required this.firstName, required this.lastName});

  @override
  _ExpenseScreenState createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  late DatabaseHelper db;
  List<Map<String, dynamic>> expenses = [];
  double totalExpenses = 0;

  @override
  void initState() {
    super.initState();
    db = DatabaseHelper();
    _loadExpenses();
  }

  void _loadExpenses() async {
    expenses = await db.getExpenses(widget.userId);
    totalExpenses = await db.getTotalExpenses(widget.userId);
    setState(() {});
  }

  Future<void> _showAddExpenseDialog() async {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController categoryController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    Future<void> _selectDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );
      if (picked != null && picked != selectedDate) {
        setState(() {
          selectedDate = picked;
        });
      }
    }

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Expense'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: categoryController,
                  decoration: InputDecoration(labelText: 'Category'),
                ),
                TextField(
                  controller: amountController,
                  decoration: InputDecoration(labelText: 'Amount (USD)'),
                  keyboardType: TextInputType.number,
                ),
                Row(
                  children: [
                    Text(
                        "Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}"),
                    IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = double.parse(amountController.text);
                final category = categoryController.text;
                final date = DateFormat('yyyy-MM-dd').format(selectedDate);

                db
                    .addExpense(widget.userId, amount, '', category, date)
                    .then((_) => _loadExpenses());

                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildExpenseList() {
    return DataTable(
      columns: [
        DataColumn(label: Text('Category')),
        DataColumn(label: Text('Amount')),
        DataColumn(label: Text('Date')),
      ],
      rows: expenses
          .map((expense) => DataRow(cells: [
                DataCell(Text(expense['category'])),
                DataCell(Text('\$${expense['amount'].toStringAsFixed(2)}')),
                DataCell(Text(expense['date'])),
              ]))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expenses'),
      ),
      drawer: CustomDrawer(
        firstName: widget.firstName,
        lastName: widget.lastName,
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _showAddExpenseDialog,
            child: Text('+ Add Expense'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
          ),
          Expanded(
            child: expenses.isEmpty
                ? Center(child: Text('No expenses available'))
                : _buildExpenseList(),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Total Expenses: \$${totalExpenses.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTap: (index) {},
        firstName: widget.firstName,
        lastName: widget.lastName,
        userId: widget.userId,
      ),
    );
  }
}
