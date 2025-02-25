import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/navigation.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    TextStyle defaultTitleTextStyle = const TextStyle(fontSize: 24, fontWeight: FontWeight.bold);
    TextStyle defaultBodyTextStyle = const TextStyle(fontSize: 16, fontWeight: FontWeight.normal);

    return IntroductionScreen(
      pages: [
        PageViewModel(
          titleWidget: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 25.0, right: 25.0, bottom: 10.0),
            child: Text(
              "Step 1: Give Custom Inputs",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ) ?? defaultTitleTextStyle,
              textAlign: TextAlign.left,
            ),
          ),
          bodyWidget: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Text(
              "To receive your personalized recommendations, provide information about your upcoming travel and preferences during your stay. You can choose to generate either a full travel plan or a simple travel plan with less information.",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                  ) ?? defaultBodyTextStyle,
              textAlign: TextAlign.left,
            ),
          ),
          image: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 75,
                  left: 18,
                  child: Image.asset(
                    'assets/pictures/helt_færdig_intro_billede_1.png',
                    width: 210,
                  ),
                ),
                Positioned(
                  bottom: 35,
                  right: 18,
                  child: Image.asset(
                    'assets/pictures/helt_færdig_intro_billede_2.png',
                    width: 210,
                  ),
                ),
              ],
            ),
          ),
          decoration: const PageDecoration(
            imageFlex: 4,
            bodyFlex: 1,
            contentMargin: EdgeInsets.zero,
            imagePadding: EdgeInsets.zero,
            bodyPadding: EdgeInsets.zero,
            imageAlignment: Alignment.center,
            bodyAlignment: Alignment.topCenter,
            titlePadding: EdgeInsets.zero,
          ),
        ),
        PageViewModel(
          titleWidget: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 25.0, right: 25.0, bottom: 10.0),
            child: Text(
              "Step 2: Receive Your Travel Plan",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ) ?? defaultTitleTextStyle,
              textAlign: TextAlign.left,
            ),
          ),
          bodyWidget: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Text(
              "After your personalized travel plan is generated, you can scroll through it and get information about things like opening hours, adress, website, rating and price level of the recommendations that have been generated.",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                  ) ?? defaultBodyTextStyle,
              textAlign: TextAlign.left,
            ),
          ),
          image: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 95,
                  left: 18,
                  child: Image.asset(
                    'assets/pictures/helt_færdig_intro_billede_3.png',
                    width: 225,
                  ),
                ),
                Positioned(
                  bottom: 65,
                  right: 18,
                  child: Image.asset(
                    'assets/pictures/helt_færdig_intro_billede_4.png',
                    width: 225,
                  ),
                ),
              ],
            ),
          ),
          decoration: const PageDecoration(
            imageFlex: 4,
            bodyFlex: 1,
            contentMargin: EdgeInsets.zero,
            imagePadding: EdgeInsets.zero,
            bodyPadding: EdgeInsets.zero,
            imageAlignment: Alignment.center,
            bodyAlignment: Alignment.topCenter,
            titlePadding: EdgeInsets.zero,
          ),
        ),
        PageViewModel(
          titleWidget: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 25.0, right: 25.0, bottom: 10.0),
            child: Text(
              "Step 3: Save and Send Travel Plan",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ) ?? defaultTitleTextStyle,
              textAlign: TextAlign.left,
            ),
          ),
          bodyWidget: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Text(
              "You can save the plan in the app to revisit later or share it with friends via messenger, text, or your preferred method. If the plan doesn't meet your needs, you can generate a new one with new inputs.",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                  ) ?? defaultBodyTextStyle,
              textAlign: TextAlign.left,
            ),
          ),
          image: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 65,
                  left: 18,
                  child: Image.asset(
                    'assets/pictures/helt_færdig_intro_billede_5.png',
                    width: 200,
                  ),
                ),
                Positioned(
                  bottom: 25,
                  right: 18,
                  child: Image.asset(
                    'assets/pictures/helt_færdig_intro_billede_6.png',
                    width: 200,
                  ),
                ),
              ],
            ),
          ),
          decoration: const PageDecoration(
            imageFlex: 4,
            bodyFlex: 1,
            contentMargin: EdgeInsets.zero,
            imagePadding: EdgeInsets.zero,
            bodyPadding: EdgeInsets.zero,
            imageAlignment: Alignment.center,
            bodyAlignment: Alignment.topCenter,
            titlePadding: EdgeInsets.zero,
          ),
        ),
      ],
      onDone: () => _onIntroEnd(context),
      onSkip: () => _onIntroEnd(context),
      showSkipButton: true,
      skip: const Text(
        "Skip",
        style: TextStyle(color: Colors.black),
      ),
      next: const Text(
        "Next",
        style: TextStyle(color: Colors.black),
      ),
      done: const Text(
        "Done",
        style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
      ),
      dotsDecorator: DotsDecorator(
        size: const Size.square(10.0),
        activeSize: const Size.square(10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        color: const Color.fromARGB(255, 200, 200, 200),
        activeColor: const Color.fromARGB(255, 50, 50, 50),
      ),
    );
  }

  void _onIntroEnd(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }
}
