import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final int index;
  final String title;
  final Widget content;
  final bool isSelected;
  final Function(int) onTileExpanded;
  final int? currentOpenedTileIndex;
  final TextStyle? titleTextStyle;

  const CustomCard({
    Key? key,
    required this.index,
    required this.title,
    required this.content,
    required this.isSelected,
    required this.onTileExpanded,
    required this.currentOpenedTileIndex,
    this.titleTextStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
        child: Column(
          children: [
            GestureDetector(
              onTap: () => onTileExpanded(index),
              child: ListTile(
                title: Text(
                  title,
                  style: titleTextStyle ?? Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 16),
                ),
                trailing: Icon(
                  isSelected
                      ? Icons.check
                      : (currentOpenedTileIndex == index
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down),
                ),
                tileColor: Colors.transparent,
              ),
            ),
            AnimatedCrossFade(
              firstChild: Container(),
              secondChild: content,
              crossFadeState: currentOpenedTileIndex == index
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
    );
  }
}
