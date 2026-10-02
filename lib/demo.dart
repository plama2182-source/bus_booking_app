import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const BusSearchCard());
}

/// SEARCH CARD
class BusSearchCard extends StatefulWidget {
  const BusSearchCard({super.key});

  @override
  State<BusSearchCard> createState() => _BusSearchCardState();
}

class _BusSearchCardState extends State<BusSearchCard> {
  String? source;
  String? destination;

  final List<String> cities = [
    "Kolkata",
    "Delhi",
    "Mumbai",
    "Bangalore",
    "Chennai"
  ];

  void swapLocations() {
    setState(() {
      final temp = source;
      source = destination;
      destination = temp;
    });
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  "Bus Booking",
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.only(top: 10),
              child:Icon(Icons.bus_alert_rounded,color: Colors.white,),
            ),
          ],
        ),
      ),

      body: 
    
SingleChildScrollView( 
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(maxWidth: 500),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 12,
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // ✅ important
            children: [
              /// FROM
              _buildField(
                label: "From",
                icon: Icons.radio_button_checked,
                value: source,
                onChanged: (val) => setState(() => source = val),
              ),

              /// SWAP BUTTON
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: GestureDetector(
                  onTap: swapLocations,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey.shade200,
                    child: const Icon(Icons.swap_vert, color: Colors.black),
                  ),
                ),
              ),

              /// TO
              _buildField(
                label: "To",
                icon: Icons.location_on,
                value: destination,
                onChanged: (val) => setState(() => destination = val),
              ),

              const SizedBox(height: 20),

              /// SEARCH BUTTON
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (source == null || destination == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Select both locations")),
                      );
                    } else if (source == destination) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                "Source & Destination can't be same")),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                "Searching buses from $source to $destination")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "SEARCH BUSES",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    )
  
    );
  } 
     /// DROPDOWN FIELD
  Widget _buildField({
    required String label,
    required IconData icon,
    required String? value,
    required Function(String?) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        hint: Text("Select $label"),
        icon: const Icon(Icons.keyboard_arrow_down),
        items: cities.map((city) {
          return DropdownMenuItem(
            value: city,
            child: Text(city),
          );
        }).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          icon: Icon(icon, color: Colors.grey),
          border: InputBorder.none,
        ),
      ),
    );
  }
  }

 













