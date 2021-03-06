import 'package:bloc/bloc.dart';
import 'package:weather_test_flutter/src/model/weather.dart';
import 'package:meta/meta.dart';

import 'package:weather_test_flutter/src/bloc/weather_event.dart';
import 'package:weather_test_flutter/src/bloc/weather_state.dart';
import 'package:weather_test_flutter/src/repository/weather_repository.dart';
import 'package:weather_test_flutter/src/api/http_exception.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final WeatherRepository weatherRepository;

  WeatherBloc({@required this.weatherRepository})
      : assert(weatherRepository != null);

  @override
  WeatherState get initialState {
    return WeatherEmpty();
  }

  @override
  Stream<WeatherState> mapEventToState(WeatherEvent event) async* {
    if (event is FetchWeather) {
      yield WeatherLoading();
      try {
        final Weather weather = await weatherRepository.getWeather(
            event.cityName,
            latitude: event.latitude,
            longitude: event.longitude);
        yield WeatherLoaded(weather: weather);
      } catch (exception) {
        print(exception);
        if (exception is HTTPException) {
          yield WeatherError(errorCode: exception.code);
        } else {
          yield WeatherError(errorCode: 500);
        }
      }
    }
  }
}
