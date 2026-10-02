
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class busAdminData extends StatefulWidget {
 

  const busAdminData({super.key});

  @override
  State<busAdminData> createState() => _busAdminDataState();
}

class _busAdminDataState extends State<busAdminData> {
   final FirebaseFirestore db = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  // Controllers for Add/Edit form
  final TextEditingController numberController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();


 Future<void> updateUser(Map<String, dynamic> user) async {

String id=user["docId"];
    await db.collection("users").doc(id).update({
    
      "name": nameController.text,
      "number": numberController.text,
      "email": emailController.text,
    
    });
   }
   
 Future<void> addUser(Map<String, dynamic>? user) async {


    await db.collection("users").add({
    
      "name": nameController.text,
      "number": numberController.text,
      "email": emailController.text,
    
    });
   }
  @override
  void dispose() {
    numberController.dispose();
    nameController.dispose();
    emailController.dispose();
  
    super.dispose();
  }

  void _showbookingDialog({Map<String, dynamic>? user}) {
  
    if (user != null) {
     
      numberController.text = user["number"];
      nameController.text = user["name"];
      emailController.text = user["email"];
     
    } else {
      _clearForm();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(user != null ? "Edit user" : "Add New user"),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Name"),
                    validator: (value) =>
                        value!.isEmpty ? "Enter  name" : null,
                  ),
                    TextFormField(
                    controller: numberController,
                    decoration: const InputDecoration(labelText: " Number"),
                    validator: (value) =>
                        value!.isEmpty ? "Enter  number" : null,
                  ),
                 
                 
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: "Email"),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value!.isEmpty ? "Enter email" : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _clearForm();
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    if (user != null) {
                      updateUser(user);
                    
                    } else {
                    addUser(user);
                      
                    }
                  });
                  Navigator.of(context).pop();
                  _clearForm();
                }
              },
              child: Text(user != null ? "Update" : "Add"),
            ),
          ],
        );
      },
    );
  }

  void _clearForm() {
    numberController.clear();
    nameController.clear();
    emailController.clear();
  
  }

  @override
  Widget build(BuildContext context) {
    int index=0;
    return Scaffold(
      appBar: AppBar(    title: const Text("Bus Admin Management",style: TextStyle(fontWeight: FontWeight.bold,color:Colors.white),),
    
      backgroundColor: Colors.red,),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showbookingDialog(),
        child: const Icon(Icons.add),
      ),
      body:Container(
  padding: const EdgeInsets.only(top: 20),

  child: Container(
   
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          blurRadius: 12,
          color: Colors.black.withOpacity(0.06),
        )
      ],
    ),

    child: StreamBuilder<QuerySnapshot>(
      stream: db.collection("users").where("role",isEqualTo: "busAdmin").where("isVerified",isEqualTo: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data["docId"] = doc.id;
          return data;
        }).toList();

        return LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: constraints.maxWidth, // 
                ),

                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),

                  child: DataTable(
                    columnSpacing: 30,
                    headingRowHeight: 55,
                    dataRowHeight: 65,

                    // 🔴 Header
                    headingRowColor: MaterialStateProperty.all(
                      const Color(0xffF44336),
                    ),

                    headingTextStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),

                    dataTextStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),

                    columns: const [
                      DataColumn(label: Text("S.No")),
                      DataColumn(label: Text("Username")),
                      DataColumn(label: Text("Number")),
                      DataColumn(label: Text("Email")),
                      DataColumn(label: Text("Actions")),
                    ],

                    rows: user.asMap().entries.map((entry) {
                      int index = entry.key;
                      var userList = entry.value;

                      return DataRow(
                        color: MaterialStateProperty.resolveWith<Color?>(
                          (states) => index.isEven
                              ? Colors.red.shade50
                              : Colors.white,
                        ),

                        cells: [
                          DataCell(Text((index + 1).toString(), style: const TextStyle(
                     
                      fontWeight: FontWeight.bold,
                    
                    ),)),

                          DataCell(Text(userList['name'].toString(), style: const TextStyle(
                     
                      fontWeight: FontWeight.bold,
                    
                    ),)),

                          // 📱 Number badge
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                userList["number"].toString(),
                                style: const TextStyle(
                                    color: Colors.blue ,fontWeight: FontWeight.bold,),
                              ),
                            ),
                          ),

                          DataCell(Text(userList["email"], style: const TextStyle(
                     
                      fontWeight: FontWeight.bold,
                    
                    ),)),

                          // 🎯 Actions
                          DataCell(
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius:
                                        BorderRadius.circular(10),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue),
                                    onPressed: () =>
                                        _showbookingDialog(
                                      user: userList,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius:
                                        BorderRadius.circular(10),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        db
                                            .collection("users")
                                            .doc(userList['docId'])
                                            .delete();
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            );
          },
        );
      },
    ),
  ),
)
    );
  }
}