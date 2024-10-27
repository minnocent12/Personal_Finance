import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/top_app_bar.dart';
import 'package:mycash/screens/goal_details_screen.dart';

class SavingsScreen extends StatefulWidget {
  final int userId;
  final String firstName;
  final String lastName;

  const SavingsScreen({
    super.key,
    required this.userId,
    required this.firstName,
    required this.lastName,
  });

  @override
  _SavingsScreenState createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  late DatabaseHelper db;
  List<Map<String, dynamic>> savingsGoals = [];
  double totalSavings = 0;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

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
    await _showSavingsGoalDialog();
  }

  Future<void> _showSavingsGoalDialog({Map<String, dynamic>? goal}) async {
    final goalNameController = TextEditingController(
      text: goal != null ? goal['goal_name'] : '',
    );
    final currentAmountController = TextEditingController(
      text: goal != null ? goal['current_amount'].toString() : '',
    );
    final targetAmountController = TextEditingController(
      text: goal != null ? goal['target_amount'].toString() : '',
    );
    DateTime? selectedDate = goal != null
        ? DateFormat('yyyy-MM-dd').parse(goal['target_date'])
        : null;

    Future<void> selectDate(BuildContext context) async {
      final picked = await showDatePicker(
        context: context,
        initialDate: selectedDate ?? DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2101),
      );
      if (picked != null) {
        setState(() {
          selectedDate = picked;
        });
      }
    }

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            bool isFormFilled() {
              return goalNameController.text.isNotEmpty &&
                  currentAmountController.text.isNotEmpty &&
                  targetAmountController.text.isNotEmpty &&
                  selectedDate != null;
            }

            return AlertDialog(
              title:
                  Text(goal != null ? 'Edit Savings Goal' : 'Add Savings Goal'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: goalNameController,
                      decoration: InputDecoration(labelText: 'Goal Name'),
                    ),
                    TextField(
                      controller: currentAmountController,
                      decoration:
                          InputDecoration(labelText: 'Current Amount (USD)'),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: targetAmountController,
                      decoration:
                          InputDecoration(labelText: 'Target Amount (USD)'),
                      keyboardType: TextInputType.number,
                    ),
                    Row(
                      children: [
                        Text(
                          "Target Date: ${selectedDate != null ? DateFormat('yyyy-MM-dd').format(selectedDate!) : 'Select Date'}",
                        ),
                        IconButton(
                          icon: Icon(Icons.calendar_today),
                          onPressed: () async {
                            await selectDate(context);
                            setState(() {}); // Update to show selected date
                          },
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
                  onPressed: isFormFilled()
                      ? () async {
                          final goalName = goalNameController.text;
                          final currentAmount =
                              double.tryParse(currentAmountController.text) ??
                                  0.0;
                          final targetAmount =
                              double.tryParse(targetAmountController.text) ??
                                  0.0;
                          final targetDate =
                              DateFormat('yyyy-MM-dd').format(selectedDate!);

                          if (goal == null) {
                            await db.addSavingsGoal(
                              widget.userId,
                              goalName,
                              targetAmount,
                              currentAmount,
                              targetDate,
                            );
                          } else {
                            await db.updateSavingsGoal(
                              goal['id'],
                              goalName,
                              targetAmount,
                              currentAmount,
                              targetDate,
                            );
                          }

                          _loadSavings();
                          Navigator.pop(context);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: Text(goal != null ? 'Update' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _openGoalDetails(int goalId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GoalDetailsScreen(
          goalId: goalId,
          userId: widget.userId, // Add this line
          firstName: widget.firstName,
          lastName: widget.lastName,
        ),
      ),
    );
  }

  void _editGoal(int goalId) {
    final goal = savingsGoals.firstWhere((goal) => goal['id'] == goalId);
    _showSavingsGoalDialog(goal: goal);
  }

  void _deleteGoal(int goalId) async {
    final confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this goal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child:
                Text(selectionColor: Color.fromARGB(1, 80, 113, 113), 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child:
                Text(selectionColor: Color.fromARGB(1, 92, 117, 143), 'Delete'),
          ),
        ],
      ),
    );
    if (confirmDelete == true) {
      await db.deleteSavingsGoal(goalId);
      _loadSavings();
    }
  }

  Widget _buildSavingsGoalList() {
    return ListView.separated(
      itemCount: savingsGoals.length,
      separatorBuilder: (context, index) => Divider(),
      itemBuilder: (context, index) {
        final goal = savingsGoals[index];
        return GestureDetector(
          onTap: () => _openGoalDetails(goal['id']),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: ListTile(
              tileColor: Colors.grey[200],
              hoverColor: Colors.green[50],
              title: Text(
                goal['goal_name'],
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Current Amount: \$${goal['current_amount']}'),
                  Text('Target Amount: \$${goal['target_amount']}'),
                  Text('Target Date: ${goal['target_date']}'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: Color.fromRGBO(8, 76, 46, 1),
                    ),
                    onPressed: () => _editGoal(goal['id']),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Color.fromRGBO(1, 31, 23, 1),
                    ),
                    onPressed: () => _deleteGoal(goal['id']),
                  ),
                ],
              ),
            ),
          ),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Savings Goal',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                  onPressed: _showAddSavingsGoalDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: Text('+ Add Savings Goal'),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
