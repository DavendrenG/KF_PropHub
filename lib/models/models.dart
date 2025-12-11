class Property {
  final String id;
  final String address;
  final double price;
  final double avm;
  final int bedrooms;
  final int bathrooms;
  final double sqm;
  final String type;
  final bool gated;
  final double lat;
  final double lng;

  Property({
    required this.id,
    required this.address,
    required this.price,
    required this.avm,
    required this.bedrooms,
    required this.bathrooms,
    required this.sqm,
    required this.type,
    required this.gated,
    required this.lat,
    required this.lng,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'].toString(),
      address: json['address'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      avm: (json['avm'] ?? 0).toDouble(),
      bedrooms: json['bedrooms'] ?? 0,
      bathrooms: json['bathrooms'] ?? 0,
      sqm: (json['sqm'] ?? 0).toDouble(),
      type: json['type'] ?? '',
      gated: json['gated'] ?? false,
      lat: (json['lat'] ?? 0).toDouble(),
      lng: (json['lng'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'address': address,
      'price': price,
      'avm': avm,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'sqm': sqm,
      'type': type,
      'gated': gated,
      'lat': lat,
      'lng': lng,
    };
  }
}

class GatedEstate {
  final String id;
  final String name;
  final String address;
  final double lat;
  final double lng;
  final int units;

  GatedEstate({
    required this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    required this.units,
  });

  factory GatedEstate.fromJson(Map<String, dynamic> json) {
    return GatedEstate(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      lat: (json['lat'] ?? 0).toDouble(),
      lng: (json['lng'] ?? 0).toDouble(),
      units: json['units'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'lat': lat,
      'lng': lng,
      'units': units,
    };
  }
}

class User {
  final String id;
  final String name;
  final String email;
  final String plan;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.plan,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      plan: json['plan'] ?? 'basic',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'plan': plan,
    };
  }
}
