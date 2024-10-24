import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/top_app_bar.dart';

class InvestmentScreen extends StatefulWidget {
  final int userId;
  final String firstName;
  final String lastName;
  final VoidCallback onDataUpdated; // Callback for data update

  InvestmentScreen({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.onDataUpdated, // Accept callback
  });

  @override
  _InvestmentScreenState createState() => _InvestmentScreenState();
}

class _InvestmentScreenState extends State<InvestmentScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Map<String, dynamic>> _investments = [];
  bool _isLoading = true;

  // Controllers for the dialog
  TextEditingController _investmentTypeController = TextEditingController();
  TextEditingController _currentValueController = TextEditingController();
  TextEditingController _amountInvestedController = TextEditingController();
  TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInvestments();
  }

  Future<void> _loadInvestments() async {
    final user = Provider.of<UserProvider>(context, listen: false).currentUser;

    if (user != null) {
      final investments = await _dbHelper.getInvestments(
          user.id); // Assuming 'id' is the user's ID in User model
      setState(() {
        _investments = investments;
        _isLoading = false;
      });
    }
  }

  Future<void> _addOrUpdateInvestment({int? id}) async {
    final user = Provider.of<UserProvider>(context, listen: false).currentUser;

    if (user != null) {
      final investmentType = _investmentTypeController.text;
      final currentValue = double.parse(_currentValueController.text);
      final amountInvested = double.parse(_amountInvestedController.text);
      final purchaseDate = _dateController.text;

      if (id == null) {
        // Add new investment
        await _dbHelper.addInvestment(
          user.id,
          investmentType,
          currentValue,
          amountInvested,
          purchaseDate,
        );
      } else {
        // Update existing investment
        await _dbHelper.updateinvestments(
          id,
          investmentType,
          currentValue,
          amountInvested,
          purchaseDate,
        );
      }

      _resetForm();
      _loadInvestments();
      Navigator.of(context).pop(); // Close the dialog
    }
  }

  Future<void> _deleteInvestment(int id) async {
    await _dbHelper.deleteinvestments(id);
    _loadInvestments();
  }

  void _resetForm() {
    _investmentTypeController.clear();
    _currentValueController.clear();
    _amountInvestedController.clear();
    _dateController.clear();
  }

  void _showInvestmentDialog(
      {int? id,
      String? investmentType,
      double? currentValue,
      double? amountInvested,
      String? purchaseDate}) {
    if (id != null) {
      _investmentTypeController.text = investmentType!;
      _currentValueController.text = currentValue.toString();
      _amountInvestedController.text = amountInvested.toString();
      _dateController.text = purchaseDate!;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(id == null ? 'Add Investment' : 'Edit Investment'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _investmentTypeController,
                  decoration: InputDecoration(labelText: 'Investment Type'),
                ),
                TextField(
                  controller: _currentValueController,
                  decoration: InputDecoration(labelText: 'Current Value'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                TextField(
                  controller: _amountInvestedController,
                  decoration: InputDecoration(labelText: 'Amount Invested'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                TextField(
                  controller: _dateController,
                  decoration: InputDecoration(labelText: 'Purchase Date'),
                  onTap: () async {
                    FocusScope.of(context).requestFocus(FocusNode());
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      _dateController.text =
                          DateFormat('yyyy-MM-dd').format(picked);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetForm();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _addOrUpdateInvestment(id: id);
              },
              child: Text(id == null ? 'Save' : 'Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: TopAppBar(scaffoldKey: _scaffoldKey), // Custom Top App Bar
      drawer: CustomDrawer(
        firstName: widget.firstName,
        lastName: widget.lastName,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Investment',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _showInvestmentDialog();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: Text(
                          '+ Add Investment',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                _investments.isEmpty
                    ? Expanded(
                        child: Center(
                          child: Text('No investments added yet.'),
                        ),
                      )
                    : Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Table(
                            border: TableBorder.all(),
                            columnWidths: {
                              0: FlexColumnWidth(1),
                              1: FlexColumnWidth(1),
                              2: FlexColumnWidth(1),
                              3: FlexColumnWidth(1.4),
                              4: FlexColumnWidth(1.8),
                            },
                            children: [
                              TableRow(
                                decoration: BoxDecoration(color: Colors.green),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('Type',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('Amount Invested',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('Current Value',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('Date',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('Actions',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white)),
                                  ),
                                ],
                              ),
                              ..._investments.map((investment) {
                                return TableRow(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child:
                                          Text(investment['investment_type']),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(investment['amount_invested']
                                          .toString()),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(investment['current_value']
                                          .toString()),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(investment['purchase_date']),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.edit),
                                            onPressed: () {
                                              _showInvestmentDialog(
                                                id: investment['id'],
                                                investmentType: investment[
                                                    'investment_type'],
                                                currentValue:
                                                    investment['current_value'],
                                                amountInvested: investment[
                                                    'amount_invested'],
                                                purchaseDate:
                                                    investment['purchase_date'],
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.delete),
                                            onPressed: () {
                                              _deleteInvestment(
                                                  investment['id']);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ),
              ],
            ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 4,
        onTap: (index) {},
        firstName: widget.firstName,
        lastName: widget.lastName,
        userId: widget.userId,
      ), // Custom Bottom Navigation Bar
    );
  }
}
