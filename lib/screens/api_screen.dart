import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/app_colors.dart';
import '../providers/app_state.dart';

class APIScreen extends StatefulWidget {
  const APIScreen({super.key});

  @override
  State<APIScreen> createState() => _APIScreenState();
}

class _APIScreenState extends State<APIScreen> {
  final _searchController = TextEditingController();

  bool _isLoading = false;
  List<Map<String, dynamic>> _properties = [];
  String _errorMessage = '';
  bool _isConnected = false;

  // MockAPI URL - YOUR ACTUAL API
  final String apiUrl =
      'https://694c480ada5ddabf00367cb6.mockapi.io/api/v1/properties';

  @override
  void initState() {
    super.initState();
    _searchController.text = ''; // Start with no filter
  }

  // FETCH MULTIPLE PROPERTIES FROM MOCKAPI
  Future<void> _fetchProperties() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _properties = [];
    });

    try {
      print('🔍 Fetching properties from: $apiUrl');

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      print('📡 Response status: ${response.statusCode}');
      print('📦 Response body length: ${response.body.length}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        print('✅ Loaded ${data.length} properties from API');

        // Map MockAPI data to our property structure
        setState(() {
          _properties = data
              .map((item) => {
                    'id': item['id'].toString(),
                    'address': item['address'] ?? 'Unknown Address',
                    'street': item['street'] ?? '',
                    'city': item['city'] ?? 'Unknown City',
                    'suburb': item['suburb'] ?? '',
                    'province': item['province'] ?? '',
                    'price': item['price'] ?? 0,
                    'bedrooms': item['bedroom'] ??
                        0, // Note: singular 'bedroom' in your API
                    'bathrooms': item['bathroom'] ??
                        0, // Note: singular 'bathroom' in your API
                    'sqm': item['sqm'] ?? 0,
                    'type': item['type'] ?? 'Property',
                    'gated': item['gated'] ?? false,
                    'lat': item['lat'] ?? 0,
                    'long': item['long'] ?? 0,
                  } as Map<String, dynamic>)
              .toList();

          _isLoading = false;
          _isConnected = true;
        });

        // Mark as connected in app state
        final appState = Provider.of<AppState>(context, listen: false);
        appState.connectAPI({
          'server': 'MockAPI',
          'database': 'Property Database',
          'username': 'API User',
          'password': '***',
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '✓ Loaded ${_properties.length} properties from MockAPI!'),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        throw Exception('API returned status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });

      print('❌ Error loading properties: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Failed to load properties: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  // FILTER PROPERTIES BY SEARCH
  List<Map<String, dynamic>> get _filteredProperties {
    if (_searchController.text.isEmpty) {
      return _properties;
    }

    final query = _searchController.text.toLowerCase();
    return _properties.where((property) {
      final address = property['address']?.toString().toLowerCase() ?? '';
      final street = property['street']?.toString().toLowerCase() ?? '';
      final city = property['city']?.toString().toLowerCase() ?? '';
      final suburb = property['suburb']?.toString().toLowerCase() ?? '';
      final type = property['type']?.toString().toLowerCase() ?? '';

      return address.contains(query) ||
          street.contains(query) ||
          city.contains(query) ||
          suburb.contains(query) ||
          type.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Property API'),
        actions: [
          if (_isConnected)
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: _showAPIInfo,
            ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          if (_isConnected) ...[
            _buildSearchBar(),
            _buildResultsHeader(),
          ],
          Expanded(
            child: _isConnected ? _buildPropertyList() : _buildConnectView(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Property API',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryRed,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (_isConnected)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'CONNECTED',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _isConnected
                      ? '${_properties.length} properties loaded'
                      : 'Connect to load property listings',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            _isConnected ? Icons.cloud_done : Icons.cloud_off,
            size: 48,
            color: _isConnected ? AppColors.success : Colors.grey.shade400,
          ),
        ],
      ),
    );
  }

  Widget _buildConnectView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.lightYellow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.accentYellow, width: 2),
            ),
            child: Column(
              children: [
                const Icon(Icons.api, color: Color(0xFFD97706), size: 48),
                const SizedBox(height: 12),
                Text(
                  'Load Property Listings',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFD97706),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Connect to MockAPI to load 50 properties from your database.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF92400E),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (_errorMessage.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _errorMessage,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.red.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _fetchProperties,
              icon: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.cloud_download),
              label: Text(
                _isLoading ? 'Loading Properties...' : 'Load Properties',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildSetupInstructions(),
        ],
      ),
    );
  }

  Widget _buildSetupInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green.shade700),
              const SizedBox(width: 8),
              Text(
                'Ready to Go!',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Your MockAPI is configured at:\n'
            'https://694c480ada5ddabf00367cb6.mockapi.io\n\n'
            'Click "Load Properties" above to see your 50 properties!',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.blue.shade900,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Search by address, street, city, or type...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${_filteredProperties.length} Properties',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          OutlinedButton.icon(
            onPressed: () {
              final appState = Provider.of<AppState>(context, listen: false);
              appState.disconnectAPI();
              setState(() {
                _isConnected = false;
                _properties = [];
                _searchController.clear();
              });
            },
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Reload'),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filteredProperties.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isNotEmpty
                  ? 'No properties match "${_searchController.text}"'
                  : 'No properties found',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            if (_searchController.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() {});
                },
                child: const Text('Clear search'),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredProperties.length,
      itemBuilder: (context, index) {
        final property = _filteredProperties[index];
        return _buildPropertyCard(property);
      },
    );
  }

  Widget _buildPropertyCard(Map<String, dynamic> property) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Property Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: Container(
              height: 180,
              width: double.infinity,
              color: Colors.grey.shade200,
              child: Icon(
                Icons.home,
                size: 64,
                color: Colors.grey.shade400,
              ),
            ),
          ),

          // Property Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        property['address'] ?? 'Unknown Address',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        property['type'] ?? 'Property',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryRed,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (property['suburb'] != null &&
                        property['suburb'].toString().isNotEmpty) ...[
                      Text(
                        '${property['suburb']}, ',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    Text(
                      property['city'] ?? 'Unknown City',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'R${_formatNumber(property['price'] ?? 0)}',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryRed,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildFeature(
                        Icons.bed, '${property['bedrooms'] ?? 0} beds'),
                    const SizedBox(width: 16),
                    _buildFeature(
                        Icons.bathtub, '${property['bathrooms'] ?? 0} baths'),
                    const SizedBox(width: 16),
                    _buildFeature(
                        Icons.square_foot, '${property['sqm'] ?? 0} m²'),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _showPropertyDetails(property),
                    child: const Text('View Details'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeature(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  void _showPropertyDetails(Map<String, dynamic> property) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          property['address'] ?? 'Property Details',
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('ID', property['id']),
              _buildDetailRow('Address', property['address']),
              _buildDetailRow('Street', property['street']),
              _buildDetailRow('Suburb', property['suburb']),
              _buildDetailRow('City', property['city']),
              _buildDetailRow('Province', property['province']),
              _buildDetailRow('Price', 'R${_formatNumber(property['price'])}'),
              _buildDetailRow(
                  'Bedrooms', property['bedrooms']?.toString() ?? 'N/A'),
              _buildDetailRow(
                  'Bathrooms', property['bathrooms']?.toString() ?? 'N/A'),
              _buildDetailRow('Size', '${property['sqm']} m²'),
              _buildDetailRow('Type', property['type']),
              _buildDetailRow(
                  'Gated', property['gated'] == true ? 'Yes' : 'No'),
              _buildDetailRow('Latitude', property['lat']?.toString() ?? 'N/A'),
              _buildDetailRow(
                  'Longitude', property['long']?.toString() ?? 'N/A'),
              const SizedBox(height: 16),
              const Text(
                'Raw Data:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  const JsonEncoder.withIndent('  ').convert(property),
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 10),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value?.toString() ?? 'N/A',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAPIInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('API Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Endpoint:',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 4),
            Text(apiUrl,
                style: const TextStyle(fontSize: 10, fontFamily: 'monospace')),
            const SizedBox(height: 12),
            Text('Total Properties: ${_properties.length}',
                style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Text('Filtered Results: ${_filteredProperties.length}',
                style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Text('Status: Connected ✓',
                style: TextStyle(fontSize: 12, color: Colors.green.shade700)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }

  String _formatNumber(dynamic number) {
    if (number == null) return '0';
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
