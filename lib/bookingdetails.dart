import 'package:busboking/demo.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:intl/intl.dart';
import 'confirm_booking.dart';
import 'session.dart';
import 'footer.dart';
import 'package:firebase_auth/firebase_auth.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const BookingDetails());
}




class BookingDetails extends StatefulWidget {
  const BookingDetails({super.key});

  @override
  State<BookingDetails> createState() => _BookingDetailsPageState();
}

class _BookingDetailsPageState extends State<BookingDetails> {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  String formatDate(String dateString) {
    if (dateString.isEmpty) return "N/A";
    DateTime date = DateTime.parse(dateString);
    return DateFormat('EEE, dd MMMM').format(date);
  }

  double getFont(double base, double width) {
    if (width > 600) return base + 2;
    return base;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "BookingDetails",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
         automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Colors.red,
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {
          double width = constraints.maxWidth;

          return FutureBuilder<QuerySnapshot>(
            future: db
                .collection('bookings')
                .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                .get(),
            builder: (context, bookingSnapshot) {
              if (!bookingSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final bookings = bookingSnapshot.data!.docs;

              if (bookings.isEmpty) {
                return const Center(child: Text("No bookings found"));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final booking = bookings[index];
return Center(
  child: ConstrainedBox(
    constraints: BoxConstraints(
      maxWidth: width > 700 ? 600 : double.infinity,
    ),
    child: Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8)
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(width > 600 ? 18 : 14),
        child: StreamBuilder<DocumentSnapshot>(
          stream: db
              .collection("schedules")
              .doc(booking["scheduleId"])
              .snapshots(),
          builder: (context, scheduleSnapshot) {
            if (!scheduleSnapshot.hasData ||
                !scheduleSnapshot.data!.exists) {
              return const Text("Schedule not found");
            }

            final schedule =
                scheduleSnapshot.data!.data() as Map<String, dynamic>;

            final routeId = schedule["routeId"];
            final dept = schedule["date"];
            final reach = schedule["reachDate"];

            Timestamp timestamp = booking['createdAt'];
            DateTime dateTime = timestamp.toDate();

            final formatted = DateFormat(
              'dd MMM yyyy, hh:mm a',
            ).format(dateTime);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Booked on",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: getFont(14, width),
                      ),
                    ),
                    Text(
                      formatted,
                      style: TextStyle(
                        fontSize: getFont(13, width),
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
  StreamBuilder<DocumentSnapshot>(
                  stream: db
                      .collection("bus")
                      .doc(booking["busId"])
                      .snapshots(),
                  builder: (context, Snapshot) {
                    if (!Snapshot.hasData ||
                        !Snapshot.data!.exists) {
                      return const Text("bus not found");
                    }

                    final bus =
                        Snapshot.data!.data() as Map<String, dynamic>;

                    return Row(
                      children: [
                        Expanded(
                          child: Text(
                            bus['busname'],
                            style: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold),
                          ),
                        ),
                      
                        Expanded(
                          child: Text(
                            bus['busNumber'],
                            textAlign: TextAlign.end,
                            style: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),

           
                StreamBuilder<DocumentSnapshot>(
                  stream: db
                      .collection("route")
                      .doc(routeId)
                      .snapshots(),
                  builder: (context, routeSnapshot) {
                    if (!routeSnapshot.hasData ||
                        !routeSnapshot.data!.exists) {
                      return const Text("Route not found");
                    }

                    final route =
                        routeSnapshot.data!.data() as Map<String, dynamic>;

                    return Row(
                      children: [
                        Expanded(
                          child: Text(
                            route['from'],
                            style: TextStyle(
                              fontSize: getFont(16, width),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Icon(Icons.arrow_forward),
                        Expanded(
                          child: Text(
                            route['to'],
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              fontSize: getFont(16, width),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: StreamBuilder<DocumentSnapshot>(
                        stream: db
                            .collection("boarding")
                            .doc(booking["boardingId"])
                            .snapshots(),
                        builder: (context, snap) {
                          if (!snap.hasData || !snap.data!.exists) {
                            return const Text("...");
                          }
                          final b =
                              snap.data!.data() as Map<String, dynamic>;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Boarding",
                                  style: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold)),
                              Text(
                                b["stopName"],
                                style: TextStyle(
                                  fontSize: getFont(13, width),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: StreamBuilder<DocumentSnapshot>(
                        stream: db
                            .collection("dropping")
                            .doc(booking["droppingId"])
                            .snapshots(),
                        builder: (context, snap) {
                          if (!snap.hasData || !snap.data!.exists) {
                            return const Text("...");
                          }
                          final d =
                              snap.data!.data() as Map<String, dynamic>;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text("Dropping",
                                  style: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold)),
                              Text(
                                d["stopName"],
                                style: TextStyle(
                                  fontSize: getFont(13, width),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                /// 📅 DATE & TIME
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "${formatDate(dept)}\n${booking['boardingTime']}",
                        style: TextStyle(
                          fontSize: getFont(12, width),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        "${formatDate(reach)}\n${booking['droppingTime']}",
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontSize: getFont(12, width),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                ///  TICKET DIVIDER
                Row(
                  children: List.generate(
                    30,
                    (index) => const Expanded(
                      child: Divider(
                        thickness: 1,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                /// 👤 PASSENGERS
                for (int i = 0;
                    i < booking["passengers"].length;
                    i++)
                  Row(
                    children: [
                      const Icon(Icons.person, size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          booking["passengers"][i]["name"],
                          style: TextStyle(
                            fontSize: getFont(12, width),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 8),

                /// 💺 SEATS
                for (int i = 0;
                    i < booking["seatnumber"].length;
                    i++)
                  Row(
                    children: [
                      const Icon(Icons.event_seat, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        booking["seatnumber"][i].toString(),
                        style: TextStyle(
                          fontSize: getFont(12, width),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
              ],
            );
          },
        ),
      ),
    ),
  ),
);
                },
              );
            },
          );
        },
      ),

      bottomNavigationBar: Footer(),
    );
  }
}