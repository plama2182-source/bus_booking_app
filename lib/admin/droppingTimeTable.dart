import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';




class DroppingTimeTable extends StatefulWidget {
  const DroppingTimeTable({super.key});

  @override
  State<DroppingTimeTable> createState() => _DroppingTimeTableState();
}

class _DroppingTimeTableState extends State<DroppingTimeTable> {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  String? selectedSource;
  String? selectedDestination;
String? selectedRouteId;
String? selectedScheduleId;
  final TextEditingController cityController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
 final TextEditingController orderController = TextEditingController();

  @override
  void dispose() {
    cityController.dispose();
    timeController.dispose();
    orderController.dispose();
    super.dispose();
  }

  void _clearForm() {
    selectedSource = null;
    selectedDestination = null;
    selectedScheduleId=null;
    cityController.clear();
    timeController.clear();
    orderController.clear();
  }

  Future<void> addDroppingTime() async {

    print(timeController.text);
    await db.collection("DroppingTimeTable").add({
      "droppingId": selectedSource,
      "scheduleId":selectedScheduleId,
     
      "city": cityController.text,
      "droppingtime": timeController.text,
       "order": int.parse(orderController.text),
    });
    _clearForm();
  }

  Future<void> updateDroppingTime(String id) async {
    await db.collection("DroppingTimeTable").doc(id).update({
     "droppingId": selectedSource,
      "scheduleId":selectedScheduleId,
     
      "city": cityController.text,
      "droppingtime": timeController.text,
      "order": int.parse(orderController.text),
    });
  }

  Future<void> deletedroppingTime(String id) async {
    await db.collection("DroppingTimeTable").doc(id).delete();
  }
 List<Map<String, String>> scheduleDropdownItems = []; // each item: {"id": scheduleId, "label": "BusName | Date"}
bool isLoadingSchedules = true;

Future<void> loadSchedulesWithBus() async {
  final scheduleSnapshot = await db.collection("schedules").get();
  List<Map<String, String>> tempList = [];

  for (var doc in scheduleSnapshot.docs) {
    final scheduleData = doc.data() as Map<String, dynamic>;
    String busName = "N/A";
 String routename= "N/A";
    if (scheduleData['busId'] != null) {
      final busDoc = await db.collection("bus").doc(scheduleData['busId']).get();
      final busData = busDoc.data() as Map<String, dynamic>?;
      busName = busData?['busname'] ?? "N/A";
    }
     if (scheduleData['routeId'] != null) {
      final routeDoc = await db.collection("route").doc(scheduleData['routeId']).get();
      final routeData = routeDoc.data() as Map<String, dynamic>?;
    
      routename = "${routeData?['from']} → ${routeData?['to']}" ?? "N/A";
    }

    tempList.add({
      "id": doc.id,
      "label": "$busName | $routename | ${scheduleData['date'] ?? ''}",
    });
  }
if (!mounted) return;
  setState(() {
    scheduleDropdownItems = tempList;
    isLoadingSchedules = false;
  });
}

@override
void initState() {
  super.initState();
  loadSchedulesWithBus();
}
Future<String> getBusName(String scheduleId) async {
  // 1. Get the schedule document
  final scheduleDoc = await FirebaseFirestore.instance
      .collection("schedules")
      .doc(scheduleId)
      .get();

  if (!scheduleDoc.exists) return "Schedule not found";

  final scheduleData = scheduleDoc.data();
  final busId = scheduleData?['busId'];
  if (busId == null) return "Bus not assigned";

  // 2. Get the bus document
  final busDoc =
      await FirebaseFirestore.instance.collection("bus").doc(busId).get();

  if (!busDoc.exists) return "Bus not found";

  final busData = busDoc.data();
  return busData?['busname'] ?? "Unknown Bus";
}




Future<String> getroute(String scheduleId) async {
 
  final scheduleDoc = await FirebaseFirestore.instance
      .collection("schedules")
      .doc(scheduleId)
      .get();

  if (!scheduleDoc.exists) return "Schedule not found";

  final scheduleData = scheduleDoc.data();
  final routeId = scheduleData?['routeId'];
  if (routeId == null) return "Route not assigned";

 
  final routeDoc =
      await FirebaseFirestore.instance.collection("route").doc(routeId).get();

  if (!routeDoc.exists) return "Route not found";

  final routeData = routeDoc.data();
 
  return   "${routeData?['from']} → ${routeData?['to']}"?? "Unknown route";
}




  void _showRouteDialog({DocumentSnapshot? data}) {
    if (data != null) {
      selectedSource = data["droppingId"];
      
       selectedScheduleId=data["scheduleId"];
      
      cityController.text = data["city"] ?? "";
      timeController.text = data["droppingtime"] ?? "";
      orderController.text=data["order"].toString() ?? "";
    
    } else {
      _clearForm();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(data == null ? "Add " : "Edit "),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
isLoadingSchedules
    ? CircularProgressIndicator()
    : DropdownButtonFormField<String>(
      
        value: selectedScheduleId,
       
                        decoration: InputDecoration(
                          labelText: "Select Schedule ",
                          border: OutlineInputBorder(),
                        ),
        items: scheduleDropdownItems.map((item) {
    
          return DropdownMenuItem<String>(
            value: item['id'],
            child: Text(item['label']!),
          );
        }).toList(),
        onChanged: (val) {
          setState(() {
            selectedScheduleId = val;
          });
        },
        validator: (val) => val == null ? "Please select a schedule" : null,
      ),
 
const SizedBox(height: 10),
              

              
                const SizedBox(height: 10),
               StreamBuilder<QuerySnapshot>(
                    stream: db.collection("dropping").snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }

                      if (!snapshot.hasData || snapshot.data == null) {
                        return const Text("No dropping point found");
                      }
                      var docs = snapshot.data!.docs;
                     
                      return DropdownButtonFormField<String>(
                        value:selectedSource,
                        decoration: InputDecoration(
                          labelText: "Select dropping point",
                          border: OutlineInputBorder(),
                        ),
                        items: docs.map((doc) {
                          return DropdownMenuItem<String>(
                            value: doc.id,
                            child: Text(doc['stopName']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedSource = value;
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 10),
              
                TextFormField(
                  controller: cityController,
                  decoration: const InputDecoration(
                    labelText: "City Name",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                         TextFormField(
                    controller: timeController,
                    decoration: const InputDecoration(
                      labelText: "Dropping time (HH:mm)",
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
                const SizedBox(height: 10),


                TextFormField(
                  controller: orderController,
                  decoration: const InputDecoration(
                    labelText: "Drop Order",
                    border: OutlineInputBorder(),
                  ),
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
                if (data == null) {
                  await addDroppingTime();
                } else {
                  await updateDroppingTime(data.id);
                }
                Navigator.pop(context);
                _clearForm();
              },
              child: Text(data == null ? "Add" : "Update"),
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
          title: const Text("Dropping Time Table Management",style: TextStyle(fontWeight: FontWeight.bold,color:Colors.white),),
    
       backgroundColor: Colors.red,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showRouteDialog(),
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
      stream: db.collection("DroppingTimeTable").snapshots(),
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
                      DataColumn(label: Text("Dropping Point")),
                      DataColumn(label: Text("Date")),
                      DataColumn(label: Text("Bus")),
                      DataColumn(label: Text("Route")),
                      DataColumn(label: Text("Time")),
                      DataColumn(label: Text("Order")),
                      DataColumn(label: Text("Actions")),
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
                          // 📍 Dropping Point
                          DataCell(
                            StreamBuilder<DocumentSnapshot>(
                              stream: db
                                  .collection("dropping")
                                  .doc(doc['droppingId'])
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData ||
                                    !snapshot.data!.exists) {
                                  return const Text("...");
                                }

                                var data = snapshot.data!.data()
                                    as Map<String, dynamic>?;

                                return Text(
                                  data?['stopName'] ?? "Unknown",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                );
                              },
                            ),
                          ),

                          // 📅 Date
                          DataCell(
                            StreamBuilder<DocumentSnapshot>(
                              stream: db
                                  .collection("schedules")
                                  .doc(doc['scheduleId'])
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData ||
                                    !snapshot.data!.exists) {
                                  return const Text("...");
                                }

                                var data = snapshot.data!.data()
                                    as Map<String, dynamic>?;

                                return Text(data?['date'] ?? "Null");
                              },
                            ),
                          ),

                          // 🚌 Bus
                          DataCell(
                            FutureBuilder<String>(
                              future: getBusName(doc["scheduleId"]),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const Text("...");
                                }
                                return Text(snapshot.data ?? "");
                              },
                            ),
                          ),

                          // 🛣 Route
                          DataCell(
                            FutureBuilder<String>(
                              future: getroute(doc["scheduleId"]),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const Text("...");
                                }
                                return Text(snapshot.data ?? "");
                              },
                            ),
                          ),

                          // ⏰ Time badge
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                doc["droppingtime"] ?? "",
                                style: const TextStyle(
                                    color: Colors.blue),
                              ),
                            ),
                          ),

                          // 🔢 Order badge
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                doc["order"].toString(),
                                style: const TextStyle(
                                    color: Colors.orange),
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
                                        _showRouteDialog(data: doc),
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
                                    onPressed: () =>
                                        deletedroppingTime(doc.id),
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