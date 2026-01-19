import 'package:flutter/material.dart';

class CustomUpgradeDialog extends StatelessWidget {
  final VoidCallback onSwitchToSimple;
  final VoidCallback? onUpgrade;

  const CustomUpgradeDialog({
    Key? key,
    required this.onSwitchToSimple,
    this.onUpgrade, 
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
          crossAxisAlignment: CrossAxisAlignment.center,
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
                ),
              ),
            ),
            const SizedBox(height: 12), 
            Text(
              "You have reached the daily limit",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
            ),
            const SizedBox(height: 12), 
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0), 
              child: Text(
                "You can only generate 4 travel plans per day with full mode on. You can either upgrade by subscribing or switch on the simple mode!",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      height: 1.5,
                    ),
              ),
            ),
            const SizedBox(height: 12), 
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
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
                        onPressed: onSwitchToSimple,
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
                          'Switch to Simple',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
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
                        onPressed: onUpgrade, // Now shows the CustomSubscriptionInfoDialog
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: onUpgrade != null ? Colors.white : Colors.grey.shade200,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15.0),
                          elevation: 2,
                        ),
                        child: Text(
                          'Upgrade',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontSize: 16,
                                color: onUpgrade != null ? Colors.black : Colors.grey,
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
