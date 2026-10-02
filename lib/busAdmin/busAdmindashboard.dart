import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:busboking/firebase_options.dart';
import 'addBus.dart';
import 'busEarning.dart';
import 'booking.dart';
import 'package:busboking/session.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'schedule.dart';
import 'package:busboking/admin/city.dart';
import 'package:busboking/admin/route.dart';
import 'package:busboking/admin/boardingData.dart';
import 'package:busboking/admin/droppingData.dart';
import 'boardingTimeTable.dart';
import 'package:busboking/signup.dart';
import 'droppingTimeTable.dart';
void main() async{
   WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const BusDashboard());
}


class BusDashboard extends StatelessWidget {
  const BusDashboard({super.key});

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
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  static List<String>? busIds;
     String? company;
  @override
  void initState() {
    super.initState();
    getValidatedBusIds();
    getcompany();
  }

  Future<void> getValidatedBusIds() async {
    setState(() {
      _ResponsiveAdminPageState.busIds = null;
    });

    try {
      var snap = await _db
          .collection("bus")
          .where("userId", isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .get();

      setState(() {
        _ResponsiveAdminPageState.busIds = snap.docs.map((doc) => doc.id).toList();
      });
    } catch (e) {
      debugPrint("Error fetching bus IDs: $e");
      setState(() {
        _ResponsiveAdminPageState.busIds = [];
      });
    }
  }

    Future<void> getcompany() async {
    setState(() {
  company = "";
    });

    try {
      var snap = await _db
          .collection("users")
         .doc(FirebaseAuth.instance.currentUser?.uid)
          .get();

      setState(() {
       company = snap["companyName"];
        
     
      });
    } catch (e) {
      debugPrint("Error fetching company name: $e");
      setState(() {
        company = "";
      });
    }
  }


  Widget _getBody() {
    switch (selectedIndex) {
      case 0: return DashboardPage();
      case 1: return AddBusScreen(company:company!);
      case 2: return booking();
      case 3: return RevenueDashboard();
      case 4: return CityData();
      case 5: return RouteData();
      case 6: return busSchedule();
      case 7: return BoardingData();
      case 8: return DroppingData();
      case 9: return BoardingTimeTable();
      case 10: return DroppingTimeTable();
      default: return DashboardPage();
    }
  }

  void onItemSelected(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 800;
        return Scaffold(
          appBar: isMobile 
              ? AppBar(
                  title: const Text('Bus Admin Panel', style: TextStyle(color: Colors.white)), 
                  backgroundColor: Colors.red,
                  iconTheme: const IconThemeData(color: Colors.white),
                ) 
              : null,
          drawer: isMobile 
              ? Drawer(child: SidebarMenu(onItemSelected: onItemSelected, selectedIndex: selectedIndex)) 
              : null,
          body: Row(
            children: [
              if (!isMobile)
                SizedBox(
                  width: 250,
                  child: SidebarMenu(onItemSelected: onItemSelected, selectedIndex: selectedIndex),
                ),
              Expanded(
                child: Container(
                  color: const Color(0xFFF8F9FD),
                  child: _getBody(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// --- SIDEBAR UI ---
class SidebarMenu extends StatelessWidget {
  final Function(int) onItemSelected;
  final int selectedIndex; // Added to track selection

  const SidebarMenu({
    super.key, 
    required this.onItemSelected, 
    required this.selectedIndex, // Required in constructor
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: ListView(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.red,
              border: Border(right: BorderSide(color: Colors.grey, width: 4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Icon(Icons.admin_panel_settings, color: Colors.white, size: 40),
                SizedBox(height: 10),
                Text('Bus Admin Panel', style: TextStyle(color: Colors.white, fontSize: 18)),
              ],
            ),
          ),
          _buildItem(Icons.dashboard, 'Dashboard', 0),
          _buildItem(Icons.directions_bus, 'Add Buses', 1),
          _buildItem(Icons.book, 'Bus Bookings', 2),
          _buildItem(Icons.money, 'Bus Revenue', 3),
          _buildItem(Icons.location_city, 'City', 4),
          _buildItem(Icons.route, 'Route', 5),
          _buildItem(Icons.schedule, 'Schedule', 6),
          _buildItem(Icons.location_on, 'Boarding Points', 7),
          _buildItem(Icons.flag, 'Dropping Points', 8),
          _buildItem(Icons.timelapse, 'Boarding Time Table', 9),
          _buildItem(Icons.timelapse, 'Dropping Time Table', 10),
        ],
      ),
    );
  }

  Widget _buildItem(IconData icon, String title, int index) {
    bool isSelected = selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        onTap: () => onItemSelected(index),
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
            fontSize: 14,
          )
        ),
      ),
    );
  }
}

// --- DASHBOARD PAGE ---
class DashboardPage extends StatelessWidget {
  DashboardPage({super.key});

  final FirebaseFirestore db = FirebaseFirestore.instance;

  Future<int> getCount(String collection, String field, dynamic value) async {
    if (value == null) return 0;
    if (value is List && value.isEmpty) return 0;

    try {
      Query query = db.collection(collection);
      if (value is List) {
        query = query.where(field, whereIn: value);
      } else {
        query = query.where(field, isEqualTo: value);
      }
      var snapshot = await query.get();
      return snapshot.docs.length;
    } catch (e) {
      debugPrint("Count Query Error: $e");
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentBusIds = _ResponsiveAdminPageState.busIds;

    if (currentBusIds == null) {
      return const Center(child: CircularProgressIndicator(color: Colors.red));
    }

    List<Map<String, dynamic>> stats = [
      {
        "title": "Total Buses",
        "icon": Icons.directions_bus,
        "collection": "bus",
        "field": "userId",
        "value": FirebaseAuth.instance.currentUser?.uid
      },
      {
        "title": "Total Bookings",
        "icon": Icons.book_online,
        "collection": "bookings",
        "field": "busId",
        "value": currentBusIds
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.red,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                // Adjust this navigation to your actual Login/Signup page
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const SignupPage()), 
                  (route) => false
                );
              }
            },
          ),
        ],
      ),
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Overview", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 300,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1.5,
                ),
                itemCount: stats.length,
                itemBuilder: (context, index) {
                  var item = stats[index];
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(item["icon"], size: 40, color: Colors.red),
                          const SizedBox(height: 12),
                          Text(item["title"], style: const TextStyle(color: Colors.grey)),
                          const SizedBox(height: 8),
                          FutureBuilder<int>(
                            future: getCount(item["collection"], item["field"], item["value"]),
                            builder: (context, snap) {
                              if (snap.connectionState == ConnectionState.waiting) {
                                return const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2));
                              }
                              return Text(
                                "${snap.data ?? 0}",
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
          ],
        ),
      ),
    );
  }
}