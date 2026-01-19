class TravelPlan {
  final String? title; 
  final String? header;
  final String? date;
  final String? location;
  final String? description;
  final List<String>? openingHours;
  final String? address;
  final String? website;
  final String? imageUrl;
  final double? rating;
  final int? userRatingsTotal;
  final int? priceLevel;

  TravelPlan({
    this.title, 
    this.header,
    this.date,
    this.location,
    this.description,
    this.openingHours,
    this.address,
    this.website,
    this.imageUrl,
    this.rating,
    this.userRatingsTotal,
    this.priceLevel,
  });

  factory TravelPlan.fromJson(Map<String, dynamic> json) {
    return TravelPlan(
      title: json['title'], 
      header: json['header'],
      date: json['date'],
      location: json['location'],
      description: json['description'],
      openingHours: json['openingHours'] != null ? List<String>.from(json['openingHours']) : null,
      address: json['address'],
      website: json['website'],
      imageUrl: json['imageUrl'],
      rating: json['rating']?.toDouble(),
      userRatingsTotal: json['userRatingsTotal'],
      priceLevel: json['priceLevel'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title, 
      'header': header,
      'date': date,
      'location': location,
      'description': description,
      'openingHours': openingHours,
      'address': address,
      'website': website,
      'imageUrl': imageUrl,
      'rating': rating,
      'userRatingsTotal': userRatingsTotal,
      'priceLevel': priceLevel,
    };
  }
}
