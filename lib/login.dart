import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:latestlnf/service/auth_service.dart';
import 'package:latestlnf/service/forgot_password.dart';
import 'package:latestlnf/service/register.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;

  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void signUserIn() async {
  String email = emailController.text.trim();
  String password = passwordController.text.trim();

  if (email.isEmpty || password.isEmpty) {
    showErrorMessage("Email and password are required.");
    return;
  }

  showDialog(
    context: context,
    builder: (context) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    },
  );

  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    Navigator.pop(context);
 // Check if the user is already authenticated
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Navigate to homepage upon successful login
      Navigator.pushReplacementNamed(context, '/homepage');
    } else {
      // Handle the case when user authentication fails
      showErrorMessage("Failed to authenticate user.");
    }
  } on FirebaseAuthException catch (e) {
    Navigator.pop(context);
    showErrorMessage(e.code);
  }
}
    // Check if the user is already authenticated
    /*User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Determine the page to navigate to after login
      bool navigateToLostItem = true; // Replace this with your actual condition for Lost Item
      bool navigateToFoundItem = true; // Replace this with your actual condition for Found Item

      if (navigateToLostItem) {
        Navigator.pushReplacementNamed(context, '/reportlostitem');
      } 
}
     else {
      // Handle the case when user authentication fails
      showErrorMessage("Failed to authenticate user.");
    }
  } on FirebaseAuthException catch (e) {
    Navigator.pop(context);
    showErrorMessage(e.code);
  }
}*/

  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 212, 209, 206),
          title: Text(
            message,
            style: const TextStyle(color: Color.fromARGB(255, 135, 133, 133)),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                Image.asset(
                  'assets/logo_lost.png',
                  height: 100,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Welcome back!',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 15),
                MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),
                const SizedBox(height: 15),
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ForgotPasswordPage(),
                            ),
                          );
                        },
                        child: const Text(
                          'Forgot password?',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                MyButton(
                  text: "Sign In",
                  onTap: signUserIn,
                ),
                const SizedBox(height: 25),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.black,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'Or continue with',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                SquareTile(
                  onTap: () => AuthService().signInWithGoogle(context),
                  imagePath: 'assets/google.png',
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20), // Adjusted padding
                  child: Column( // Changed from Row to Column
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Not a member?",
                            style: TextStyle(color: Colors.black),
                          ),
                          const SizedBox(
                            width: 5,
                                                ),GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RegisterPage(onTap: null)), // Navigate to RegisterPage
                          );
                        },
                        child: const Text(
                          "Register Now",
                          style: TextStyle(
                            color: Color.fromARGB(255, 250, 147, 44),
                            fontWeight: FontWeight.bold,),
                        ),
                      ),],
                      ),
                      const SizedBox(height: 20), // Added SizedBox for spacing
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
class MyButton extends StatelessWidget {
  final void Function()? onTap;
  final String text;

  const MyButton({
    super.key,
    required this.onTap,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(25),
        margin: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
            color: const Color.fromARGB(255, 185, 102, 18), borderRadius: BorderRadius.circular(8)),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Color.fromARGB(255, 255, 255, 255),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

class MyTextField extends StatelessWidget {
  // ignore: prefer_typing_uninitialized_variables
  final controller;
  final String hintText;
  final bool obscureText;

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                color: Color.fromARGB(255, 255, 253, 253),
                width: 1.5,
              ),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color.fromARGB(255, 249, 213, 187)),
            ),
            fillColor: const Color.fromARGB(255, 255, 219, 189),
            filled: true,
            hintText: hintText,
            hintStyle: const TextStyle(
              color: Colors.white,
            ),
          ),
        ));
  }
}

class SquareTile extends StatelessWidget {
  final String imagePath;
  final void Function()? onTap;

  const SquareTile({
    super.key,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: const Color.fromARGB(255, 88, 85, 85)),
          borderRadius: BorderRadius.circular(16),
          color:  const Color.fromARGB(255, 255, 219, 189),//const Color.fromARGB(255, 228, 226, 226),
        ),
        child: Image.asset(
          imagePath,
          height: 30,
        ),
      ),
    );
  }
}