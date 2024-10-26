// lib/screens/budget_screen.dart

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
    super.key, // Using super-parameters as per Dart 2.17
    required this.userId,
    required this.firstName,
    required this.lastName,
  });

  @override
  // Suppressing the linter warning for private types in public API
  // ignore: library_private_types_in_public_api
  _BudgetScreenState createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  late DatabaseHelper db;
  double monthlyBudget = 0.0;
  double totalExpenses = 0.0;
  double remainingBudget = 0.0;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  bool isLoading = false; // To manage loading state

  @override
  void initState() {
    super.initState();
    db = DatabaseHelper();
    _loadBudgetData();
  }

  // Function to load budget and expenses data
  void _loadBudgetData() async {
    setState(() {
      isLoading = true;
    });
    try {
      double fetchedBudget = await db.getUserBudget(widget.userId);
      double fetchedExpenses = await db.getTotalExpenses(widget.userId);
      if (!mounted) return; // Ensure widget is still mounted
      setState(() {
        monthlyBudget = fetchedBudget;
        totalExpenses = fetchedExpenses;
        remainingBudget = monthlyBudget - totalExpenses;
      });
    } catch (e) {
      // Remove print statement; use SnackBar for user feedback
      // print('Error loading budget data: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load budget data')),
      );
    } finally {
      // Do not use return in finally
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  // Function to display the Set Budget dialog
  void _showSetBudgetDialog() {
    final TextEditingController budgetController =
        TextEditingController(text: monthlyBudget.toStringAsFixed(2));

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        // Use dialogContext to avoid confusion
        return AlertDialog(
          title: Text("Set Monthly Budget"),
          content: TextField(
            controller: budgetController,
            decoration: InputDecoration(labelText: 'Budget Amount (USD)'),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext), // Use dialogContext
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final budgetText = budgetController.text.trim();
                final budgetAmount = double.tryParse(budgetText) ?? -1.0;

                if (budgetAmount < 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Please enter a valid budget amount')),
                  );
                  return;
                }

                try {
                  await db.setUserBudget(widget.userId, budgetAmount);
                  if (!mounted) return; // Ensure widget is still mounted
                  _loadBudgetData();
                  Navigator.pop(dialogContext); // Use dialogContext
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Budget updated successfully')),
                  );
                } catch (e) {
                  // Remove print statement; use SnackBar for user feedback
                  // print('Error saving budget: $e');
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update budget')),
                  );
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

  // Widget to display budget overview
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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch, // Stretch to full width
                children: [
                  _buildBudgetOverview(),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Removed print statement to adhere to best practices
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
        currentIndex: 5,
        onTap: (index) {},
        firstName: widget.firstName,
        lastName: widget.lastName,
        userId: widget.userId,
      ), // Custom Bottom Navigation Bar
    );
  }
}
