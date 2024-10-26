import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import '../database/database_helper.dart';
import 'home_screen.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/user.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();

  String? emailError;
  String? passwordError;

  // Password strength criteria
  bool isPasswordStrong(String password) {
    final passwordPattern = r'^(?=.*[A-Z])(?=.*\d)[A-Za-z\d]{8,}$';
    final regExp = RegExp(passwordPattern);
    return regExp.hasMatch(password);
  }

  void resetPassword(BuildContext context) async {
    String email = emailController.text;
    String newPassword = newPasswordController.text;

    setState(() {
      emailError = email.isEmpty || !EmailValidator.validate(email)
          ? "Please enter a valid email"
          : null;
      passwordError = newPassword.isEmpty || !isPasswordStrong(newPassword)
          ? "Please enter a strong password"
          : null;
    });

    if (emailError == null && passwordError == null) {
      DatabaseHelper db = DatabaseHelper();
      var user = await db.getUserByEmail(email);

      if (user != null) {
        // Update the password
        await db.updatePassword(email, newPassword);

        // Create User instance
        User currentUser = User(
          id: user['id'],
          firstName: user['first_name'],
          lastName: user['last_name'],
        );

        // Set user in UserProvider
        Provider.of<UserProvider>(context, listen: false).setUser(currentUser);

        // Navigate to Home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              userId: currentUser.id,
              firstName: currentUser.firstName,
              lastName: currentUser.lastName,
            ),
          ),
        );
      } else {
        setState(() {
          emailError = "Email not found, please try again";
        });
      }
    }
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
                // Adjust the logo size
                Image.asset(
                  'lib/assets/images/Mycash_Logo.png',
                  width: 150,
                  height: 150,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 20),
                Text(
                  "Reset Password",
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
                      // Email field
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 10.0),
                        ),
                        onChanged: (value) {
                          setState(() {
                            emailError =
                                value.isEmpty || !EmailValidator.validate(value)
                                    ? "Please enter a valid email"
                                    : null;
                          });
                        },
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

                      // New Password field
                      TextField(
                        controller: newPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 10.0),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.info_outline),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Password Criteria'),
                                    content: Text(
                                        'Your password must be at least 8 characters long, '
                                        'contain an uppercase letter and a number.'),
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
                            },
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            passwordError =
                                value.isEmpty || !isPasswordStrong(value)
                                    ? "Please enter a strong password"
                                    : null;
                          });
                        },
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

                      // Reset Button
                      ElevatedButton(
                        onPressed: () => resetPassword(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 24.0),
                        ),
                        child: Text(
                          'Reset Password',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      SizedBox(height: 20),

                      // Links
                      Text("Already have an account?"),
                      TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/signIn'),
                        child: Text("Sign In",
                            style: TextStyle(color: Colors.green)),
                      ),
                      Text("Don't have an account?"),
                      TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/signUp'),
                        child: Text("Sign Up",
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
