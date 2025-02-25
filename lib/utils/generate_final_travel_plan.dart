import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/openAI_service.dart';
import '../services/google_places_service.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

void printFullOutput(String output) {
  debugPrint(output, wrapWidth: 5000);
}

Future<List<Map<String, dynamic>>> generateTravelPlan(
  String location,
  PickerDateRange selectedDateRange,
  List<bool> isSelectedInterests,
  List<bool> isSelectedAccommodation,
  double proximityValue,
  {bool useFullPlan = true} 
) async {

  final openAIApiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
  final googleApiKey = dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '';

  final openAIService = OpenAIService(openAIApiKey);
  final googleService = GooglePlacesService(googleApiKey);

  final selectedInterestsText = isSelectedInterests
      .asMap()
      .entries
      .where((entry) => entry.value)
      .map((entry) => [
        'Highlights', 'Hidden Gems', 'Nature', 'Food', 'Beaches', 'Shopping', 'Nightlife', 'History', 'Museums', 
        'Road Trips', 'Adventure', 'Wine', 'Beer', 'Nightclubs', 'Bars', 'Mountains', 'Hiking', 'Diving', 'Snorkeling',
        'Cliff Jumping', 'Concerts', 'Festivals', 'Architecture', 'Sports', 'Basketball', 'Football', 'Baseball',
        'Cycling', 'Golf', 'Tennis', 'Surfing', 'Skiing', 'Snowboarding', 'Climbing', 'National Parks', 'Fishing',
        'Theme Parks', 'Art', 'Science', 'Romantic Spots', 'Famous Landmarks', 'Abandoned Places',
        'Film Locations', 'Untraditional Experiences', 'Local Experiences', 'One Star Experiences'
      ][entry.key])
      .join(", ");

  final selectedAccommodationText = isSelectedAccommodation
      .asMap()
      .entries
      .where((entry) => entry.value)
      .map((entry) => [
        'Cheap', 'Value', 'Expensive', 'Luxury', 'City Center', 'Remote', 'Weird', 'Unique', 'Traditional', 
        'Hotel', 'Hostel', 'Outdoor', 'Quirky', 'Historical', 'Authentic', 'Family Friendly', 'One Star Experience'
      ][entry.key])
      .join(", ");

  final startDate = DateFormat('d. MMMM').format(selectedDateRange.startDate!);
  final endDate = selectedDateRange.endDate != null ? DateFormat('d. MMMM').format(selectedDateRange.endDate!) : startDate;

  final int numDays = selectedDateRange.endDate != null ? selectedDateRange.endDate!.difference(selectedDateRange.startDate!).inDays + 1 : 1;

  String PromptForShortStay = '''
  Generate a detailed JSON travel plan for a trip from $startDate to $endDate in $location. Include 2-3 daily activities within this period. 

  Accommodation Preference: $selectedAccommodationText. Recommend one single accommodation for the entire stay from $startDate to $endDate.

  Focus on: $selectedInterestsText and the most interesting locations when planning the itinerary. Include at least one unique or lesser-known activity that is not typically recommended.

  Make sure the format is, the accommodation recommendation for some period, then activities within this period, next accommodation recommendation for some period, and then activities within this period.

  Ensure all place names, addresses, and descriptions use standard English letters and are clear and concise.
  
  Activities outside the specified location are allowed, but should not exceed $proximityValue km in distance. Use the following JSON format strictly:

  [
    {
      "title": "$location", 
      "description": "provide an introduction of the trip to $location, summarizing the travel plan in 1-2 sentences - follow up with 1-2 practical travel tips, such as transportation advice, seasonal weather considerations, or money-saving tips specific to $location."
    },
    {
      "header": "name of the recommended accommodation",
      "date": "start date (d. MMMM) - end date (d. MMMM)",
      "location": "name of the recommended accommodation, city, country - such that the place to be identified on Google Places.",
      "description": "2-3 sentence description of the accommodation"
    },
    {
      "header": "name of the activity",
      "date": "date, month and specific recommended hour for the activity in the format: (d. MMMM HH:MM)",
      "location": "name of the recommended activity, city, country - such that the place to be identified on Google Places.",
      "description": "2-3 sentence description"
    },
    ...
  ]
  ''';

  String PromptForMediumStay = '''
  Generate a detailed JSON travel plan for a trip from $startDate to $endDate in $location. Include 1-2 daily activities within this period. 

  Accommodation Preference: $selectedAccommodationText. Recommend one single accommodation for the entire stay from $startDate to $endDate.

  Focus on: $selectedInterestsText and the most interesting locations when planning the itinerary. Include at least one unique or lesser-known activity that is not typically recommended.

  Make sure the format is, the accommodation recommendation for some period, then activities within this period, next accommodation recommendation for some period, and then activities within this period.

  Ensure all place names, addresses, and descriptions use standard English letters and are clear and concise. 
  
  Activities outside the specified location are allowed, but should not exceed $proximityValue km in distance. Use the following JSON format strictly:

  [
    {
      "title": "$location", 
      "description": "provide an introduction of the trip to $location, summarizing the travel plan in 1-2 sentences - follow up with 1-2 practical travel tips, such as transportation advice, seasonal weather considerations, or money-saving tips specific to $location."
    },
    {
      "header": "name of the recommended accommodation",
      "date": "start date (d. MMMM) - end date (d. MMMM)",
      "location": "name of the recommended accommodation, city, country - such that the place to be identified on Google Places.",
      "description": "2-3 sentence description of the accommodation"
    },
    {
      "header": "name of the activity",
      "date": "date, month and specific recommended hour for the activity in the format: (d. MMMM HH:MM)",
      "location": "name of the recommended activity, city, country - such that the place to be identified on Google Places.",
      "description": "2-3 sentence description"
    },
    ...
  ]
  ''';

  String PromptForLongStay = '''
  Generate a detailed JSON travel plan for a trip from $startDate to $endDate in $location. Include 0-1 daily activities within this period, in total there should be at least 10 activities and max 15 activities. 

  Accommodation Preference: $selectedAccommodationText. Recommend two accommodations for the entire stay from $startDate to $endDate.

  Focus on: $selectedInterestsText and the most interesting locations when planning the itinerary. Include at least one unique or lesser-known activity that is not typically recommended.

  Make sure the format is, the accommodation recommendation for some period, then activities within this period, next accommodation recommendation for some period, and then activities within this period.

  Ensure all place names, addresses, and descriptions use standard English letters and are clear and concise.
  
  Activities outside the specified location are allowed, but should not exceed $proximityValue km in distance. Use the following JSON format strictly:

  [
    {
      "title": "$location", 
      "description": "provide an introduction of the trip to $location, summarizing the travel plan in 1-2 sentences - follow up with 1-2 practical travel tips, such as transportation advice, seasonal weather considerations, or money-saving tips specific to $location."
    },
    {
      "header": "name of the recommended accommodation",
      "date": "start date (d. MMMM) - end date (d. MMMM)",
      "location": "name of the recommended accommodation, city, country - such that the place to be identified on Google Places.",
      "description": "2-3 sentence description of the accommodation"
    },
    {
      "header": "name of the activity",
      "date": "date, month and specific recommended hour for the activity in the format: (d. MMMM HH:MM)",
      "location": "name of the recommended activity, city, country - such that the place to be identified on Google Places.",
      "description": "2-3 sentence description"
    },
    ...
  ]
  You can recommend activities that are outside the specified location, but the maximum distance we want to travel for an activity is $proximityValue km. Double-check the JSON for any errors before finalizing.
  ''';

  String prompt;
  if (numDays <= 4) {
    prompt = PromptForShortStay;
  } else if (numDays <= 9) {
    prompt = PromptForMediumStay;
  } else {
    prompt = PromptForLongStay;
  }

  Future<List<Map<String, dynamic>>> fetchAndValidateTravelPlan(String prompt) async {
    String previousTravelPlanRaw = '';

    for (int attempt = 1; attempt <= 2; attempt++) {
      try {
        final String travelPlanRaw = await openAIService.generateText(prompt);

        // Clean the JSON output by removing any content before the first `[` and after the last `]`
        final int firstBracketIndex = travelPlanRaw.indexOf('[');
        final int lastBracketIndex = travelPlanRaw.lastIndexOf(']');
        
        if (firstBracketIndex != -1 && lastBracketIndex != -1) {
          String travelPlanJson = travelPlanRaw.substring(firstBracketIndex, lastBracketIndex + 1).trim();
          
          // Print the cleaned JSON output
          printFullOutput("Cleaned JSON output: $travelPlanJson");

          // Additional step to ensure the JSON structure is valid
          final List<dynamic> travelPlans = jsonDecode(travelPlanJson);
          print("Successfully generated travel plan on attempt $attempt");
          return travelPlans.map((plan) => Map<String, dynamic>.from(plan)).toList();
        } else {
          throw Exception('Invalid JSON structure');
        }
      } catch (e) {
        if (attempt == 2) {
          print("Error generating travel plan after 2 attempts: $e");
          rethrow;
        }
        print("Attempt $attempt failed with error: $e. Retrying...");
        prompt = "The JSON structure wasn't correct in the previous attempt. The error was: $e. Here is the previous output: $previousTravelPlanRaw Please correct the JSON structure to ensure proper formatting and syntax.";
        printFullOutput("Retrying with updated prompt: $prompt");
      }
    }
    return [];
  }

  try {
    List<Map<String, dynamic>> travelPlans = await fetchAndValidateTravelPlan(prompt);
    List<Map<String, dynamic>> enrichedPlans = [];

    for (var plan in travelPlans) {
      if (plan.containsKey('title')) { 
        enrichedPlans.add({
          'title': plan['title'],
          'description': plan['description']
        });

        // Conditionally fetch the image for the location only in full plan mode
        if (useFullPlan) {
          try {
            print("Fetching place ID for location: $location");
            final String? locationPlaceId = await googleService.fetchPlaceId(location);
            Map<String, dynamic>? locationDetails;
            if (locationPlaceId != null) {
              locationDetails = await googleService.fetchPlaceDetails(locationPlaceId);
            }
            if (locationDetails != null) {
              enrichedPlans.last['imageUrl'] = locationDetails['photoUrl'];
            }
          } catch (e) {
            print("Error fetching image for location: $location, error: $e");
          }
        }

      } else {
        final String location = plan['location'] ?? '';
        final String header = plan['header'] ?? '';
        final String date = plan['date'] ?? '';
        final String description = plan['description'] ?? '';

        if (useFullPlan) {
          try {
            final String? placeId = await googleService.fetchPlaceId(location);
            Map<String, dynamic>? placeDetails;
            if (placeId != null) {
              placeDetails = await googleService.fetchPlaceDetails(placeId);
            }
            enrichedPlans.add({
              'header': header,
              'date': date,
              'location': location,
              'description': description,
              'imageUrl': placeDetails?['photoUrl'], 
              'address': placeDetails?['address'], 
              'openingHours': placeDetails?['openingHours'], 
              'website': placeDetails?['website'], 
              'rating': placeDetails?['rating'], 
              'userRatingsTotal': placeDetails?['userRatingsTotal'], 
              'priceLevel': placeDetails?['priceLevel'], 
            });
          } catch (e) {
            print("Error fetching place details for location: $location, error: $e");
            enrichedPlans.add({
              'header': header,
              'date': date,
              'location': location,
              'description': description,
            });
          }
        } else {
          enrichedPlans.add({
            'header': header,
            'date': date,
            'location': location,
            'description': description,
          });
        }
      }
    }

    return enrichedPlans;
  } catch (e) {
    print("Error generating travel plan: $e");
    rethrow;
  }
}
