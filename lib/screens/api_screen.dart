import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../providers/app_state.dart';

class APIScreen extends StatefulWidget {
  const APIScreen({super.key});

  @override
  State<APIScreen> createState() => _APIScreenState();
}

class _APIScreenState extends State<APIScreen> {
  final _formKey = GlobalKey<FormState>();
  final _serverController = TextEditingController();
  final _databaseController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SQL Server Integration'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeader(appState.apiConnected),
            const SizedBox(height: 16),
            appState.apiConnected
                ? _buildConnectedView(appState)
                : _buildConnectionForm(appState),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isConnected) {
    return Container(
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
                Text(
                  'SQL Server Integration',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryRed,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Connect to Knowledge Factory\'s property database for live data access',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.storage,
            size: 48,
            color: isConnected ? AppColors.success : Colors.grey.shade400,
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionForm(AppState appState) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.lightYellow,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.accentYellow, width: 2),
          ),
          child: Row(
            children: [
              const Icon(Icons.info, color: Color(0xFFD97706)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'API Connection Required',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFD97706),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Enter your SQL Server credentials to access live property data, AVM calculations, and enriched datasets.',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF92400E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _serverController,
                decoration: const InputDecoration(
                  labelText: 'Server Address',
                  hintText: 'e.g., sql.knowledgefactory.co.za',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter server address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _databaseController,
                decoration: const InputDecoration(
                  labelText: 'Database Name',
                  hintText: 'e.g., PropertyData',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter database name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter username';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      appState.connectAPI({
                        'server': _serverController.text,
                        'database': _databaseController.text,
                        'username': _usernameController.text,
                        'password': _passwordController.text,
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Successfully connected to database!'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  },
                  child: const Text('Connect to Database'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConnectedView(AppState appState) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFD1FAE5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.success, width: 2),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.success),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Successfully Connected',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Server: ${_serverController.text} | Database: ${_databaseController.text}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF065F46),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildDataTables(),
        const SizedBox(height: 16),
        _buildSampleData(),
        const SizedBox(height: 16),
        _buildAPIEndpoints(),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              appState.disconnectAPI();
              _clearForm();
            },
            child: const Text('Disconnect'),
          ),
        ),
      ],
    );
  }

  Widget _buildDataTables() {
    final tables = [
      'Properties',
      'AVM_Valuations',
      'Market_Trends',
      'Gated_Estates',
      'Sales_History',
    ];

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available Data Tables',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...tables.map((table) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    table,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Query →',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.primaryRed,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildSampleData() {
    return Container(
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryRed,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Text(
              'Sample Property Data (Live from SQL Server)',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Property ID')),
                DataColumn(label: Text('Address')),
                DataColumn(label: Text('AVM Value')),
                DataColumn(label: Text('Last Updated')),
              ],
              rows: [
                DataRow(cells: [
                  const DataCell(Text('PRO-2024-001')),
                  const DataCell(Text('123 Oak Ave, Sandton')),
                  DataCell(Text('R3,450,000',
                      style: GoogleFonts.inter(
                          color: AppColors.primaryRed,
                          fontWeight: FontWeight.bold))),
                  const DataCell(Text('2024-12-10')),
                ]),
                DataRow(cells: [
                  const DataCell(Text('PRO-2024-002')),
                  const DataCell(Text('45 Pine Rd, Bryanston')),
                  DataCell(Text('R5,100,000',
                      style: GoogleFonts.inter(
                          color: AppColors.primaryRed,
                          fontWeight: FontWeight.bold))),
                  const DataCell(Text('2024-12-10')),
                ]),
                DataRow(cells: [
                  const DataCell(Text('PRO-2024-003')),
                  const DataCell(Text('78 Beach Dr, Umhlanga')),
                  DataCell(Text('R2,900,000',
                      style: GoogleFonts.inter(
                          color: AppColors.primaryRed,
                          fontWeight: FontWeight.bold))),
                  const DataCell(Text('2024-12-09')),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAPIEndpoints() {
    final endpoints = [
      {
        'method': 'GET',
        'path': '/api/properties',
        'desc': 'Fetch all properties'
      },
      {
        'method': 'GET',
        'path': '/api/avm/:propertyId',
        'desc': 'Get AVM valuation'
      },
      {'method': 'POST', 'path': '/api/estates', 'desc': 'Create gated estate'},
      {
        'method': 'GET',
        'path': '/api/analytics',
        'desc': 'Market analytics data'
      },
    ];

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'API Endpoints',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryRed,
            ),
          ),
          const SizedBox(height: 12),
          ...endpoints.map((endpoint) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: endpoint['method'] == 'GET'
                          ? Colors.blue.shade100
                          : Colors.green.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      endpoint['method']!,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: endpoint['method'] == 'GET'
                            ? Colors.blue.shade700
                            : Colors.green.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      endpoint['path']!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    endpoint['desc']!,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  void _clearForm() {
    _serverController.clear();
    _databaseController.clear();
    _usernameController.clear();
    _passwordController.clear();
  }

  @override
  void dispose() {
    _serverController.dispose();
    _databaseController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
