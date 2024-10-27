import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import '../database/database_helper.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/top_app_bar.dart';

class ReportsScreen extends StatefulWidget {
  final int userId;
  final String firstName;
  final String lastName;

  const ReportsScreen({
    super.key,
    required this.userId,
    required this.firstName,
    required this.lastName,
  });

  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late DatabaseHelper db;
  List<charts.Series<ExpenseData, String>> _expenseSeries = [];
  List<charts.Series<TimeSeriesIncome, DateTime>> _incomeSeries = [];
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    db = DatabaseHelper();
    _generateData();
  }

  void _generateData() async {
    // Fetch expense categories and amounts
    List<Map<String, dynamic>> expenseData =
        await db.getExpensesGroupedByCategory(widget.userId);

    // Check if expenseData is not empty
    if (expenseData.isNotEmpty) {
      var barData = expenseData.map((data) {
        return ExpenseData(
          category: data['category'],
          amount: data['total_amount'] ?? 0.0,
        );
      }).toList();

      // Populate expense series
      setState(() {
        _expenseSeries = [
          charts.Series<ExpenseData, String>(
            id: 'Expenses',
            colorFn: (_, __) =>
                charts.MaterialPalette.green.shadeDefault, // Set color to green
            domainFn: (ExpenseData data, _) => data.category,
            measureFn: (ExpenseData data, _) => data.amount,
            data: barData,
            labelAccessorFn: (ExpenseData data, _) =>
                '${data.category}: \$${data.amount.toStringAsFixed(2)}',
          ),
        ];
      });
    } else {
      setState(() {
        _expenseSeries = []; // Clear series if no data
      });
    }

    // Fetch income over time
    List<Map<String, dynamic>> incomeData =
        await db.getMonthlyIncome(widget.userId);

    // Check if incomeData is not empty
    if (incomeData.isNotEmpty) {
      var lineData = incomeData.map((data) {
        return TimeSeriesIncome(
          date: DateTime.parse('${data['date']}-01'),
          amount: data['total_amount'] ?? 0.0,
        );
      }).toList();

      // Populate income series
      setState(() {
        _incomeSeries = [
          charts.Series<TimeSeriesIncome, DateTime>(
            id: 'Income',
            colorFn: (_, __) =>
                charts.MaterialPalette.green.shadeDefault, // Set color to green
            domainFn: (TimeSeriesIncome data, _) => data.date,
            measureFn: (TimeSeriesIncome data, _) => data.amount,
            data: lineData,
          ),
        ];
      });
    } else {
      setState(() {
        _incomeSeries = []; // Clear series if no data
      });
    }
  }

  Widget _buildExpenseChart() {
    return charts.BarChart(
      _expenseSeries,
      animate: true,
      animationDuration: const Duration(seconds: 1),
      vertical: false, // Horizontal bar chart
      barRendererDecorator: charts.BarLabelDecorator<String>(),
    );
  }

  Widget _buildIncomeChart() {
    return charts.TimeSeriesChart(
      _incomeSeries,
      animate: true,
      animationDuration: const Duration(seconds: 1),
      dateTimeFactory: const charts.LocalDateTimeFactory(),
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
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              'Expense Distribution',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Container(
              height: 300,
              child: _expenseSeries.isEmpty
                  ? const Center(child: Text('No expense data available'))
                  : _buildExpenseChart(),
            ),
            const SizedBox(height: 20),
            const Text(
              'Income Over Time',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Container(
              height: 300,
              padding: const EdgeInsets.all(16),
              child: _incomeSeries.isEmpty
                  ? const Center(child: Text('No income data available'))
                  : _buildIncomeChart(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 6,
        onTap: (index) {},
        firstName: widget.firstName,
        lastName: widget.lastName,
        userId: widget.userId,
      ),
    );
  }
}

class ExpenseData {
  final String category;
  final double amount;

  ExpenseData({required this.category, required this.amount});
}

class TimeSeriesIncome {
  final DateTime date;
  final double amount;

  TimeSeriesIncome({required this.date, required this.amount});
}
