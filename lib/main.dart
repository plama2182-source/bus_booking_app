
import 'package:busboking/index.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'utils/responsive.dart';
import 'login.dart';
import 'verifyemail.dart';
import 'session.dart';
import 'package:busboking/admin/dashboard.dart';
import 'package:busboking/busAdmin/busAdmindashboard.dart';
import 'pendingVerification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  runApp(const MaterialApp(
     debugShowCheckedModeBanner: false,
    home: AuthWrapper()));
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

 @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // Listen to the Firebase Auth login state
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        
        // 1. If waiting for Firebase connection
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // 2. If the user is logged in
        if (snapshot.hasData) {
          User user = snapshot.data!;

          // 3. Check if email is verified
          if (!user.emailVerified) {
            return const VerifyEmailPage(); 
          }

          // 4. Fetch the User Role from Firestore
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }

              if (roleSnapshot.hasData && roleSnapshot.data!.exists) {
                String role = roleSnapshot.data!.get('role');
              
                // REDIRECTION LOGIC
                if (role == 'admin') {
                  return const Dashboard();
                } else if (role == 'busAdmin') {
                   bool isVerified= roleSnapshot.data!.get('isVerified');
  if (isVerified == true) {
    return const BusDashboard();
  } else {
    return const PendingVerificationPage(); 
  }
} else {
                  return const FirstPage(); 
                }
              }

              // Fallback if document doesn't exist yet
              return const Scaffold(body: Center(child: Text("User data not found.")));
            },
          );
        }

        // 5. If user is NOT logged in
        return const LoginPage(); 
      },
    );
  }
}