import 'package:flutter/material.dart';
import 'package:weather_test_flutter/src/screens/weather_screen.dart';

class Routes {
  static final mainRoute = <String, WidgetBuilder>{
    '/home': (context) => WeatherScreen(),
  };
}
