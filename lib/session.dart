class Session {
  static String? userId;

  static bool get isLoggedIn => userId != null;
}





// class SignupPage extends StatefulWidget {
//   const SignupPage({super.key});

//   @override
//   State<SignupPage> createState() => _SignupPageState();
// }

// class _SignupPageState extends State<SignupPage> {
//   // Controllers
//   final TextEditingController usernameController = TextEditingController();
//   final TextEditingController phoneController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   final TextEditingController adminCodeController = TextEditingController();

//   // State for toggles
//   bool isStaff = false;
//   bool obscurePassword = true;

//   // ---------------- VALIDATION HELPERS (Keeping your logic) ----------------
//   bool isEmailValid(String email) {
//     return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
//         .hasMatch(email);
//   }

//   bool isPhoneValid(String phone) {
//     return RegExp(r'^[0-9]{10}$').hasMatch(phone);
//   }

//   // ---------------- CREATE USERS (Updated for Admin logic) ----------------
//   Future<void> createUser(BuildContext context, String user, String num,
//       String email, String password) async {
//     try {
//       // 1. Create account in Firebase Auth
//       UserCredential result = await FirebaseAuth.instance.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );

//       // 2. Determine Role (Secret code logic)
//       String role = (isStaff && adminCodeController.text == "BUS_ADMIN_2026") ? "admin" : "user";

//       // 3. Save additional info to Firestore
//       await FirebaseFirestore.instance.collection("users").doc(result.user!.uid).set({
//         "name": user,
//         "number": num,
//         "email": email,
//         "uid": result.user!.uid,
//         "role": role,
//         "password": password 
//       });

//       await result.user!.sendEmailVerification();
//     } on FirebaseAuthException catch (e) {
//       if (context.mounted) {
//         _showError(context, e.message ?? "Authentication Error");
//       }
//     } catch (e) {
//       if (context.mounted) {
//         _showError(context, e.toString());
//       }
//     }
//   }

//   void _showError(BuildContext context, String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xFFE53935), Color(0xFFB71C1C)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(24),
//             child: Container(
//               constraints: const BoxConstraints(maxWidth: 420),
//               padding: const EdgeInsets.all(30),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(25),
//                 boxShadow: const [
//                   BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 10))
//                 ],
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const Icon(Icons.directions_bus, size: 70, color: Colors.red),
//                   const SizedBox(height: 10),
//                   const Text(
//                     "Create Account",
//                     style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 5),
//                   const Text("Join the journey with us",
//                       style: TextStyle(color: Colors.grey)),
//                   const SizedBox(height: 30),

//                   // Fields
//                   _buildTextField(usernameController, "Username", Icons.person),
//                   const SizedBox(height: 15),
//                   _buildTextField(phoneController, "Phone Number", Icons.phone, type: TextInputType.phone),
//                   const SizedBox(height: 15),
//                   _buildTextField(emailController, "Email", Icons.email, type: TextInputType.emailAddress),
//                   const SizedBox(height: 15),
//                   _buildTextField(passwordController, "Password", Icons.lock, 
//                     isPassword: true, 
//                     obscure: obscurePassword,
//                     toggleObscure: () => setState(() => obscurePassword = !obscurePassword)
//                   ),
                  
//                   // Role Toggle
//                   Row(
//                     children: [
//                       Checkbox(
//                         value: isStaff,
//                         activeColor: Colors.red,
//                         onChanged: (val) => setState(() => isStaff = val!),
//                       ),
//                       const Text("Registering as Staff?"),
//                     ],
//                   ),

//                   if (isStaff) ...[
//                     const SizedBox(height: 10),
//                     _buildTextField(adminCodeController, "Secret Access Code", Icons.security),
//                   ],

//                   const SizedBox(height: 30),
                  
//                   // Sign Up Button
//                   SizedBox(
//                     width: double.infinity,
//                     height: 55,
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.red,
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//                         elevation: 5,
//                       ),
//                       onPressed: _handleSignup,
//                       child: const Text(
//                         "Sign Up",
//                         style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 20),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Text("Already have an account?"),
//                       TextButton(
//                         onPressed: () => Navigator.pop(context),
//                         child: const Text("Log In", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField(TextEditingController controller, String label, IconData icon,
//       {TextInputType type = TextInputType.text, bool isPassword = false, bool obscure = false, VoidCallback? toggleObscure}) {
//     return TextField(
//       controller: controller,
//       keyboardType: type,
//       obscureText: obscure,
//       decoration: InputDecoration(
//         labelText: label,
//         prefixIcon: Icon(icon, color: Colors.red),
//         suffixIcon: isPassword 
//           ? IconButton(icon: Icon(obscure ? Icons.visibility_off : Icons.visibility), onPressed: toggleObscure)
//           : null,
//         filled: true,
//         fillColor: Colors.grey[100],
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
//         contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
//       ),
//     );
//   }

//   void _handleSignup() async {
//     String email = emailController.text.trim();
//     String phone = phoneController.text.trim();

//     if (usernameController.text.isNotEmpty &&
//         phone.isNotEmpty &&
//         email.isNotEmpty &&
//         passwordController.text.isNotEmpty) {
      
//       if (!isEmailValid(email)) {
//         _showError(context, "Please enter a valid email");
//         return;
//       }

//       if (!isPhoneValid(phone)) {
//         _showError(context, "Please enter a valid 10-digit number");
//         return;
//       }

//       await createUser(context, usernameController.text, phone, email, passwordController.text);
      
//       if (context.mounted) {
//         // Redirect to AuthWrapper (Main Entry)
//         Navigator.of(context).pushAndRemoveUntil(
//           MaterialPageRoute(builder: (context) => const AuthWrapper()),
//           (route) => false,
//         );
//       }
//     } else {
//       _showError(context, "All fields are required");
//     }
//   }
// }