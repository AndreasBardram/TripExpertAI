import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../components/custom_error_message.dart';
import '../components/custom_profile_dialog.dart';
import '../components/custom_purchase_dialog.dart';
import '../utils/handle_payment.dart';

class CustomSettingScreen extends StatefulWidget {
  const CustomSettingScreen({Key? key}) : super(key: key);

  @override
  _CustomSettingScreenState createState() => _CustomSettingScreenState();
}

class _CustomSettingScreenState extends State<CustomSettingScreen> {
  final InAppPurchaseService _inAppPurchaseService = InAppPurchaseService();
  String accessStatus = 'Free Version';
  int totalSimplePlansCount = 0;
  int totalFullPlansCount = 0;

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

    _inAppPurchaseService.isFullAccess.addListener(() {
      setState(() {
        accessStatus = _inAppPurchaseService.isFullAccess.value
            ? 'Premium Version'
            : 'Free Version';
      });
    });

    _fetchProfileData();
  }

  @override
  void dispose() {
    _inAppPurchaseService.dispose();
    super.dispose();
  }

  Future<void> _fetchProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isPremium = _inAppPurchaseService.isFullAccess.value;
    setState(() {
      accessStatus = isPremium ? 'Premium Version' : 'Free Version';
      totalSimplePlansCount = prefs.getInt('totalSimplePlanCount') ?? 0;
      totalFullPlansCount = prefs.getInt('totalFullPlanCount') ?? 0;
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

  void _showProfileDialog() async {
    await _fetchProfileData();
    showDialog(
      context: context,
      builder: (_) => CustomProfileDialog(
        subscriptionStatus: accessStatus,
        simplePlansCount: totalSimplePlansCount,
        fullPlansCount: totalFullPlansCount,
      ),
    );
  }

  void _showPurchaseDialog() {
    showDialog(
      context: context,
      builder: (_) => CustomPurchaseInfoDialog(
        onAccept: () async {
          Navigator.pop(context);
          await _inAppPurchaseService.initiatePurchase();
        },
        onCancel: () => Navigator.pop(context),
        purchaseTitle: 'TripExpert AI Full Access',
        purchaseText:
            'One time purchase for \$1.99, which unlocks unlimited access to full travel plans.',
        privacyPolicyUrl: 'https://www.freeprivacypolicy.com/live/xxxxxx',
        termsOfUseUrl:
            'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/',
      ),
    );
  }

  Future<void> _openPrivacyPolicy() async {
    const url = 'https://www.freeprivacypolicy.com/live/xxxxxx';
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      _showCustomMessage('Could not launch Privacy Policy URL');
    }
  }

  Future<void> _openTermsOfUse() async {
    const url =
        'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/';
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      _showCustomMessage('Could not launch Terms of Use URL');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7F7),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildButton(label: 'Your Profile', onPressed: _showProfileDialog),
            const SizedBox(height: 4),
            _buildButton(
              label: 'Privacy Policy',
              onPressed: _openPrivacyPolicy,
            ),
            const SizedBox(height: 4),
            _buildButton(
              label: 'Terms of Use',
              onPressed: _openTermsOfUse,
            ),
            const SizedBox(height: 4),
            _buildButton(
              label: 'Restore Purchase',
              onPressed: () => _inAppPurchaseService.restorePurchases(),
            ),
            const SizedBox(height: 4),
            _buildButton(
              label: 'Upgrade to Premium',
              onPressed: _showPurchaseDialog,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black,
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            padding: const EdgeInsets.symmetric(vertical: 15),
            elevation: 2,
          ),
          child: Text(
            label,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontSize: 16, color: Colors.black),
          ),
        ),
      ),
    );
  }
}
