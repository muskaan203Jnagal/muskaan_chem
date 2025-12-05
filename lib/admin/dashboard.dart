// ============================================================================
// lib/admin/dashboard.dart (V9 - Composite Index Avoided)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// --- Enums and Utility Classes ---

enum DateFilter { today, last7Days, last30Days, thisMonth, allTime }

class DateUtils {
  static DateTime getStartDate(DateFilter filter) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (filter) {
      case DateFilter.today:
        return today;
      case DateFilter.last7Days:
        return today.subtract(const Duration(days: 6));
      case DateFilter.last30Days:
        return today.subtract(const Duration(days: 29));
      case DateFilter.thisMonth:
        return DateTime(now.year, now.month, 1);
      case DateFilter.allTime:
        return DateTime(2000, 1, 1); 
    }
  }

  static DateTime getPreviousStartDate(DateFilter filter, DateTime currentStartDate) {
    final now = DateTime.now();
    
    switch (filter) {
      case DateFilter.today:
        return currentStartDate.subtract(const Duration(days: 1));
      case DateFilter.last7Days:
        return currentStartDate.subtract(const Duration(days: 7));
      case DateFilter.last30Days:
        return currentStartDate.subtract(const Duration(days: 30));
      case DateFilter.thisMonth:
        return DateTime(currentStartDate.year, currentStartDate.month - 1, 1);
      case DateFilter.allTime:
        return now.subtract(const Duration(days: 1)); 
    }
  }

  static String getFilterName(DateFilter filter) {
    switch (filter) {
      case DateFilter.today:
        return 'Today';
      case DateFilter.last7Days:
        return 'Last 7 Days';
      case DateFilter.last30Days:
        return 'Last 30 Days';
      case DateFilter.thisMonth:
        return 'This Month';
      case DateFilter.allTime:
        return 'All Time';
    }
  }
}


// --- Main Dashboard Widget ---

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DateFilter _selectedFilter = DateFilter.last7Days;
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NumberFormat _currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '\$');
  final int lowStockThreshold = 5; // Low stock defined as 5 units or less

  // Helper to fetch the earnings stream based on the selected filter/dates
  Stream<QuerySnapshot> _getEarningsStream() {
    DateTime startDate = DateUtils.getStartDate(_selectedFilter);
    
    // Custom range logic
    if (_selectedFilter == DateFilter.allTime && _customStartDate != null && _customEndDate != null) {
      startDate = _customStartDate!;
      final endDate = _customEndDate!.add(const Duration(days: 1)); 
      
      return _firestore.collection('earnings')
          .where('date', isGreaterThanOrEqualTo: startDate)
          .where('date', isLessThan: endDate)
          .orderBy('date', descending: true)
          .snapshots();
    }
    
    // True 'All Time'
    if (_selectedFilter == DateFilter.allTime) {
      return _firestore.collection('earnings')
          .orderBy('date', descending: true)
          .snapshots();
    }
    
    // Preset filters
    return _firestore.collection('earnings')
        .where('date', isGreaterThanOrEqualTo: startDate)
        .orderBy('date', descending: true)
        .snapshots();
  }

  // Function to fetch and summarize previous period data
  Future<Map<String, num>> _fetchPreviousPeriodData() async {
    if (_selectedFilter == DateFilter.allTime) return {};

    final currentStartDate = DateUtils.getStartDate(_selectedFilter);
    final prevStartDate = DateUtils.getPreviousStartDate(_selectedFilter, currentStartDate);
    final prevEndDate = currentStartDate.subtract(const Duration(microseconds: 1));
    
    if (prevStartDate.isAfter(prevEndDate)) return {};

    final prevSnapshot = await _firestore.collection('earnings')
        .where('date', isGreaterThanOrEqualTo: prevStartDate)
        .where('date', isLessThan: prevEndDate.add(const Duration(days:1)))
        .get();

    double totalRevenue = 0.0;
    int totalOrders = 0;
    int totalItemsSold = 0;

    for (var doc in prevSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      totalRevenue += (data['totalRevenue'] ?? 0.0).toDouble();
      totalOrders += (data['totalOrders'] as num? ?? 0).toInt();
      totalItemsSold += (data['totalItemsSold'] as num? ?? 0).toInt();
    }

    return {
      'totalRevenue': totalRevenue,
      'totalOrders': totalOrders,
      'totalItemsSold': totalItemsSold,
    };
  }

  // UPDATED: Function to fetch the list of low stock products without a composite index
  Future<List<Map<String, dynamic>>> _fetchLowStockProducts() async {
    try {
      // 1. Query only by the 'status' field (only one where clause)
      final QuerySnapshot snapshot = await _firestore.collection('products')
          .where('status', isEqualTo: 'active')
          .get();
          
      List<Map<String, dynamic>> lowStockList = [];
      
      // 2. Filter the results client-side (in the app) for the 'stock' threshold
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final stock = (data['stock'] as num? ?? 0).toInt();
        
        if (stock <= lowStockThreshold) {
          // Found a low stock product
          lowStockList.add({
            'name': data['name'] as String? ?? 'Unnamed Product',
            'stock': stock, 
          });
        }
      }
      
      return lowStockList;
    } catch (e) {
      // You should now only see this if a single-field index for 'status' is missing
      print('Error fetching low stock products: $e');
      return [];
    }
  }

  // Helper to calculate and display the comparison percentage
  Widget _buildComparisonWidget(num currentValue, num previousValue, {bool isCurrency = false}) {
    if (_selectedFilter == DateFilter.allTime || previousValue == 0) {
      return const Text('vs. Prior Period N/A', style: TextStyle(color: Colors.grey, fontSize: 12));
    }

    double change = 0;
    if (isCurrency) {
        change = (currentValue.toDouble() - previousValue.toDouble());
    } else {
        change = (currentValue.toInt() - previousValue.toInt()).toDouble();
    }
    
    double percentageChange = (change / previousValue) * 100;
    
    final changeColor = percentageChange >= 0 ? Colors.green[700] : Colors.red[700];
    final icon = percentageChange >= 0 ? Icons.arrow_upward : Icons.arrow_downward;
    
    return Row(
      children: [
        Icon(icon, size: 14, color: changeColor),
        const SizedBox(width: 4),
        Text(
          '${percentageChange.abs().toStringAsFixed(1)}%',
          style: TextStyle(color: changeColor, fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(width: 4),
        const Text('vs. Prior Period', style: TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Future<void> _selectCustomDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _customStartDate != null && _customEndDate != null 
          ? DateTimeRange(start: _customStartDate!, end: _customEndDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _selectedFilter = DateFilter.allTime; 
        _customStartDate = picked.start;
        _customEndDate = picked.end;
      });
    }
  }
  
  // Dedicated widget to display the list of low stock products
  Widget _buildLowStockDetailCard(List<Map<String, dynamic>> products) {
    if (products.isEmpty) {
      return const SizedBox.shrink(); 
    }
    
    return Card(
      elevation: 2,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  'Products Needing Restock (Stock <= $lowStockThreshold)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red[700]),
                ),
              ],
            ),
            const Divider(),
            
            // Constrain the height of the list view
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return ListTile(
                    dense: true,
                    title: Text(product['name'], style: const TextStyle(fontWeight: FontWeight.w500)),
                    trailing: Text(
                      'Stock: ${product['stock']}', 
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)
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

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormatter = DateFormat('MMM d, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Analytics Dashboard'),
        elevation: 1,
        automaticallyImplyLeading: false, 
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Filter and Range Selection ---
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Text('View Data For:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<DateFilter>(
                        decoration: const InputDecoration(
                          labelText: 'Time Period',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        value: _selectedFilter,
                        items: DateFilter.values.map((filter) {
                          return DropdownMenuItem(
                            value: filter,
                            child: Text(DateUtils.getFilterName(filter)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedFilter = val;
                              _customStartDate = null;
                              _customEndDate = null;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: ElevatedButton.icon(
                        onPressed: _selectCustomDateRange,
                        icon: const Icon(Icons.date_range),
                        label: Text(
                          _customStartDate != null
                              ? 'Custom Range: ${dateFormatter.format(_customStartDate!)} - ${dateFormatter.format(_customEndDate!)}'
                              : 'Select Custom Range',
                        ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48), 
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // --- Low Stock Products List (Independent FutureBuilder) ---
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchLowStockProducts(),
              builder: (context, lowStockSnapshot) {
                if (lowStockSnapshot.connectionState == ConnectionState.waiting) {
                  return const LinearProgressIndicator();
                }
                
                final lowStockProducts = lowStockSnapshot.data ?? [];
                
                return _buildLowStockDetailCard(lowStockProducts);
              },
            ),

            const SizedBox(height: 16),
            
            // --- Analytics Stream Builder (Metrics) ---
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _getEarningsStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No earnings data found for this period.'));
                  }
                  
                  final dailyData = snapshot.data!.docs;
                  double totalRevenue = 0.0;
                  int totalOrders = 0;
                  int totalItemsSold = 0;
                  
                  // Calculate overall totals from the filtered daily data (Current Period)
                  for (var doc in dailyData) {
                    final data = doc.data() as Map<String, dynamic>;
                    totalRevenue += (data['totalRevenue'] ?? 0.0).toDouble();
                    
                    final dailyOrders = (data['totalOrders'] as num? ?? 0).toInt();
                    totalOrders += dailyOrders;
                    
                    final dailyItems = (data['totalItemsSold'] as num? ?? 0).toInt();
                    totalItemsSold += dailyItems;
                  }
                  
                  // Wrap metric display in a FutureBuilder to fetch comparison data
                  return FutureBuilder<Map<String, num>>(
                    future: _fetchPreviousPeriodData(),
                    builder: (context, prevSnapshot) {
                      if (prevSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: Text('Loading comparison data...')); 
                      }

                      final prevData = prevSnapshot.data ?? {};
                      final prevTotalRevenue = (prevData['totalRevenue'] ?? 0.0).toDouble();
                      final prevTotalOrders = (prevData['totalOrders'] ?? 0).toInt();
                      final prevTotalItemsSold = (prevData['totalItemsSold'] ?? 0).toInt();
                      
                      final aov = totalOrders > 0 ? totalRevenue / totalOrders : 0.0;
                      final prevAov = prevTotalOrders > 0 ? prevTotalRevenue / prevTotalOrders : 0.0;


                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- Summary Cards Row 1: Revenue, Orders, Items Sold, AOV ---
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildStatCard(
                                title: 'Total Revenue', 
                                value: _currencyFormatter.format(totalRevenue), 
                                color: Colors.green,
                                comparisonWidget: _buildComparisonWidget(totalRevenue, prevTotalRevenue, isCurrency: true),
                              ),
                              _buildStatCard(
                                title: 'Total Orders', 
                                value: totalOrders.toString(), 
                                color: Colors.blue,
                                comparisonWidget: _buildComparisonWidget(totalOrders, prevTotalOrders),
                              ),
                              _buildStatCard(
                                title: 'Total Items Sold', 
                                value: totalItemsSold.toString(), 
                                color: Colors.orange,
                                comparisonWidget: _buildComparisonWidget(totalItemsSold, prevTotalItemsSold),
                              ),
                              _buildStatCard(
                                title: 'Avg. Order Value (AOV)', 
                                value: _currencyFormatter.format(aov), 
                                color: Colors.purple,
                                comparisonWidget: _buildComparisonWidget(aov, prevAov, isCurrency: true),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),
                          
                          const Text('Daily Revenue Breakdown', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const Divider(),
                          
                          // --- Daily Breakdown List ---
                          Expanded(
                            child: Card(
                              elevation: 1,
                              child: ListView.builder(
                                itemCount: dailyData.length,
                                itemBuilder: (context, index) {
                                  final doc = dailyData[index];
                                  final data = doc.data() as Map<String, dynamic>;
                                  
                                  final revenue = (data['totalRevenue'] ?? 0.0).toDouble();
                                  final orders = (data['totalOrders'] as num? ?? 0).toInt();
                                  final itemsSold = (data['totalItemsSold'] as num? ?? 0).toInt();
                                  final date = (data['date'] as Timestamp).toDate();

                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.indigo,
                                      child: Text(date.day.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    ),
                                    title: Text('Sales for ${DateFormat('EEEE, MMM d, yyyy').format(date)}'),
                                    subtitle: Text('$orders Orders | $itemsSold Items Sold'),
                                    trailing: Text(
                                      _currencyFormatter.format(revenue),
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green[700]),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Stat Card Widget
  Widget _buildStatCard({
    required String title, 
    required String value, 
    required Color color,
    Widget? comparisonWidget, 
  }) {
    return Expanded(
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 28, 
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              if (comparisonWidget != null) comparisonWidget,
            ],
          ),
        ),
      ),
    );
  }
}