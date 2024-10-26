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
    try {
      double fetchedBudget = await db.getUserBudget(widget.userId);
      double fetchedExpenses = await db.getTotalExpenses(widget.userId);
      setState(() {
        monthlyBudget = fetchedBudget;
        totalExpenses = fetchedExpenses;
        remainingBudget = monthlyBudget - totalExpenses;
      });
    } catch (e) {
      print('Error loading budget data: $e');
      // Optionally show an error message to the user
    }
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
              onPressed: () async {
                final budgetAmount =
                    double.tryParse(budgetController.text) ?? 0.0;
                print('Attempting to save budget: $budgetAmount'); // Debug print
                try {
                  await db.setUserBudget(widget.userId, budgetAmount);
                  print('Budget saved successfully'); // Debug print
                  _loadBudgetData();
                  Navigator.pop(context);
                } catch (e) {
                  print('Error saving budget: $e'); // Debug print
                  // Optionally show an error message to the user
                }
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
      crossAxisAlignment: CrossAxisAlignment.start, // Align texts to the start
      children: [
        Text(
          'Monthly Budget: \$${monthlyBudget.toStringAsFixed(2)}',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'Total Expenses: \$${totalExpenses.toStringAsFixed(2)}',
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 8),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch to full width
          children: [
            _buildBudgetOverview(),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                print('Set Budget button pressed'); // Debug print
                _showSetBudgetDialog();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 16.0),
              ),
              child: Text(
                'Set Budget',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          print('BottomNavBar tapped: $index'); // Debug print
          // Handle navigation based on index
          // Example:
          // if (index == 0) Navigator.pushNamed(context, '/home');
        },
        firstName: widget.firstName,
        lastName: widget.lastName,
        userId: widget.userId,
      ),
    );
  }
}
