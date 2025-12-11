import 'package:flutter/foundation.dart';
import '../models/models.dart';

class AppState extends ChangeNotifier {
  User? _currentUser;
  String _subscriptionPlan = 'basic';
  List<Property> _properties = [];
  List<GatedEstate> _gatedEstates = [];
  List<Property> _savedProperties = [];
  bool _apiConnected = false;

  // Getters
  User? get currentUser => _currentUser;
  String get subscriptionPlan => _subscriptionPlan;
  List<Property> get properties => _properties;
  List<GatedEstate> get gatedEstates => _gatedEstates;
  List<Property> get savedProperties => _savedProperties;
  bool get apiConnected => _apiConnected;

  AppState() {
    _loadSampleData();
  }

  void _loadSampleData() {
    _properties = [
      Property(
        id: '1',
        address: '123 Oak Avenue, Sandton',
        price: 3500000,
        avm: 3450000,
        bedrooms: 4,
        bathrooms: 3,
        sqm: 350,
        type: 'House',
        gated: true,
        lat: -26.1076,
        lng: 28.0567,
      ),
      Property(
        id: '2',
        address: '45 Pine Road, Bryanston',
        price: 5200000,
        avm: 5100000,
        bedrooms: 5,
        bathrooms: 4,
        sqm: 480,
        type: 'House',
        gated: true,
        lat: -26.0667,
        lng: 28.0167,
      ),
      Property(
        id: '3',
        address: '78 Beach Drive, Umhlanga',
        price: 2800000,
        avm: 2900000,
        bedrooms: 3,
        bathrooms: 2,
        sqm: 220,
        type: 'Apartment',
        gated: true,
        lat: -29.7248,
        lng: 31.0820,
      ),
      Property(
        id: '4',
        address: '12 Mountain View, Constantia',
        price: 8500000,
        avm: 8300000,
        bedrooms: 6,
        bathrooms: 5,
        sqm: 650,
        type: 'Estate',
        gated: true,
        lat: -34.0133,
        lng: 18.4417,
      ),
    ];
  }

  // Authentication
  void login(String email, String password) {
    _currentUser = User(
      id: '1',
      name: 'John Smith',
      email: email,
      plan: _subscriptionPlan,
    );
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  // Subscription
  void updateSubscription(String plan) {
    _subscriptionPlan = plan;
    if (_currentUser != null) {
      _currentUser = User(
        id: _currentUser!.id,
        name: _currentUser!.name,
        email: _currentUser!.email,
        plan: plan,
      );
    }
    notifyListeners();
  }

  // Properties
  void addProperty(Property property) {
    _properties.add(property);
    notifyListeners();
  }

  void saveProperty(Property property) {
    if (!_savedProperties.any((p) => p.id == property.id)) {
      _savedProperties.add(property);
      notifyListeners();
    }
  }

  void unsaveProperty(String propertyId) {
    _savedProperties.removeWhere((p) => p.id == propertyId);
    notifyListeners();
  }

  bool isPropertySaved(String propertyId) {
    return _savedProperties.any((p) => p.id == propertyId);
  }

  // Gated Estates
  void addGatedEstate(GatedEstate estate) {
    _gatedEstates.add(estate);
    notifyListeners();
  }

  void removeGatedEstate(String estateId) {
    _gatedEstates.removeWhere((e) => e.id == estateId);
    notifyListeners();
  }

  // API Connection
  void connectAPI(Map<String, String> connectionDetails) {
    // Simulate API connection
    _apiConnected = true;
    notifyListeners();
  }

  void disconnectAPI() {
    _apiConnected = false;
    notifyListeners();
  }

  // Search
  List<Property> searchProperties({
    String? query,
    double? minPrice,
    double? maxPrice,
    int? minBedrooms,
    String? type,
  }) {
    var filtered = List<Property>.from(_properties);

    if (query != null && query.isNotEmpty) {
      filtered = filtered
          .where((p) => p.address.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    if (minPrice != null) {
      filtered = filtered.where((p) => p.price >= minPrice).toList();
    }

    if (maxPrice != null) {
      filtered = filtered.where((p) => p.price <= maxPrice).toList();
    }

    if (minBedrooms != null) {
      filtered = filtered.where((p) => p.bedrooms >= minBedrooms).toList();
    }

    if (type != null && type.isNotEmpty) {
      filtered = filtered.where((p) => p.type == type).toList();
    }

    return filtered;
  }
}
