
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:intl/intl.dart';
import 'passenger_details.dart';
import 'footer.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(BoardingDroppingPage(
 date: '',reachDate:'',from:'',to:'',selectedSeat: [],seatid: [],price:'',busname:'',scheduleId: '',)
  );
}



class BoardingDroppingPage extends StatefulWidget {
  final String date;
  final String reachDate;
  final String from;
  final String to;
  final List selectedSeat;
  final List seatid;
  final String price;
  final String busname;
  final String scheduleId;

  const BoardingDroppingPage({
    super.key,
    required this.date,
    required this.reachDate,
    required this.from,
    required this.to,
    required this.selectedSeat,
    required this.seatid,
    required this.price,
    required this.busname,
    required this.scheduleId,
  });

  @override
  State<BoardingDroppingPage> createState() => _BoardingDroppingPageState();
}

class _BoardingDroppingPageState extends State<BoardingDroppingPage> {
  final FirebaseFirestore db = FirebaseFirestore.instance;

 
  Stream<QuerySnapshot>? _boardingStream;
  Stream<QuerySnapshot>? _droppingStream;

  String? selectedBoardingId;
  String? selectedDroppingId;
  String? selectedBoardingName;
  String? selectedDroppingName;
  String? selectedBoardingTime;
  String? selectedDroppingTime;
  List<Map<String, dynamic>> boardingDroppingDetails = [];

  @override
  void initState() {
    super.initState();
   
    _boardingStream = db
        .collection('boardingTimeTable')
        .where('scheduleId', isEqualTo: widget.scheduleId)
        .snapshots();

    _droppingStream = db
        .collection('DroppingTimeTable')
        .where('scheduleId', isEqualTo: widget.scheduleId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 10,
        shadowColor: Colors.black,
        backgroundColor: Colors.red,
        title: const Text(
          "Select boarding and dropping points",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- BOARDING SECTION ---
            _buildSelectionCard(
              title: "Boarding Points",
              stream: _boardingStream,
              isBoarding: true,
            ),

            const SizedBox(height: 30),

            // --- DROPPING SECTION ---
            _buildSelectionCard(
              title: "Dropping Points",
              stream: _droppingStream,
              isBoarding: false,
            ),

            const SizedBox(height: 30),

            // --- CONFIRM BUTTON ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                onPressed: selectedBoardingId != null && selectedDroppingId != null
                    ? () {
                        boardingDroppingDetails = [
                          {
                            "stopId": selectedBoardingId,
                            "stopName": selectedBoardingName,
                            "time": selectedBoardingTime,
                          },
                          {
                            "stopId": selectedDroppingId,
                            "stopName": selectedDroppingName,
                            "time": selectedDroppingTime,
                          },
                        ];

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Passenger(
                              date: widget.date,
                              reachDate: widget.reachDate,
                              from: widget.from,
                              to: widget.to,
                              selectedSeat: widget.selectedSeat,
                              seatid: widget.seatid,
                              price: widget.price,
                              busname: widget.busname,
                              scheduleId: widget.scheduleId,
                              boardingDroppingDetails: boardingDroppingDetails,
                            ),
                          ),
                        );
                      }
                    : null,
                child: const Text("Continue", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
       bottomNavigationBar: Footer(),
    );
  }


  Widget _buildSelectionCard({required String title, required Stream<QuerySnapshot>? stream, required bool isBoarding}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color.fromARGB(255, 214, 210, 210), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 2,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          StreamBuilder<QuerySnapshot>(
            stream: stream,
            builder: (context, snapshot) {
              // 3. Fix: Check if data exists before showing loader
              if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Text("No ${title.toLowerCase()} available");
              }

              var docs = snapshot.data!.docs;

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> data = docs[index].data() as Map<String, dynamic>;
                  String pointId = isBoarding ? data['boardingId'] : data['droppingId'];
                  String time = isBoarding ? data['boardingtime'] : data['droppingtime'];

                  return StreamBuilder<DocumentSnapshot>(
                    stream: db.collection(isBoarding ? 'boarding' : 'dropping').doc(pointId).snapshots(),
                    builder: (context, pointSnap) {
                      if (!pointSnap.hasData) return const ListTile(title: Text("Loading..."));
                      
                      var pointData = pointSnap.data!.data() as Map<String, dynamic>;
                      String stopName = pointData['stopName'] ?? 'Unknown';

                      return Card(
                        child: RadioListTile<String>(
                          title: Text("$stopName ($time)", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          value: pointId,
                          groupValue: isBoarding ? selectedBoardingId : selectedDroppingId,
                          onChanged: (value) {
                            setState(() {
                              if (isBoarding) {
                                selectedBoardingId = value;
                                selectedBoardingTime = time;
                                selectedBoardingName = stopName;
                              } else {
                                selectedDroppingId = value;
                                selectedDroppingTime = time;
                                selectedDroppingName = stopName;
                              }
                            });
                          },
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}