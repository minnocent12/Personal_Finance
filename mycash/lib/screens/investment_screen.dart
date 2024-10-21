import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/custom_drawer.dart';

class InvestmentScreen extends StatefulWidget {
  final int userId;
  final String firstName;
  final String lastName;

  InvestmentScreen(
      {required this.userId, required this.firstName, required this.lastName});

  @override
  _InvestmentScreenState createState() => _InvestmentScreenState();
}

class _InvestmentScreenState extends State<InvestmentScreen> {
  late DatabaseHelper db;
  List<Map<String, dynamic>> investments = [];
  double totalInvestments = 0;

  @override
  void initState() {
    super.initState();
    db = DatabaseHelper();
    _loadInvestments();
  }

  void _loadInvestments() async {
    investments = await db.getInvestments(widget.userId);
    totalInvestments = await db.getTotalInvestments(widget.userId);
    setState(() {});
  }

  Future<void> _showAddInvestmentDialog() async {
    final TextEditingController investmentTypeController =
        TextEditingController();
    final TextEditingController currentValueController =
        TextEditingController();
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
          title: Text('Add Investment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: investmentTypeController,
                  decoration: InputDecoration(labelText: 'Investment Type'),
                ),
                TextField(
                  controller: currentValueController,
                  decoration: InputDecoration(labelText: 'Current Value (USD)'),
                  keyboardType: TextInputType.number,
                ),
                Row(
                  children: [
                    Text(
                      "Purchase Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}",
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
                final investmentType = investmentTypeController.text;
                final currentValue = double.parse(currentValueController.text);
                final purchaseDate =
                    DateFormat('yyyy-MM-dd').format(selectedDate);

                db
                    .addInvestment(widget.userId, investmentType, currentValue,
                        purchaseDate)
                    .then((_) => _loadInvestments());

                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInvestmentList() {
    return DataTable(
      columns: [
        DataColumn(label: Text('Investment Type')),
        DataColumn(label: Text('Current Value')),
        DataColumn(label: Text('Purchase Date')),
      ],
      rows: investments
          .map((investment) => DataRow(cells: [
                DataCell(Text(investment['investment_type'])),
                DataCell(Text(
                    '\$${investment['current_value'].toStringAsFixed(2)}')),
                DataCell(Text(investment['purchase_date'])),
              ]))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Investments'),
      ),
      drawer: CustomDrawer(
        firstName: widget.firstName,
        lastName: widget.lastName,
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _showAddInvestmentDialog,
            child: Text('+ Add Investment'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
          ),
          Expanded(
            child: investments.isEmpty
                ? Center(child: Text('No investments available'))
                : _buildInvestmentList(),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Total Investments: \$${totalInvestments.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
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
