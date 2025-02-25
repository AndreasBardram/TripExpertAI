import 'package:flutter/material.dart';

class CustomProfileDialog extends StatelessWidget {
  final String subscriptionStatus;
  final int simplePlansCount;
  final int fullPlansCount;

  const CustomProfileDialog({
    Key? key,
    required this.subscriptionStatus,
    required this.simplePlansCount,
    required this.fullPlansCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Container(
                color: Colors.white,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: Image.asset(
                  'assets/pictures/1024x1024_png_app_logo.png',
                  height: 100,
                  width: 100,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Your Profile Stats:",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              "Subscription: $subscriptionStatus",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    height: 1.5,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              "Simple Plans Generated: $simplePlansCount",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    height: 1.5,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              "Full Plans Generated: $fullPlansCount",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    height: 1.5,
                  ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 50,
              margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
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
                    Navigator.of(context).pop();
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
                    'Close',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontSize: 16, color: Colors.black),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
