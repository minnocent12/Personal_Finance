import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/top_app_bar.dart';

class IncomeScreen extends StatefulWidget {
  final int userId;
  final String firstName;
  final String lastName;
  final VoidCallback onDataUpdated; // Callback for data update

  IncomeScreen({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.onDataUpdated, // Accept callback
  });

  @override
  _IncomeScreenState createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  late DatabaseHelper db;
  List<Map<String, dynamic>> incomeList = [];
  double totalIncome = 0.0;
  final GlobalKey<ScaffoldState> scaffoldKey =
      GlobalKey<ScaffoldState>(); // Declare scaffoldKey here

  @override
  void initState() {
    super.initState();
    db = DatabaseHelper();
    _loadIncome();
  }

  void _loadIncome() async {
    incomeList = await db.getIncomeByUserId(widget.userId);
    totalIncome = await db.getTotalIncome(widget.userId);
    setState(() {});
  }

  Future<void> _showAddIncomeDialog() async {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController sourceController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
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
          title: Text('Add Income'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                decoration: InputDecoration(labelText: 'Amount (USD)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: sourceController,
                decoration: InputDecoration(labelText: 'Source'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}",
                      overflow: TextOverflow.ellipsis,
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
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = double.parse(amountController.text);
                final source = sourceController.text;
                final description = descriptionController.text;
                final date = DateFormat('yyyy-MM-dd').format(selectedDate);

                db
                    .addIncome(widget.userId, amount, description, date, source)
                    .then((_) {
                  _loadIncome();
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

  void _showEditIncomeDialog(Map<String, dynamic> income) async {
    final TextEditingController amountController =
        TextEditingController(text: income['amount'].toString());
    final TextEditingController sourceController =
        TextEditingController(text: income['source']);
    final TextEditingController descriptionController =
        TextEditingController(text: income['description']);
    DateTime selectedDate = DateTime.parse(income['date']);

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
          title: Text('Edit Income'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                decoration: InputDecoration(labelText: 'Amount (USD)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: sourceController,
                decoration: InputDecoration(labelText: 'Source'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}",
                      overflow: TextOverflow.ellipsis,
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
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = double.parse(amountController.text);
                final source = sourceController.text;
                final description = descriptionController.text;
                final date = DateFormat('yyyy-MM-dd').format(selectedDate);

                db
                    .updateIncome(
                        income['id'], amount, description, date, source)
                    .then((_) {
                  _loadIncome();
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
                'Source',
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
      children: incomeList.map((income) {
        return TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(income['source']),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('\$${income['amount']}'),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(income['date']),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, size: 20),
                    onPressed: () {
                      _showEditIncomeDialog(income);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, size: 20),
                    onPressed: () {
                      db.deleteIncome(income['id']).then((_) {
                        _loadIncome();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey, // Assign the key here
      appBar: TopAppBar(scaffoldKey: scaffoldKey), // Use the same key
      drawer: CustomDrawer(
        firstName: widget.firstName,
        lastName: widget.lastName,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Income',
                    style: TextStyle(fontSize: 20, color: Colors.green),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: _showAddIncomeDialog,
                  child: Text('+ Add Income'),
                ),
              ],
            ),
            SizedBox(height: 10),
            _buildTableHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: _buildTableBody(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Total Income: \$${totalIncome.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
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
