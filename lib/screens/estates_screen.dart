import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../utils/app_colors.dart';
import '../providers/app_state.dart';
import '../models/models.dart';

class EstatesScreen extends StatefulWidget {
  const EstatesScreen({super.key});

  @override
  State<EstatesScreen> createState() => _EstatesScreenState();
}

class _EstatesScreenState extends State<EstatesScreen> {
  bool _captureMode = false;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  final _unitsController = TextEditingController();
  bool _isCapturing = false;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gated Estates & Complexes'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            if (_captureMode) _buildCaptureForm() else _buildEstatesList(appState),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
            'Gated Estates & Complexes',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryRed,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Capture and manage gated complex locations with GPS precision for accurate property mapping.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _captureMode = !_captureMode;
                  if (!_captureMode) {
                    _clearForm();
                  }
                });
              },
              icon: Icon(_captureMode ? Icons.close : Icons.add),
              label: Text(_captureMode ? 'Cancel' : 'Add New Estate'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaptureForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightYellow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accentYellow, width: 2),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Capture New Gated Estate',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Estate Name',
                hintText: 'e.g., Bryanston Estate',
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter estate name';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Full Address',
                hintText: 'Street, Suburb, City',
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter address';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _latController,
                    decoration: const InputDecoration(
                      labelText: 'Latitude',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _lngController,
                    decoration: const InputDecoration(
                      labelText: 'Longitude',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _unitsController,
              decoration: const InputDecoration(
                labelText: 'Number of Units',
                filled: true,
                fillColor: Colors.white,
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter number of units';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isCapturing ? null : _captureGPSLocation,
              icon: _isCapturing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.my_location),
              label: Text(_isCapturing ? 'Capturing...' : 'Capture GPS Location'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentYellow,
                foregroundColor: AppColors.darkRed,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _saveEstate,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Save Estate'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstatesList(AppState appState) {
    if (appState.gatedEstates.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: appState.gatedEstates.map((estate) {
        return _buildEstateCard(estate, appState);
      }).toList(),
    );
  }

  Widget _buildEstateCard(GatedEstate estate, AppState appState) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        estate.name,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        estate.address,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.location_on,
                  color: AppColors.primaryRed,
                  size: 28,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Latitude:', estate.lat.toStringAsFixed(6)),
            _buildInfoRow('Longitude:', estate.lng.toStringAsFixed(6)),
            _buildInfoRow('Units:', estate.units.toString()),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewOnMap(estate),
                    icon: const Icon(Icons.map),
                    label: const Text('View on Map'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryRed,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _deleteEstate(estate, appState),
                  icon: const Icon(Icons.delete),
                  color: AppColors.error,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(48),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.location_city,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No gated estates captured yet',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Click "Add New Estate" to start mapping complexes',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _captureGPSLocation() async {
    setState(() {
      _isCapturing = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latController.text = position.latitude.toStringAsFixed(6);
        _lngController.text = position.longitude.toStringAsFixed(6);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location captured successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isCapturing = false;
      });
    }
  }

  void _saveEstate() {
    if (_formKey.currentState!.validate()) {
      final appState = Provider.of<AppState>(context, listen: false);
      
      final estate = GatedEstate(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        address: _addressController.text,
        lat: double.parse(_latController.text),
        lng: double.parse(_lngController.text),
        units: int.parse(_unitsController.text),
      );

      appState.addGatedEstate(estate);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Estate saved successfully!'),
          backgroundColor: AppColors.success,
        ),
      );

      setState(() {
        _captureMode = false;
      });
      _clearForm();
    }
  }

  void _clearForm() {
    _nameController.clear();
    _addressController.clear();
    _latController.clear();
    _lngController.clear();
    _unitsController.clear();
  }

  void _viewOnMap(GatedEstate estate) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(estate.name),
        content: Text(
          'Coordinates:\n${estate.lat.toStringAsFixed(6)}, ${estate.lng.toStringAsFixed(6)}\n\n'
          'In a production app, this would open Google Maps or a map view.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _deleteEstate(GatedEstate estate, AppState appState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Estate'),
        content: Text('Are you sure you want to delete ${estate.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              appState.removeGatedEstate(estate.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Estate deleted'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _unitsController.dispose();
    super.dispose();
  }
}
