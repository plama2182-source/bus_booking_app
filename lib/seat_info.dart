import 'package:busboking/boarding_dropping.dart';
import 'package:busboking/passenger_details.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'bookingdetails.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(SeatInfo(from: '', to: '', busname: '', scheduleId: '', price: '',date:'',reachDate:''));
}












// class SeatInfo extends StatefulWidget {
//  final String from;
//   final String to;
//   final String busname;
//   final String scheduleId;

//   final String price;
//   final String date;
//   final String reachDate;
//   const SeatInfo({
//     super.key,
//     required this.from,
//     required this.to,
//     required this.busname,
//     required this.scheduleId,
//     required this.price,
   
//        required this.date,
//          required this.reachDate,
//   });

//   @override
//   State<SeatInfo> createState() => _SeatPageState();
// }

// class _SeatPageState extends State<SeatInfo> {
//   List<int> selectedSeats = [];
//   List<String> selectedSeatIds = [];


//   late Future<Map<String, dynamic>> _layoutFuture;

//   @override
//   void initState() {
//     super.initState();
  
//     _layoutFuture = _fetchBusLayout();
//   }

//   Future<Map<String, dynamic>> _fetchBusLayout() async {
//     DocumentSnapshot scheduleDoc = await FirebaseFirestore.instance
//         .collection('schedules')
//         .doc(widget.scheduleId)
//         .get();

//     if (!scheduleDoc.exists) throw Exception("Schedule not found");

//     String busId = scheduleDoc.get('busId');

//     DocumentSnapshot busDoc = await FirebaseFirestore.instance
//         .collection('bus') 
//         .doc(busId)
//         .get();

//     if (!busDoc.exists) throw Exception("Bus layout not found");

//     return busDoc.data() as Map<String, dynamic>;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.red,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () {
            
//             Navigator.pop(context); 
//           },
//         ),
//         title: Text("${widget.from} ➔ ${widget.to}", 
//             style: const TextStyle(color: Colors.white, fontSize: 16)),
//       ),
      
//       body: FutureBuilder<Map<String, dynamic>>(
//         future: _layoutFuture, 
//         builder: (context, layoutSnapshot) {
//           if (layoutSnapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
          
         
//           final int seatsPerRow = layoutSnapshot.data!['layout_type'] ?? 4;
//           final int aisleIndex = layoutSnapshot.data!['aisle_index'] ?? 2;
//           final int totalColumns = seatsPerRow + 1;

//           return Column(
//             children: [
//               const SizedBox(height: 20),
//               _buildLegend(),
              
//               Expanded(
//                 child: StreamBuilder<QuerySnapshot>(
//                   stream: FirebaseFirestore.instance
//                       .collection('schedules')
//                       .doc(widget.scheduleId)
//                       .collection('seats')
//                       .orderBy('seatNumber')
//                       .snapshots(),
//                   builder: (context, seatSnapshot) {
//                     if (!seatSnapshot.hasData) return const Center(child: CircularProgressIndicator());

//                     var seatDocs = seatSnapshot.data!.docs;

//                     return GridView.builder(
//                       padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
//                       itemCount: (seatDocs.length / seatsPerRow).ceil() * totalColumns,
//                       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: totalColumns,
//                         mainAxisSpacing: 12,
//                         crossAxisSpacing: 12,
//                       ),
//                       itemBuilder: (context, index) {
//                         int col = index % totalColumns;
//                         int row = index ~/ totalColumns;

//                         if (col == aisleIndex) return const SizedBox(); // Aisle space

//                         int seatIndex = (row * seatsPerRow) + (col > aisleIndex ? col - 1 : col);
//                         if (seatIndex >= seatDocs.length) return const SizedBox();

//                         var data = seatDocs[seatIndex].data() as Map<String, dynamic>;
//                         int number = data['seatNumber'] ?? 0;
//                         bool isBooked = data['status'] == 'booked';
//                         bool isSelected = selectedSeats.contains(number);

//                         return GestureDetector(
//                           onTap: () => _handleSeatTap(number, seatDocs[seatIndex].id, isBooked),
//                           child: Container(
                           
//                             decoration: BoxDecoration(
//                               color: isBooked ? Colors.grey.shade300 : (isSelected ? Colors.blue : Colors.white),
//                               borderRadius: BorderRadius.circular(8),
//                               border: Border.all(
//                                 color: isBooked ? Colors.grey : (isSelected ? Colors.blue : Colors.green),
//                                 width: 2,
//                               ),
//                             ),
//                             child: Icon(
//                               Icons.event_seat,
//                               color: isBooked ? Colors.grey.shade600 : (isSelected ? Colors.white : Colors.green),
//                             ),
//                           ),
//                         );
//                       },
//                     );
//                   },
//                 ),
//               ),
//               _buildBottomPanel(),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   void _handleSeatTap(int number, String id, bool isBooked) {
//     if (isBooked) return;
//     setState(() {
//       if (selectedSeats.contains(number)) {
//         selectedSeats.remove(number);
//         selectedSeatIds.remove(id);
//       } else {
//         selectedSeats.add(number);
//         selectedSeatIds.add(id);
//       }
//     });
//   }

//   Widget _buildLegend() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         _legendItem(Colors.grey, "Booked"),
//         const SizedBox(width: 20),
//         _legendItem(Colors.green, "Available"),
//         const SizedBox(width: 20),
//         _legendItem(Colors.blue, "Selected"),
//       ],
//     );
//   }

//   Widget _legendItem(Color color, String label) {
//     return Row(
//       children: [
//         Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
//         const SizedBox(width: 5),
//         Text(label, style: const TextStyle(fontSize: 12)),
//       ],
//     );
//   }

//   Widget _buildBottomPanel() {
//     int pricePerSeat = int.tryParse(widget.price) ?? 0;
//     int total = selectedSeats.length * pricePerSeat;

//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text("Seats: ${selectedSeats.isEmpty ? 'None' : selectedSeats.join(', ')}", style: const TextStyle(fontWeight: FontWeight.bold)),
//               Text("Total: ₹$total", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
//             ],
//           ),
//           const SizedBox(height: 15),
//           SizedBox(
//             width: double.infinity,
//             height: 50,
//             child: ElevatedButton(
//               style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//               onPressed: selectedSeats.isEmpty ? null : () {

//                  Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) => BoardingDroppingPage(date:widget.date,reachDate:widget.reachDate,from:widget.from,to:widget.to,selectedSeat:selectedSeats,seatid:selectedSeatIds,price:total.toString(),busname: widget.busname,scheduleId: widget.scheduleId,),
//                                   ),
//                                 );
//               },
//               child: const Text("PROCEED TO PAYMENT", style: TextStyle(color: Colors.white)),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }






class SeatInfo extends StatefulWidget {
  final String from;
  final String to;
  final String busname;
  final String scheduleId;
  final String price;
  final String date;
  final String reachDate;

  const SeatInfo({
    super.key,
    required this.from,
    required this.to,
    required this.busname,
    required this.scheduleId,
    required this.price,
    required this.date,
    required this.reachDate,
  });

  @override
  State<SeatInfo> createState() => _SeatPageState();
}

class _SeatPageState extends State<SeatInfo> {
  List<int> selectedSeats = [];
  List<String> selectedSeatIds = [];

  late Future<Map<String, dynamic>> _layoutFuture;

  @override
  void initState() {
    super.initState();
    _layoutFuture = _fetchBusLayout();
  }

  Future<Map<String, dynamic>> _fetchBusLayout() async {
    DocumentSnapshot scheduleDoc = await FirebaseFirestore.instance
        .collection('schedules')
        .doc(widget.scheduleId)
        .get();

    if (!scheduleDoc.exists) throw Exception("Schedule not found");

    String busId = scheduleDoc.get('busId');

    DocumentSnapshot busDoc = await FirebaseFirestore.instance
        .collection('bus')
        .doc(busId)
        .get();

    if (!busDoc.exists) throw Exception("Bus layout not found");

    return busDoc.data() as Map<String, dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    bool isDesktop = screenWidth > 800;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "${widget.from} ➔ ${widget.to}",
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),

      // 🔥 Responsive Center Wrapper
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isDesktop ? 650 : double.infinity,
          ),
          child: FutureBuilder<Map<String, dynamic>>(
            future: _layoutFuture,
            builder: (context, layoutSnapshot) {
              if (layoutSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final layout = layoutSnapshot.data!;
              final int seatsPerRow = layout['layout_type'] ?? 4;
              final int aisleIndex = layout['aisle_index'] ?? 2;
              final int totalColumns = seatsPerRow + 1;

              return Column(
                children: [
                  const SizedBox(height: 20),
                  _buildLegend(),

                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('schedules')
                          .doc(widget.scheduleId)
                          .collection('seats')
                          .orderBy('seatNumber')
                          .snapshots(),
                      builder: (context, seatSnapshot) {
                        if (!seatSnapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        var seatDocs = seatSnapshot.data!.docs;

                        return GridView.builder(
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? 60 : 20,
                            vertical: 20,
                          ),
                          itemCount: (seatDocs.length / seatsPerRow).ceil() * totalColumns,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: totalColumns,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: isDesktop ? 1.2 : 1,
                          ),
                          itemBuilder: (context, index) {
                            int col = index % totalColumns;
                            int row = index ~/ totalColumns;

                            if (col == aisleIndex) return const SizedBox();

                            int seatIndex = (row * seatsPerRow) +
                                (col > aisleIndex ? col - 1 : col);

                            if (seatIndex >= seatDocs.length) {
                              return const SizedBox();
                            }

                            var data = seatDocs[seatIndex].data() as Map<String, dynamic>;
                            int number = data['seatNumber'] ?? 0;
                            bool isBooked = data['status'] == 'booked';
                            bool isSelected = selectedSeats.contains(number);

                            return GestureDetector(
                              onTap: () => _handleSeatTap(
                                number,
                                seatDocs[seatIndex].id,
                                isBooked,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isBooked
                                      ? Colors.grey.shade300
                                      : (isSelected ? Colors.blue : Colors.white),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isBooked
                                        ? Colors.grey
                                        : (isSelected ? Colors.blue : Colors.green),
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  Icons.event_seat,
                                  size: isDesktop ? 28 : 20,
                                  color: isBooked
                                      ? Colors.grey.shade600
                                      : (isSelected ? Colors.white : Colors.green),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

                  // 🔥 Bottom Panel (Responsive Padding)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: isDesktop ? 40 : 0),
                    child: _buildBottomPanel(),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _handleSeatTap(int number, String id, bool isBooked) {
    if (isBooked) return;

    setState(() {
      if (selectedSeats.contains(number)) {
        selectedSeats.remove(number);
        selectedSeatIds.remove(id);
      } else {
        selectedSeats.add(number);
        selectedSeatIds.add(id);
      }
    });
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem(Colors.grey, "Booked"),
        const SizedBox(width: 20),
        _legendItem(Colors.green, "Available"),
        const SizedBox(width: 20),
        _legendItem(Colors.blue, "Selected"),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildBottomPanel() {
    int pricePerSeat = int.tryParse(widget.price) ?? 0;
    int total = selectedSeats.length * pricePerSeat;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Seats: ${selectedSeats.isEmpty ? 'None' : selectedSeats.join(', ')}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                "Total: ₹$total",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: selectedSeats.isEmpty
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BoardingDroppingPage(
                            date: widget.date,
                            reachDate: widget.reachDate,
                            from: widget.from,
                            to: widget.to,
                            selectedSeat: selectedSeats,
                            seatid: selectedSeatIds,
                            price: total.toString(),
                            busname: widget.busname,
                            scheduleId: widget.scheduleId,
                          ),
                        ),
                      );
                    },
              child: const Text(
                "PROCEED TO PAYMENT",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}