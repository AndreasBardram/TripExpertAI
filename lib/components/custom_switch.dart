import 'package:flutter/material.dart';

class CustomSwitchCard extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const CustomSwitchCard({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
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
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            child: Center(
              child: Text(
                value ? 'Full' : 'Simple',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
