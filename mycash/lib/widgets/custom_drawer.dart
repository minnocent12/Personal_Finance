import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  final String firstName;
  final String lastName;

  CustomDrawer({required this.firstName, required this.lastName});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Profile section
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(Icons.account_circle,
                    size: 80, color: Color.fromARGB(255, 0, 0, 0)),
                SizedBox(height: 8),
                Text(
                  '$firstName $lastName',
                  style: TextStyle(color: Color(0xFF333333), fontSize: 18),
                ),
              ],
            ),
          ),
          Divider(),

          // Expanded to push menu items to take up available space
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(context, Icons.home, 'Home', '/home'),
                _buildDrawerItem(
                    context, Icons.attach_money, 'Income', '/income'),
                _buildDrawerItem(
                    context, Icons.money_off, 'Expenses', '/expenses'),
                _buildDrawerItem(
                    context, Icons.savings, 'Saving Goals', '/savings'),
                _buildDrawerItem(
                    context, Icons.trending_up, 'Investments', '/investments'),
                _buildDrawerItem(context, Icons.account_balance_wallet,
                    'Budgeting', '/budgeting'),
                _buildDrawerItem(context, Icons.report, 'Reports', '/reports'),
                _buildDrawerItem(
                    context, Icons.settings, 'Settings', '/settings'),
              ],
            ),
          ),

          // Logout section at the bottom
          Divider(),
          Container(
            color: Color(0xFFF9F9F9),
            child: ListTile(
              leading: Icon(Icons.logout, color: Colors.black),
              title: Text('Logout'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/signIn');
              },
            ),
          ),
        ],
      ),
    );
  }

  ListTile _buildDrawerItem(
      BuildContext context, IconData icon, String title, String route) {
    return ListTile(
      leading: Icon(icon, color: Color(0xFF333333)),
      title: Text(title),
      onTap: () {
        Navigator.pop(context); // Close the drawer
        Navigator.pushNamed(context, route); // Navigate to the route
      },
      hoverColor: Color(0xFFF5F5F5),
      contentPadding: EdgeInsets.symmetric(horizontal: 16),
      tileColor: Colors.white,
      shape: Border(bottom: BorderSide(color: Color(0xFFDDDDDD))),
    );
  }
}
