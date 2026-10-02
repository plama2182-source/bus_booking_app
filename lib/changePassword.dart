

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:busboking/utils/responsive.dart';

import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordPage extends StatefulWidget {
  

  const ChangePasswordPage({super.key, });

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController oldPass = TextEditingController();
  TextEditingController newPass = TextEditingController();
  TextEditingController confirmPass = TextEditingController();

  bool isLoading = false;
  bool obscure1 = true;
  bool obscure2 = true;
  bool obscure3 = true;

  Future<void> changePassword() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => isLoading = true);

  try {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      return;
    }

 
    AuthCredential credential = EmailAuthProvider.credential(
      email: user.email!, 
      password: oldPass.text, 
    );

    await user.reauthenticateWithCredential(credential);

  
    await user.updatePassword(newPass.text);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Password Updated Successfully")),
    );

  } on FirebaseAuthException catch (e) {
    String message = "Something went wrong";

    if (e.code == 'wrong-password') {
      message = "Current password is incorrect";
    } else if (e.code == 'weak-password') {
      message = "Password should be at least 6 characters";
    } else if (e.code == 'requires-recent-login') {
      message = "Please login again and try";
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  }

  setState(() => isLoading = false);
}


  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Change Password",style:TextStyle(fontWeight: FontWeight.bold,color:Colors.white),),
        backgroundColor: Colors.red,
         leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: width > 500 ? 400 : width * 0.9, // responsive width
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 10),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Icon(Icons.lock, size: 60, color: Colors.red),
                  SizedBox(height: 20),

                  /// OLD PASSWORD
                  TextFormField(
                    controller: oldPass,
                    obscureText: obscure1,
                    decoration: InputDecoration(
                      labelText: "Old Password",
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(obscure1
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () {
                          setState(() => obscure1 = !obscure1);
                        },
                      ),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "Enter old password" : null,
                  ),

                  SizedBox(height: 15),

                  /// NEW PASSWORD
                  TextFormField(
                    controller: newPass,
                    obscureText: obscure2,
                    decoration: InputDecoration(
                      labelText: "New Password",
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(obscure2
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () {
                          setState(() => obscure2 = !obscure2);
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) return "Enter new password";
                      if (value.length < 6)
                        return "Password must be at least 6 characters";
                      return null;
                    },
                  ),

                  SizedBox(height: 15),

                  /// CONFIRM PASSWORD
                  TextFormField(
                    controller: confirmPass,
                    obscureText: obscure3,
                    decoration: InputDecoration(
                      labelText: "Confirm Password",
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(obscure3
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () {
                          setState(() => obscure3 = !obscure3);
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) return "Confirm password";
                      if (value != newPass.text)
                        return "Passwords do not match";
                      return null;
                    },
                  ),

                  SizedBox(height: 25),

                  /// BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : changePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              "Update Password",
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}