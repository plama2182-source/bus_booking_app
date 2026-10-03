import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class busdata extends StatefulWidget {
  const busdata({super.key});

  @override
  State<busdata> createState() => _busdataState();
}

class _busdataState extends State<busdata> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore db = FirebaseFirestore.instance;

  // Controllers
  final TextEditingController numberController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController seatsController = TextEditingController();
    final TextEditingController layoutController = TextEditingController();
  final TextEditingController columnController = TextEditingController();
  final TextEditingController aisle_indexController = TextEditingController();

  @override
  void dispose() {
    numberController.dispose();
    nameController.dispose();
    typeController.dispose();
    seatsController.dispose();
     layoutController.dispose();
    columnController.dispose();
    aisle_indexController.dispose();
    super.dispose();
  }

  Future<void> addBus() async {
    await db.collection("bus").add({
      "busNumber": numberController.text,
      "busname": nameController.text,
      "type": typeController.text,
      "totalSeats": int.parse(seatsController.text),
      "layout_type":int.parse(layoutController.text),
      "column": int.parse(columnController.text)  ,
      "aisle_index":int.parse(aisle_indexController.text) 
    });
  }

  Future<void> updateBus(String id) async {
    await db.collection("bus").doc(id).update({
      "busNumber": numberController.text,
      "busname": nameController.text,
      "type": typeController.text,
      "totalSeats": int.parse(seatsController.text),
      "layout_type":int.parse(layoutController.text),
     "column": int.parse(columnController.text)  ,
      "aisle_index":int.parse(aisle_indexController.text) 
    });
  }

  Future<void> deleteBus(String id) async {
    await db.collection("bus").doc(id).delete();
  }

  void _showBusDialog({Map<String, dynamic>? bus}) {
    if (bus != null) {
      numberController.text = bus["busNumber"];
      nameController.text = bus["busname"];
      typeController.text = bus["type"];
      seatsController.text = bus["totalSeats"].toString();
      layoutController.text=bus['layout_type'].toString();
         columnController.text=bus['column'].toString();
            aisle_indexController.text=bus['aisle_index'].toString();
    } else {
      _clearForm();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(bus != null ? "Edit Bus" : "Add Bus"),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: numberController,
                  decoration: const InputDecoration(labelText: "Bus Number"),
                  validator: (value) => value!.isEmpty ? "Enter bus number" : null,
                ),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Bus Name"),
                  validator: (value) => value!.isEmpty ? "Enter bus name" : null,
                ),
                TextFormField(
                  controller: typeController,
                  decoration: const InputDecoration(labelText: "Type"),
                  validator: (value) => value!.isEmpty ? "Enter type" : null,
                ),
                TextFormField(
                  controller: seatsController,
                  decoration: const InputDecoration(labelText: "Number of Seats"),
                  validator: (value) => value!.isEmpty ? "Enter number of seats" : null,
                ),
                TextFormField(
                  controller: layoutController,
                
                  decoration: const InputDecoration(labelText: "Layout Type"),
                  validator: (value) => value!.isEmpty ? "Enter layout type" : null,
                ),
                 TextFormField(
                  controller: columnController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Column"),
                  validator: (value) => value!.isEmpty ? "Enter column " : null,
                ),
                 TextFormField(
                  controller: aisle_indexController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Gap Index:"),
                  validator: (value) => value!.isEmpty ? "Enter gap index" : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _clearForm();
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  if (bus != null) {
                    await updateBus(bus["docId"]);
                  } else {
                    await addBus();
                  }

                  Navigator.pop(context);
                  _clearForm();
                }
              },
              child: Text(bus != null ? "Update" : "Add"),
            ),
          ],
        );
      },
    );
  }

  void _clearForm() {
    numberController.clear();
    nameController.clear();
    typeController.clear();
    seatsController.clear();
     layoutController.clear();
    columnController.clear();
    aisle_indexController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Bus Management",style: TextStyle(fontWeight: FontWeight.bold,color:Colors.white),),
    
       backgroundColor: Colors.red,
      ),
     
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => _showBusDialog(),
      //   child: const Icon(Icons.add),
      // ),
      body:Container(
  width: double.infinity,
   padding: const EdgeInsets.only(top: 20),

  child: Container(
   

    child: StreamBuilder<QuerySnapshot>(
      stream: db.collection("bus").snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final buses = snapshot.data!.docs.map((doc) {
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
                  minWidth: constraints.maxWidth, 
                ),

                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),

                  child: DataTable(
                    columnSpacing: 40,
                    headingRowHeight: 55,
                    dataRowHeight: 65,

                   
                    headingRowColor: MaterialStateProperty.all(
                      const Color(0xffF44336),
                    ),

                    headingTextStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),

                    dataTextStyle: const TextStyle(
                    
                      fontWeight: FontWeight.w500,
                    ),

                    columns: const [
                       DataColumn(label: Text("Bus Owner")),
                       DataColumn(label: Text("Bus Company")),
                      DataColumn(label: Text("Bus Number")),
                      DataColumn(label: Text("Name")),
                      DataColumn(label: Text("Seats")),
                      DataColumn(label: Text("Type")),
                       DataColumn(label: Text("layout type")),
                      DataColumn(label: Text("column")),
                      DataColumn(label: Text("Aisle Index")),
                      DataColumn(label: Text("Actions")),
                    ],

                    rows: buses.asMap().entries.map((entry) {
                      int index = entry.key;
                      var bus = entry.value;

                      return DataRow(
                        // ✅ Alternating rows
                        color: MaterialStateProperty.resolveWith<Color?>(
                          (states) => index.isEven
                              ? Colors.red.shade50
                              : Colors.white,
                        ),

                        cells: [
                           
                     DataCell(
                              StreamBuilder<DocumentSnapshot>(
                                stream: db
                                    .collection("users")
                                    .doc(bus['userId'])
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData ||
                                      !snapshot.data!.exists) {
                                    return const Text("...");
                                  }

                                  var user = snapshot.data!.data()
                                      as Map<String, dynamic>;
 return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  "${user['name']} ", style: const TextStyle(
                     
                      fontWeight: FontWeight.bold,
                    
                    )),
                                             
                                            ],
                                          );
                                 
                                },
                              ),
                            ),
                          DataCell(Text(bus["company"].toString(), style: const TextStyle(
                     
                      fontWeight: FontWeight.bold,
                    
                    ),)),

                          DataCell(Text(bus["busname"].toString(), style: const TextStyle(
                     
                      fontWeight: FontWeight.bold,
                    
                    ),)),

                     DataCell(Text(bus["busNumber"].toString(), style: const TextStyle(
                     
                      fontWeight: FontWeight.bold,
                    
                    ),)),

                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                bus["totalSeats"].toString(),
                                style: const TextStyle(
                                    color: Colors.blue),
                              ),
                            ),
                          ),

                     
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                bus["type"].toString(),
                                style: const TextStyle(
                                    color: Colors.orange),
                              ),
                            ),
                          ),
 DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                              " ${bus["layout_type"].toString()} row",
                                style: const TextStyle(
                                    color: Colors.blue),
                              ),
                            ),
                          ),
 DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                bus["column"].toString(),
                                style: const TextStyle(
                                    color: Colors.blue),
                              ),
                            ),
                          ),
 DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                bus["aisle_index"].toString(),
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
                                        _showBusDialog(bus: bus),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius:
                                        BorderRadius.circular(10),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () async {
                                      await deleteBus(
                                          bus["docId"]);
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
));
  }
}








