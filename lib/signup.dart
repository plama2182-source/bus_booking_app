import 'package:firebase_core/firebase_core.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'utils/responsive.dart';
import 'main.dart';
import 'login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(SignupPage());
}

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  // Controllers
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController companyController = TextEditingController(); // For BusAdmin
  final TextEditingController secretCodeController = TextEditingController(); // For SuperAdmin

  // State Management
  String selectedRole = "user"; 
  bool obscurePassword = true;
  bool isLoading = false;

 
  bool isEmailValid(String email) {
    return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  bool isPhoneValid(String phone) {
    return RegExp(r'^[0-9]{10}$').hasMatch(phone);
  }

  Future<void> createUser() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String name = usernameController.text.trim();
    String phone = phoneController.text.trim();

    // 1. Basic Validation
    if (name.isEmpty || phone.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnackBar("All fields are required", Colors.orange);
      return;
    }
    if (!isEmailValid(email)) {
      _showSnackBar("Invalid email format", Colors.orange);
      return;
    }
    if (!isPhoneValid(phone)) {
      _showSnackBar("Invalid 10-digit phone number", Colors.orange);
      return;
    }

    // 2. Role Specific Validation
    if (selectedRole == 'admin' && secretCodeController.text != "BUS_ADMIN_2026") {
      _showSnackBar("Invalid Secret Admin Code", Colors.red);
      return;
    }
    if (selectedRole == 'busAdmin' && companyController.text.isEmpty) {
      _showSnackBar("Company Name is required for Bus Owners", Colors.orange);
      return;
    }

    setState(() => isLoading = true);

    try {
      // 3. Firebase Auth Creation
      UserCredential result = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 4. Firestore Document Creation
      Map<String, dynamic> userData = {
        "uid": result.user!.uid,
        "name": name,
        "number": phone,
        "email": email,
        "role": selectedRole,
        "createdAt": FieldValue.serverTimestamp(),
      };

      // Add extra data if they are a Bus Owner
      if (selectedRole == 'busAdmin') {
        userData["companyName"] = companyController.text.trim();
        userData["isVerified"] = false; // Requires SuperAdmin approval
      }

      await FirebaseFirestore.instance.collection("users").doc(result.user!.uid).set(userData);
      try {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    await user.sendEmailVerification();
    print("Verification email sent successfully");
  }
} catch (e) {
  print("Failed to send email: $e");

}
    

  
       
       if (context.mounted) {

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthWrapper()),
          (route) => false,
        );
      }
      
    } on FirebaseAuthException catch (e) {
      _showSnackBar(e.message ?? "An error occurred", Colors.red);
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showSnackBar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Decor
          Positioned(
            top: -100,
            right: -100,
            child: CircleAvatar(radius: 150, backgroundColor: Colors.red.withOpacity(0.1)),
          ),
          
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.directions_bus_filled, size: 80, color: Colors.red),
                  const SizedBox(height: 10),
                  const Text("Join BusApp", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 30),

                  // ROLE SELECTOR
                  _buildRoleSelector(),
                  const SizedBox(height: 25),

                  // INPUT FIELDS
                  _buildTextField(usernameController, "Full Name", Icons.person_outline),
                  const SizedBox(height: 15),
                  _buildTextField(phoneController, "Phone Number", Icons.phone_android_outlined, type: TextInputType.phone),
                  const SizedBox(height: 15),
                  _buildTextField(emailController, "Email Address", Icons.alternate_email, type: TextInputType.emailAddress),
                  const SizedBox(height: 15),
                  _buildTextField(passwordController, "Password", Icons.lock_outline, isPassword: true),

                 
                  if (selectedRole == "busAdmin") ...[
                    const SizedBox(height: 15),
                    _buildTextField(companyController, "Bus Company Name", Icons.business_center_outlined),
                  ],
                  if (selectedRole == "admin") ...[
                    const SizedBox(height: 15),
                    _buildTextField(secretCodeController, "Super Admin Secret Code", Icons.admin_panel_settings_outlined, obscure: true),
                  ],

                  const SizedBox(height: 30),

                 
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: isLoading ? null :  createUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: isLoading 
                        ? const CircularProgressIndicator(color: Colors.white) 
                        : const Text("Create Account", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  
                  TextButton(
                    onPressed: () =>  Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          ),
                    child: const Text("Already have an account? Log In", style: TextStyle(color: Colors.grey)),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- UI WIDGET COMPONENTS ---

  Widget _buildRoleSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          _roleTab("user", "User", Icons.person),
          _roleTab("busAdmin", "Owner", Icons.directions_bus),
          _roleTab("admin", "Admin", Icons.security),
        ],
      ),
    );
  }

  Widget _roleTab(String role, String label, IconData icon) {
    bool isSelected = selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedRole = role),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected ? [const BoxShadow(color: Colors.black12, blurRadius: 4)] : [],
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.red : Colors.grey, size: 20),
              Text(label, style: TextStyle(color: isSelected ? Colors.black : Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, 
      {TextInputType type = TextInputType.text, bool isPassword = false, bool obscure = false}) {
    return TextField(
      controller: controller,
      keyboardType: type,
      obscureText: isPassword ? obscurePassword : obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.redAccent),
        suffixIcon: isPassword ? IconButton(
          icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => obscurePassword = !obscurePassword),
        ) : null,
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }
}