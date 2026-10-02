import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class RevenuePage extends StatefulWidget {
  const RevenuePage({super.key});

  @override
  State<RevenuePage> createState() => _RevenuePageState();
}

class _RevenuePageState extends State<RevenuePage> {
  final db = FirebaseFirestore.instance;

  String selectedFilter = "month";
  DateTime selectedDate = DateTime.now(); //  NEW

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    int crossAxisCount = 4;

    if (width < 600) {
      crossAxisCount = 1;
    } else if (width < 1000) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 4;
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            //  FILTER + DATE PICKER
            Padding(
              padding: const EdgeInsets.all(20),
              child: Wrap(
                spacing: 10,
                children: [
                  // _filterBtn("Today"),
                 
                  // _filterBtn("Month"),

                  //  DATE PICKER
                  ElevatedButton(
                    onPressed: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );

                      if (picked != null) {
                        setState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                    child: const Text("Select Date"),
                  ),
                ],
              ),
            ),

           StreamBuilder<QuerySnapshot>(
  stream: db.collection("bookings").snapshots(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return const Center(child: Text("No data"));
    }

    final bookings = snapshot.data!.docs;

    double total = 0;
    double today = 0;
    double month = 0;

    // SAFE DATE
    DateTime now = selectedDate ?? DateTime.now();

    //  use NOW not DateTime.now()
    int daysInMonth = DateTime(
      now.year,
      now.month + 1,
      0,
    ).day;

    List<double> chartData =
        selectedFilter == "month"
            ? List.filled(daysInMonth, 0)
            : List.filled(7, 0);

    //  SAFE WEEK START
    DateTime startOfWeek =
        now.subtract(Duration(days: now.weekday - 1));

    for (var doc in bookings) {
      var data = doc.data() as Map<String, dynamic>;

      // SAFE FIELD CHECKS
      if (data["paymentStatus"] != "Paid") continue;
      if (data["createdAt"] == null) continue;

      double price =
          double.tryParse(data["price"]?.toString() ?? "0") ?? 0;

      DateTime date =
          (data["createdAt"] as Timestamp).toDate();

      total += price;

      // TODAY
      if (date.day == now.day &&
          date.month == now.month &&
          date.year == now.year) {
        today += price;
      }

      // MONTH
      if (date.month == now.month &&
          date.year == now.year) {
        month += price;
      }

      // WEEK
   
      // MONTH CHART
      if (selectedFilter == "month") {
        if (date.month == now.month &&
            date.year == now.year) {
          int index = date.day - 1;

          if (index >= 0 && index < chartData.length) {
            chartData[index] += price;
          }
        }
      }
    }

    return Column(
      children: [

        //  CARDS
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.builder(
            itemCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: width < 600 ? 2.5 : 1.8,
            ),
            itemBuilder: (context, index) {
              final items = [
                ["Total Revenue", total, Icons.wallet, Colors.green],
                ["Selected Day", today, Icons.today, Colors.blue],
                ["Selected Month", month, Icons.bar_chart, Colors.orange],
              ];

              return _card(
                items[index][0] as String,
                items[index][1] as double,
                items[index][2] as IconData,
                items[index][3] as Color,
              );
            },
          ),
        ),

        const SizedBox(height: 30),

   
        Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  blurRadius: 10,
                  color: Colors.black.withOpacity(0.05),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Revenue Analytics",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: width < 600 ? 200 : 300,
                  child: _buildChart(chartData),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  },
)
        ],
      ),
    ),
  );
}

  // FILTER BUTTON
  Widget _filterBtn(String label) {
    bool isActive = selectedFilter == label.toLowerCase();

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isActive ? Colors.red : Colors.grey.shade200,
          foregroundColor:
              isActive ? Colors.white : Colors.black,
        ),
        onPressed: () {
          setState(() {
            selectedFilter = label.toLowerCase();
          });
        },
        child: Text(label),
      ),
    );
  }

  //  CARD
  Widget _card(String title, double value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(color: Colors.grey.shade600)),
              const SizedBox(height: 8),
              Text(
                "₹${value.toStringAsFixed(0)}",
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          )
        ],
      ),
    );
  }

  //  CHART
 Widget _buildChart(List<double> data) {
  return SizedBox(
    height: 250,
    child: BarChart(
      BarChartData(
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),

        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
          
      if (selectedFilter == "month") {
        return Text((value.toInt() + 1).toString(),
            style: TextStyle(fontSize: 10));
      }

      return const Text("");
              },
            ),
          ),
          leftTitles: AxisTitles(
    sideTitles: SideTitles(
      showTitles: true,
      reservedSize:50,
      interval: 1000, // 

      getTitlesWidget: (value, meta) {
        return Text(
          "₹${value.toInt()}",
          style: const TextStyle(fontSize: 12),
        );
      },
    ),
  ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),

        barGroups: data.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value,
                width: selectedFilter == "month" ? 8 : 10,
                borderRadius: BorderRadius.circular(6),

                gradient: LinearGradient(
                  colors: [
                    Colors.red,
                    Colors.orange,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    ),
  );
}
}