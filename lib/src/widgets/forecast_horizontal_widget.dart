import 'package:flutter/material.dart';
import 'package:weather_test_flutter/main.dart';
import 'package:weather_test_flutter/src/model/weather.dart';
import 'package:weather_test_flutter/src/widgets/value_tile.dart';
import 'package:intl/intl.dart';

/// Renders a horizontal scrolling list of weather conditions
/// Used to show forecast
/// Shows DateTime, Weather Condition icon and Temperature
class ForecastHorizontal extends StatelessWidget {
  const ForecastHorizontal({
    Key key,
    @required this.weathers,
  }) : super(key: key);

  final List<Weather> weathers;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: this.weathers.length,
        separatorBuilder: (context, index) => Divider(
              height: 100,
              color: Colors.white,
            ),
        padding: EdgeInsets.only(left: 5, right: 5),
        itemBuilder: (context, index) {
          final item = this.weathers[index];
          return Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Center(
                child: ValueTile(
                  DateFormat('EEEE hh:mm',Locale('es').languageCode).format(
                      DateTime.fromMillisecondsSinceEpoch(item.time * 1000)),
                  '${item.temperature.as(AppStateContainer.of(context).temperatureUnit).round()}°',
                  iconData: item.getIconData(),
                )),
          );
        },
      ),
    );
  }
}
