
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:intl/intl.dart';
import 'businfo.dart';
import 'footer.dart';




// class FirstPage extends StatefulWidget {
//   const FirstPage({super.key});

//   @override
//   State<FirstPage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<FirstPage> {
//   final FirebaseFirestore db = FirebaseFirestore.instance;

//   DateTime? selectedDate;
//   String? source;
//   String? destination;

//   Future<void> pickDate() async {
//     DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime.now(),
//       lastDate: DateTime(2100),
//     );

//     if (picked != null) {
//       setState(() {
//         selectedDate = picked;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//          automaticallyImplyLeading: false,
//         backgroundColor: Colors.red,
//         title: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: const [
//             Text(
//               "Bus Booking",
//               style: TextStyle(
//                   fontSize: 17,
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold),
//             ),
//             Icon(Icons.bus_alert_rounded, color: Colors.white),
//           ],
//         ),
//       ),

//       body: Container(
      
//       decoration: BoxDecoration(
//       color:Colors.red,
//     borderRadius: BorderRadius.only(
//       bottomLeft: Radius.circular(20),
//       bottomRight: Radius.circular(20),
//     ),
//   ),
//   padding:EdgeInsets.all(10),
//         child: StreamBuilder<QuerySnapshot>(
//         stream: db.collection("city").snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return const Center(child: Text("No data"));
//           }

//           var docs = snapshot.data!.docs;

//           List<String> cities =
//               docs.map((doc) => doc["name"].toString()).toList();

//           return LayoutBuilder(
//             builder: (context, constraints) {
//               double maxWidth =
//                   constraints.maxWidth > 600 ? 500 : double.infinity;

//               return SingleChildScrollView( 
//                 child: Center(
//                   child: Container(
//                     width: maxWidth,
//                     padding: const EdgeInsets.all(16),
//                     child: Container(
//                       padding: const EdgeInsets.all(20),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(15),
                        
//                       ),
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [

//                           const SizedBox(height: 30),

//                           /// SOURCE
//                           _buildDropdown(
//                             hint: "Source",
//                             icon: Icons.location_on,
//                             color: Colors.lightGreen,
//                             value: source,
//                             items: cities,
//                             onChanged: (value) {
//                               setState(() => source = value);
//                             },
//                           ),

//                           const SizedBox(height: 20),

//                           /// DESTINATION
//                           _buildDropdown(
//                             hint: "Destination",
//                             icon: Icons.location_on,
//                             color: Colors.redAccent,
//                             value: destination,
//                             items: cities,
//                             onChanged: (value) {
//                               setState(() => destination = value);
//                             },
//                           ),

//                           const SizedBox(height: 20),

//                           /// DATE PICKER
//                           GestureDetector(
//                             onTap: pickDate,
//                             child: Container(
//                               width: double.infinity,
//                               padding: const EdgeInsets.all(10),
//                                decoration: BoxDecoration(
//        color:  const Color.fromARGB(255, 235, 233, 233), // background color
//     borderRadius: BorderRadius.circular(13), 
        
//       ),
//                               child: Row(
//                                 children: [
//                                   const Icon(Icons.calendar_today,
//                                       color: Colors.blue),
//                                   const SizedBox(width: 10),
//                                   Text(
//                                     selectedDate == null
//                                         ? "Select Date"
//                                         : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),

//                           const SizedBox(height: 20),

//                           /// BUTTON
//                           SizedBox(
//                             width: double.infinity,
//                             child: ElevatedButton(
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.red,
//                                 padding:
//                                     const EdgeInsets.symmetric(vertical: 14),
//                               ),
//                               onPressed: () {
//                                 if (source != null &&
//                                     destination != null &&
//                                     selectedDate != null) {
//                                   String date = DateFormat('yyyy-MM-dd')
//                                       .format(selectedDate!);

//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (context) => BusInfo(
//                                         from: source!,
//                                         destination: destination!,
//                                         date: date,
//                                       ),
//                                     ),
//                                   );
//                                 } else {
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     const SnackBar(
//                                       content: Text(
//                                           "Please enter source and destination"),
//                                     ),
//                                   );
//                                 }
//                               },
//                               child: const Text(
//                                 "Search Buses",
//                                 style: TextStyle(color: Colors.white),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//       ),

//       bottomNavigationBar: Footer(),
//     );
//   }

//   /// 🔥 REUSABLE DROPDOWN
//   Widget _buildDropdown({
//     required String hint,
//     required IconData icon,
//     required Color color,
//     required String? value,
//     required List<String> items,
//     required Function(String?) onChanged,
//   }) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10),
     
//       decoration: BoxDecoration(
//        color:  const Color.fromARGB(255, 235, 233, 233), // background color
//     borderRadius: BorderRadius.circular(13), 
        
//       ),
//       child: Row(
//         children: [
//           Icon(icon, color: color),
//           const SizedBox(width: 10),
//           Expanded(
//             child: DropdownButtonFormField<String>(
//               value: value,
//               isExpanded: true,
//                style: const TextStyle(
//     color: Colors.grey, // 👈 font color
//     fontSize: 16,
//   ),
//               icon: const Icon(Icons.keyboard_arrow_down),
//               decoration: const InputDecoration(
//                 border: InputBorder.none,
                
//               ),
//               hint: Text(hint),
//               items: items.map((city) {
//                 return DropdownMenuItem(
//                   value: city,
//                   child: Text(city),
//                 );
//               }).toList(),
//               onChanged: onChanged,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }




class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  DateTime? selectedDate;
  String? source;
  String? destination;
  
 
  late Stream<QuerySnapshot> _cityStream;

  @override
  void initState() {
    super.initState();
    _cityStream = db.collection("city").snapshots();
  }

  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.redAccent, 
              onPrimary: Colors.white, 
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _cityStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.red));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No cities found in database"));
                }

                List<String> cities = snapshot.data!.docs
                    .map((doc) => doc["name"].toString())
                    .toList();

                return LayoutBuilder(
                  builder: (context, constraints) {
                    bool isDesktop = constraints.maxWidth > 800;

                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? 40 : 20,
                        ),
                        child: Transform.translate(
                          offset: const Offset(0, -50),
                          child: _buildSearchCard(cities, isDesktop),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const Footer(), // 
    );
  }

 
  Widget _buildHeader() {
    return Container(
      height:150,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE53935), Color(0xFFB71C1C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Book Your Ride",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.directions_bus, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                "Find the best bus routes at the lowest prices",
                style: TextStyle(color: Colors.white70, fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildSearchCard(List<String> cities, bool isDesktop) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 25,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: isDesktop 
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(flex: 3, child: _buildDropdown(
                label: "From", 
                hint: "Source", 
                icon: Icons.location_on_outlined, 
                value: source, 
                items: cities, 
                onChanged: (val) => setState(() => source = val)
              )),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                child: Icon(Icons.swap_horiz, color: Colors.grey),
              ),
              Expanded(flex: 3, child: _buildDropdown(
                label: "To", 
                hint: "Destination", 
                icon: Icons.navigation_outlined, 
                value: destination, 
                items: cities, 
                onChanged: (val) => setState(() => destination = val)
              )),
              const SizedBox(width: 20),
              Expanded(flex: 3, child: _buildDatePicker()),
              const SizedBox(width: 20),
              Expanded(flex: 2, child: _buildSearchButton()),
            ],
          )
        : Column(
            children: [
              _buildDropdown(
                label: "From", 
                hint: "Select Source", 
                icon: Icons.location_on_outlined, 
                value: source, 
                items: cities, 
                onChanged: (val) => setState(() => source = val)
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(),
              ),
              _buildDropdown(
                label: "To", 
                hint: "Select Destination", 
                icon: Icons.navigation_outlined, 
                value: destination, 
                items: cities, 
                onChanged: (val) => setState(() => destination = val)
              ),
              const SizedBox(height: 25),
              _buildDatePicker(),
              const SizedBox(height: 30),
              _buildSearchButton(),
            ],
          ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String hint,
    required IconData icon,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: items.contains(value) ? value : null,
      onChanged: onChanged,
      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
        prefixIcon: Icon(icon, color: Colors.redAccent),
        border: InputBorder.none,
        hintText: hint,
      ),
      items: items.map((city) => DropdownMenuItem(value: city, child: Text(city))).toList(),
    );
  }


  Widget _buildDatePicker() {
    return InkWell(
      onTap: pickDate,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(15),
          color: Colors.grey.shade50,
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month_outlined, color: Colors.redAccent),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Departure Date", style: TextStyle(fontSize: 11, color: Colors.grey)),
                Text(
                  selectedDate == null
                      ? "Select Date"
                      : DateFormat('EEE, dd MMM').format(selectedDate!),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

 
  Widget _buildSearchButton() {
    return SizedBox(
      width: double.infinity,
      height: 30,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFB71C1C),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 4,
          shadowColor: Colors.red.withOpacity(0.4),
        ),
        onPressed: () {
          if (source != null && destination != null && selectedDate != null) {
             Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BusInfo(
                                        from: source!,
                                        destination: destination!,
                                        date: DateFormat('yyyy-MM-dd')
                                      .format(selectedDate!),
                                      ),
                                    ),
                                  );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Please complete all fields")),
            );
          }
        },
        child: const Text(
          "SEARCH",
          style: TextStyle(
            color: Colors.white, 
            fontSize: 16, 
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }}