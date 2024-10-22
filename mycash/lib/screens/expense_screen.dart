import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/top_app_bar.dart';

class ExpenseScreen extends StatefulWidget {
  final int userId;
  final String firstName;
  final String lastName;
  final VoidCallback onDataUpdated;

  ExpenseScreen({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.onDataUpdated,
  });

  @override
  _ExpenseScreenState createState() => _ExpenseScreenState();
}

class ExpenseData {
  final String category;
  final double amount;

  ExpenseData(this.category, this.amount);
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  late DatabaseHelper db;
  List<Map<String, dynamic>> expenses = [];
  double totalExpenses = 0.0;
  Map<String, double> expenseDistribution = {};

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    db = DatabaseHelper();
    _loadExpenses();
  }

  void _loadExpenses() async {
    expenses = await db.getExpenses(widget.userId);
    totalExpenses = await db.getTotalExpenses(widget.userId);
    _calculateExpenseDistribution();
    setState(() {});
  }

  void _calculateExpenseDistribution() {
    expenseDistribution = {};
    for (var expense in expenses) {
      String category = expense['category'];
      double amount = expense['amount'];

      if (expenseDistribution.containsKey(category)) {
        expenseDistribution[category] = expenseDistribution[category]! + amount;
      } else {
        expenseDistribution[category] = amount;
      }
    }
  }

  List<charts.Series<ExpenseData, String>> _createChartData() {
    final data = expenseDistribution.entries
        .map((entry) => ExpenseData(entry.key, entry.value))
        .toList();

    return [
      charts.Series<ExpenseData, String>(
        id: 'Expenses',
        domainFn: (ExpenseData entry, _) => entry.category,
        measureFn: (ExpenseData entry, _) => entry.amount,
        data: data,
        labelAccessorFn: (ExpenseData entry, _) =>
            '${entry.category}: \$${entry.amount.toStringAsFixed(2)}',
      )
    ];
  }

  Widget _buildTableHeader() {
    return Table(
      border: TableBorder.all(color: Colors.black),
      columnWidths: {
        0: FlexColumnWidth(1.2),
        1: FlexColumnWidth(1.5),
        2: FlexColumnWidth(1.5),
        3: FlexColumnWidth(1.5),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.green),
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Category',
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Amount (\$)',
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Date',
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Actions',
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTableBody() {
    return Table(
      border: TableBorder.all(color: Colors.black),
      columnWidths: {
        0: FlexColumnWidth(1.2),
        1: FlexColumnWidth(1.5),
        2: FlexColumnWidth(1.5),
        3: FlexColumnWidth(1.5),
      },
      children: expenses.map((expense) {
        return TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(expense['category']),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('\$${expense['amount'].toStringAsFixed(2)}'),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(expense['date']),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, size: 20),
                    onPressed: () {
                      _showEditExpenseDialog(expense);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, size: 20),
                    onPressed: () {
                      db.deleteExpense(expense['id']).then((_) {
                        _loadExpenses();
                        widget.onDataUpdated(); // Notify data update
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildPieChart() {
    if (expenseDistribution.isEmpty) {
      return Center(child: Text('No data available'));
    }

    return Column(
      children: [
        Container(
          height: 200,
          child: charts.PieChart(
            _createChartData(),
            animate: true,
            defaultRenderer: charts.ArcRendererConfig(
              arcWidth: 60,
              arcRendererDecorators: [
                charts.ArcLabelDecorator(
                    labelPosition: charts.ArcLabelPosition.inside),
              ],
            ),
          ),
        ),
        Wrap(
          spacing: 10.0,
          children: expenseDistribution.keys.map((category) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 15,
                  height: 15,
                  color: Colors.primaries[
                          expenseDistribution.keys.toList().indexOf(category) %
                              Colors.primaries.length]
                      .withOpacity(1.0),
                ),
                SizedBox(width: 4),
                Text(category),
              ],
            );
          }).toList(),
        ),
      ],
    );
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
                    Expanded(
                      child: Text(
                        "Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}",
                      ),
                    ),
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
                    .then((_) {
                  _loadExpenses();
                  widget.onDataUpdated(); // Notify data update
                });

                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditExpenseDialog(Map<String, dynamic> expense) async {
    final TextEditingController amountController =
        TextEditingController(text: expense['amount'].toString());
    final TextEditingController categoryController =
        TextEditingController(text: expense['category']);
    DateTime selectedDate = DateTime.parse(expense['date']);

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
          title: Text('Edit Expense'),
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
                    Expanded(
                      child: Text(
                        "Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}",
                      ),
                    ),
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
                    .updateExpense(expense['id'], amount, category, date)
                    .then((_) {
                  _loadExpenses();
                  widget.onDataUpdated(); // Notify data update
                });

                Navigator.pop(context);
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: TopAppBar(scaffoldKey: scaffoldKey),
      drawer: CustomDrawer(
        firstName: widget.firstName,
        lastName: widget.lastName,
      ),
      body: SingleChildScrollView(
        // Make the body scrollable
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Expenses',
                    style: TextStyle(fontSize: 20, color: Colors.green),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                ElevatedButton(
                  onPressed: _showAddExpenseDialog,
                  child: Text('+ Add Expense'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            expenses.isEmpty
                ? Center(child: Text('No expenses available'))
                : Column(
                    children: [
                      _buildTableHeader(),
                      _buildTableBody(),
                    ],
                  ),
            SizedBox(height: 10), // Added spacing
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Total Expenses: \$${totalExpenses.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            _buildPieChart(),
            SizedBox(height: 20), // Added spacing at the bottom
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTap: (index) {},
        firstName: widget.firstName,
        lastName: widget.lastName,
        userId: widget.userId,
      ),
    );
  }
}
