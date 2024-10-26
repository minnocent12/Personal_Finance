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
  final List<charts.Series<ExpenseData, String>> _expenseSeries = [];
  final List<charts.Series<TimeSeriesIncome, DateTime>> _incomeSeries = [];
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

    // Prepare pie chart data
    var pieData = expenseData.map((data) {
      return ExpenseData(
        category: data['category'],
        amount: data['total_amount'],
      );
    }).toList();

    _expenseSeries.add(
      charts.Series(
        id: 'Expenses',
        domainFn: (ExpenseData data, _) => data.category,
        measureFn: (ExpenseData data, _) => data.amount,
        data: pieData,
        labelAccessorFn: (ExpenseData data, _) =>
            '${data.category}: \$${data.amount.toStringAsFixed(2)}',
      ),
    );

    // Fetch income over time
    List<Map<String, dynamic>> incomeData =
        await db.getMonthlyIncome(widget.userId);

    var lineData = incomeData.map((data) {
      return TimeSeriesIncome(
        date: DateTime.parse(data['date']),
        amount: data['total_amount'],
      );
    }).toList();

    _incomeSeries.add(
      charts.Series(
        id: 'Income',
        domainFn: (TimeSeriesIncome data, _) => data.date,
        measureFn: (TimeSeriesIncome data, _) => data.amount,
        data: lineData,
      ),
    );

    setState(() {});
  }

  Widget _buildExpenseChart() {
    return charts.PieChart(
      _expenseSeries,
      animate: true,
      animationDuration: Duration(seconds: 1),
      defaultRenderer: charts.ArcRendererConfig(
        arcWidth: 100,
        arcRendererDecorators: [
          charts.ArcLabelDecorator(
              labelPosition: charts.ArcLabelPosition.inside),
        ],
      ),
    );
  }

  Widget _buildIncomeChart() {
    return charts.TimeSeriesChart(
      _incomeSeries,
      animate: true,
      animationDuration: Duration(seconds: 1),
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
            SizedBox(height: 20),
            Text(
              'Expense Distribution',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Container(
              height: 300,
              padding: EdgeInsets.all(16),
              child: _expenseSeries.isEmpty
                  ? Center(child: Text('No expense data available'))
                  : _buildExpenseChart(),
            ),
            SizedBox(height: 20),
            Text(
              'Income Over Time',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Container(
              height: 300,
              padding: EdgeInsets.all(16),
              child: _incomeSeries.isEmpty
                  ? Center(child: Text('No income data available'))
                  : _buildIncomeChart(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 4,
        onTap: (index) {
          // Handle navigation if necessary
        },
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
