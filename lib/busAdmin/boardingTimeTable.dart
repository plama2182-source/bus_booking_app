import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BoardingTimeTable extends StatefulWidget {
  const BoardingTimeTable({super.key});

  @override
  State<BoardingTimeTable> createState() => _BoardingTimeTableState();
}

class _BoardingTimeTableState extends State<BoardingTimeTable> {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  String? selectedSource;
  String? selectedDestination;
  String? selectedRouteId;
  String? selectedScheduleId;
  final TextEditingController cityController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController orderController = TextEditingController();
  final String currentAdminId = FirebaseAuth.instance.currentUser?.uid ?? "";

  Future<List<String>> getAdminBusIds() async {
    QuerySnapshot busSnapshot = await db
        .collection("bus")
        .where("userId", isEqualTo: currentAdminId)
        .get();

    return busSnapshot.docs.map((doc) => doc.id).toList();
  }

  Future<List<String>> getscheduleIds(List busid) async {
    QuerySnapshot busSnapshot = await db
        .collection("schedules")
        .where("busId", whereIn: busid)
        .get();

    return busSnapshot.docs.map((doc) => doc.id).toList();
  }

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
    selectedScheduleId = null;
    cityController.clear();
    timeController.clear();
    orderController.clear();
  }

  Future<void> addBoardingTime() async {
    await db.collection("boardingTimeTable").add({
      "boardingId": selectedSource,
      "scheduleId": selectedScheduleId,

      "city": cityController.text,
      "boardingtime": timeController.text,
      "order": int.parse(orderController.text),
    });
    _clearForm();
  }

  Future<void> updateBoardingTime(String id) async {
    await db.collection("boardingTimeTable").doc(id).update({
      "boardingId": selectedSource,
      "scheduleId": selectedScheduleId,

      "city": cityController.text,
      "boardingtime": timeController.text,
      "order": int.parse(orderController.text),
    });
  }

  Future<void> deleteBoardingTime(String id) async {
    await db.collection("boardingTimeTable").doc(id).delete();
  }

  List<Map<String, String>> scheduleDropdownItems = [];
  bool isLoadingSchedules = true;

  Future<void> loadSchedulesWithBus() async {
    List<String> bus = await getAdminBusIds();
    final scheduleSnapshot = await db
        .collection("schedules")
        .where('busId', whereIn: bus)
        .get();
    List<Map<String, String>> tempList = [];

    for (var doc in scheduleSnapshot.docs) {
      final scheduleData = doc.data() as Map<String, dynamic>;
      String busName = "N/A";
      String routename = "N/A";
      if (scheduleData['busId'] != null) {
        final busDoc = await db
            .collection("bus")
            .doc(scheduleData['busId'])
            .get();
        final busData = busDoc.data() as Map<String, dynamic>?;
        busName = busData?['busname'] ?? "N/A";
      }
      if (scheduleData['routeId'] != null) {
        final routeDoc = await db
            .collection("route")
            .doc(scheduleData['routeId'])
            .get();
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
    final busDoc = await FirebaseFirestore.instance
        .collection("bus")
        .doc(busId)
        .get();

    if (!busDoc.exists) return "Bus not found";

    final busData = busDoc.data();
    return busData?['busname'] ?? "Unknown Bus";
  }

  Future<String> getroute(String scheduleId) async {
    // 1. Get the schedule document
    final scheduleDoc = await FirebaseFirestore.instance
        .collection("schedules")
        .doc(scheduleId)
        .get();

    if (!scheduleDoc.exists) return "Schedule not found";

    final scheduleData = scheduleDoc.data();
    final routeId = scheduleData?['routeId'];
    if (routeId == null) return "Route not assigned";

    // 2. Get the bus document
    final routeDoc = await FirebaseFirestore.instance
        .collection("route")
        .doc(routeId)
        .get();

    if (!routeDoc.exists) return "Route not found";

    final routeData = routeDoc.data();

    return "${routeData?['from']} → ${routeData?['to']}" ?? "Unknown route";
  }

  void _showRouteDialog({DocumentSnapshot? data}) {
    if (data != null) {
      selectedSource = data["boardingId"];

      selectedScheduleId = data["scheduleId"];

      cityController.text = data["city"] ?? "";
      timeController.text = data["boardingtime"] ?? "";
      orderController.text = data["order"].toString() ?? "";
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
                        validator: (val) =>
                            val == null ? "Please select a schedule" : null,
                      ),

                const SizedBox(height: 10),

                const SizedBox(height: 10),
                StreamBuilder<QuerySnapshot>(
                  stream: db.collection("boarding").snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }

                    if (!snapshot.hasData || snapshot.data == null) {
                      return const Text("No boarding found");
                    }
                    var docs = snapshot.data!.docs;

                    return DropdownButtonFormField<String>(
                      value: selectedSource,
                      decoration: InputDecoration(
                        labelText: "Select boarding point",
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
                const SizedBox(height: 10),

                TextFormField(
                  controller: orderController,
                  decoration: const InputDecoration(
                    labelText: "Stop Order",
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
                  await addBoardingTime();
                } else {
                  await updateBoardingTime(data.id);
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
        title: const Text(
          "Boarding Time Table  Management",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),

        backgroundColor: Colors.red,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showRouteDialog(),
        child: const Icon(Icons.add),
      ),
      body: Container(
        padding: const EdgeInsets.only(top: 20),

        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(blurRadius: 12, color: Colors.black.withOpacity(0.06)),
            ],
          ),

          child: FutureBuilder<List<String>>(
            future: getAdminBusIds(),
            builder: (context, busIdsSnapshot) {
              if (busIdsSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final myBusIds = busIdsSnapshot.data ?? [];

              if (myBusIds.isEmpty) {
                return const Center(
                  child: Text("No schedule found for this admin."),
                );
              }

              return FutureBuilder<List<String>>(
                future: getscheduleIds(myBusIds),
                builder: (context, busIdsSnapshot) {
                  if (busIdsSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final scheduleIds = busIdsSnapshot.data ?? [];

                  if (myBusIds.isEmpty) {
                    return const Center(
                      child: Text("No schedule found for this admin."),
                    );
                  }
                  return StreamBuilder<QuerySnapshot>(
                    stream: db
                        .collection("boardingTimeTable")
                        .where('scheduleId', whereIn: scheduleIds)
                        .snapshots(),
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
                                    DataColumn(label: Text("Boarding Point")),
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
                                      color:
                                          MaterialStateProperty.resolveWith<
                                            Color?
                                          >(
                                            (states) => index.isEven
                                                ? Colors.red.shade50
                                                : Colors.white,
                                          ),

                                      cells: [
                                        // 📍 Boarding Point
                                        DataCell(
                                          StreamBuilder<DocumentSnapshot>(
                                            stream: db
                                                .collection("boarding")
                                                .doc(doc['boardingId'])
                                                .snapshots(),
                                            builder: (context, snapshot) {
                                              if (!snapshot.hasData ||
                                                  !snapshot.data!.exists) {
                                                return const Text("...");
                                              }

                                              var data =
                                                  snapshot.data!.data()
                                                      as Map<String, dynamic>?;

                                              return Text(
                                                data?['stopName'] ?? "Unknown",
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                ),
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

                                              var data =
                                                  snapshot.data!.data()
                                                      as Map<String, dynamic>?;

                                              return Text(
                                                data?['date'] ?? "Null",
                                              );
                                            },
                                          ),
                                        ),

                                        // 🚌 Bus
                                        DataCell(
                                          FutureBuilder<String>(
                                            future: getBusName(
                                              doc["scheduleId"],
                                            ),
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
                                              horizontal: 10,
                                              vertical: 5,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              doc["boardingtime"] ?? "",
                                              style: const TextStyle(
                                                color: Colors.blue,
                                              ),
                                            ),
                                          ),
                                        ),

                                        // 🔢 Order badge
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 5,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.orange.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              doc["order"].toString(),
                                              style: const TextStyle(
                                                color: Colors.orange,
                                              ),
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
                                                  icon: const Icon(
                                                    Icons.edit,
                                                    color: Colors.blue,
                                                  ),
                                                  onPressed: () =>
                                                      _showRouteDialog(
                                                        data: doc,
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
                                                  icon: const Icon(
                                                    Icons.delete,
                                                    color: Colors.red,
                                                  ),
                                                  onPressed: () =>
                                                      deleteBoardingTime(
                                                        doc.id,
                                                      ),
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
