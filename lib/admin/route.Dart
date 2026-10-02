import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class RouteData extends StatefulWidget {
  const RouteData({super.key});

  @override
  State<RouteData> createState() => _RouteDataState();
}

class _RouteDataState extends State<RouteData> {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  String? selectedSource;
  String? selectedDestination;

  final TextEditingController distanceController = TextEditingController();
  final TextEditingController durationController = TextEditingController();

  @override
  void dispose() {
    distanceController.dispose();
    durationController.dispose();
    super.dispose();
  }

  void _clearForm() {
    selectedSource = null;
    selectedDestination = null;
    distanceController.clear();
    durationController.clear();
  }

  Future<void> addRoute() async {
    await db.collection("route").add({
      "from": selectedSource,
      "to": selectedDestination,
      "distance": distanceController.text,
      "duration": durationController.text,
    });
    _clearForm();
  }

  Future<void> updateRoute(String id) async {
    await db.collection("route").doc(id).update({
      "from": selectedSource,
      "to": selectedDestination,
      "distance": distanceController.text,
      "duration": durationController.text,
    });
  }

  Future<void> deleteRoute(String id) async {
    await db.collection("route").doc(id).delete();
  }

  void _showRouteDialog({DocumentSnapshot? route}) {
    if (route != null) {
      selectedSource = route["from"];
      selectedDestination = route["to"];
      distanceController.text = route["distance"] ?? "";
      durationController.text = route["duration"] ?? "";
    } else {
      _clearForm();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(route == null ? "Add Route" : "Edit Route"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream: db.collection("city").snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }

                    var docs = snapshot.data!.docs;

                    return DropdownButtonFormField<String>(
                      value: selectedSource,
                      decoration: const InputDecoration(
                        labelText: "From",
                        border: OutlineInputBorder(),
                      ),
                      items: docs.map((doc) {
                        return DropdownMenuItem<String>(
                          value: doc["name"],
                          child: Text(doc["name"]),
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
                StreamBuilder<QuerySnapshot>(
                  stream: db.collection("city").snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }

                    var docs = snapshot.data!.docs;

                    return DropdownButtonFormField<String>(
                      value: selectedDestination,
                      decoration: const InputDecoration(
                        labelText: "To",
                        border: OutlineInputBorder(),
                      ),
                      items: docs.map((doc) {
                        return DropdownMenuItem<String>(
                          value: doc["name"],
                          child: Text(doc["name"]),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedDestination = value;
                        });
                      },
                    );
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: distanceController,
                  decoration: const InputDecoration(
                    labelText: "Distance (km)",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: durationController,
                  decoration: const InputDecoration(
                    labelText: "Duration (e.g. 8h 30m)",
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
                if (route == null) {
                  await addRoute();
                } else {
                  await updateRoute(route.id);
                }
                Navigator.pop(context);
                _clearForm();
              },
              child: Text(route == null ? "Add" : "Update"),
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
          title: const Text("Route Management",style: TextStyle(fontWeight: FontWeight.bold,color:Colors.white),),
    
       backgroundColor: Colors.red,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showRouteDialog(),
        child: const Icon(Icons.add),
      ),
      body: Container(
        padding: EdgeInsets.only(top:20),
        child: Container(
        

          decoration: BoxDecoration(
          
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: Colors.white,
              width:5,
            ),
          ),
      child:
      StreamBuilder<QuerySnapshot>(
        stream: db.collection("route").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
 if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No data"));
          }
          var docs = snapshot.data!.docs;

          return LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: constraints.maxWidth,
                        ),


                        
                        child: DataTable(
      columnSpacing: 30,
      headingRowHeight: 55,
      dataRowHeight: 60,

    
      headingRowColor: MaterialStateProperty.all(const Color(0xffF44336)),

headingTextStyle: const TextStyle(
  color: Colors.white,
  fontWeight: FontWeight.bold,
  fontSize: 15,
),

      dataTextStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),

      columns: const [
        DataColumn(label: Text("From")),
        DataColumn(label: Text("To")),
        DataColumn(label: Text("Distance")),
        DataColumn(label: Text("Duration")),
        DataColumn(label: Text("Actions")),
      ],

      rows: docs.asMap().entries.map((entry) {
        int index = entry.key;
        var doc = entry.value;

        return DataRow(
          // ✅ Alternating row color
          color: MaterialStateProperty.resolveWith<Color?>(
            (states) =>
                index.isEven ? Colors.grey.shade50 : Colors.white,
          ),

          cells: [
            DataCell(Text(doc["from"] ?? "",style: TextStyle(fontWeight:FontWeight.bold),)),

            DataCell(Text(doc["to"] ?? "",style: TextStyle(fontWeight:FontWeight.bold),)),

            // ✅ Styled distance (badge style)
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  doc["distance"] ?? "",
                  style: const TextStyle(color: Colors.blue),
                ),
              ),
            ),

            // ✅ Styled duration
            DataCell(
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  doc["duration"] ?? "",
                  style: const TextStyle(color: Colors.orange),
                ),
              ),
            ),

            // ✅ Actions (modern buttons)
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
                          _showRouteDialog(route: doc),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.delete,
                          color: Colors.red),
                      onPressed: () => deleteRoute(doc.id),
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
    )));
  }
}



