import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:flutter/services.dart';
import 'confirm_booking.dart';
import 'session.dart';
import 'footer.dart';
void main() async {
    WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const CardPayment(busname:'',dept:'',reach:'',from:'',to:'',seatid: [],
  seatNumber: [],price:'',name:[],age:[],gender: [],scheduleId:'',boardingDroppingDetails: [],));
}

class CardPayment extends StatefulWidget {
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
 const CardPayment({super.key,required this.busname,required this.dept,required this.reach,
 required this.from, required this.to,required this.seatid,required this.seatNumber,required this.price,
 required this.name, required this.age, required this.gender, required this.scheduleId, required this.boardingDroppingDetails
 });






  @override
  State<CardPayment> createState() => _CardPaymentPageState();
}
class ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text;

    if (text.length >= 3) {
      text = text.substring(0, 2) + '/' + text.substring(2);
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
class _CardPaymentPageState extends State<CardPayment> {
   final _formKey = GlobalKey<FormState>();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expiryController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

 final FirebaseFirestore db = FirebaseFirestore.instance;



Future<bool> booking() async {
  try {
    final scheduleData = await getBusRoute(widget.scheduleId);

    // 🔒 STEP 1: Lock seats safely
    await db.runTransaction((transaction) async {
      List<DocumentReference> seatRefs = widget.seatid.map((seatId) {
        return db
            .collection('schedules')
            .doc(widget.scheduleId)
            .collection('seats')
            .doc(seatId);
      }).toList();

      for (var ref in seatRefs) {
        var snap = await transaction.get(ref);

        if (!snap.exists) {
          throw Exception("Seat not found");
        }

        if (snap.get('status') == 'booked') {
          throw Exception("Seat already booked ");
        }
      }

      // ✅ Book seats
      for (var ref in seatRefs) {
        transaction.update(ref, {'status': 'booked'});
      }
    });

    // ✅ STEP 2: ONLY if above succeeds → create booking
    await db.collection("bookings").add({
      "userId": FirebaseAuth.instance.currentUser?.uid,
      "scheduleId": widget.scheduleId,
      "seatIds": widget.seatid,
      "seatnumber": widget.seatNumber,
      "passengers": [
        for (int i = 0; i < widget.name.length; i++)
          {
            "name": widget.name[i],
            "age": widget.age[i],
            "gender": widget.gender[i]
          }
      ],
      "boardingId": widget.boardingDroppingDetails[0]["stopId"],
      "droppingId": widget.boardingDroppingDetails[1]["stopId"],
      "boardingTime": widget.boardingDroppingDetails[0]["time"],
      "droppingTime": widget.boardingDroppingDetails[1]["time"],
      "paymentStatus": "Paid",
      "paymentMode": "card",
      "price": widget.price,
      "createdAt": FieldValue.serverTimestamp(),
      "busId": scheduleData?['busId'],
      "routeId": scheduleData?['routeId']
    });

    return true;

  } catch (e) {
       
                   ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Seats already booked try another seat")),
      );
    return false;
  }
}

//   Future<void> seatStatus() async {

//  for(int i=0; i<widget.seatid.length;i++){
//   await db
//           .collection("schedules")
//           .doc(widget.scheduleId)
//           .collection("seats")
//           .doc(widget.seatid[i])
//           .update({
        
//         "status": "booked",
//       });
    
//   }
//   }
bool isValidExpiryFormat(String input) {
  final regex = RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$');
  return regex.hasMatch(input);
}

bool isFutureDate(String input) {
  final parts = input.split('/');
  int month = int.parse(parts[0]);
  int year = int.parse(parts[1]);

  int fullYear = 2000 + year;

  final now = DateTime.now();
  final expiryDate = DateTime(fullYear, month + 1, 0);

  return expiryDate.isAfter(now);
}

  Future<Map<String, dynamic>?> getBusRoute(String id) async {


 var doc= await db
          .collection("schedules").doc(id).get();
         
        if(doc.exists)
        {
               return doc.data();
               
        } 
    
  
  }


  @override
  Widget build(BuildContext context) {
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
              children: [
                Text(
                  "Card Payment",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
           
          ],
        ),
      ),
      body: Container(
        padding:EdgeInsets.all(10) ,
        child: 
        SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        
        child: Form(
          key: _formKey,
 child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Card Details",
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 20),

            // Name on Card
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Cardholder Name",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 20),
TextFormField(
   controller: cardNumberController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Card Number",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.credit_card),
              ),
  inputFormatters: [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(16),
  ],
  validator: (value) {
    if (value == null || value.isEmpty) {
      return "Enter card number";
    }
    if (value.length != 16) {
      return "Must be 16 digits";
    }
    return null;
  },
),
            // Card Number
          
            const SizedBox(height: 20),

            // Expiry & CVV
            Row(
              children: [
 Expanded(
                    child: TextFormField(
                      controller: expiryController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "MM/YY",
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                        ExpiryDateFormatter(),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Required";
                        }
                        if (!isValidExpiryFormat(value)) {
                          return "Invalid";
                        }
                        if (!isFutureDate(value)) {
                          return "Expired";
                        }
                        return null;
                      },
                    ),
                  ),

                const SizedBox(width: 20),
                Expanded(
                  child:
                TextFormField(
                  controller: cvvController,
  keyboardType: TextInputType.number,
  decoration: const InputDecoration(
                      labelText: "CV",
                      border: OutlineInputBorder(),
                    ),
  obscureText: true, // hides digits for security
  inputFormatters: [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(4),
  ],
  validator: (value) {
    if (value == null || value.isEmpty) {
      return "Enter CVV";
    }
    if (value.length < 3 || value.length > 4) {
      return "Invalid CVV";
    }
    return null;
  },
),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Amount
            const Text(
              "Amount",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child:  Text(
                 widget.price, 
                style: TextStyle(fontSize:14, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 40),

            // CardPayment Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () async {
                 
                 if (_formKey.currentState!.validate()) {
                    bool result= await booking();
                    if(result){
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Confirm(busname:widget.busname,dept:widget.dept,reach:widget.reach,from:widget.from,to:widget.to,seatid:widget.seatid,seatNumber:widget.seatNumber,price:widget.price,name:widget.name,age:widget.age,gender:widget.gender,scheduleId:widget.scheduleId,boardingDroppingDetails:widget.boardingDroppingDetails,),
                                  ),
                                );
                  } 
                 }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "CardPayment Now",
                  style: TextStyle(fontSize:14,color:Colors.white),
                ),
              ),
            ),
          ],
        )
        )
       ,
      ),
      ),
       bottomNavigationBar: Footer(),
    );
  }
}


        