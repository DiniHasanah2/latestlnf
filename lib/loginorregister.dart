import 'package:flutter/material.dart';
import 'package:latestlnf/service/login.dart' as login;
import 'package:latestlnf/service/register.dart' as register;

class LoginOrRegisterPage extends StatefulWidget {
  final Null Function() onTap;

  const LoginOrRegisterPage({super.key, required this.onTap});

  @override
  State<LoginOrRegisterPage> createState() => _LoginOrRegisterPageState();
}

class _LoginOrRegisterPageState extends State<LoginOrRegisterPage> {
  bool showLoginPage = true;

  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
    //widget.onTap(); // Call the onTap function passed from outside
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: showLoginPage
          ? login.LoginPage(onTap: togglePages)
          : register.RegisterPage(onTap: togglePages),
    );
  }
}

/*class _LoginOrRegisterPageState extends State<LoginOrRegisterPage> {
  bool showLoginPage = true;

  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: showLoginPage
          ? login.LoginPage(onTap: togglePages)
          : register.RegisterPage(onTap: togglePages),
    );
  }
}*/
