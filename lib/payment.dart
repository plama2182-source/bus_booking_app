import 'package:busboking/businfo.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:intl/intl.dart';
import 'card_payment.dart';
import 'footer.dart';
 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(Payment(busname:'',dept:'',reach:'',from:'',to:'',seatid: [],
  seatNumber: [],price:'',name:[],age:[],gender: [],scheduleId:'',boardingDroppingDetails: [],
  ));
}

class Payment extends StatefulWidget {
 

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
  final List<Map<String,dynamic>> boardingDroppingDetails ;
 const Payment({super.key,required this.busname,required this.dept,required this.reach,
 required this.from, required this.to,required this.seatid,required this.seatNumber,required this.price,
 required this.name, required this.age, required this.gender, required this.scheduleId, required this.boardingDroppingDetails
 });

 



  @override
  State<Payment> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Payment> {
  String selectedOption = "Male";

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            widget.name.clear();
             widget.age.clear();
              widget.gender.clear();
              
            Navigator.pop(context); 
          },
        ),
        elevation: 10,
        shadowColor: Colors.black,
        backgroundColor: Colors.red,
        title: Column(
          children: [
            Row(
              children: [
                Text(
                  "Payment Information",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.from,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Icon(Icons.arrow_forward, size: 15, color: Colors.white),
                    Text(widget.to,
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
          ],
        ),
      ),

      body: Container(
        padding: EdgeInsets.all(20),

        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.busname, style: TextStyle(color: Colors.grey)),
              ],
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                 widget.dept,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                Text(
                 widget.reach,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.boardingDroppingDetails[0]['stopName'],
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Icon(Icons.arrow_forward, size:25, color: Colors.grey),
                Text(
                 widget.boardingDroppingDetails[1]['stopName'],
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 24),
  //       InkWell(
  // onTap: () {
  //   // Navigator.push(
  //   //   context,
  //   //   MaterialPageRoute(
  //   //     builder: (context) => NextPage(),
  //   //   ),
  //   // );
  // },
  // child: Card(
  //             color: const Color.fromARGB(255, 246, 250, 250),
  //             elevation: 8,
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(15),
  //             ),
  //             child: Container(
  //               padding: EdgeInsets.all(20),

  //               child: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   SizedBox(height: 5),
  //                   Row(
  //                     children: [
  //                       Text(
  //                         "UPI",
  //                         style: TextStyle(
  //                           fontSize: 20,
  //                           fontWeight: FontWeight.bold,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
                    
                 
                    
                    
  //                 //  Row(
  //                 //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 //   children: [
  //                 //     Row(
  //                 //     children: [
  //                 //       Icon(Icons.payment, size:25, color: Colors.grey),
  //                 //       SizedBox(width: 5),
  //                 //         Text("Google Pay", style: TextStyle(
  //                 //           fontSize: 14,
  //                 //           fontWeight: FontWeight.bold,
  //                 //         ),),
                          
                          
  //                 //     ]),
                        
                      
  //                 //   ],
                  
  //                 // ), 
  //                  Divider(),
  //                 //  Row(children: [ Icon(Icons.input_rounded, size:25, color: Colors.grey),
  //                 //       SizedBox(width: 5),
  //                 //         Text("Enter UPI ID", style: TextStyle(
  //                 //           fontSize: 14,
  //                 //           fontWeight: FontWeight.bold,
  //                 //         ),),],),
                   
                   
                  
                    

  //                 ],
  //               ),
  //             ),
  //           ),

  // ),
                 InkWell(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CardPayment(busname:widget.busname,dept:widget.dept,reach:widget.reach,from:widget.from,to:widget.to,seatid:widget.seatid,seatNumber:widget.seatNumber,price:widget.price,name:widget.name,age:widget.age,gender:widget.gender,scheduleId:widget.scheduleId,boardingDroppingDetails:widget.boardingDroppingDetails,),
      ),
    );
  },
  child:
             Card(
              color: const Color.fromARGB(255, 246, 250, 250),
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Container(
                padding: EdgeInsets.all(20),

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Text(
                          "Credit/Debit Card",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    
                 
                    
                    
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                      children: [
                        Icon(Icons.credit_card_rounded, size:25, color: Colors.grey),
                        SizedBox(width: 5),
                          Text("Add credit / debit card", style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),),
                          
                          
                      ]),
                        
                      
                    ],
                  
                   )
                  
                   
                  
                    

                  ],
                ),
              ),
            )
                 ),   

  

           
          ],
        ),
      ),
    bottomNavigationBar: Footer(),
    );
  }
}