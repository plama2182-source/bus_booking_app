import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:busboking/session.dart';
import 'package:firebase_auth/firebase_auth.dart';
import'package:intl/intl.dart';
class booking extends StatefulWidget {
 

  const booking({super.key});

  @override
  State<booking> createState() => _bookingState();
}

class _bookingState extends State<booking> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore db = FirebaseFirestore.instance;
  // Controllers for Add/Edit form
  final TextEditingController nameController = TextEditingController();
  final TextEditingController seatsController = TextEditingController();
  final TextEditingController statusController = TextEditingController();
final String currentAdminId = FirebaseAuth.instance.currentUser?.uid ?? "";

Future<List<String>> getAdminBusIds() async {
    QuerySnapshot busSnapshot = await db
        .collection("bus")
        .where("userId", isEqualTo: currentAdminId)
        .get();

    return busSnapshot.docs.map((doc) => doc.id).toList();
  }


 Future<void> updateBooking(String? id,Map<String, dynamic> booking, int index) async {



List passengers = booking["passengers"] ?? [];
List seats=booking["seatnumber"] ?? [];
List seatId=booking["seatIds"] ?? [];
passengers[index]["name"] = nameController.text;
seats[index]=seatsController.text;
seatId[index]="seat_${seatsController.text}";

    await db.collection("bookings").doc(id).update({
    
    
      "seatnumber": seats,
     "seatIds":seatId,
       "paymentStatus": statusController.text,
      "passengers" : passengers

    });
   }


  @override
  void dispose() {
    
    nameController.dispose();
    
    seatsController.dispose();
    statusController.dispose();
    super.dispose();
  }

  void _showbookingDialog({Map<String, dynamic>? booking, String? docId,int? index}) {
  
    if (booking != null) {
       nameController.text = booking["passengers"][index]["name"];
    
       seatsController.text = booking["seatnumber"][index].toString();
       statusController.text = booking["paymentStatus"].toString();
    } else {
      _clearForm();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(booking != null ? "Edit booking" : "Add New booking"),
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
                        value!.isEmpty ? "Enter booking name" : null,
                  ),
                   
                  TextFormField(
                    controller: seatsController,
                    decoration: const InputDecoration(labelText: "Seat number"),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value!.isEmpty ? "Enter number of seats" : null,
                  ),
                  TextFormField(
                    controller: statusController,
                    decoration: const InputDecoration(labelText: "Payment Status"),
                    keyboardType: TextInputType.number,
                    validator: (value) =>
                        value!.isEmpty ? "Enter price" : null,
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
                    if (booking != null && index != null) {
                   
                     updateBooking(docId,booking,index);
                     
                    } else {
                      // Add new booking
                      
                    }
                  });
                  Navigator.of(context).pop();
                  _clearForm();
                }
              },
              child: Text(booking != null ? "Update" : "Add"),
            ),
          ],
        );
      },
    );
  }

  void _clearForm() {
  
    nameController.clear();
    seatsController.clear();
    statusController.clear();
  }

List<Map<String,dynamic>>? list;

  @override
  Widget build(BuildContext context) {
    String convertDate(String input) {
  final inputFormat = DateFormat('EEE, dd MMMM yyyy hh:mm a');
  final outputFormat = DateFormat('dd-MM-yyyy ');

  DateTime date = inputFormat.parse(input);
  return outputFormat.format(date);
}
    return Scaffold(
      appBar: AppBar(    title: const Text("Booking Management",style: TextStyle(fontWeight: FontWeight.bold,color:Colors.white),),
    
      backgroundColor: Colors.red,),
    
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
            return const Center(child: Text("No buses found for this admin."));
          }

          return StreamBuilder<QuerySnapshot>(
            // Use the list of IDs from the FutureBuilder
            stream: db.collection("bookings")
                .where("busId", whereIn: myBusIds)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return Text("Error: ${snapshot.error}");
              if (!snapshot.hasData) return const LinearProgressIndicator();

              final bookings = snapshot.data!.docs;
    
    
    


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
                    columnSpacing: 26,
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
                      DataColumn(label: Text("S.No")),
                      DataColumn(label: Text("Booking Date")),
                      DataColumn(label: Text("Passenger")),
                      DataColumn(label: Text("Seat")),
                      DataColumn(label: Text("Route / Bus")),
                      DataColumn(label: Text("Board / Drop")),
                      DataColumn(label: Text("Dep/Arr")),
                      DataColumn(label: Text("Status")),
                      DataColumn(label: Text("Actions")),
                    ],

                    rows: bookings.asMap().entries.expand((entry) {
                      int bookingIndex = entry.key;
                      var data =
                          entry.value.data() as Map<String, dynamic>;
                      String docId = entry.value.id;
                      List passengers = data["passengers"] ?? [];

                      return passengers.asMap().entries.map((pEntry) {
                        int passengerIndex = pEntry.key;
                        var passenger = pEntry.value;

                        Timestamp timestamp = data['createdAt'];
                        DateTime dateTime = timestamp.toDate();

                        final formatted = DateFormat(
                          'dd MMM yyyy, hh:mm a',
                        ).format(dateTime);

                        return DataRow(
                          color: MaterialStateProperty.resolveWith<Color?>(
                            (states) => passengerIndex.isEven
                                ? Colors.red.shade50
                                : Colors.white,
                          ),

                          cells: [
                            DataCell(Text(
                                "${bookingIndex + 1}.${passengerIndex + 1}", style: const TextStyle(
                     
                      fontWeight: FontWeight.bold,
                    
                    ))),

                            DataCell(Text(formatted, style: const TextStyle(
                     
                      fontWeight: FontWeight.bold,
                    
                    ))),

                            DataCell(Text(passenger['name'], style: const TextStyle(
                     
                      fontWeight: FontWeight.bold,
                    
                    ))),

                            //Seat badge
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  data['seatnumber'][passengerIndex]
                                      .toString(),
                                  style: const TextStyle(
                                      color: Colors.blue),
                                ),
                              ),
                            ),

                          
                            DataCell(
                              StreamBuilder<DocumentSnapshot>(
                                stream: db
                                    .collection("schedules")
                                    .doc(data['scheduleId'])
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData ||
                                      !snapshot.data!.exists) {
                                    return const Text("...");
                                  }

                                  var schedule = snapshot.data!.data()
                                      as Map<String, dynamic>;

                                  return FutureBuilder<DocumentSnapshot>(
                                    future: db
                                        .collection("route")
                                        .doc(schedule['routeId'])
                                        .get(),
                                    builder: (context, routeSnap) {
                                      if (!routeSnap.hasData ||
                                          !routeSnap.data!.exists) {
                                        return const Text("...");
                                      }

                                      var route = routeSnap.data!.data()
                                          as Map<String, dynamic>;

                                      return FutureBuilder<
                                          DocumentSnapshot>(
                                        future: db
                                            .collection("bus")
                                            .doc(schedule['busId'])
                                            .get(),
                                        builder: (context, busSnap) {
                                          if (!busSnap.hasData ||
                                              !busSnap.data!.exists) {
                                            return const Text("...");
                                          }

                                          var bus = busSnap.data!.data()
                                              as Map<String, dynamic>;

                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  "${route['from']} → ${route['to']}", style: const TextStyle(
                     
                      fontWeight: FontWeight.bold,
                    
                    )),
                                              Text(
                                                "Bus: ${bus['busname']}",
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey ,fontWeight: FontWeight.bold,),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                            ),

                           
                          DataCell(
  FutureBuilder<DocumentSnapshot>(
    future: db
        .collection("boarding")
        .doc(data["boardingId"])
        .get(),
    builder: (context, boardingSnap) {
      if (boardingSnap.connectionState != ConnectionState.done) {
        return const Text("Loading...");
      }

      if (!boardingSnap.hasData || !boardingSnap.data!.exists) {
        return const Text("No Board");
      }

      var boardData =
          boardingSnap.data!.data() as Map<String, dynamic>;

      return FutureBuilder<DocumentSnapshot>(
        future: db
            .collection("dropping")
            .doc(data["droppingId"])
            .get(),
        builder: (context, dropSnap) {
          if (dropSnap.connectionState != ConnectionState.done) {
            return const Text("Loading...");
          }

          if (!dropSnap.hasData || !dropSnap.data!.exists) {
            return const Text("No Drop");
          }

          var dropData =
              dropSnap.data!.data() as Map<String, dynamic>;

          return Text(
            "${boardData['stopName'] ?? 'N/A'} → ${dropData['stopName'] ?? 'N/A'}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          );
        },
      );
    },
  ),
),

                             DataCell(
                              StreamBuilder<DocumentSnapshot>(
                                stream: db
                                    .collection("schedules")
                                    .doc(data['scheduleId'])
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData ||
                                      !snapshot.data!.exists) {
                                    return const Text("...");
                                  }

                                  var date = snapshot.data!.data()
                                      as Map<String, dynamic>;
  return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  "${date['date']} → ${date['reachDate']}", style: const TextStyle(
                     
                      fontWeight: FontWeight.bold,
                    
                    )),
                                              Text(
                                                " ${data['boardingTime']} → ${data['droppingTime']}",
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey ,fontWeight: FontWeight.bold,),
                                              ),
                                            ],
                                          );
                                 ;
                                },
                              ),
                            ),
                            
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: data["paymentStatus"] ==
                                          "Success"
                                      ? Colors.green.shade50
                                      : Colors.orange.shade50,
                                  borderRadius:
                                      BorderRadius.circular(20),
                                ),
                                child: Text(
                                  data["paymentStatus"],
                                  style: TextStyle(
                                    color: data["paymentStatus"] ==
                                            "Success"
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                ),
                              ),
                            ),

                            
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
                                        booking: data,
                                        docId: docId,
                                        index: passengerIndex,
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
                                      onPressed: () async {
                                        await db
                                            .collection("bookings")
                                            .doc(docId)
                                            .delete();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      });
                    }).toList(),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
        }
    )
  ),
)
    );
  }
}



