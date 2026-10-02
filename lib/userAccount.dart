import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:intl/intl.dart';
import 'personalData.dart';
import 'changePassword.dart';
import 'session.dart';
import 'footer.dart';
import 'signup.dart';

import 'login.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(Account());
}

class Account extends StatefulWidget {
  const Account({super.key});

   
  @override
  State<Account> createState() => AccountDetailsPageState();
}

class AccountDetailsPageState extends State<Account> { 
  final FirebaseFirestore db = FirebaseFirestore.instance;

 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: AppBar(
             automaticallyImplyLeading: false,
              leading: Icon(Icons.person_add_rounded,size:30,color: Colors.white,),
        elevation: 10,
        shadowColor: Colors.black,
        backgroundColor: Colors.red,
       
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  "My Account",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 20),
           
           
            Divider(),


InkWell(
  onTap: () {
    Navigator.push(
      context,
      
      MaterialPageRoute(builder: (context) =>  personalInfo()),
    );
    
  },
  child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [


                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Icon(Icons.person), Text("Personal Information")],
                ),
                Row(children: [Icon(Icons.arrow_forward_ios_rounded)]),
              ],
            ),
),

           
            SizedBox(height: 20),
            Divider(),

            
InkWell(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>  ChangePasswordPage()),
    );
  },
       child:      Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.password_rounded),
                    Text("Change Password"),
                  ],
                ),
                Row(children: [Icon(Icons.arrow_forward_ios_rounded)]),
              ],
            ),),
            SizedBox(height: 20),
            Divider(),

            InkWell(
  onTap: () 
     async {
   
    await FirebaseAuth.instance.signOut(); 
    
    if (context.mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => SignupPage()));
    }
  },
        child:    Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Icon(Icons.output), Text("Sign Out")],
                ),
                Row(children: [Icon(Icons.arrow_forward_ios_rounded)]),
              ],
            ),
            ),
            SizedBox(height: 20),
            Divider(),
          ],
        ),
      
      ),
      bottomNavigationBar: Footer(),
    );
  }
}









