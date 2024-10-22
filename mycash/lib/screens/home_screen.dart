import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/database_helper.dart';
import '../providers/user_provider.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/top_app_bar.dart'; // Import TopAppBar
import 'income_screen.dart';
import 'expense_screen.dart';
import 'savings_screen.dart';
import 'investment_screen.dart';

class HomeScreen extends StatefulWidget {
  final int userId;
  final String firstName;
  final String lastName;

  HomeScreen({
    required this.userId,
    required this.firstName,
    required this.lastName,
  });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DatabaseHelper db;
  double totalIncome = 0;
  double totalExpenses = 0;
  double totalSavings = 0;
  double totalInvestments = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    db = DatabaseHelper();
    _loadData(); // Load data on init
  }

  Future<void> _loadData() async {
    final user = Provider.of<UserProvider>(context, listen: false).currentUser;

    if (user != null) {
      try {
        totalIncome = await db.getTotalIncome(user.id);
        totalExpenses = await db.getTotalExpenses(user.id);
        totalSavings = await db.getTotalSavings(user.id);
        totalInvestments = await db.getTotalInvestments(user.id);
      } catch (e) {
        // Handle error here (e.g., show a message to the user)
        print("Error loading data: $e");
      }
      setState(() {});
    }
  }

  Widget _buildSection(String title, double total, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Text('\$${total.toStringAsFixed(2)}',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
              Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).currentUser;

    if (user == null) {
      return Scaffold(
        key: _scaffoldKey,
        appBar: TopAppBar(scaffoldKey: _scaffoldKey), // Use your TopAppBar
        body: Center(child: Text('No user data found.')),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: TopAppBar(scaffoldKey: _scaffoldKey), // Use your TopAppBar
      drawer: CustomDrawer(firstName: user.firstName, lastName: user.lastName),
      body: ListView(
        children: [
          _buildSection('Total Income', totalIncome, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => IncomeScreen(
                  userId: user.id,
                  firstName: user.firstName,
                  lastName: user.lastName,
                  onDataUpdated: _loadData,
                ),
              ),
            );
          }),
          _buildSection('Total Expenses', totalExpenses, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ExpenseScreen(
                  userId: user.id,
                  firstName: user.firstName,
                  lastName: user.lastName,
                  onDataUpdated: _loadData,
                ),
              ),
            );
          }),
          _buildSection('Total Savings', totalSavings, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SavingsScreen(
                  userId: user.id,
                  firstName: user.firstName,
                  lastName: user.lastName,
                ),
              ),
            );
          }),
          _buildSection('Total Investments', totalInvestments, () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => InvestmentScreen(
                  userId: user.id,
                  firstName: user.firstName,
                  lastName: user.lastName,
                  onDataUpdated: _loadData,
                ),
              ),
            );
          }),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0,
        onTap: (index) {},
        firstName: user.firstName,
        lastName: user.lastName,
        userId: user.id,
      ),
    );
  }
}
