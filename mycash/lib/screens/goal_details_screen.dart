import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/top_app_bar.dart';

class GoalDetailsScreen extends StatefulWidget {
  final int goalId;
  final String firstName;
  final String lastName;
  final int userId;

  const GoalDetailsScreen({
    Key? key,
    required this.goalId,
    required this.firstName,
    required this.lastName,
    required this.userId,
  }) : super(key: key);

  @override
  _GoalDetailsScreenState createState() => _GoalDetailsScreenState();
}

class _GoalDetailsScreenState extends State<GoalDetailsScreen> {
  late DatabaseHelper db;
  String goalName = '';
  double totalAmount = 0;
  List<Map<String, dynamic>> savingsEntries = [];
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    db = DatabaseHelper();
    _loadGoalDetails();
  }

  Future<void> _loadGoalDetails() async {
    final goal = await db.getGoal(widget.goalId);
    if (goal != null) {
      goalName = goal['goal_name'] ?? '';
      totalAmount = goal['current_amount'] ?? 0.0;
      savingsEntries = await db.getSavingsEntries(widget.goalId);
    }
    setState(() {});
  }

  Future<void> _showAddSavingsDialog() async {
    final amountController = TextEditingController();
    DateTime? selectedDate;

    Future<void> selectDate(BuildContext context) async {
      final picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
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
            return AlertDialog(
              title: Text('Add Savings Entry'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: amountController,
                      decoration: InputDecoration(labelText: 'Amount (USD)'),
                      keyboardType: TextInputType.number,
                    ),
                    Row(
                      children: [
                        Text(
                          "Date: ${selectedDate != null ? DateFormat('yyyy-MM-dd').format(selectedDate!) : 'Select Date'}",
                        ),
                        IconButton(
                          icon: Icon(Icons.calendar_today),
                          onPressed: () async {
                            await selectDate(context);
                            setState(() {});
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
                  child: Text(
                      selectionColor: Color.fromARGB(1, 80, 113, 113),
                      'Cancel'),
                ),
                ElevatedButton(
                  onPressed: amountController.text.isNotEmpty &&
                          selectedDate != null
                      ? () async {
                          final amount = double.parse(amountController.text);
                          final date =
                              DateFormat('yyyy-MM-dd').format(selectedDate!);
                          await db.addSavingsEntry(widget.goalId, amount, date);
                          await db.updateGoalCurrentAmount(
                              widget.goalId, amount);
                          _loadGoalDetails();
                          Navigator.pop(context);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _editSavingsEntry(Map<String, dynamic> entry) async {
    final amountController =
        TextEditingController(text: entry['amount'].toString());
    DateTime selectedDate = DateFormat('yyyy-MM-dd').parse(entry['date']);

    Future<void> selectDate(BuildContext context) async {
      final picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2000),
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
            return AlertDialog(
              title: Text('Edit Savings Entry'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: amountController,
                    decoration: InputDecoration(labelText: 'Amount (USD)'),
                    keyboardType: TextInputType.number,
                  ),
                  Row(
                    children: [
                      Text(
                        "Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}",
                      ),
                      IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () async {
                          await selectDate(context);
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                      selectionColor: Color.fromARGB(1, 80, 113, 113),
                      'Cancel'),
                ),
                ElevatedButton(
                  onPressed: amountController.text.isNotEmpty
                      ? () async {
                          final updatedAmount =
                              double.parse(amountController.text);
                          final updatedDate =
                              DateFormat('yyyy-MM-dd').format(selectedDate);
                          await db.updateSavingsEntry(
                              entry['id'], updatedAmount, updatedDate);
                          _loadGoalDetails();
                          Navigator.pop(context);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteSavingsEntry(int entryId, double entryAmount) async {
    final confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete'),
        content: Text('Are you sure you want to delete this entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child:
                Text(selectionColor: Color.fromARGB(1, 80, 113, 113), 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmDelete == true) {
      await db.deleteSavingsEntry(entryId);
      await db.updateGoalCurrentAmount(widget.goalId, -entryAmount);
      _loadGoalDetails();
    }
  }

  Widget _buildTable() {
    return Column(
      children: [
        Container(
          color: Colors.green[200],
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Expanded(
                    child: Text('Amount',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    child: Text('Date',
                        style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(
                    child: Text('Action',
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ),
        ),
        ...savingsEntries.map(
          (entry) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Text('\$${entry['amount'].toStringAsFixed(2)}')),
                Expanded(child: Text(entry['date'])),
                Expanded(
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.edit,
                          color: Color.fromRGBO(8, 76, 46, 1),
                        ),
                        onPressed: () => _editSavingsEntry(entry),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: Color.fromRGBO(1, 31, 23, 1),
                        ),
                        onPressed: () =>
                            _deleteSavingsEntry(entry['id'], entry['amount']),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
      drawer:
          CustomDrawer(firstName: widget.firstName, lastName: widget.lastName),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  goalName,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: _showAddSavingsDialog,
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: Text('+ Add Savings'),
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: savingsEntries.isEmpty
                  ? Center(child: Text('No savings entries available'))
                  : _buildTable(),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Total: \$${totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
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
