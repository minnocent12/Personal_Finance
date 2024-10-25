import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/top_app_bar.dart';

class BudgetScreen extends StatefulWidget {
  final int userId;
  final String firstName;
  final String lastName;

  const BudgetScreen({
    Key? key,
    required this.userId,
    required this.firstName,
    required this.lastName,
  }) : super(key: key);

  @override
  _BudgetScreenState createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  late DatabaseHelper db;
  double monthlyBudget = 0.0;
  double totalExpenses = 0.0;
  double remainingBudget = 0.0;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    db = DatabaseHelper();
    _loadBudgetData();
  }

  void _loadBudgetData() async {
    monthlyBudget = await db.getUserBudget(widget.userId);
    totalExpenses = await db.getTotalExpenses(widget.userId);
    remainingBudget = monthlyBudget - totalExpenses;
    setState(() {});
  }

  void _showSetBudgetDialog() {
    final TextEditingController budgetController =
        TextEditingController(text: monthlyBudget.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Set Monthly Budget"),
          content: TextField(
            controller: budgetController,
            decoration: InputDecoration(labelText: 'Budget Amount (USD)'),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final budgetAmount =
                    double.tryParse(budgetController.text) ?? 0.0;
                db.setUserBudget(widget.userId, budgetAmount).then((_) {
                  _loadBudgetData();
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBudgetOverview() {
    return Column(
      children: [
        Text(
          'Monthly Budget: \$${monthlyBudget.toStringAsFixed(2)}',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          'Total Expenses: \$${totalExpenses.toStringAsFixed(2)}',
          style: TextStyle(fontSize: 16),
        ),
        Text(
          'Remaining Budget: \$${remainingBudget.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            color: remainingBudget >= 0 ? Colors.green : Colors.red,
          ),
        ),
      ],
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildBudgetOverview(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showSetBudgetDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: Text('Set Budget'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          // Handle navigation if necessary
        },
        firstName: widget.firstName,
        lastName: widget.lastName,
        userId: widget.userId,
      ),
    );
  }
}
