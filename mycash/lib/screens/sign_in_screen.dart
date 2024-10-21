import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/database_helper.dart';
import '../models/user.dart';
import '../providers/user_provider.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? emailError;
  String? passwordError;

  void signIn(BuildContext context) async {
    String email = emailController.text;
    String password = passwordController.text;

    setState(() {
      emailError = email.isEmpty ? "Your email is required." : null;
      passwordError = password.isEmpty ? "Your password is required." : null;
    });

    if (email.isNotEmpty && password.isNotEmpty) {
      DatabaseHelper db = DatabaseHelper();
      var userData = await db.getUser(email, password);
      if (userData != null) {
        // Create a User object
        User user = User(
          id: userData['id'],
          firstName: userData['first_name'],
          lastName: userData['last_name'],
        );

        // Set the user in the provider
        Provider.of<UserProvider>(context, listen: false).setUser(user);

        // Redirect to home screen
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Show error dialog for invalid credentials
        _showErrorDialog(context);
      }
    }
  }

  void _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Login Failed!'),
          content: Text('Please check your email and password and try again.'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.grey[200],
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'lib/assets/images/logo.png',
                  width: 150,
                  height: 150,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 20),
                Text(
                  "Sign In",
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0,
                            horizontal: 10.0,
                          ),
                        ),
                      ),
                      if (emailError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            emailError!,
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                      SizedBox(height: 16),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0,
                            horizontal: 10.0,
                          ),
                        ),
                      ),
                      if (passwordError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            passwordError!,
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => signIn(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(
                            vertical: 12.0,
                            horizontal: 24.0,
                          ),
                        ),
                        child: Text(
                          'Sign In',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text("Don't have an account?"),
                      TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/signUp'),
                        child: Text("Sign Up",
                            style: TextStyle(color: Colors.green)),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/resetPassword'),
                        child: Text("Forgot your password?",
                            style: TextStyle(color: Colors.green)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
