import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import '../utils/generate_final_travel_plan.dart';
import '../components/custom_dropdown_card.dart';
import '../components/custom_switch.dart';
import '../components/custom_loading_screen.dart';
import '../components/custom_error_message.dart';
import '../components/custom_upgrade_dialog.dart';
import '../components/custom_purchase_dialog.dart';
import '../utils/handle_payment.dart'; 

class HomePage extends StatefulWidget {
  final Function(List<Map<String, dynamic>>)? onGeneratePlan;
  final ValueChanged<bool> onLoading;
  final ValueChanged<String> onLocationUpdated;
  final ValueChanged<bool> onFullPlanModeChanged;
  final bool useFullPlan;

  const HomePage({
    Key? key,
    this.onGeneratePlan,
    required this.onLoading,
    required this.onLocationUpdated,
    required this.onFullPlanModeChanged,
    required this.useFullPlan,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = false;
  late bool _useFullPlan = widget.useFullPlan;

  List<bool> isSelectedInterests = List.generate(46, (_) => false);
  List<bool> isSelectedAccommodation = List.generate(17, (_) => false);

  PickerDateRange? _selectedDateRange;
  final TextEditingController _locationController = TextEditingController();
  final FocusNode _locationFocusNode = FocusNode();
  String _location = '';
  int? _currentOpenedTileIndex;
  late final Timer _timer = Timer(const Duration(seconds: 0), () {});
  double _sliderValue = 0;
  int _totalSimplePlanCount = 0;
  int _totalFullPlanCount = 0;

  final InAppPurchaseService _inAppPurchaseService = InAppPurchaseService();

  @override
  void initState() {
    super.initState();
    _inAppPurchaseService.initialize();
    _inAppPurchaseService.onFullAccessPurchased = () {
      _showCustomMessage('Full access purchased successfully!');
    };
    _inAppPurchaseService.onRestoredFullAccess = () {
      _showCustomMessage('Full access restored successfully!');
    };
    _inAppPurchaseService.onFullAccessAlreadyActive = () {
      _showCustomMessage('You already have TripExpert Premium!');
    };
    _inAppPurchaseService.onError = (errorMessage) {
      _showCustomMessage(errorMessage);
    };

    _inAppPurchaseService.isFullAccess.addListener(_onFullAccessChanged);

    _locationFocusNode.addListener(_handleFocusChange);
    _resetDailyPlanCounts();
    _loadTotalPlanCounts();
  }

  @override
  void dispose() {
    _locationFocusNode.removeListener(_handleFocusChange);
    _locationFocusNode.dispose();
    _locationController.dispose();
    if (_timer.isActive) {
      _timer.cancel();
    }

    _inAppPurchaseService.dispose();

    super.dispose();
  }

  Future<void> _loadTotalPlanCounts() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _totalSimplePlanCount = prefs.getInt('totalSimplePlanCount') ?? 0;
      _totalFullPlanCount = prefs.getInt('totalFullPlanCount') ?? 0;
    });
  }

  void _resetDailyPlanCounts() async {
    final prefs = await SharedPreferences.getInstance();
    final currentDate = DateTime.now();
    final lastResetDateStr = prefs.getString('lastResetDate');
    final lastResetDate =
        lastResetDateStr != null ? DateTime.parse(lastResetDateStr) : null;

    if (lastResetDate == null || currentDate.difference(lastResetDate).inDays >= 1) {
      await prefs.setInt('planCount', 0);
      await prefs.setInt('simplePlanCount', 0);
      await prefs.setString('lastResetDate', currentDate.toIso8601String());
    }
  }

  void _handleFocusChange() {
    if (!_locationFocusNode.hasFocus) {
      _updateLocation();
    }
  }

  void _updateLocation() {
    setState(() {
      _location = _locationController.text;
    });
    widget.onLocationUpdated(_location);
  }

  void _onDateSelected(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      _selectedDateRange = args.value;
    });
  }

  void _onTileExpanded(int index) {
    setState(() {
      _currentOpenedTileIndex = _currentOpenedTileIndex == index ? null : index;
    });
  }

  void _showCustomMessage(String message) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.hideCurrentSnackBar();
    scaffoldMessenger.showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        content: CustomErrorMessage(message: message),
      ),
    );
  }

  void _showPlanSwitchSnackBar(bool isFullPlan) {
    final message = isFullPlan
        ? "Generate full travel plan enabled"
        : "Generate simple travel plan enabled";
    _showCustomMessage(message);
  }

  void _showUpgradeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return CustomUpgradeDialog(
          onSwitchToSimple: () {
            setState(() {
              _useFullPlan = false;
            });
            widget.onFullPlanModeChanged(false);
            Navigator.pop(context);
            _showPlanSwitchSnackBar(false);
          },
          onUpgrade: () {
            Navigator.pop(context);
            _showPurchaseInfoDialog();
          },
        );
      },
    );
  }

  void _showPurchaseInfoDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return CustomPurchaseInfoDialog(
          onAccept: _initiatePurchase,
          onCancel: () => Navigator.pop(context),
          purchaseTitle: 'TripExpert AI Full Access',
          purchaseText:
              'One time purchase for \$1.99, which unlocks unlimited access to create as many full travel plans as you like.',
          privacyPolicyUrl: 'https://www.freeprivacypolicy.com/live/8f7ff3b3-xxxx-xxxx-xxxx-09aa2xxxxxx',
          termsOfUseUrl: 'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/',
        );
      },
    );
  }

  void _initiatePurchase() async {
    Navigator.pop(context);
    await _inAppPurchaseService.initiatePurchase();
  }

  void _onFullAccessChanged() {
    if (_inAppPurchaseService.isFullAccess.value) {
      setState(() {
        _useFullPlan = true;
      });
      widget.onFullPlanModeChanged(true);
    } else {
      setState(() {
        _useFullPlan = false;
      });
      widget.onFullPlanModeChanged(false);
    }
  }

  void _generateSimpleTravelPlan() async {
    _updateLocation();
    final prefs = await SharedPreferences.getInstance();
    final currentDate = DateTime.now();
    final lastResetDateStr = prefs.getString('lastResetDate');
    final lastResetDate =
        lastResetDateStr != null ? DateTime.parse(lastResetDateStr) : null;

    if (lastResetDate == null || currentDate.difference(lastResetDate).inDays >= 1) {
      await prefs.setInt('planCount', 0);
      await prefs.setInt('simplePlanCount', 0);
      await prefs.setString('lastResetDate', currentDate.toIso8601String());
    }

    int planCount = prefs.getInt('planCount') ?? 0;
    int simplePlanCount = prefs.getInt('simplePlanCount') ?? 0;

    // Use isFullAccess.value instead of fullAccess
    if (_useFullPlan && planCount >= (_inAppPurchaseService.isFullAccess.value ? 100 : 4)) {
      _showUpgradeDialog();
      return;
    }

    if (!_useFullPlan && simplePlanCount >= 100) {
      _showCustomMessage('You have reached the limit of generating 100 simple travel plans today');
      return;
    }

    List<String> missingFields = [];
    if (_selectedDateRange == null) missingFields.add('date');
    if (_location.isEmpty) missingFields.add('location');
    if (_sliderValue == 0) missingFields.add('maximum travel distance');
    if (!isSelectedAccommodation.contains(true)) missingFields.add('accommodation preference');
    if (!isSelectedInterests.contains(true)) missingFields.add('at least one interest');

    if (missingFields.isNotEmpty) {
      _showCustomMessage('Please select: ${missingFields.join(', ')}.');
      return;
    }

    setState(() {
      _isLoading = true;
    });
    widget.onLoading(true);

    try {
      final travelPlans = await generateTravelPlan(
        _location,
        _selectedDateRange!,
        isSelectedInterests,
        isSelectedAccommodation,
        _sliderValue * _sliderValue * 300,
        useFullPlan: _useFullPlan,
      );

      widget.onGeneratePlan?.call(travelPlans);

      if (_useFullPlan) {
        planCount += 1;
        await prefs.setInt('planCount', planCount);
        _totalFullPlanCount += 1;
        await prefs.setInt('totalFullPlanCount', _totalFullPlanCount);
      } else {
        simplePlanCount += 1;
        await prefs.setInt('simplePlanCount', simplePlanCount);
        _totalSimplePlanCount += 1;
        await prefs.setInt('totalSimplePlanCount', _totalSimplePlanCount);
      }

      _resetSelections();
    } catch (e) {
      _showCustomMessage("The service is currently not working, please try again later.");
    } finally {
      if (!mounted) return;
      _timer.cancel();
      setState(() {
        _isLoading = false;
      });
      widget.onLoading(false);
    }
  }

  void _resetSelections() {
    setState(() {
      _selectedDateRange = null;
      _locationController.clear();
      _location = '';
      isSelectedInterests = List.generate(46, (_) => false);
      isSelectedAccommodation = List.generate(17, (_) => false);
      _sliderValue = 0;
    });
  }

  Future<void> _resetPlanCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('planCount', 0);
    await prefs.setInt('simplePlanCount', 0);
    await prefs.setString('lastResetDate', DateTime.now().toIso8601String());
    _showCustomMessage('Plan count reset successfully (for testing purposes)');
  }

  @override
  Widget build(BuildContext context) {
    double proximityValue = (_sliderValue * _sliderValue * 500).round().toDouble();
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            _updateLocation();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            child: _isLoading
                ? const CustomLoadingScreen()
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Welcome To TripExpert AI\n',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24,
                                      ),
                                ),
                                TextSpan(
                                  text: 'your personalized ai travel planner',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 16,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        _buildCard(
                          0,
                          'Select your travel dates',
                          _buildDatePicker(),
                          _selectedDateRange != null,
                        ),
                        _buildCard(
                          1,
                          'Choose the destination',
                          _buildLocationInput(),
                          _location.isNotEmpty,
                        ),
                        _buildCard(
                          2,
                          'Select your interests',
                          _buildInterests(),
                          isSelectedInterests.contains(true),
                        ),
                        _buildCard(
                          3,
                          'Select accommodation preference',
                          _buildAccommodationPreferences(),
                          isSelectedAccommodation.contains(true),
                        ),
                        _buildCard(
                          4,
                          'Maximum travel distance',
                          _buildProximitySlider(proximityValue),
                          _sliderValue > 0,
                        ),
                        _buildGenerateButton(),
                        //_buildResetButton(), 
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(int index, String title, Widget content, bool isSelected) {
    return CustomCard(
      index: index,
      title: title,
      content: content,
      isSelected: isSelected,
      onTileExpanded: _onTileExpanded,
      currentOpenedTileIndex: _currentOpenedTileIndex,
    );
  }

  Widget _buildDatePicker() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 0.0),
      child: SfDateRangePicker(
        onSelectionChanged: _onDateSelected,
        selectionMode: DateRangePickerSelectionMode.range,
        initialSelectedRange: _selectedDateRange,
        todayHighlightColor: Colors.grey,
        backgroundColor: Colors.white,
        selectionTextStyle: const TextStyle(color: Colors.black, fontSize: 14),
        rangeTextStyle: const TextStyle(color: Colors.black, fontSize: 14),
        headerStyle: const DateRangePickerHeaderStyle(
          backgroundColor: Colors.white,
          textStyle: TextStyle(color: Colors.black, fontSize: 14),
        ),
        monthCellStyle: const DateRangePickerMonthCellStyle(
          textStyle: TextStyle(color: Colors.black, fontSize: 14),
          todayTextStyle: TextStyle(color: Colors.black, fontSize: 14),
        ),
        yearCellStyle: const DateRangePickerYearCellStyle(
          textStyle: TextStyle(color: Colors.black, fontSize: 14),
          todayTextStyle: TextStyle(color: Colors.black, fontSize: 14),
        ),
        selectionColor: const Color.fromARGB(255, 200, 200, 200),
        startRangeSelectionColor: const Color.fromARGB(255, 160, 160, 160),
        endRangeSelectionColor: const Color.fromARGB(255, 160, 160, 160),
        rangeSelectionColor: const Color.fromARGB(255, 220, 220, 220),
      ),
    );
  }

  Widget _buildLocationInput() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: TextField(
        controller: _locationController,
        focusNode: _locationFocusNode,
        cursorColor: Colors.black,
        cursorWidth: 1.0,
        decoration: const InputDecoration(
          labelText: 'Location',
          labelStyle: TextStyle(
            color: Color.fromARGB(255, 100, 100, 100),
            fontSize: 14,
          ),
          floatingLabelStyle: TextStyle(
            color: Color.fromARGB(255, 100, 100, 100),
            fontSize: 14,
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Color.fromARGB(255, 180, 180, 180)),
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color.fromARGB(255, 180, 180, 180)),
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color.fromARGB(255, 180, 180, 180)),
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
        ),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14),
      ),
    );
  }

  Widget _buildProximitySlider(double proximityValue) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          Text(
            'Distance: ${proximityValue.round()} KM',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14),
          ),
          SfSlider(
            min: 0,
            max: 1,
            value: _sliderValue,
            stepSize: 0.01,
            enableTooltip: true,
            tooltipTextFormatterCallback: (actualValue, _) {
              return (_sliderValue * _sliderValue * 500).round().toString();
            },
            onChanged: (value) {
              setState(() {
                _sliderValue = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInterests() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Wrap(
        spacing: 4.0,
        runSpacing: -10.0,
        children: List<Widget>.generate(46, (int index) {
          return RawChip(
            label: Text(
              [
                'Highlights',
                'Hidden Gems',
                'Nature',
                'Food',
                'Beaches',
                'Shopping',
                'Nightlife',
                'History',
                'Museums',
                'Road Trips',
                'Adventure',
                'Wine',
                'Beer',
                'Nightclubs',
                'Bars',
                'Mountains',
                'Hiking',
                'Diving',
                'Snorkeling',
                'Cliff Jumping',
                'Concerts',
                'Festivals',
                'Architecture',
                'Sports',
                'Basketball',
                'Football',
                'Baseball',
                'Cycling',
                'Golf',
                'Tennis',
                'Surfing',
                'Skiing',
                'Snowboarding',
                'Climbing',
                'National Parks',
                'Fishing',
                'Theme Parks',
                'Art',
                'Science',
                'Romantic Spots',
                'Famous Landmarks',
                'Abandoned Places',
                'Film Locations',
                'Untraditional Experiences',
                'Local Experiences',
                'One Star Experiences'
              ][index],
              style: const TextStyle(fontSize: 14),
            ),
            selected: isSelectedInterests[index],
            onSelected: (bool selected) {
              setState(() {
                isSelectedInterests[index] = selected;
              });
            },
            selectedColor: const Color.fromARGB(255, 180, 180, 180),
            showCheckmark: false,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
              side: const BorderSide(color: Color.fromARGB(255, 180, 180, 180)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
          );
        }),
      ),
    );
  }

  Widget _buildAccommodationPreferences() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Wrap(
        spacing: 4.0,
        runSpacing: -10.0,
        children: List<Widget>.generate(17, (int index) {
          return RawChip(
            label: Text(
              [
                'Cheap',
                'Value',
                'Expensive',
                'Luxury',
                'City Center',
                'Remote',
                'Weird',
                'Unique',
                'Traditional',
                'Hotel',
                'Hostel',
                'Outdoor',
                'Quirky',
                'Historical',
                'Authentic',
                'Family Friendly',
                'One Star Experience'
              ][index],
              style: const TextStyle(fontSize: 14),
            ),
            selected: isSelectedAccommodation[index],
            onSelected: (bool selected) {
              setState(() {
                isSelectedAccommodation[index] = selected;
              });
            },
            selectedColor: const Color.fromARGB(255, 180, 180, 180),
            showCheckmark: false,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
              side: const BorderSide(color: Color.fromARGB(255, 180, 180, 180)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
          );
        }),
      ),
    );
  }

  Widget _buildGenerateButton() {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Container(
              height: 50,
              margin: const EdgeInsets.only(left: 5.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: ElevatedButton(
                  onPressed: _generateSimpleTravelPlan,
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
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontSize: 16),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 60,
            width: _useFullPlan ? 100 : 110,
            child: CustomSwitchCard(
              value: _useFullPlan,
              onChanged: (bool value) {
                setState(() {
                  _useFullPlan = value;
                });
                widget.onFullPlanModeChanged(value);
                _showPlanSwitchSnackBar(value);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResetButton() {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        height: 50,
        margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15.0),
          child: ElevatedButton(
            onPressed: _resetPlanCount,
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
              'Reset Travel Plan Count',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
