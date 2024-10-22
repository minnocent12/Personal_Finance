import 'package:flutter/material.dart';
import '../screens/income_screen.dart';
import '../screens/home_screen.dart';
import '../screens/expense_screen.dart';
import '../screens/savings_screen.dart';
import '../screens/investment_screen.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final String firstName;
  final String lastName;
  final int userId;

  BottomNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.firstName,
    required this.lastName,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      selectedItemColor: Color.fromARGB(255, 4, 163, 44),
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      items: [
        _buildBottomNavItem(Icons.home, 'Home'),
        _buildBottomNavItem(Icons.attach_money, 'Income'),
        _buildBottomNavItem(Icons.money_off, 'Expenses'),
        _buildBottomNavItem(Icons.savings, 'Saving'),
        _buildBottomNavItem(Icons.trending_up, 'Investments'),
        _buildBottomNavItem(Icons.account_balance_wallet, 'Budget'),
        _buildBottomNavItem(Icons.report, 'Report'),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(
                  userId: userId,
                  firstName: firstName,
                  lastName: lastName,
                ),
              ),
            );
            break;
          case 1:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => IncomeScreen(
                  userId: userId,
                  firstName: firstName,
                  lastName: lastName,
                  onDataUpdated: () {}, // No need to update for navigation
                ),
              ),
            );
            break;
          case 2:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ExpenseScreen(
                  userId: userId,
                  firstName: firstName,
                  lastName: lastName,
                  onDataUpdated: () {},
                ),
              ),
            );
            break;
          case 3:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => SavingsScreen(
                  userId: userId,
                  firstName: firstName,
                  lastName: lastName,
                ),
              ),
            );
            break;
          case 4:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => InvestmentScreen(
                  userId: userId,
                  firstName: firstName,
                  lastName: lastName,
                  onDataUpdated: () {},
                ),
              ),
            );
            break;
          case 5:
            Navigator.pushNamed(context, '/budgeting');
            break;
          case 6:
            Navigator.pushNamed(context, '/reports');
            break;
        }
      },
    );
  }

  BottomNavigationBarItem _buildBottomNavItem(IconData icon, String label) {
    return BottomNavigationBarItem(
      icon: Icon(icon),
      label: label,
    );
  }
}
