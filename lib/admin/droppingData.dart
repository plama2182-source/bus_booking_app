import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DroppingData extends StatefulWidget {
  const DroppingData({super.key});

  @override
  State<DroppingData> createState() => _DroppingDataState();
}

class _DroppingDataState extends State<DroppingData> {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  final TextEditingController stopName = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
 final TextEditingController sequenceController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
String? selectedRouteId;
  void clearFields() {
    selectedRouteId=null;
    stopName.clear();
    cityController.clear();
    addressController.clear();
    sequenceController.clear();
  }

  Future<void> addBoading() async {
    if (_formKey.currentState!.validate()) {
      await db.collection("dropping").add({
         "routeId":selectedRouteId,
        "stopName": stopName.text.trim(),
        "city": cityController.text.trim(),
        "address": addressController.text.trim(),
         "sequence":int.parse(sequenceController.text.trim()) ,
      
      });

      clearFields();
     
    }
  }


 Future<void> update(String id) async {
 
      await db.collection("dropping").doc(id).update({
         "routeId":selectedRouteId,
        "stopName": stopName.text.trim(),
        "city": cityController.text.trim(),
        "address": addressController.text.trim(),
        "sequence":int.parse(sequenceController.text.trim()) ,
      
      });

      clearFields();
     
    
  }


  Future<void> delete(String id) async {
    await db.collection("dropping").doc(id).delete();
  }

  void _showboardingDialog({DocumentSnapshot? points}) {
     if (points != null) {
      stopName.text = points["stopName"];
      cityController.text = points["city"];
      addressController.text = points["address"];
      sequenceController.text = points["sequence"].toString();
      selectedRouteId=points['routeId'];
    } else {
         clearFields();
    }
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
           title: Text(points == null ? "Add Dropping" : "Edit Dropping"),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                    StreamBuilder<QuerySnapshot>(
                    stream: db.collection("route").snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }

                      if (!snapshot.hasData || snapshot.data == null) {
                        return const Text("No routes found");
                      }
                      var docs = snapshot.data!.docs;
                      if (selectedRouteId == null && docs.isNotEmpty) {
 
      selectedRouteId = docs.first.id;
  
}
                      return DropdownButtonFormField<String>(
                        value:selectedRouteId,
                        decoration: InputDecoration(
                          labelText: "Select route",
                          border: OutlineInputBorder(),
                        ),
                        items: docs.map((doc) {
                          return DropdownMenuItem<String>(
                            value: doc.id,
                            child: Text("${doc['from']} → ${doc['to']}"),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedRouteId = value;
                          });
                        },
                      );
                    },
                  ),
                TextFormField(
                  controller: stopName,
                  decoration: const InputDecoration(labelText: "Stop Name"),
                
                ),
                TextFormField(
                  controller: cityController,
                  decoration: const InputDecoration(labelText: "City Name"),
                 
                ),
                TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: "Address"),
                   
                ),
                 TextFormField(
                  controller: sequenceController,
                  decoration: const InputDecoration(labelText: "Sequence"),
                  
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
             ElevatedButton(
              onPressed: () async {
                if (points == null) {
                  await addBoading();
                } else {
                
                  await update(points.id);
                }
                Navigator.pop(context);
                clearFields();
              },
              child: Text(points == null ? "Add" : "Update"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Dropping Point Management",style: TextStyle(fontWeight: FontWeight.bold,color:Colors.white),),
    
       backgroundColor: Colors.red,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showboardingDialog,
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
      stream: db.collection("dropping").snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No data"));
        }

        var docs = snapshot.data!.docs;

        return LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: constraints.maxWidth, // ✅ FULL WIDTH
                ),

                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),

                  child: DataTable(
                    columnSpacing: 28,
                    headingRowHeight: 55,
                    dataRowHeight: 65,

                    // 🔴 Header
                    headingRowColor: MaterialStateProperty.all(
                      const Color(0xffd32f2f),
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
                      DataColumn(label: Text("Route")),
                      DataColumn(label: Text("Stop Name")),
                      DataColumn(label: Text("City")),
                      DataColumn(label: Text("Address")),
                      DataColumn(label: Text("Seq")),
                      DataColumn(label: Text("Action")),
                    ],

                    rows: docs.asMap().entries.map((entry) {
                      int index = entry.key;
                      var doc = entry.value;

                      return DataRow(
                        color: MaterialStateProperty.resolveWith<Color?>(
                          (states) => index.isEven
                              ? Colors.red.shade50
                              : Colors.white,
                        ),

                        cells: [
                          // 📍 Route
                          DataCell(
                            StreamBuilder<DocumentSnapshot>(
                              stream: db
                                  .collection("route")
                                  .doc(doc['routeId'])
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData ||
                                    !snapshot.data!.exists) {
                                  return const Text("...");
                                }

                                var data = snapshot.data!.data()
                                    as Map<String, dynamic>?;

                                return Text(
                                  "${data?['from']} → ${data?['to']}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                );
                              },
                            ),
                          ),

                          DataCell(Text(doc['stopName'] ?? '')),

                          DataCell(Text(doc['city'] ?? '')),

                          DataCell(Text(doc['address'] ?? '')),

                          // 🔢 Sequence badge
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                doc['sequence'].toString(),
                                style: const TextStyle(
                                    color: Colors.blue),
                              ),
                            ),
                          ),

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
                                        _showboardingDialog(
                                      points: doc,
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
                                    onPressed: () =>   delete(doc.id),
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