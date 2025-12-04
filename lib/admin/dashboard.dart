// lib/dashboard.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({Key? key}) : super(key: key);

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Configure thresholds
  final int lowStockThreshold = 5;

  // Helper: format as rupee-like string
  String _currency(num n) {
    final s = n.toInt().toString();
    return '₹' + s.replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
  }

  // Copy recent orders CSV to clipboard
  void _copyCSVFromDocs(List<QueryDocumentSnapshot> docs) {
    final header = 'OrderID,Customer,Total,Status,Date';
    final rows = docs.map((d) {
      final data = d.data() as Map<String, dynamic>;
      final id = d.id;
      final customer = (data['customerName'] ?? data['customer'] ?? '').toString();
      final total = (data['total'] ?? 0).toString();
      final status = (data['status'] ?? '').toString();
      final ts = data['createdAt'];
      final date = ts is Timestamp ? ts.toDate().toIso8601String().split('T').first : (data['date'] ?? '');
      return '$id,$customer,$total,$status,$date';
    }).join('\n');

    final csv = '$header\n$rows';
    Clipboard.setData(ClipboardData(text: csv));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('CSV copied to clipboard')));
  }

  // Build daily sales for last 7 days from a list of order docs
  List<_DaySales> _compute7DaySales(List<QueryDocumentSnapshot> docs) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6)); // inclusive
    // init map
    final map = <String, num>{};
    for (int i = 0; i < 7; i++) {
      final day = start.add(Duration(days: i));
      final key = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
      map[key] = 0;
    }

    for (final d in docs) {
      final data = d.data() as Map<String, dynamic>;
      final ts = data['createdAt'];
      if (ts is Timestamp) {
        final dt = ts.toDate();
        final key = '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
        if (map.containsKey(key)) {
          final amt = (data['total'] is num) ? data['total'] as num : num.tryParse('${data['total']}') ?? 0;
          map[key] = (map[key] ?? 0) + amt;
        }
      }
    }

    return map.entries.map((e) {
      final parts = e.key.split('-');
      final day = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      final label = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'][day.weekday - 1];
      return _DaySales(label, map[e.key] ?? 0);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final thirtyDaysAgo = Timestamp.fromDate(now.subtract(const Duration(days: 30)));
    final sevenDaysAgo = Timestamp.fromDate(now.subtract(const Duration(days: 7)));

    // streams
    final ordersLast30Stream = _firestore
        .collection('orders')
        .where('createdAt', isGreaterThanOrEqualTo: thirtyDaysAgo)
        .snapshots();

    final ordersLast7Stream = _firestore
        .collection('orders')
        .where('createdAt', isGreaterThanOrEqualTo: sevenDaysAgo)
        .snapshots();

    final recentOrdersStream = _firestore
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .limit(10)
        .snapshots();

    final lowStockStream =
        _firestore.collection('products').where('stock', isLessThanOrEqualTo: lowStockThreshold).snapshots();

    final usersStream = _firestore.collection('users').snapshots();

    return Scaffold(
      backgroundColor: const Color(0xfff1f5f9),
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: const Text("Dashboard", style: TextStyle(color: Colors.white)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Metrics section: we merge ordersLast30Stream and usersStream and lowStockStream with nested StreamBuilders
            StreamBuilder<QuerySnapshot>(
              stream: ordersLast30Stream,
              builder: (context, ordersSnap30) {
                final ordersDocs30 = ordersSnap30.data?.docs ?? [];
                // compute revenue and orders
                num revenue30 = 0;
                for (final d in ordersDocs30) {
                  final data = d.data() as Map<String, dynamic>;
                  final amt = (data['total'] is num) ? data['total'] as num : num.tryParse('${data['total']}') ?? 0;
                  revenue30 += amt;
                }
                final ordersCount30 = ordersDocs30.length;

                return StreamBuilder<QuerySnapshot>(
                  stream: usersStream,
                  builder: (context, usersSnap) {
                    final usersCount = usersSnap.data?.docs.length ?? 0;
                    return StreamBuilder<QuerySnapshot>(
                      stream: lowStockStream,
                      builder: (context, lowSnap) {
                        final lowCount = lowSnap.data?.docs.length ?? 0;

                        return Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            _metricCard("Revenue (30d)", _currency(revenue30), Icons.attach_money, Colors.amber),
                            _metricCard("Orders (30d)", "$ordersCount30", Icons.shopping_cart, Colors.indigo),
                            _metricCard("Customers", "$usersCount", Icons.people, Colors.green),
                            _metricCard("Low Stock", "$lowCount", Icons.error, Colors.red),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 20),

            // Sales chart + quick actions: chart uses ordersLast7Stream
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: ordersLast7Stream,
                    builder: (context, snap) {
                      final docs = snap.data?.docs ?? [];
                      final daySales = _compute7DaySales(docs);
                      return _salesChart(daySales);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 260,
                  child: _quickActionsWidget(recentOrdersStream),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Recent orders + low stock list
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: recentOrdersStream,
                    builder: (context, snap) {
                      final docs = snap.data?.docs ?? [];
                      return _recentOrdersTable(docs);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 300,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: lowStockStream,
                    builder: (context, snap) {
                      final docs = snap.data?.docs ?? [];
                      final items = docs.map((d) {
                        final data = d.data() as Map<String, dynamic>;
                        return ProductStock(
                          data['name']?.toString() ?? 'Unnamed',
                          data['sku']?.toString() ?? d.id,
                          (data['stock'] is int) ? data['stock'] as int : (int.tryParse('${data['stock']}') ?? 0),
                        );
                      }).toList();
                      return _lowStockCard(items);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================
  // UI helper builders
  // ============================
  Widget _metricCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.black54)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ])),
          Icon(icon, size: 40, color: color),
        ],
      ),
    );
  }

  Widget _salesChart(List<_DaySales> daySales) {
    // small representation that draws the chart according to daySales values
    return Container(
      height: 280,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: CustomPaint(
        painter: _DayChartPainter(daySales),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const SizedBox(height: 8),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: daySales.map((d) => Expanded(child: Center(child: Text(d.label, style: const TextStyle(fontSize: 12, color: Colors.black54))))).toList())
          ],
        ),
      ),
    );
  }

  Widget _quickActionsWidget(Stream<QuerySnapshot> recentOrdersStream) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("Quick Actions", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            // Try to push to catalog route - keep fallback message if not registered
            const catalogRouteName = '/catalog';
            try {
              Navigator.of(context).pushNamed(catalogRouteName);
            } catch (e) {
              _showText('Catalog route not found — register it in main.dart or update this code.');
            }
          },
          child: const Text("Create Product"),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () => _showText('Open refunds view (stub) — implement navigation/API here.'),
          child: const Text("Process Refund"),
        ),
        const SizedBox(height: 12),
        // Export Orders CSV — we read the latest 10 shown in the Recent Orders stream
        StreamBuilder<QuerySnapshot>(
          stream: recentOrdersStream,
          builder: (context, snap) {
            final docs = snap.data?.docs ?? [];
            return ElevatedButton(
              onPressed: docs.isEmpty ? null : () => _copyCSVFromDocs(docs),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("Export Orders CSV"),
            );
          },
        ),
      ]),
    );
  }

  Widget _recentOrdersTable(List<QueryDocumentSnapshot> docs) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("Recent Orders", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        docs.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: Text('No recent orders')),
              )
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 12,
                  headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
                  columns: const [
                    DataColumn(label: Text("Order")),
                    DataColumn(label: Text("Customer")),
                    DataColumn(label: Text("Total")),
                    DataColumn(label: Text("Status")),
                    DataColumn(label: Text("Date")),
                  ],
                  rows: docs.map((d) {
                    final data = d.data() as Map<String, dynamic>;
                    final id = d.id;
                    final customer = (data['customerName'] ?? data['customer'] ?? '').toString();
                    final total = (data['total'] ?? 0).toString();
                    final status = (data['status'] ?? '').toString();
                    final ts = data['createdAt'];
                    final date = ts is Timestamp ? ts.toDate().toIso8601String().split('T').first : (data['date'] ?? '');
                    return DataRow(cells: [
                      DataCell(Text(id)),
                      DataCell(Text(customer)),
                      DataCell(Text('₹$total')),
                      DataCell(Text(status)),
                      DataCell(Text(date)),
                    ]);
                  }).toList(),
                ),
              ),
      ]),
    );
  }

  Widget _lowStockCard(List<ProductStock> items) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("Low Stock Items", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (items.isEmpty)
          const Text("All good — no low stock items", style: TextStyle(color: Colors.black54))
        else
          ...items.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text("SKU: ${p.sku}", style: const TextStyle(color: Colors.black54, fontSize: 12)),
                  ]),
                  Text("${p.stock} left",
                      style: TextStyle(color: p.stock <= 2 ? Colors.red : Colors.orange, fontWeight: FontWeight.bold))
                ]),
              )),
      ]),
    );
  }

  void _showText(String s) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s)));
  }
}

// ==========================
// lightweight models & painters
// ==========================
class ProductStock {
  final String name;
  final String sku;
  final int stock;
  ProductStock(this.name, this.sku, this.stock);
}

class _DaySales {
  final String label;
  final num amount;
  _DaySales(this.label, this.amount);
}

class _DayChartPainter extends CustomPainter {
  final List<_DaySales> days;
  _DayChartPainter(this.days);

  @override
  void paint(Canvas canvas, Size size) {
    if (days.isEmpty) return;
    final paintLine = Paint()
      ..color = Colors.indigo
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final paintGrid = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;

    final maxVal = days.map((d) => d.amount).reduce((a, b) => a > b ? a : b).toDouble();
    final itemCount = days.length;
    final dx = size.width / (itemCount - 1);

    // grid
    for (int i = 0; i < 4; i++) {
      final y = size.height / 4 * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paintGrid);
    }

    // line
    final path = Path();
    for (int i = 0; i < days.length; i++) {
      final x = dx * i;
      final y = size.height - (maxVal == 0 ? 0 : (days[i].amount / maxVal) * size.height);
      if (i == 0) path.moveTo(x, y);
      else path.lineTo(x, y);
    }
    canvas.drawPath(path, paintLine);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
