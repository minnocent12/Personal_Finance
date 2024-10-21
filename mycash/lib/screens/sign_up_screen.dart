import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'package:email_validator/email_validator.dart'; // For email validation
import 'package:provider/provider.dart';
import '../providers/user_provider.dart'; // Import your UserProvider
import '../models/user.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? firstNameError;
  String? lastNameError;
  String? emailError;
  String? passwordError;

  // Password strength criteria
  bool isPasswordStrong(String password) {
    final passwordPattern = r'^(?=.*[A-Z])(?=.*\d)[A-Za-z\d]{8,}$';
    final regExp = RegExp(passwordPattern);
    return regExp.hasMatch(password);
  }

  void signUp(BuildContext context) async {
    String firstName = firstNameController.text;
    String lastName = lastNameController.text;
    String email = emailController.text;
    String password = passwordController.text;

    setState(() {
      firstNameError =
          firstName.isEmpty ? "Please enter your first name" : null;
      lastNameError = lastName.isEmpty ? "Please enter your last name" : null;
      emailError = email.isEmpty || !EmailValidator.validate(email)
          ? "Please enter a valid email"
          : null;
      passwordError = password.isEmpty || !isPasswordStrong(password)
          ? "Please enter a strong password"
          : null;
    });

    if (firstName.isNotEmpty &&
        lastName.isNotEmpty &&
        EmailValidator.validate(email) &&
        isPasswordStrong(password)) {
      DatabaseHelper db = DatabaseHelper();

      // Check if email is already used
      bool emailExists = await db.isEmailUsed(email);

      if (emailExists) {
        setState(() {
          emailError = "The email is already used";
        });
      } else {
        int userId = await db.createUser(firstName, lastName, email, password);

        // Create User instance
        User newUser =
            User(id: userId, firstName: firstName, lastName: lastName);

        // Set user in UserProvider
        Provider.of<UserProvider>(context, listen: false).setUser(newUser);

        // Redirect to home screen
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  // Function to show password criteria dialog
  void _showPasswordCriteriaDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Password Criteria'),
          content: Text(
              'Your password must:\n- Be at least  8 characters long\n- Start with an uppercase letter\n- Contain at least one number.'),
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
        color: Colors.grey[200], // Set the background color to light gray
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Adjust the logo size
                Image.asset(
                  'lib/assets/images/logo.png',
                  width: 150, // Set the desired width
                  height: 150, // Set the desired height
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 20),
                Text(
                  "Sign Up",
                  style: TextStyle(
                      color: Colors.green,
                      fontSize: 28,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      // First Name field
                      TextField(
                        controller: firstNameController,
                        decoration: InputDecoration(
                          labelText: 'First Name',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 10.0),
                        ),
                        onChanged: (value) {
                          setState(() {
                            firstNameError = value.isEmpty
                                ? "Please enter your first name"
                                : null;
                          });
                        },
                      ),
                      if (firstNameError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            firstNameError!,
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                      SizedBox(height: 16), // Space between fields

                      // Last Name field
                      TextField(
                        controller: lastNameController,
                        decoration: InputDecoration(
                          labelText: 'Last Name',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 10.0),
                        ),
                        onChanged: (value) {
                          setState(() {
                            lastNameError = value.isEmpty
                                ? "Please enter your last name"
                                : null;
                          });
                        },
                      ),
                      if (lastNameError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            lastNameError!,
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                      SizedBox(height: 16), // Space between fields

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
                      SizedBox(height: 16), // Space between fields

                      // Password field with info icon
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 10.0),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.info_outline),
                            onPressed: () =>
                                _showPasswordCriteriaDialog(context),
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

                      // Sign Up button
                      ElevatedButton(
                        onPressed: () => signUp(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 24.0),
                        ),
                        child: Text(
                          'Sign Up',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      SizedBox(height: 20), // Space before links
                      Text("Already have an account?"),
                      TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/signIn'),
                        child: Text("Sign In",
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
