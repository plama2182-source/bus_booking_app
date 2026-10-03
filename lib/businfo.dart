import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'seat_info.dart';
import 'footer.dart';
class BusInfo extends StatefulWidget {
  final String from;
  final String destination;
  final String date;
  const BusInfo({
    super.key,
    required this.from,
    required this.destination,
    required this.date,
  });

  @override
  State<BusInfo> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<BusInfo> {





Future<List<Map<String, dynamic>>> getBuses() async {
  List<Map<String, dynamic>> busList = [];

  var routeSnapshot = await FirebaseFirestore.instance
      .collection('route')
      .where('from', isEqualTo: widget.from)
      .where('to', isEqualTo: widget.destination)
      .get();

  if (routeSnapshot.docs.isEmpty) {
    print("Route not found");
    return busList;
  }




 String routeId = routeSnapshot.docs.first.id;

  var schedulesSnapshot = await FirebaseFirestore.instance
      .collection('schedules')
      .where('routeId', isEqualTo: routeId)
      .where('date', isEqualTo: widget.date)
      .get();

  for (var scheduleDoc in schedulesSnapshot.docs) {
    final busId = scheduleDoc['busId'];
    final price = scheduleDoc['price'];
    final boardingTime=scheduleDoc['boardingTime'];
    final droppingTime=scheduleDoc['droppingTime'];
    final droppingDate=scheduleDoc['reachDate'];
    final scheduleId = scheduleDoc.id;

    final seatDoc = await FirebaseFirestore.instance
        .collection('schedules')
        .doc(scheduleId)
        .collection("seats")
        .where('status', isEqualTo: "available")
        .count()
        .get();



  

    final busDoc = await FirebaseFirestore.instance
        .collection('bus')
        .doc(busId)
        .get();

    if (busDoc.exists) {
      final busData = busDoc.data()!;
      busData["busId"]=busDoc.id;
      busData["price"] = price;
      busData["scheduleId"] = scheduleId;
      busData["seat"] = seatDoc.count.toString();
     busData["dept"]=boardingTime;
      busData["reach"]=droppingTime;
busData["reachDate"]=droppingDate;

      busList.add(busData);
    }
  }

  return busList;
}

  @override
  Widget build(BuildContext context) {
    String from = widget.from;
    String destination = widget.destination;

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      widget.from,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Icon(Icons.arrow_forward, size: 15, color: Colors.white),
                  ],
                ),

                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(5),

                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(15),
                      ),

                      child: Text(
                        widget.date,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  widget.destination,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getBuses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No data"));
          }

          final buses = snapshot.data!;

          return ListView.builder(
            padding: EdgeInsets.all(18),
            itemCount: buses.length,
            itemBuilder: (context, index) {
              final bus = buses[index];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SeatInfo(
                        from: from,
                        to: destination,
                        busname: bus["busname"],
                        scheduleId: bus["scheduleId"],
                        price: bus["price"],
                        date: widget.date,
                        reachDate:bus["reachDate"]
                      ),
                    ),
                  );
                },
                child: Card(
                  color: const Color.fromARGB(255, 240, 241, 241),
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),

                  child: Container(
                    width: 320,
                    padding: EdgeInsets.all(20),

                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 5),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  bus['dept'],
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Icon(
                                  Icons.remove,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                                Text(
                                  bus['reach'],
                                  style: TextStyle(
                                    color: Colors.black,
                                   // fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              bus['price'],
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${bus["seat"].toString()} seats",
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Onwards",
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height:7),
                        Row(children: [

                           Text(bus["company"],style: TextStyle(
                                  
                                  fontWeight: FontWeight.bold,
                                  
                                ),),
                           Icon(
                                  Icons.directions_bus_rounded,
                                  size: 20,
                                  color: Colors.grey,
                                ),

                        ],),


                       SizedBox(height:1),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(
                                  7,
                                ), 
                              ),
                              padding: EdgeInsets.all(5),

                              child: Text(
                             "${bus['busname']}-${bus['busNumber']}" ,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),

                            Text(
                              bus["type"],
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                              
                        SizedBox(height: 5),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
       bottomNavigationBar: Footer(),
    );
  }
}
