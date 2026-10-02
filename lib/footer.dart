
import 'package:flutter/material.dart';
import 'index.dart';
import 'bookingdetails.dart';
import 'userAccount.dart';


class Footer extends StatelessWidget {
  const Footer({super.key});

 

  
 
  @override
  Widget build(BuildContext context) {
    return 
     Container(
    height:60,
    padding:EdgeInsets.all(1),
     color:  Color(0xFFE53935),
     
    alignment: Alignment.center,
    
 child:   Padding(
  padding: EdgeInsets.symmetric(
    horizontal:30, // left & right
    vertical:5,   // top & bottom
  ),
    child:Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
  onTap: () {
     Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>  FirstPage(),
      ),
    );
  },
   child:  Column(
    children: [
        Container(
         decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: const Color.fromARGB(255, 214, 210, 210),
                            width: 2,
                          ),
                        ),
        child: Icon(Icons.search,color: Colors.red,size:18,),
       ), SizedBox(height: 2,),
       Text("Home",style: TextStyle(fontSize:12,fontWeight: FontWeight.bold,color:Colors.white),)
    ],
   )),
  InkWell(
  onTap: () {
   Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>  BookingDetails(),
      ),
    );
  },
   child:
      Column(
        children: [
           Container(
         decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: const Color.fromARGB(255, 214, 210, 210),
                            width: 2,
                          ),
                        ),
        child: Icon(Icons.book_rounded,color: Colors.red,),
       ),
       SizedBox(height: 2,),
       Text("Booking",style: TextStyle(fontSize:12,fontWeight: FontWeight.bold,color:Colors.white),)
  
        ],
        
      )
      
      ),
     
       InkWell(
  onTap: () {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>Account(),
      ),
    );
  },
   child:
      Column(
        children: [
           Container(
         decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: const Color.fromARGB(255, 214, 210, 210),
                            width: 2,
                          ),
                        ),
        child: Icon(Icons.person,color: Colors.red,),
       ), SizedBox(height: 2,),
       Text("Account",style: TextStyle(fontSize:12,fontWeight: FontWeight.bold,color:Colors.white),)
  
        ],
      ))
      ],
    )
     )
  )
    ;
  }
}