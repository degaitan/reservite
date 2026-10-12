class Restaurant {
  final int id;
  final String name;
  final String address;
  final String city;
  final String phone;
  final String? description;
  final double? rating;
  final int? priceRange;
  final int slotDuration;
  final DateTime? latestReservation;
  final int? pendingRequests;

  const Restaurant({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.phone,
    this.description,
    this.rating,
    this.priceRange,
    required this.slotDuration,
    this.latestReservation,
    this.pendingRequests
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
        id: json['id'],
        name: json['name'],
        address: json['address'],
        city: json['city'],
        phone: json['phone'],
        description: json['description'],
        rating: json['rating'],
        priceRange: json['price_range'],
        slotDuration: json['slot_duration'],
        latestReservation: json['latest_reservation'] == null
            ? null
            : DateTime.parse(json['latest_reservation']),
        pendingRequests: json['pending_requests']);
  }
}