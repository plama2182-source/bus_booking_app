

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class RevenueDashboard extends StatefulWidget {
  const RevenueDashboard({Key? key}) : super(key: key);

  @override
  State<RevenueDashboard> createState() =>
      _RevenueDashboardState();
}

class _RevenueDashboardState extends State<RevenueDashboard> {

  // ============================================================
  // FIREBASE
  // ============================================================

  final FirebaseFirestore _db =
      FirebaseFirestore.instance;

  // ============================================================
  // CURRENT USER
  // ============================================================

  String? _currentUserId;

  // ============================================================
  // BUS ID -> BUS NAME
  // ============================================================

  Map<String, String> _busIdToNameMap = {};

  // ============================================================
  // FILTER VARIABLES
  // ============================================================

  DateTime _selectedDate = DateTime.now();

  String _busSearchQuery = "";

  final TextEditingController _searchController =
      TextEditingController();

  // Date filter ON/OFF
  bool _dateFilterEnabled = true;

  // Bus filter ON/OFF
  bool _busFilterEnabled = false;

  // ============================================================
  // INIT STATE
  // ============================================================

  @override
  void initState() {
    super.initState();

    // Get currently logged-in user's UID
    _currentUserId =
        FirebaseAuth.instance.currentUser?.uid;

    // Load only this user's buses
    _loadBusNames();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  // ============================================================
  // LOAD CURRENT USER'S BUS NAMES
  // ============================================================

  Future<void> _loadBusNames() async {

    // If no user is logged in
    if (_currentUserId == null) {
      return;
    }

    try {

      // Get ONLY buses belonging to current user
      QuerySnapshot snap = await _db
          .collection("bus")
          .where(
            "userId",
            isEqualTo: _currentUserId,
          )
          .get();

      Map<String, String> tempMap = {};

      for (var doc in snap.docs) {

        Map<String, dynamic> data =
            doc.data() as Map<String, dynamic>;

        String busName =
            (data["busname"] ?? "Unnamed Bus")
                .toString()
                .trim();

        // Store bus ID -> bus name
        tempMap[doc.id] =
            busName.toLowerCase();
      }

      if (mounted) {
        setState(() {
          _busIdToNameMap = tempMap;
        });
      }

    } catch (e) {

      debugPrint(
        "Error loading current user's buses: $e",
      );
    }
  }

  // ============================================================
  // GET DISPLAY NAME
  // ============================================================

  Future<String> getDisplayName(
    String collection,
    String docId,
  ) async {

    if (docId == "null" ||
        docId.isEmpty) {
      return "N/A";
    }

    try {

      DocumentSnapshot doc =
          await _db
              .collection(collection)
              .doc(docId)
              .get();

      if (!doc.exists) {
        return "Unknown";
      }

      Map<String, dynamic> data =
          doc.data() as Map<String, dynamic>;

      // ========================================================
      // ROUTE
      // ========================================================

      if (collection == "route") {

        return
            "${data["from"] ?? "?"} → "
            "${data["to"] ?? "?"}";
      }

      // ========================================================
      // BUS
      // ========================================================

      return data["busname"] ??
          "Unnamed Bus";

    } catch (e) {

      debugPrint(
        "Error getting display name: $e",
      );

      return "Error";
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(0xFFF8F9FD),

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(

        title: const Text(
          "Bus Revenue Analytics",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        centerTitle: true,

        backgroundColor:
            Colors.red,

        elevation: 0,
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: Column(
        children: [

          // ====================================================
          // FILTER BAR
          // ====================================================

          _buildFilterBar(),

          // ====================================================
          // REVENUE DATA
          // ====================================================

          Expanded(

            child:
                StreamBuilder<QuerySnapshot>(

              stream: _db
                  .collection("bookings")
                  .orderBy(
                    "createdAt",
                    descending: true,
                  )
                  .snapshots(),

              builder:
                  (context, snapshot) {

                // =================================================
                // LOADING BOOKINGS
                // =================================================

                if (snapshot.connectionState ==
                    ConnectionState.waiting) {

                  return const Center(
                    child:
                        CircularProgressIndicator(),
                  );
                }

                // =================================================
                // ERROR
                // =================================================

                if (snapshot.hasError) {

                  return Center(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(20),

                      child: Text(
                        "Error loading revenue:\n"
                        "${snapshot.error}",

                        textAlign:
                            TextAlign.center,

                        style:
                            const TextStyle(
                          color:
                              Colors.red,
                        ),
                      ),
                    ),
                  );
                }

                // =================================================
                // USER NOT LOGGED IN
                // =================================================

                if (_currentUserId == null) {

                  return const Center(
                    child: Text(
                      "No user is currently logged in.",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  );
                }

                // =================================================
                // LOADING USER'S BUS DATA
                // =================================================

                if (_busIdToNameMap.isEmpty) {

                  return const Center(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,

                      children: [

                        CircularProgressIndicator(),

                        SizedBox(height: 15),

                        Text(
                          "Loading your bus data...",
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // =================================================
                // NO BOOKING DATA
                // =================================================

                if (!snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {

                  return const Center(
                    child: Text(
                      "No booking data found.",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  );
                }

                // =================================================
                // GROUPING
                // =================================================

                Map<String, double> grouping = {};

                // =================================================
                // LOOP THROUGH BOOKINGS
                // =================================================

                for (var doc
                    in snapshot.data!.docs) {

                  try {

                    // =================================================
                    // DOCUMENT DATA
                    // =================================================

                    final data =
                        doc.data()
                            as Map<String, dynamic>;

                    // =================================================
                    // CREATED AT
                    // =================================================

                    if (!data.containsKey(
                          "createdAt",
                        ) ||
                        data["createdAt"] ==
                            null) {

                      continue;
                    }

                    Timestamp timestamp =
                        data["createdAt"]
                            as Timestamp;

                    DateTime bookingDate =
                        timestamp.toDate();

                    // =================================================
                    // BUS ID
                    // =================================================

                    String busId =
                        data["busId"]
                            ?.toString() ??
                        "";

                    // =================================================
                    // USER BUS VALIDATION
                    //
                    // Only process bookings whose busId
                    // exists inside _busIdToNameMap.
                    //
                    // _busIdToNameMap contains ONLY buses
                    // belonging to current user.
                    // =================================================

                    if (!_busIdToNameMap
                        .containsKey(busId)) {

                      continue;
                    }

                    // =================================================
                    // BUS NAME
                    // =================================================

                    String busName =
                        _busIdToNameMap[busId] ??
                            "";

                    // =================================================
                    // DATE FILTER
                    // =================================================

                    bool matchesDate =
                        true;

                    if (_dateFilterEnabled) {

                      matchesDate =
                          bookingDate.month ==
                              _selectedDate.month &&
                          bookingDate.year ==
                              _selectedDate.year;
                    }

                    // =================================================
                    // BUS NAME FILTER
                    // =================================================

                    bool matchesBusName =
                        true;

                    if (_busFilterEnabled &&
                        _busSearchQuery
                            .isNotEmpty) {

                      matchesBusName =
                          busName.contains(
                        _busSearchQuery
                            .toLowerCase()
                            .trim(),
                      );
                    }

                    // =================================================
                    // APPLY BOTH FILTERS
                    // =================================================

                    if (matchesDate &&
                        matchesBusName) {

                      // ===========================================
                      // ROUTE ID
                      // ===========================================

                      String routeId =
                          data["routeId"]
                              ?.toString() ??
                          "unknown";

                      // ===========================================
                      // PRICE
                      // ===========================================

                      double price =
                          double.tryParse(
                                data["price"]
                                        ?.toString() ??
                                    "0",
                              ) ??
                              0.0;

                      // ===========================================
                      // DATE
                      // ===========================================

                      String formattedDate =
                          DateFormat(
                        "MMM dd, yyyy",
                      ).format(
                        bookingDate,
                      );

                      // ===========================================
                      // GROUPING KEY
                      // ===========================================

                      String key =
                          "$busId|"
                          "$formattedDate|"
                          "$routeId";

                      // ===========================================
                      // ADD REVENUE
                      // ===========================================

                      grouping[key] =
                          (grouping[key] ??
                              0.0) +
                          price;
                    }

                  } catch (e) {

                    debugPrint(
                      "Error processing booking: $e",
                    );

                    continue;
                  }
                }

                // =================================================
                // CREATE ROWS
                // =================================================

                List<Map<String, dynamic>>
                    rows = [];

                grouping.forEach(
                  (key, total) {

                    List<String> parts =
                        key.split("|");

                    if (parts.length >= 3) {

                      rows.add({

                        "busId":
                            parts[0],

                        "date":
                            parts[1],

                        "routeId":
                            parts[2],

                        "total":
                            total,
                      });
                    }
                  },
                );

                // =================================================
                // SORT ROWS
                // =================================================

                rows.sort(
                  (a, b) {

                    return a["date"]
                        .toString()
                        .compareTo(
                          b["date"]
                              .toString(),
                        );
                  },
                );

                // =================================================
                // NO RESULTS AFTER FILTER
                // =================================================

                if (rows.isEmpty) {

                  return Column(
                    children: [

                      // SUMMARY
                      Padding(
                        padding:
                            const EdgeInsets.all(
                          16,
                        ),

                        child:
                            _buildSummaryHeader(
                          rows,
                        ),
                      ),

                      // MESSAGE
                      const Expanded(
                        child: Center(
                          child: Column(

                            mainAxisAlignment:
                                MainAxisAlignment
                                    .center,

                            children: [

                              Icon(
                                Icons.search_off,
                                size: 60,
                                color:
                                    Colors.grey,
                              ),

                              SizedBox(
                                height: 15,
                              ),

                              Text(
                                "No revenue found",
                                style:
                                    TextStyle(
                                  fontSize:
                                      18,

                                  fontWeight:
                                      FontWeight
                                          .bold,

                                  color:
                                      Colors.grey,
                                ),
                              ),

                              SizedBox(
                                height: 5,
                              ),

                              Text(
                                "Try changing your filters",
                                style:
                                    TextStyle(
                                  color:
                                      Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }

                // =================================================
                // MAIN DATA UI
                // =================================================

                return Padding(

                  padding:
                      const EdgeInsets.all(
                    16,
                  ),

                  child: Column(
                    children: [

                      // =================================================
                      // SUMMARY
                      // =================================================

                      _buildSummaryHeader(
                        rows,
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      // =================================================
                      // DATA TABLE
                      // =================================================

                      Expanded(

                        child: Container(

                          decoration:
                              BoxDecoration(

                            color:
                                Colors.white,

                            borderRadius:
                                BorderRadius
                                    .circular(
                              20,
                            ),

                            boxShadow: [

                              BoxShadow(

                                color:
                                    Colors.black
                                        .withOpacity(
                                  0.05,
                                ),

                                blurRadius:
                                    20,

                                offset:
                                    const Offset(
                                  0,
                                  10,
                                ),
                              ),
                            ],
                          ),

                          child: ClipRRect(

                            borderRadius:
                                BorderRadius
                                    .circular(
                              20,
                            ),

                            child:
                                SingleChildScrollView(

                              scrollDirection:
                                  Axis.vertical,

                              child:
                                  SingleChildScrollView(

                                scrollDirection:
                                    Axis.horizontal,

                                child:
                                    DataTable(

                                  horizontalMargin:
                                      24,

                                  columnSpacing:
                                      40,

                                  headingRowHeight:
                                      60,

                                  dataRowHeight:
                                      70,

                                  headingRowColor:
                                      WidgetStateProperty
                                          .all(
                                    Colors.indigo
                                        .withOpacity(
                                      0.03,
                                    ),
                                  ),

                                  dividerThickness:
                                      0.5,

                                  // =================================================
                                  // COLUMNS
                                  // =================================================

                                  columns: [

                                    DataColumn(
                                      label:
                                          _headerText(
                                        "DATE",
                                      ),
                                    ),

                                    DataColumn(
                                      label:
                                          _headerText(
                                        "BUS",
                                      ),
                                    ),

                                    DataColumn(
                                      label:
                                          _headerText(
                                        "ROUTE",
                                      ),
                                    ),

                                    DataColumn(
                                      label:
                                          _headerText(
                                        "EARNINGS",
                                      ),
                                    ),
                                  ],

                                  // =================================================
                                  // ROWS
                                  // =================================================

                                  rows:
                                      rows
                                          .map(
                                            (item) =>
                                                _buildDataRow(
                                              item,
                                            ),
                                          )
                                          .toList(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FILTER BAR
  // ============================================================

  Widget _buildFilterBar() {

    return Container(

      padding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),

      color:
          Colors.white,

      child: Row(
        children: [

          // ======================================================
          // BUS SEARCH
          // ======================================================

          Expanded(

            child: TextField(

              controller:
                  _searchController,

              // ==================================================
              // BUS SEARCH CHANGED
              // ==================================================

              onChanged: (value) {

                setState(() {

                  _busSearchQuery =
                      value.trim();

                  if (value
                      .trim()
                      .isEmpty) {

                    _busFilterEnabled =
                        false;

                  } else {

                    _busFilterEnabled =
                        true;
                  }
                });
              },

              decoration:
                  InputDecoration(

                hintText:
                    "Search Bus ...",

                prefixIcon:
                    const Icon(
                  Icons.search,
                  size: 20,
                ),

                // =================================================
                // CLEAR SEARCH
                // =================================================

                suffixIcon:

                    _searchController
                            .text
                            .isNotEmpty

                        ? IconButton(

                            icon:
                                const Icon(
                              Icons.clear,
                            ),

                            onPressed: () {

                              _searchController
                                  .clear();

                              setState(() {

                                _busSearchQuery =
                                    "";

                                _busFilterEnabled =
                                    false;
                              });
                            },
                          )

                        : null,

                filled:
                    true,

                fillColor:
                    const Color(
                  0xFFF8F9FD,
                ),

                border:
                    OutlineInputBorder(

                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),

                  borderSide:
                      BorderSide.none,
                ),

                contentPadding:
                    EdgeInsets.zero,
              ),
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          // ======================================================
          // DATE FILTER
          // ======================================================

          GestureDetector(

            onTap: () async {

              DateTime? picked =
                  await showDatePicker(

                context:
                    context,

                initialDate:
                    _selectedDate,

                firstDate:
                    DateTime(2020),

                lastDate:
                    DateTime(2030),
              );

              if (picked != null) {

                setState(() {

                  _selectedDate =
                      picked;

                  _dateFilterEnabled =
                      true;
                });
              }
            },

            child: Container(

              padding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),

              decoration:
                  BoxDecoration(

                color:
                    Colors.indigoAccent
                        .withOpacity(
                  0.1,
                ),

                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
              ),

              child: Row(
                children: [

                  const Icon(
                    Icons.calendar_month,

                    color:
                        Colors.indigoAccent,

                    size: 20,
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  Text(

                    _dateFilterEnabled

                        ? DateFormat(
                            "MMM yyyy",
                          ).format(
                            _selectedDate,
                          )

                        : "All Dates",

                    style:
                        const TextStyle(

                      color:
                          Colors.indigoAccent,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(
            width: 8,
          ),

          // ======================================================
          // CLEAR ALL FILTERS
          // ======================================================

          IconButton(

            tooltip:
                "Clear Filters",

            onPressed: () {

              _searchController
                  .clear();

              setState(() {

                _busSearchQuery =
                    "";

                _busFilterEnabled =
                    false;

                _dateFilterEnabled =
                    false;
              });
            },

            icon: const Icon(
              Icons.filter_alt_off,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TABLE HEADER
  // ============================================================

  Widget _headerText(
    String label,
  ) {

    return Text(

      label,

      style: TextStyle(

        color:
            Colors.indigo.shade900,

        fontWeight:
            FontWeight.w800,

        fontSize: 12,

        letterSpacing: 1.2,
      ),
    );
  }

  // ============================================================
  // DATA ROW
  // ============================================================

  DataRow _buildDataRow(
    Map<String, dynamic> item,
  ) {

    return DataRow(

      cells: [

        // ======================================================
        // DATE
        // ======================================================

        DataCell(

          Text(

            item["date"]
                .toString(),

            style: TextStyle(

              color:
                  Colors.grey.shade600,

              fontWeight:
                  FontWeight.w500,
            ),
          ),
        ),

        // ======================================================
        // BUS NAME
        // ======================================================

        DataCell(

          FutureBuilder<String>(

            future:
                getDisplayName(
              "bus",
              item["busId"],
            ),

            builder:
                (context, snap) {

              return Text(

                snap.data ??
                    "...",

                style:
                    const TextStyle(

                  fontWeight:
                      FontWeight.bold,

                  color:
                      Colors.black87,
                ),
              );
            },
          ),
        ),

        // ======================================================
        // ROUTE
        // ======================================================

        DataCell(

          FutureBuilder<String>(

            future:
                getDisplayName(
              "route",
              item["routeId"],
            ),

            builder:
                (context, snap) {

              return Container(

                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),

                decoration:
                    BoxDecoration(

                  color:
                      Colors.blue.shade50,

                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                ),

                child: Text(

                  snap.data ??
                      "...",

                  style:
                      TextStyle(

                    color:
                        Colors.blue.shade700,

                    fontSize: 12,

                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              );
            },
          ),
        ),

        // ======================================================
        // EARNINGS
        // ======================================================

        DataCell(

          Text(

            "₹${(item["total"] as double).toStringAsFixed(2)}",

            style:
                TextStyle(

              color:
                  Colors.green.shade700,

              fontWeight:
                  FontWeight.w900,

              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SUMMARY HEADER
  // ============================================================

  Widget _buildSummaryHeader(
    List<Map<String, dynamic>> rows,
  ) {

    double grandTotal =
        rows.fold(

      0.0,

      (sum, item) =>
          sum +
          (item["total"] as double),
    );

    return Row(
      children: [

        // ======================================================
        // TOTAL REVENUE
        // ======================================================

        _statCard(

          "Total Revenue",

          "₹${grandTotal.toStringAsFixed(2)}",

          Colors.green,

          Icons.account_balance_wallet,
        ),

        const SizedBox(
          width: 15,
        ),

        // ======================================================
        // TRIPS
        // ======================================================

        _statCard(

          "Trips",

          "${rows.length}",

          Colors.orange,

          Icons.route,
        ),
      ],
    );
  }

  // ============================================================
  // STAT CARD
  // ============================================================

  Widget _statCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {

    return Expanded(

      child: Container(

        padding:
            const EdgeInsets.all(
          20,
        ),

        decoration:
            BoxDecoration(

          color:
              Colors.white,

          borderRadius:
              BorderRadius.circular(
            20,
          ),

          border:
              Border.all(

            color:
                color.withOpacity(
              0.1,
            ),

            width: 2,
          ),
        ),

        child: Row(
          children: [

            // ==================================================
            // ICON
            // ==================================================

            CircleAvatar(

              backgroundColor:
                  color.withOpacity(
                0.1,
              ),

              child:
                  Icon(
                icon,
                color: color,
              ),
            ),

            const SizedBox(
              width: 15,
            ),

            // ==================================================
            // TEXT
            // ==================================================

            Column(

              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [

                Text(

                  title,

                  style:
                      const TextStyle(

                    color:
                        Colors.grey,

                    fontSize: 12,
                  ),
                ),

                Text(

                  value,

                  style:
                      const TextStyle(

                    fontSize: 18,

                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}