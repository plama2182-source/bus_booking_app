import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:busboking/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:busboking/signup.dart';
import 'busData.dart';
import 'bookingData.dart';
import 'userData.dart';
import 'scheduleData.dart';
import 'route.dart';
import 'city.dart';
import 'boardingData.dart';
import 'droppingData.dart';
import 'boardingTimeTable.dart';
import 'droppingTimeTable.dart';
import 'revenue.dart';
import 'busRevenue.dart';
import 'busadmin.dart';
import 'verifyBusAdmin.dart';
import 'changePassword.dart';
void main() async{
   WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const Dashboard());
}


class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ResponsiveAdminPage(),
    );
  }
}

class ResponsiveAdminPage extends StatefulWidget {
  const ResponsiveAdminPage({super.key});

  @override
  State<ResponsiveAdminPage> createState() => _ResponsiveAdminPageState();
}

class _ResponsiveAdminPageState extends State<ResponsiveAdminPage> {
  int selectedIndex = 0;

  // Your list of pages preserved exactly
  List<Widget> pages = [
    DashboardPage(),
    busdata(),
    scheduleData(),
    bookingData(),
    userData(),
    busAdminData(),
    RouteData(),
    CityData(),
    BoardingData(),
    DroppingData(),
    BoardingTimeTable(),
    DroppingTimeTable(),
    SuperAdminVerificationScreen(),
    RevenuePage(),
    RevenueDashboard(),
 AdminChangePassword(),
  ];

  @override
  Widget build(BuildContext context) {
   

    return LayoutBuilder(
      builder: (context, constraints) {
        // Updated to pass selectedIndex to SidebarMenu
        if (constraints.maxWidth < 800) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Admin Panel', style: TextStyle(color: Colors.white)),
              backgroundColor: Colors.red,
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            drawer: Drawer(
              child: SidebarMenu(
                onItemSelected: onItemSelected,
                selectedIndex: selectedIndex, // Added
              ),
            ),
            body: pages[selectedIndex],
          );
        } else {
        
          return Scaffold(
            body: Row(
              children: [
                SizedBox(
                  width: 250,
                  child: SidebarMenu(
                    onItemSelected: onItemSelected,
                    selectedIndex: selectedIndex, // Added
                  ),
                ),
                const VerticalDivider(width: 1, thickness: 1),
                Expanded(child: pages[selectedIndex]),
              ],
            ),
          );
        }
      },
    );
  }

  void onItemSelected(int index) {
    setState(() {
      selectedIndex = index;
    });
    // Safely close drawer if on mobile
    if (MediaQuery.of(context).size.width < 800) {
      Navigator.of(context).maybePop();
    }
  }
}

class SidebarMenu extends StatelessWidget {
  final Function(int) onItemSelected;
  final int selectedIndex; // Added tracker

  const SidebarMenu({
    super.key, 
    required this.onItemSelected, 
    required this.selectedIndex // Added to constructor
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.red,
              border: Border(right: BorderSide(color: Colors.grey, width: 4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.admin_panel_settings, color: Colors.white, size: 40),
                SizedBox(height: 10),
                Text('Admin Panel',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          buildItem(Icons.dashboard, 'Dashboard', 0),
          buildItem(Icons.directions_bus, 'Buses', 1),
          buildItem(Icons.schedule_send_rounded, 'Schedules', 2),
          buildItem(Icons.book_online, 'Bookings', 3),
          buildItem(Icons.people, 'Users', 4),
          buildItem(Icons.admin_panel_settings, 'Bus Admin', 5),
          buildItem(Icons.route_outlined, 'Route', 6),
          buildItem(Icons.location_city_rounded, 'City', 7),
          buildItem(Icons.location_on, 'Boarding', 8),
          buildItem(Icons.flag, 'Dropping', 9),
          buildItem(Icons.timelapse, 'Boarding Time Table', 10),
          buildItem(Icons.timelapse, 'Dropping Time Table', 11),
          buildItem(Icons.verified_user, 'Bus Admin Verification', 12),
          buildItem(Icons.timelapse, 'Revenue Table', 13),
          buildItem(Icons.directions_bus, 'Bus Revenue Table', 14),
          buildItem(Icons.password  , 'Change Password', 15),
        ],

      ),
    );
  }

  Widget buildItem(IconData icon, String title, int index) {
    // Determine if this item is currently active
    bool isSelected = selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        selected: isSelected,
        selectedTileColor: Colors.red.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        leading: Icon(
          icon, 
          color: isSelected ? Colors.red : Colors.grey.shade600
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.red : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        onTap: () => onItemSelected(index),
      ),
    );
  }
}

// --- DashboardPage preserved with UI improvements ---
class DashboardPage extends StatelessWidget {
  DashboardPage({super.key});

  final FirebaseFirestore db = FirebaseFirestore.instance;

  Future<int> getCount(String collection, String title) async {
  
  
    if(title=="Total Users")
{
 var snapshot = await db.collection(collection).where("role",isEqualTo: "user").get();
  return snapshot.docs.length;
}
else if (title=="Total Bus Admin")
{
 var snapshot = await db.collection(collection).where("role",isEqualTo: "busAdmin").where("isVerified",isEqualTo: true).get();
  return snapshot.docs.length;
}
else{
    var snapshot = await db.collection(collection).get();
  return snapshot.docs.length;
}
   
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> data = [
      {"title": "Total Users", "icon": Icons.people, "collection": "users"},
      {"title": "Total Bus Admin", "icon": Icons.add_moderator_outlined, "collection": "users"},
      {"title": "Total Buses", "icon": Icons.directions_bus, "collection": "bus"},
      {"title": "Total Bookings", "icon": Icons.book_online, "collection": "bookings"},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard Overview", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.red,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignupPage()));
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 300,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 1.3,
          ),
          itemCount: data.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.red.withOpacity(0.1),
                      child: Icon(data[index]["icon"], color: Colors.red),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      data[index]["title"],
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    FutureBuilder<int>(
                      future: getCount(data[index]["collection"],data[index]['title']),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2));
                        }
                        return Text(
                          snapshot.data?.toString() ?? "0",
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}