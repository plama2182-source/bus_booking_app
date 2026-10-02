
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:intl/intl.dart';
import 'payment.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(Passenger(date: '',reachDate:'',from:'',to:'',selectedSeat: [],seatid: [],price:'',busname:'',scheduleId: '',boardingDroppingDetails: [],));
}

class Passenger extends StatefulWidget {

  final String date;
    final String reachDate;
  final String from;
  final String to;
  final List selectedSeat;
  final List seatid;
  final String price;
  final String busname;
  final String scheduleId;
  final List<Map<String,dynamic>> boardingDroppingDetails ;
  const Passenger({
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
     required this.boardingDroppingDetails

  });

 
 
  @override
  State<Passenger> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Passenger> {
  String selectedOption = "Male";
  List<TextEditingController> nameControllers = [];
  List<TextEditingController> ageControllers = [];
  List<String?> genderList = [];
   List age=[];
   List name=[];
   List gender=[];
  @override
  void initState() {
    super.initState();

    for (int i = 0; i < widget.selectedSeat.length; i++) {
      nameControllers.add(TextEditingController());
      ageControllers.add(TextEditingController());
      genderList.add(null);
    }
  }

double getFont(BuildContext context, double size) {
  double width = MediaQuery.of(context).size.width;

  double scale = width / 400;

  return (size * scale).clamp(size * 0.85, size * 1.4);
}
  bool validatePassengers() {
  for (int i = 0; i < nameControllers.length; i++) {
    if (nameControllers[i].text.isEmpty ||
        ageControllers[i].text.isEmpty ||
        genderList[i] == null) {
      return false;
    }
  }
   for (int i = 0; i < nameControllers.length; i++) {
    name.add(nameControllers[i].text);
    age.add(ageControllers[i].text);
    gender.add(genderList[i]);
    }
  

  
  return true;
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
                  "Passenger Information",
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
                 "${formatDate(widget.date)} - ${widget.boardingDroppingDetails[0]['time']}",
                  style: TextStyle(fontWeight: FontWeight.bold,fontSize: getFont(context,12),),
                ),

                Text(
                  "${formatDate(widget.reachDate)} - ${widget.boardingDroppingDetails[1]['time']}",
                  style: TextStyle(fontWeight: FontWeight.bold,fontSize: getFont(context,12)),
                ),
              ],
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                   " ${widget.boardingDroppingDetails[0]['stopName']}",
                  style: TextStyle(fontWeight: FontWeight.bold,fontSize: getFont(context,13)),
                ),
                Icon(Icons.arrow_forward, size:25, color: Colors.grey),
                Text(
                  " ${widget.boardingDroppingDetails[1]['stopName']}",
                  style: TextStyle(fontWeight: FontWeight.bold,fontSize: getFont(context,13),)
                ),
              ],
            ),
            SizedBox(height: 24),
            Expanded(child:
            ListView.builder(
                itemCount:widget.selectedSeat.length,
  itemBuilder: (context, index) {
    return 
             
 Card(
              color: const Color.fromARGB(255, 246, 250, 250),
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Container(
                padding: EdgeInsets.all(15),

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Text(
                          "Passenger Details",
                          style: TextStyle(
                            fontSize: getFont(context,12),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    
                    Divider(),
                    
                    
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                      children: [
                        Icon(Icons.person, size:25, color: Colors.grey),
                        SizedBox(width: 5),
                          Text("Passenger${index+1}", style: TextStyle(
                            fontSize: getFont(context,10),
                            fontWeight: FontWeight.bold,
                          ),),
                      ]),
                        
                          Text("Seat No: ${widget.selectedSeat[index]}", style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),)
                    ],
                   ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                          controller: nameControllers[index],

                            decoration: InputDecoration(
                              labelText: "Name",

                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 2,
                                  color: Colors.grey,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),

                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 2,
                                  color: Colors.blue,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                             controller: ageControllers[index],
                            decoration: InputDecoration(
                              labelText: "Age",

                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 2,
                                  color: Colors.grey,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),

                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 2,
                                  color: Colors.blue,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: RadioListTile(
                            title: Text("Male",style: TextStyle(fontSize:13),),
                            value: "Male",
                           groupValue: genderList[index],
                            onChanged: (value) {
                              setState(() {
                                selectedOption = value!;
                                
            genderList[index] = value;
         
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile(
                            title: Text("Female",style: TextStyle(fontSize:13)),
                            value: "Female",
                            groupValue: genderList[index],
                            onChanged: (value) {
                              setState(() {
                                selectedOption = value!;
                               
            genderList[index] = value;
          
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 5),
                  ],
                ),
              ),
            );
  }

            ),
           
            )
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 246, 250, 250),
          border: Border(top: BorderSide(color: Colors.grey, width: 1)),
        ),
        padding: EdgeInsets.all(5),
        height: 90,

        child: Container(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Amount",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Text(
                    "${widget.price}",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (validatePassengers()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Payment(busname:widget.busname,dept:widget.date,reach:widget.reachDate,from:widget.from,to:widget.to,seatid:widget.seatid,seatNumber:widget.selectedSeat,price:widget.price,name:name,age:age,gender:gender,scheduleId:widget.scheduleId,boardingDroppingDetails:widget.boardingDroppingDetails),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please fill all passenger details"),
        ),
      );
    }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Pay Now",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
