import 'package:flutter/material.dart';

class NoTransitionPageRoute<T> extends MaterialPageRoute<T> {
  NoTransitionPageRoute({required WidgetBuilder builder, RouteSettings? settings})
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return child; 
  }
}
