// ============================================================================
// lib/admin/shipping.dart (Frontend UI for Envia Shipping Integration)
// ============================================================================

import 'package:flutter/material.dart';

// --- Data Models ---

class EnviaQuote {
  final String carrier;
  final String service;
  final double price;
  final int days; // Estimated transit days

  EnviaQuote({required this.carrier, required this.service, required this.price, required this.days});
  
  // Factory to create a Quote object from the Cloud Function response Map
  factory EnviaQuote.fromMap(Map<String, dynamic> map) {
    return EnviaQuote(
      carrier: map['carrier'] ?? 'N/A',
      service: map['service'] ?? 'Standard',
      price: (map['price'] ?? 0.0).toDouble(),
      days: map['days'] ?? 5,
    );
  }
}

// --- Mock API Service (Replaced by actual Cloud Function calls in a real app) ---

// In a real app, this would use 'https' package to call a secured 
// Firebase Cloud Function endpoint that handles the Envia API keys/requests.
class ShippingService {
  // Simulates a call to a Cloud Function (e.g., /api/envia/quote)
  Future<List<EnviaQuote>> getQuotes({
    required String zipFrom,
    required String zipTo,
    required double weight,
    required double length,
    required double width,
    required double height,
  }) async {
    // --- START OF MOCK API LOGIC ---
    // In reality, the Cloud Function would make the actual Envia API call here.
    await Future.delayed(const Duration(seconds: 1)); // Simulate network latency

    if (zipFrom == zipTo) {
      throw Exception('Origin and destination zip codes cannot be the same.');
    }
    
    // Mock response data simulating different carriers/services
    final mockData = [
      {'carrier': 'DHL', 'service': 'Express', 'price': 55.50, 'days': 2},
      {'carrier': 'FedEx', 'service': 'Ground', 'price': 32.75, 'days': 4},
      {'carrier': 'UPS', 'service': 'Saver', 'price': 48.00, 'days': 3},
    ];
    
    // Adjust price based on weight/dimensions for a slightly more realistic mock
    final sizeFactor = (weight + length + width + height) / 10; 

    return mockData.map((map) {
      // Create quotes based on mock data and size factor
      final adjustedPrice = (map['price'] as double) * sizeFactor;
      return EnviaQuote(
        carrier: map['carrier'] as String,
        service: map['service'] as String,
        price: adjustedPrice, 
        days: map['days'] as int,
      );
    }).toList();
    // --- END OF MOCK API LOGIC ---
  }
}


// ----------------------------------------------------------------------------
// --- Main Shipping Page Widget ---
// ----------------------------------------------------------------------------

class ShippingPage extends StatefulWidget {
  const ShippingPage({Key? key}) : super(key: key);

  @override
  State<ShippingPage> createState() => _ShippingPageState();
}

class _ShippingPageState extends State<ShippingPage> {
  final _formKey = GlobalKey<FormState>();
  final _service = ShippingService();

  // --- Form Controllers & State ---
  // You might want to pre-fill 'zipFrom' from a settings/warehouse document
  String _zipFrom = '10001'; 
  String _zipTo = '';
  String _countryFrom = 'US';
  String _countryTo = 'US';

  // Product Dimensions (simplified to single package for this example)
  double? _weight; // kg
  double? _length; // cm
  double? _width; // cm
  double? _height; // cm
  
  // Quote State
  List<EnviaQuote> _quotes = [];
  bool _isLoading = false;
  String? _errorMessage;

  // --- Quote Generation Logic ---

  Future<void> _getShippingQuotes() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
      _quotes = [];
      _errorMessage = null;
    });

    try {
      final quotes = await _service.getQuotes(
        zipFrom: _zipFrom,
        zipTo: _zipTo,
        weight: _weight!,
        length: _length!,
        width: _width!,
        height: _height!,
      );
      
      // Sort by price (lowest first)
      quotes.sort((a, b) => a.price.compareTo(b.price));

      setState(() {
        _quotes = quotes;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to fetch quotes: ${e.toString().split(':').last.trim()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // --- UI Builder ---
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Envia Shipping Quotes'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Quote Input Form (Sidebar/Left)
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Shipping Parameters', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const Divider(),

                        // --- Origin Details ---
                        const SizedBox(height: 10),
                        const Text('Origin (Your Warehouse)', style: TextStyle(fontWeight: FontWeight.bold)),
                        TextFormField(
                          initialValue: _zipFrom,
                          decoration: const InputDecoration(labelText: 'Origin Zip Code*'),
                          onChanged: (val) => _zipFrom = val.trim(),
                          validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
                        ),
                        // You'd add a Country Picker here

                        const SizedBox(height: 20),
                        // --- Destination Details ---
                        const Text('Destination (Customer)', style: TextStyle(fontWeight: FontWeight.bold)),
                        TextFormField(
                          decoration: const InputDecoration(labelText: 'Destination Zip Code*'),
                          onChanged: (val) => _zipTo = val.trim(),
                          validator: (val) => (val == null || val.isEmpty) ? 'Required' : null,
                        ),
                        // You'd add a Country Picker here
                        
                        const SizedBox(height: 20),
                        // --- Package Dimensions ---
                        const Text('Package Dimensions (Single Package)', style: TextStyle(fontWeight: FontWeight.bold)),
                        Row(
                          children: [
                            Flexible(
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'Weight (kg)*'),
                                onSaved: (val) => _weight = double.tryParse(val ?? ''),
                                validator: (val) => (val == null || double.tryParse(val) == null) ? 'Num required' : null,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'Length (cm)*'),
                                onSaved: (val) => _length = double.tryParse(val ?? ''),
                                validator: (val) => (val == null || double.tryParse(val) == null) ? 'Num required' : null,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'Width (cm)*'),
                                onSaved: (val) => _width = double.tryParse(val ?? ''),
                                validator: (val) => (val == null || double.tryParse(val) == null) ? 'Num required' : null,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'Height (cm)*'),
                                onSaved: (val) => _height = double.tryParse(val ?? ''),
                                validator: (val) => (val == null || double.tryParse(val) == null) ? 'Num required' : null,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _getShippingQuotes,
                          icon: _isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.calculate),
                          label: Text(_isLoading ? 'Getting Quotes...' : 'Get Quotes'),
                          style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(45)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 2. Quote Results (Main Area/Right)
          Expanded(
            flex: 3,
            child: Container(
              color: const Color(0xFFF9FAFB), // Use background color from admin.dart
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Available Quotes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const Divider(),
                  
                  if (_isLoading)
                    const Center(child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 10),
                          Text('Fetching rates from Envia...', style: TextStyle(color: Colors.indigo)),
                        ],
                      ),
                    )),

                  if (_errorMessage != null)
                    Card(
                      color: Colors.red[50],
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      ),
                    ),

                  if (!_isLoading && _quotes.isEmpty && _errorMessage == null)
                    const Center(child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('Enter parameters and click "Get Quotes" to see results.'),
                    )),

                  if (_quotes.isNotEmpty)
                    Expanded(
                      child: ListView.builder(
                        itemCount: _quotes.length,
                        itemBuilder: (context, index) {
                          final quote = _quotes[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: index == 0 ? Colors.indigo.shade300 : Colors.grey.shade200, width: index == 0 ? 2 : 1),
                            ),
                            child: ListTile(
                              leading: index == 0 ? const Icon(Icons.star, color: Colors.amber) : const Icon(Icons.local_shipping, color: Colors.blueGrey),
                              title: Text('${quote.carrier} - ${quote.service}', style: TextStyle(fontWeight: FontWeight.bold, color: index == 0 ? Colors.indigo : null)),
                              subtitle: Text('Est. Transit Time: ${quote.days} days'),
                              trailing: Text(
                                '\$${quote.price.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}