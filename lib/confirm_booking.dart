import 'package:busboking/businfo.dart';
import 'package:busboking/index.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'main.dart';


void main() async {

  runApp (Confirm(busname:'',dept:'',reach:'',from:'',to:'',seatid: [],
  seatNumber: [],price:'',name:[],age:[],gender: [],scheduleId:'',boardingDroppingDetails: [],));
}


class Confirm extends StatefulWidget {
  final String busname;
final String dept;
final String reach;
final String from;
final String to;
final List seatid;
final List seatNumber;
final String price;
final List name;
final List age;
final List gender;
final String scheduleId;
final List<Map<String,dynamic>> boardingDroppingDetails;

 const Confirm({super.key,required this.busname,required this.dept,required this.reach,
 required this.from, required this.to,required this.seatid,required this.seatNumber,required this.price,
 required this.name, required this.age, required this.gender, required this.scheduleId,required this.boardingDroppingDetails
 });

 
  @override
  State<Confirm> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Confirm> {
  void _incrementCounter() {
    setState(() {});
  }

 String formatDate(String dateString) {
    if (dateString == null || dateString.isEmpty) {
      return "N/A";
    }
    DateTime date = DateTime.parse(dateString);
    return DateFormat('EEE, dd MMMM').format(date);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         automaticallyImplyLeading: false,
        backgroundColor:  Colors.red,  
       
        title: Text("Confirm Booking", style: TextStyle( fontWeight: FontWeight.bold,color:Colors.white),),
         centerTitle: true,
      ),

body:  SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Success Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 28),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Your ticket has been booked successfully!",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Ticket Card
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                      Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Busname", style: const TextStyle(
                       
                        fontWeight: FontWeight.bold,
                      ),),
                       
                        Text(
                     widget.busname,
                      style: const TextStyle(
                       
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                      ],
                    ),

                   
                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${formatDate(widget.dept)} - ${widget.boardingDroppingDetails[0]['time']}"  , style: TextStyle(fontSize:10, fontWeight: FontWeight.bold,color:Colors.grey),),
                        const Icon(Icons.arrow_forward, color: Colors.grey),
                        Text("${formatDate(widget.reach)} - ${widget.boardingDroppingDetails[1]['time']}",   style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold,color:Colors.grey),),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(widget.from, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(widget.to, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),

                    const Divider(height: 25),
                    Column(
children: [
for(int i=0;i<widget.name.length;i++)
 Row(
                          children: [
                        const Icon(Icons.person, size: 20, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text("Passenger: ${widget.name[i]}" , style: TextStyle(fontSize:12, fontWeight: FontWeight.bold,color:Colors.grey),),
                        
                      ],
                    ),

                    const SizedBox(height: 10),
for(int i=0;i<widget.seatNumber.length;i++)
                    Row(
                         children: [
                        const Icon(Icons.event_seat, size: 20, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text("Seats: ${widget.seatNumber[i].toString()}" , style: TextStyle(fontSize:12, fontWeight: FontWeight.bold,color:Colors.grey),),
                        
                      ],
                    ),
],

                    ),
                   
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                 Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (context) => const FirstPage()),
  (route) => false,
);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.red,
                ),
                child: const Text(
                  "Back to Home",
                  style: TextStyle(fontSize: 16,color:Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),

    );

  }

 }
















