import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CityData extends StatefulWidget {
  const CityData({super.key});

  @override
  State<CityData> createState() => _CityDataState();
}

class _CityDataState extends State<CityData> {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  final TextEditingController cityNameController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController cityCodeController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  void clearFields() {
    cityNameController.clear();
    stateController.clear();
    cityCodeController.clear();
  }

  Future<void> addCity() async {
    if (_formKey.currentState!.validate()) {
      await db.collection("city").add({
        "name": cityNameController.text.trim(),
        "state": stateController.text.trim(),
        "cityCode": cityCodeController.text.trim(),
        "isActive": true,
        "createdAt": FieldValue.serverTimestamp(),
      });

      clearFields();
    
    }
  }

  Future<void> updateCity(String id) async {
    if (_formKey.currentState!.validate()) {
      await db.collection("city").doc(id).update({
        "name": cityNameController.text.trim(),
        "state": stateController.text.trim(),
        "cityCode": cityCodeController.text.trim(),
        "isActive": true,
        "createdAt": FieldValue.serverTimestamp(),
      });

      clearFields();
    
    }
  }


  Future<void> deleteCity(String id) async {
    await db.collection("city").doc(id).delete();
  }


  

  void showAddCityDialog({Map<String, dynamic>? city}) {

      if (city != null) {
      cityNameController.text = city["name"];
      stateController.text = city["state"];
      cityCodeController.text = city["cityCode"];
     
    } else {
      clearFields();
    }
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(city != null ? "Edit City" : "Add City"),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: cityNameController,
                  decoration: const InputDecoration(labelText: "City Name"),
                  validator: (value) =>
                      value!.isEmpty ? "Enter city name" : null,
                ),
                TextFormField(
                  controller: stateController,
                  decoration: const InputDecoration(labelText: "State"),
                  validator: (value) =>
                      value!.isEmpty ? "Enter state" : null,
                ),
                TextFormField(
                  controller: cityCodeController,
                  decoration: const InputDecoration(labelText: "City Code"),
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
                if (_formKey.currentState!.validate()) {
                  if (city != null) {
                    await updateCity(city["docId"]);
                  } else {
                    await addCity();
                  }

                  Navigator.pop(context);
                  clearFields();
                }
              },
              child: Text(city != null ? "Update" : "Add"),
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
          title: const Text("City Management",style: TextStyle(fontWeight: FontWeight.bold,color:Colors.white),),
    
       backgroundColor: Colors.red,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddCityDialog,
        child: const Icon(Icons.add),
      ),
      body: Container(
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
      stream: db.collection("city").snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

       

 final cities = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data["docId"] = doc.id;
          return data;
        }).toList();


        if (cities.isEmpty) {
          return const Center(child: Text("No cities added"));
        }

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
                    columnSpacing: 30,
                    headingRowHeight: 55,
                    dataRowHeight: 65,

                 
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
                      DataColumn(label: Text("City Name")),
                      DataColumn(label: Text("State")),
                      DataColumn(label: Text("Code")),
                      DataColumn(label: Text("Action")),
                    ],

                    rows: cities.asMap().entries.map((entry) {
                      int index = entry.key;
                      var data = entry.value;
                     

                      return DataRow(
                        color: MaterialStateProperty.resolveWith<Color?>(
                          (states) => index.isEven
                              ? Colors.red.shade50
                              : Colors.white,
                        ),

                        cells: [
                          DataCell(Text(data['name'] ?? '', style: const TextStyle(
                     
                      fontWeight: FontWeight.bold,
                    
                    ),)),

                          DataCell(Text(data['state'] ?? '', style: const TextStyle(
                     
                      fontWeight: FontWeight.bold,
                    
                    ),)),

                          // 🏷 Code badge
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                data['cityCode'] ?? '',
                                style: const TextStyle(
                                    color: Colors.blue),
                              ),
                            ),
                          ),

                          // 🎯 Action
                          DataCell(
                            Row(
                     children: [


                      Container(
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.edit,
                                    color: Colors.blue),
                                onPressed: () =>
                                      showAddCityDialog(city:data)
                              ),
                            ),
                            SizedBox(width: 10,),
                                Container(
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.red),
                                onPressed: () =>
                                    deleteCity(data['docId']),
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
),
    );
  }
}
