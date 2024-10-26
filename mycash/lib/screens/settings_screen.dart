import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/top_app_bar.dart';

class SettingsScreen extends StatefulWidget {
  final int userId;
  final String firstName;
  final String lastName;

  const SettingsScreen({
    super.key,
    required this.userId,
    required this.firstName,
    required this.lastName,
  });

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late DatabaseHelper db;
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  bool isEditing = false;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    db = DatabaseHelper();
    _loadUserData();
  }

  void _loadUserData() async {
    var user = await db.getUserById(widget.userId);
    if (user != null) {
      firstNameController.text = user['first_name'];
      lastNameController.text = user['last_name'];
      emailController.text = user['email'];
      setState(() {});
    }
  }

  void _updateUserData() async {
    await db.updateUser(
      widget.userId,
      firstNameController.text,
      lastNameController.text,
      emailController.text,
    );
    setState(() {
      isEditing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Profile updated successfully')),
    );
  }

  void _changePassword() {
    Navigator.pushNamed(context, '/resetPassword');
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Settings',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: firstNameController,
              decoration: InputDecoration(labelText: 'First Name'),
              enabled: isEditing,
            ),
            TextField(
              controller: lastNameController,
              decoration: InputDecoration(labelText: 'Last Name'),
              enabled: isEditing,
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
              enabled: isEditing,
            ),
            SizedBox(height: 20),
            isEditing
                ? ElevatedButton(
                    onPressed: _updateUserData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: Text('Save Changes'),
                  )
                : ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isEditing = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: Text('Edit Profile'),
                  ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _changePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: Text('Change Password'),
            ),
          ],
        ),
      ),
    );
  }
}
