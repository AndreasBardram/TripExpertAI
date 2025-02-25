import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'utils/navigation.dart';
import 'screens/introduction_screen.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

const Color primaryColor = Color(0xFFF7F7F7);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/.env");
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _loading = true;
  bool _seenOnboarding = false;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool seenOnboarding = prefs.getBool('seenOnboarding') ?? false;
    if (mounted) {
      setState(() {
        _seenOnboarding = seenOnboarding;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Container(color: primaryColor);
    } else {
      return MaterialApp(
        scaffoldMessengerKey: scaffoldMessengerKey,
        title: 'TripExpert AI',
        theme: _buildThemeData(),
        home: _seenOnboarding ? const MainScreen() : const OnboardingScreen(),
        debugShowCheckedModeBanner: false,
      );
    }
  }

  ThemeData _buildThemeData() {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: primaryColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.black,
      ),
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        onPrimary: Colors.black,
        secondary: primaryColor,
        onSecondary: Colors.black,
        surface: primaryColor,
        onSurface: Colors.black,
        error: Colors.red,
        onError: Colors.white,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
