import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
class busSchedule extends StatefulWidget {
  const busSchedule({super.key});

  @override
  State<busSchedule> createState() => _busScheduleState();
}

class _busScheduleState extends State<busSchedule> {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  // Controllers for Add/Edit form
  final TextEditingController deptDate = TextEditingController();
  final TextEditingController deptTime = TextEditingController();
  final TextEditingController from = TextEditingController();
  final TextEditingController price = TextEditingController();
  final TextEditingController reachTime = TextEditingController();
  final TextEditingController reachDate = TextEditingController();
  final TextEditingController to = TextEditingController();

  String? busId;
  String? selectedRouteId;
final String currentAdminId = FirebaseAuth.instance.currentUser?.uid ?? "";

Future<List<String>> getAdminBusIds() async {
    QuerySnapshot busSnapshot = await db
        .collection("bus")
        .where("userId", isEqualTo: currentAdminId)
        .get();

    return busSnapshot.docs.map((doc) => doc.id).toList();
  }



  Future<void> updatebusSchedule(Map<String, dynamic> busSchedule) async {
    String id = busSchedule["docId"];

    await db.collection("schedules").doc(id).update({
      "busId": busId,
      "date": deptDate.text,
      "boardingTime": deptTime.text,
      "routeId": selectedRouteId,
      "price": price.text,
      "droppingTime": reachTime.text,
      "reachDate": reachDate.text,
    });
  }

  Future<void> addbusSchedule() async {

     DocumentReference busScheduleRef = await db.collection("schedules").add({
      "busId": busId,
      "date": deptDate.text,
      "boardingTime": deptTime.text,
      "routeId": selectedRouteId,
      "price": price.text,
      "droppingTime": reachTime.text,
      "reachDate": reachDate.text,
    });

 final busDoc = await FirebaseFirestore.instance
      .collection('bus')
      .doc(busId)
      .get();
    
int seatnumber=busDoc['totalSeats'];

    createSeats( busScheduleRef.id,seatnumber);
  }

 Future<void> createSeats(String busScheduleId,int num) async {
    for (int i = 1; i <= num; i++) {
      await db
          .collection("schedules")
          .doc(busScheduleId)
          .collection("seats")
          .doc("seat_$i")
          .set({
        "seatNumber": i,
        "status": "available",
      });
    }
  }
  @override
  void dispose() {
    deptDate.dispose();
    deptTime.dispose();
    from.dispose();
    price.dispose();
    reachTime.dispose();
    reachDate.dispose();
   
    super.dispose();
  }

  void _showbookingDialog({Map<String, dynamic>? busSchedule}) {
    if (busSchedule != null) {
    
      deptDate.text = busSchedule["date"];
      deptTime.text = busSchedule["boardingTime"];
      reachDate.text = busSchedule["reachDate"];
      reachTime.text = busSchedule["droppingTime"];
      price.text = busSchedule["price"].toString();
       busId = busSchedule["busId"];
       
    selectedRouteId = busSchedule["routeId"];
    } else {
      _clearForm();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(busSchedule != null ? "Edit busSchedule" : "Add New busSchedule"),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
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
                  SizedBox(height: 10),

                  SizedBox(height: 10),
                  StreamBuilder<QuerySnapshot>(
                    stream: db.collection("bus").where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid).snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }

                      if (!snapshot.hasData || snapshot.data == null) {
                        return const Text("No buses found");
                      }
                       var docs = snapshot.data!.docs;
                      if (busId == null && docs.isNotEmpty) {
  busId = docs.first.id;
}
                      return DropdownButtonFormField<String>(
                        value:busId,
                        decoration: InputDecoration(
                          labelText: "Select bus",
                          border: OutlineInputBorder(),
                        ),
                        items: docs.map((doc) {
                          return DropdownMenuItem<String>(
                            value: doc.id,
                            child: Text(doc["busname"]),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            busId = value;
                          });
                        },
                      );
                    },
                  ),
                  SizedBox(height: 10),

                  TextFormField(
                    controller: deptDate,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: "Departure Date",
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );

                      if (pickedDate != null) {
                        
deptDate.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                              }
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: deptTime,
                    decoration: const InputDecoration(
                      labelText: "Departure time (HH:mm)",
                    ),
                    keyboardType: TextInputType.datetime,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Enter time";
                      }

                      final regex = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$');

                      if (!regex.hasMatch(value)) {
                        return "Invalid time format (HH:mm)";
                      }

                      return null;
                    },
                  ),

                  SizedBox(height: 10),
                  TextFormField(
                    controller: reachDate,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: "Reach Date",
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );

                      if (pickedDate != null) {
                       reachDate.text = DateFormat('yyyy-MM-dd').format(pickedDate);
  }
                    },
                  ),
                  TextFormField(
                    controller: reachTime,
                    decoration: const InputDecoration(
                      labelText: "Reach Time (HH:mm)",
                    ),
                    keyboardType: TextInputType.datetime,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Enter time";
                      }

                      final regex = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$');

                      if (!regex.hasMatch(value)) {
                        return "Invalid time format (HH:mm)";
                      }

                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: price,
                    decoration: const InputDecoration(labelText: "Price "),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value!.isEmpty ? "Enter price " : null,
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
                    if (busSchedule != null) {
                      updatebusSchedule(busSchedule);
                    } else {
                      addbusSchedule();
                    }
                  });
                  Navigator.of(context).pop();
                  _clearForm();
                }
              },
              child: Text(busSchedule != null ? "Update" : "Add"),
            ),
          ],
        );
      },
    );
  }

  void _clearForm() {
    deptDate.clear();
    deptTime.clear();
    from.clear();
    price.clear();
    reachTime.clear();
    reachDate.clear();
    to.clear();
  }

  @override
  Widget build(BuildContext context) {
    int index = 0;
    String? from;
    String? to;
  
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text("Schedule Management",style: TextStyle(fontWeight: FontWeight.bold,color:Colors.white),)),
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

    child:FutureBuilder<List<String>>(
        future: getAdminBusIds(),
        builder: (context, busIdsSnapshot) {
          if (busIdsSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final myBusIds = busIdsSnapshot.data ?? [];

          if (myBusIds.isEmpty) {
            return const Center(child: Text("No schedule found for this admin."));
          }

          return StreamBuilder<QuerySnapshot>(
            // Use the list of IDs from the FutureBuilder
            stream: db.collection("schedules")
                .where("busId", whereIn: myBusIds)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Text("Error: ${snapshot.error}");
              if (!snapshot.hasData) return const LinearProgressIndicator();

       

        final busSchedule = snapshot.data!.docs.map((doc) {
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
                    columnSpacing: 28,
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
                      DataColumn(label: Text("Bus")),
                      DataColumn(label: Text("From")),
                      DataColumn(label: Text("To")),
                      DataColumn(label: Text("Dep Date")),
                      DataColumn(label: Text("Dep Time")),
                      DataColumn(label: Text("Reach Date")),
                      DataColumn(label: Text("Reach Time")),
                      DataColumn(label: Text("Price")),
                      DataColumn(label: Text("Actions")),
                    ],

                    rows: busSchedule.asMap().entries.map((entry) {
                      int index = entry.key;
                      var busScheduleList = entry.value;

                      return DataRow(
                        color: MaterialStateProperty.resolveWith<Color?>(
                          (states) => index.isEven
                              ? Colors.red.shade50
                              : Colors.white,
                        ),

                        cells: [
                          DataCell(Text((index + 1).toString(), style: const TextStyle(
                     
                      fontWeight: FontWeight.bold,
                    
                    ))),

                          // 🚍 Bus Name
                          DataCell(
                            StreamBuilder<DocumentSnapshot>(
                              stream: db
                                  .collection("bus")
                                  .doc(busScheduleList['busId'])
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData ||
                                    !snapshot.data!.exists) {
                                  return const Text("...");
                                }
                                var data = snapshot.data!.data()
                                    as Map<String, dynamic>?;
                              
                                return Text(
                                  data?['busname'] ?? "Unknown",  style: const TextStyle(
                     
                      fontWeight: FontWeight.bold,
                    )
                                );
                              },
                            ),
                          ),

                          // 📍 Fromr
                          DataCell(
                            StreamBuilder<DocumentSnapshot>(
                              stream: db
                                  .collection("route")
                                  .doc(busScheduleList['routeId'])
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData ||
                                    !snapshot.data!.exists) {
                                  return const Text("...");
                                }
                                var data = snapshot.data!.data()
                                    as Map<String, dynamic>?;
                                from = data?['from'];
                                return Text(data?['from'] ?? "Unknown", style: const TextStyle(
                     
                      fontWeight: FontWeight.bold,
                    ));
                              },
                            ),
                          ),

                          // 📍 To
                          DataCell(
                            StreamBuilder<DocumentSnapshot>(
                              stream: db
                                  .collection("route")
                                  .doc(busScheduleList['routeId'])
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData ||
                                    !snapshot.data!.exists) {
                                  return const Text("...");
                                }
                                var data = snapshot.data!.data()
                                    as Map<String, dynamic>?;
                                to = data?['to'];
                                return Text(data?['to'] ?? "Unknown", style: const TextStyle(
                     
                      fontWeight: FontWeight.bold,
                    ));
                              },
                            ),
                          ),

                          DataCell(Text(busScheduleList['date'].toString(), style: const TextStyle(
                     
                      fontWeight: FontWeight.bold,
                    ))),

                          DataCell(
                            Text(busScheduleList['boardingTime'].toString(), style: const TextStyle(
                     
                      fontWeight: FontWeight.bold,
                    )),
                          ),

                          DataCell(Text(busScheduleList["reachDate"], style: const TextStyle(
                     
                      fontWeight: FontWeight.bold,
                    ))),

                          DataCell(
                            Text(busScheduleList['droppingTime'].toString(), style: const TextStyle(
                     
                      fontWeight: FontWeight.bold,
                    )),
                          ),

                          // 💰 Price badge
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "₹${busScheduleList["price"]}",
                                style: const TextStyle(
                                    color: Colors.green, 
                      fontWeight: FontWeight.bold,),
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
                                    onPressed: () => _showbookingDialog(
                                      busSchedule: busScheduleList,
                                    
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
                                            .collection("schedules")
                                            .doc(busScheduleList['docId'])
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
    );}
    )
  ),
),
    );
  }
}
