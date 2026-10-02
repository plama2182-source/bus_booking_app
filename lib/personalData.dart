import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:intl/intl.dart';
import 'session.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(personalInfo());
}

class personalInfo extends StatefulWidget {
 
 
  @override
  State<personalInfo> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<personalInfo> {
 

    late TextEditingController nameController=TextEditingController();
  late TextEditingController emailController =TextEditingController();
 late TextEditingController numberController =TextEditingController();
  
final FirebaseFirestore db = FirebaseFirestore.instance;
    






 Future<void> saveData() async {
    await db.collection("users").doc( FirebaseAuth.instance.currentUser?.uid).update({
        
        "name": nameController.text,
        "email": emailController.text,
        "number": numberController.text
      });
     
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); 
          },
        ),
        elevation: 10,
        shadowColor: Colors.black,
        backgroundColor: Colors.red,
        title: Column(
          children: [
            Row(
              children: [
                Text(
                  "Personal Information",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
           
          ],
        ),
      ),

      body:StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
  stream: FirebaseFirestore.instance
      .collection("users")
      .doc( FirebaseAuth.instance.currentUser?.uid)
      .snapshots(),
        builder: (context, snapshot) {
           if (snapshot.connectionState == ConnectionState.waiting) {
      return const CircularProgressIndicator();
    }

    if (!snapshot.hasData || !snapshot.data!.exists) {
      return const Text("User not found");
    }

    final data = snapshot.data!.data()!;

        return  Column(
          children: [
          
           
          
            SizedBox(height: 24),
            Expanded(child:
            ListView.builder(
                itemCount:1,
               
  itemBuilder: (context, index) {
    
         nameController.text=data['name'];
         emailController.text=data['email'];
         numberController.text=data['number'];
    return 
         
 Card(
              color: const Color.fromARGB(255, 246, 250, 250),
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Container(
                padding: EdgeInsets.all(20),

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Text(
                          "Personal Details",
                          style: TextStyle(
                           
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    
                    Divider(),
                    
                    
                 
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                          controller: nameController,
                           
                            decoration: InputDecoration(
                            
                              
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 2,
                                  color: Colors.grey,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),

                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 2,
                                  color: Colors.blue,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                             controller: emailController,
                            decoration: InputDecoration(
                              labelText: "Email",

                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 2,
                                  color: Colors.grey,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),

                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 2,
                                  color: Colors.blue,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
SizedBox(height: 10),
                                
 Row(
                      children: [
                        Expanded(
                          child: TextField(
                             controller: numberController,
                            decoration: InputDecoration(
                              labelText: "Contact",

                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 2,
                                  color: Colors.grey,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),

                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 2,
                                  color: Colors.blue,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
         

                    SizedBox(height: 5),
                  ],
                ),
              ),
            );
  }

            ),
           
            )
          ],
        );},
      ),
      bottomNavigationBar: Container(
    padding: const EdgeInsets.all(16),
    child: SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          saveData();
        },
        style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,

                            ),
        child: const Text("Save Changes",style: TextStyle(color:Colors.white),),
      ),
    ),
  ),
    );
  }
}
