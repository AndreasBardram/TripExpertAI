import 'dart:convert';
import 'package:http/http.dart' as http;

class GooglePlacesService {
  final String apiKey;

  GooglePlacesService(this.apiKey);

  Future<String?> fetchPlaceId(String locationName) async {
    final String encodedLocationName = Uri.encodeFull(locationName);
    final String url = 'https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=$encodedLocationName&inputtype=textquery&fields=place_id&key=$apiKey';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return data['candidates'].isNotEmpty ? data['candidates'][0]['place_id'] : null;
      } else {
        throw Exception('Failed to fetch place ID: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching place ID: $e');
    }
  }

  Future<Map<String, dynamic>?> fetchPlaceDetails(String placeId) async {
    final String detailsUrl = 'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=name,formatted_address,opening_hours,website,photos,rating,user_ratings_total,price_level&key=$apiKey';
    try {
      final response = await http.get(Uri.parse(detailsUrl));
      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        if (data['result'] != null) {
          final address = data['result']['formatted_address'];
          final openingHours = data['result']['opening_hours']?['weekday_text'];
          final website = data['result']['website'];
          final rating = data['result']['rating'];
          final userRatingsTotal = data['result']['user_ratings_total'];
          final priceLevel = data['result']['price_level'];
          String? photoUrl;
          if (data['result']['photos'] != null && data['result']['photos'].isNotEmpty) {
            final photoReference = data['result']['photos'][0]['photo_reference'];
            const maxWidth = 1600;  
            photoUrl = 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=$maxWidth&photoreference=$photoReference&key=$apiKey';
          }
          return {
            'address': address,
            'openingHours': openingHours,
            'website': website,
            'photoUrl': photoUrl,
            'rating': rating,
            'userRatingsTotal': userRatingsTotal,
            'priceLevel': priceLevel,
          };
        } else {
          throw Exception('No result found');
        }
      } else {
        throw Exception('Failed to fetch place details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching place details: $e');
    }
  }
}
