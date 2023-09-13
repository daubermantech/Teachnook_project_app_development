import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'task_list_page.dart';

void main() => runApp(const LoginApp());

class LoginApp extends StatelessWidget {
  const LoginApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late SharedPreferences _prefs;

  bool _isDarkMode = false; // Track the current theme mode

  Future<void> _login(BuildContext context) async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    // Perform login authentication logic here (e.g., check username and password).
    // For simplicity, let's assume a successful login for now.
    bool isAuthenticated = true;

    if (isAuthenticated) {
      // Store the login details securely.
      await _prefs.setString('username', username);

      // Navigate to the CRUD operations page.
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TaskListPage(
            username: username, // Pass the username to the TaskListPage.
          ),
        ),
      );
    } else {
      // Handle authentication failure (e.g., show an error message).
    }
  }

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        _prefs = prefs;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(), // Define light and dark themes
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Login Page"),
          actions: [
            // Add a toggle button to switch between light and dark themes
            IconButton(
              icon: Icon(_isDarkMode ? Icons.brightness_7 : Icons.brightness_3),
              onPressed: () {
                setState(() {
                  _isDarkMode = !_isDarkMode;
                });
              },
            ),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 20),
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: "Username"),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Password"),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    await _login(context);
                  },
                  child: const Text("Login"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
