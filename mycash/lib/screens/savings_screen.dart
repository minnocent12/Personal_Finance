import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/custom_drawer.dart';

class SavingsScreen extends StatefulWidget {
  final int userId;
  final String firstName;
  final String lastName;

  const SavingsScreen(
      {super.key, required this.userId, required this.firstName, required this.lastName});

  @override
  _SavingsScreenState createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  late DatabaseHelper db;
  List<Map<String, dynamic>> savingsGoals = [];
  double totalSavings = 0;

  @override
  void initState() {
    super.initState();
    db = DatabaseHelper();
    _loadSavings();
  }

  void _loadSavings() async {
    savingsGoals = await db.getSavingsGoals(widget.userId);
    totalSavings = await db.getTotalSavings(widget.userId);
    setState(() {});
  }

  Future<void> _showAddSavingsGoalDialog() async {
    final TextEditingController goalNameController = TextEditingController();
    final TextEditingController targetAmountController =
        TextEditingController();
    DateTime selectedDate = DateTime.now();

    Future<void> selectDate(BuildContext context) async {
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
          title: Text('Add Savings Goal'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: goalNameController,
                  decoration: InputDecoration(labelText: 'Goal Name'),
                ),
                TextField(
                  controller: targetAmountController,
                  decoration: InputDecoration(labelText: 'Target Amount (USD)'),
                  keyboardType: TextInputType.number,
                ),
                Row(
                  children: [
                    Text(
                      "Target Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}",
                    ),
                    IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () => selectDate(context),
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
                final goalName = goalNameController.text;
                final targetAmount = double.parse(targetAmountController.text);
                final targetDate =
                    DateFormat('yyyy-MM-dd').format(selectedDate);

                db
                    .addSavingsGoal(
                        widget.userId, goalName, targetAmount, targetDate)
                    .then((_) => _loadSavings());

                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSavingsGoalList() {
    return DataTable(
      columns: [
        DataColumn(label: Text('Goal Name')),
        DataColumn(label: Text('Target Amount')),
        DataColumn(label: Text('Target Date')),
      ],
      rows: savingsGoals
          .map((goal) => DataRow(cells: [
                DataCell(Text(goal['goal_name'])),
                DataCell(Text('\$${goal['target_amount'].toStringAsFixed(2)}')),
                DataCell(Text(goal['target_date'])),
              ]))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Savings Goals'),
      ),
      drawer: CustomDrawer(
        firstName: widget.firstName,
        lastName: widget.lastName,
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _showAddSavingsGoalDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: Text('+ Add Savings Goal'),
          ),
          Expanded(
            child: savingsGoals.isEmpty
                ? Center(child: Text('No savings goals available'))
                : _buildSavingsGoalList(),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Total Savings: \$${totalSavings.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 3,
        onTap: (index) {},
        firstName: widget.firstName,
        lastName: widget.lastName,
        userId: widget.userId,
      ),
    );
  }
}
