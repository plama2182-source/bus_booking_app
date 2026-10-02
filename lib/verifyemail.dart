import 'package:firebase_core/firebase_core.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'utils/responsive.dart';
import 'main.dart';




class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});
  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  Timer? timer;

  @override
  void initState() {
    super.initState();
    // Check every 3 seconds if they clicked the link
    timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      await FirebaseAuth.instance.currentUser?.reload();
      if (FirebaseAuth.instance.currentUser!.emailVerified) {
       
        timer.cancel();
        // Force the app to rebuild and move to HomePage
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (c) => const AuthWrapper()));
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const Text("Confirm your email! Check your inbox."),
            ElevatedButton(
              onPressed: () => FirebaseAuth.instance.currentUser?.sendEmailVerification(),
              child: const Text("Resend Link"),
            ),
            TextButton(
              onPressed: ()async=>{await FirebaseAuth.instance.currentUser?.delete()},
              child: const Text("Cancel"),
            ),
          ],
        ),
      ),
    );
  }
}