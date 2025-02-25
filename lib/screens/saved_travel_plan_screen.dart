import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'dart:convert';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../models/travel_plan.dart';
import '../utils/navigation.dart';
import '../components/custom_page_route.dart';
import '../utils/pdf_generator.dart';
import '../components/custom_error_message.dart';
import '../main.dart';

class SavedTravelPlanPage extends StatefulWidget {
  final VoidCallback onRefresh;
  final String location;

  const SavedTravelPlanPage({super.key, required this.onRefresh, required this.location});

  @override
  _SavedTravelPlanPageState createState() => _SavedTravelPlanPageState();
}

class _SavedTravelPlanPageState extends State<SavedTravelPlanPage> {
  List<Map<String, dynamic>> savedTravelPlans = [];
  String _location = '';
  bool _useFullPlan = true;

  @override
  void initState() {
    super.initState();
    _location = widget.location;
    _loadSavedTravelPlan();
  }

  Future<void> _loadSavedTravelPlan() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? travelPlanJson = prefs.getString('savedTravelPlan');
    String? savedLocation = prefs.getString('savedLocation');
    bool? savedUseFullPlan = prefs.getBool('useFullPlan');

    setState(() {
      if (travelPlanJson != null) {
        List<dynamic> travelPlanList = jsonDecode(travelPlanJson);
        savedTravelPlans = travelPlanList.cast<Map<String, dynamic>>();
      }
      _location = savedLocation ?? _location;
      _useFullPlan = savedUseFullPlan ?? true;
    });
  }

  Future<void> _launchUrl(String? urlString, {bool isAddress = false}) async {
    if (urlString == null) return;
    Uri url;
    if (isAddress) {
      final query = Uri.encodeComponent(urlString);
      url = Uri.parse('https://maps.apple.com/?q=$query');
    } else {
      url = Uri.parse(urlString);
    }

    final canLaunch = await canLaunchUrl(url);
    if (canLaunch) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      _showErrorSnackBar('Could not launch $urlString');
    }
  }

  void _showErrorSnackBar(String message) {
    final scaffoldMessenger = scaffoldMessengerKey.currentState;

    scaffoldMessenger?.hideCurrentSnackBar();
    scaffoldMessenger?.clearSnackBars();
    scaffoldMessenger?.showSnackBar(
      SnackBar(
        content: CustomErrorMessage(message: message),
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildOpeningHoursWidget(List<String>? openingHours) {
    if (openingHours == null || openingHours.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4.0),
          ...openingHours.map((hour) => Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(hour,
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12)),
              )).toList(),
          const SizedBox(height: 8.0),
        ],
      ),
    );
  }

  Future<void> _saveTravelPlan(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> jsonRecommendations = savedTravelPlans;
    String travelPlanJson = jsonEncode(jsonRecommendations);
    await prefs.setString('savedTravelPlan', travelPlanJson);

    _showErrorSnackBar('Travel plan saved successfully');

    widget.onRefresh();
    Navigator.pushAndRemoveUntil(
      context,
      NoTransitionPageRoute(builder: (context) => const MainScreen(initialIndex: 1)),
      (route) => false,
    );
  }

  void _sendTravelPlan(BuildContext context) async {
    _showErrorSnackBar('Preparing travel plan for sharing');

    try {
      final parsedRecommendations = savedTravelPlans.map((plan) => TravelPlan.fromJson(plan)).toList();
      await PdfGenerator.generateAndSharePdf(parsedRecommendations);
    } catch (e) {
      _showErrorSnackBar('Failed to compile travel plan');
    }
  }

  Widget _buildGenerateNewPlanButton(BuildContext context, {bool isCentered = false}) {
    final button = Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0.3,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              NoTransitionPageRoute(builder: (context) => const MainScreen(initialIndex: 1)),
              (route) => false,
            );
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black,
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            elevation: 2,
          ),
          child: Text(
            'Generate New Travel Plan',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 16),
          ),
        ),
      ),
    );

    return isCentered
        ? Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.85,
              child: button,
            ),
          )
        : Expanded(
            flex: 4,
            child: button,
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: savedTravelPlans.isEmpty
            ? _buildGenerateNewPlanButton(context, isCentered: true)
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: savedTravelPlans.length + 1,
                      itemBuilder: (context, index) {
                        if (index < savedTravelPlans.length) {
                          final plan = TravelPlan.fromJson(savedTravelPlans[index]);

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                            child: Column(
                              children: <Widget>[
                                _buildPlanCard(context, plan, index == 0),
                                if (plan.imageUrl != null)
                                  _buildImageCard(plan.imageUrl!),
                              ],
                            ),
                          );
                        } else {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 6.0),
                            child: Row(
                              children: [
                                _buildGenerateNewPlanButton(context),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    height: 50,
                                    margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.1),
                                          spreadRadius: 0.3,
                                          blurRadius: 2,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(15.0),
                                      child: ElevatedButton(
                                        onPressed: () => _sendTravelPlan(context),
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.black,
                                          backgroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15.0),
                                          ),
                                          padding: const EdgeInsets.symmetric(vertical: 15.0),
                                          elevation: 2,
                                        ),
                                        child: const Icon(FluentIcons.send_32_regular, size: 18.0),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, TravelPlan plan, bool isFirstCard) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 0.3,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (plan.header != null)
                Text(
                  plan.header!,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                ),
              if (plan.title != null)
                ...[
                  Text(
                    plan.title!,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                  ),
                  const SizedBox(height: 4.0),
                ],
              if (plan.date != null && plan.location != null)
                ...[
                  const SizedBox(height: 8.0),
                  Text(
                    "${plan.date} at ${plan.location}",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                          fontSize: 12,
                        ),
                  ),
                  const SizedBox(height: 8.0),
                ],
              if (isFirstCard && _useFullPlan)
                Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        const WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Icon(Icons.push_pin, color: Colors.red, size: 16),
                        ),
                        const WidgetSpan(
                          child: SizedBox(width: 2.0),
                        ),
                        TextSpan(
                          text: plan.description ?? '',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Text(
                  plan.description ?? '',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
                ),
              _buildOpeningHoursWidget(plan.openingHours),
              if (plan.address != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.red, size: 16),
                      const SizedBox(width: 4.0),
                      Expanded(
                        child: RichText(
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: plan.address!,
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 12,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => _launchUrl(plan.address, isAddress: true),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (plan.website != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0, bottom: 4.0),
                  child: Row(
                    children: [
                      const Icon(Icons.public, color: Colors.blue, size: 16),
                      const SizedBox(width: 4.0),
                      Expanded(
                        child: RichText(
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: plan.website!,
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontSize: 12,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => _launchUrl(plan.website),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (plan.rating != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Rating (${plan.userRatingsTotal} reviews): ',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontSize: 12,
                              ),
                        ),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: RatingBarIndicator(
                            rating: plan.rating!,
                            itemBuilder: (context, index) => const Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            itemCount: 5,
                            itemSize: 20.0,
                            direction: Axis.horizontal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (plan.priceLevel != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Average Price Level: ',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 12,
                            ),
                      ),
                      Expanded(
                        child: Row(
                          children: List.generate(
                            5,
                            (index) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 0.0),
                              child: Icon(
                                Icons.attach_money,
                                color: index < plan.priceLevel! ? Colors.green : const Color.fromARGB(255, 135, 135, 135),
                                size: 18.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageCard(String imageUrl) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 0.3,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15.0),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: 325,
          ),
        ),
      ),
    );
  }
}
