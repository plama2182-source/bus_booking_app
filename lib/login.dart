
 
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signup.dart';
import 'index.dart';
import 'utils/responsive.dart';
import 'session.dart';
import 'package:busboking/admin/dashboard.dart';
import 'package:busboking/busAdmin/busAdmindashboard.dart';
import 'demo.dart';
import 'pendingVerification.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Renamed to emailController for clarity, as Firebase Auth needs Email
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

Future<void> resetPassword() async {

  if (emailController.text.isEmpty) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Enter email first")),
  );
}
else{
  try {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text);
     ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Password reset email sent. Check your mail")),
  );
   
  } on FirebaseAuthException catch (e) {
    print("Error: ${e.message}");
  }
}
}

  Future<void> checkLogin(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // 1. Authenticate with Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(userCredential.user!.uid)
          .get();

      if (!mounted) return;

      if (userDoc.exists) {
        var data = userDoc.data() as Map<String, dynamic>;
        String role = data["role"] ?? "user";
      
      

      
        if (role == "user") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const FirstPage()),
          );
        } else if (role == "admin") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Dashboard()),
          );
        } else if (role == "busAdmin") {
            bool isVerified=data["isVerified"]??false;
            if (isVerified == true) {
   Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const BusDashboard()),
          );
  } else {
    Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PendingVerificationPage()),
          );
  }
          
        }
      } else {
        // If Auth succeeds but Firestore record is missing
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User data not found in database")),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = "Login Failed";
      if (e.code == 'user-not-found') message = "No user found with this email.";
      if (e.code == 'wrong-password') message = "Incorrect password.";
      if (e.code == 'invalid-email') message = "Invalid email format.";

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(Icons.directions_bus, size: 60, color: Colors.red),
                const SizedBox(height: 20),
                const Text(
                  "Bus Booking",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),

                // Email Field
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),

                // Password Field
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 30),

                InkWell(
  onTap: () {
   resetPassword();
  },
  child: const Text(
    "Forgot Password?",
    style: TextStyle(
      color: Colors.blue,
      decoration: TextDecoration.underline,
    ),
  ),
),
const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading 
                      ? null 
                      : () => checkLogin(emailController.text, passwordController.text),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Login", style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),

                const SizedBox(height: 10),

                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignupPage()),
                    );
                  },
                  child: const Text("Don't have an account? Sign Up"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}