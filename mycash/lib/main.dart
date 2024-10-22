import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/sign_in_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/home_screen.dart';
import 'screens/income_screen.dart';
import 'screens/expense_screen.dart';
import 'screens/savings_screen.dart';
import 'screens/investment_screen.dart';
import 'providers/user_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyCash',
      initialRoute: '/',
      routes: {
        '/': (context) => SignInScreen(),
        '/signIn': (context) => SignInScreen(),
        '/signUp': (context) => SignUpScreen(),
        '/resetPassword': (context) => ResetPasswordScreen(),
        '/home': (context) {
          final user = Provider.of<UserProvider>(context);
          return HomeScreen(
            userId: user.currentUser?.id ?? 0,
            firstName: user.currentUser?.firstName ?? '',
            lastName: user.currentUser?.lastName ?? '',
          );
        },
        '/expenses': (context) {
          final user = Provider.of<UserProvider>(context);
          return ExpenseScreen(
            userId: user.currentUser?.id ?? 0,
            firstName: user.currentUser?.firstName ?? '',
            lastName: user.currentUser?.lastName ?? '',
            onDataUpdated: () {
              // Optional: Implement a callback to update the data on return
            },
          );
        },
        '/income': (context) {
          final user = Provider.of<UserProvider>(context);
          return IncomeScreen(
            userId: user.currentUser?.id ?? 0,
            firstName: user.currentUser?.firstName ?? '',
            lastName: user.currentUser?.lastName ?? '',
            onDataUpdated: () {
              // Optional: Implement a callback to update the data on return
            },
          );
        },
        '/savings': (context) {
          final user = Provider.of<UserProvider>(context);
          return SavingsScreen(
            userId: user.currentUser?.id ?? 0,
            firstName: user.currentUser?.firstName ?? '',
            lastName: user.currentUser?.lastName ?? '',
          );
        },
        '/Investment': (context) {
          final user = Provider.of<UserProvider>(context);
          return InvestmentScreen(
            userId: user.currentUser?.id ?? 0,
            firstName: user.currentUser?.firstName ?? '',
            lastName: user.currentUser?.lastName ?? '',
            onDataUpdated: () {
              // Optional: Implement a callback to update the data on return
            },
          );
        },
      },
    );
  }
}
