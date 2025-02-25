import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import '../screens/home_screen.dart';
import '../screens/saved_travel_plan_screen.dart';
import '../screens/travel_plan_screen.dart';
import '../components/custom_page_route.dart';
import '../components/custom_loading_screen.dart';
import '../screens/settings_screen.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({this.initialIndex = 1, Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;
  bool _isLoading = false;
  String _location = '';
  bool _useFullPlan = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex; // Default to Home screen
  }

  void updateRecommendationAndSwitchTab(List<Map<String, dynamic>> newRecommendations) {
    Navigator.push(
      context,
      NoTransitionPageRoute(
        builder: (context) => AIRecommendationsPage(
          recommendations: newRecommendations,
          onTabTapped: onTabTapped,
          currentIndex: _currentIndex,
          onRefresh: _loadSavedTravelPlans,
          location: _location,
          useFullPlan: _useFullPlan,
        ),
      ),
    );
  }

  void onLoading(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
    });
  }

  void updateLocation(String location) {
    setState(() {
      _location = location;
    });
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _loadSavedTravelPlans() {
    setState(() {});
  }

  void onFullPlanModeChanged(bool isFullPlan) {
    setState(() {
      _useFullPlan = isFullPlan;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(index: _currentIndex, children: _buildChildren()),
          if (_isLoading)
            const Positioned.fill(
              child: CustomLoadingScreen(),
            ),
        ],
      ),
      bottomNavigationBar: _isLoading
          ? const SizedBox.shrink()
          : BottomNavigationBar(
              onTap: onTabTapped,
              currentIndex: _currentIndex,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(FluentIcons.settings_24_regular, size: 25),
                  label: 'Settings',
                ),
                BottomNavigationBarItem(
                  icon: Icon(FluentIcons.home_24_regular, size: 25),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(FluentIcons.save_16_regular, size: 25),
                  label: 'Saved Plan',
                ),
              ],
            ),
    );
  }

  List<Widget> _buildChildren() {
    return [
      const CustomSettingScreen(),
      HomePage(
        onGeneratePlan: updateRecommendationAndSwitchTab,
        onLoading: onLoading,
        onLocationUpdated: updateLocation,
        useFullPlan: _useFullPlan,
        onFullPlanModeChanged: onFullPlanModeChanged,
      ),
      SavedTravelPlanPage(
        onRefresh: _loadSavedTravelPlans,
        location: _location,
      ),
    ];
  }
}
