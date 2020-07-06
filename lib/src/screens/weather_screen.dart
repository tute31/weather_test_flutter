import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:weather_test_flutter/main.dart';
import 'package:weather_test_flutter/src/api/weather_api_client.dart';
import 'package:weather_test_flutter/src/bloc/weather_bloc.dart';
import 'package:weather_test_flutter/src/bloc/weather_event.dart';
import 'package:weather_test_flutter/src/bloc/weather_state.dart';
import 'package:weather_test_flutter/src/repository/weather_repository.dart';
import 'package:weather_test_flutter/src/api/api_keys.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_test_flutter/src/widgets/weather_widget.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utils/converters.dart';

class WeatherScreen extends StatefulWidget {
  final WeatherRepository weatherRepository = WeatherRepository(
      weatherApiClient: WeatherApiClient(
          httpClient: http.Client(), apiKey: ApiKey.OPEN_WEATHER_MAP));
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen>
    with TickerProviderStateMixin {
  WeatherBloc _weatherBloc;
  String _cityName = 'Buenos Aires';
  AnimationController _fadeController;
  Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _weatherBloc = WeatherBloc(weatherRepository: widget.weatherRepository);
    _fetchWeatherWithCity();
//    _showLocationDeniedDialog(PermissionHandler());
//    _fetchWeatherWithLocation().catchError((error) {
//
//    });
    _fadeController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: AppStateContainer.of(context).theme.primaryColor,
          elevation: 3,
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                DateFormat('EEEE, d MMMM yyyy', Locale('es').languageCode)
                    .format(DateTime.now()),
                style: TextStyle(
                    color: AppStateContainer.of(context)
                        .theme
                        .accentColor
                        .withAlpha(80),
                    fontSize: 14),
              )
            ],
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.filter_list),
              color: AppStateContainer.of(context).theme.accentColor,
              onPressed: () {
                _settingModalBottomSheet(context);
              },
            )
          ],
        ),
        backgroundColor: Colors.white,
        body: Material(
          child: Container(
            constraints: BoxConstraints.expand(),
            decoration: BoxDecoration(
                color: AppStateContainer.of(context).theme.primaryColor),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: BlocBuilder(
                  bloc: _weatherBloc,
                  builder: (_, WeatherState weatherState) {
                    if (weatherState is WeatherLoaded) {
                      this._cityName = weatherState.weather.cityName;
                      _fadeController.reset();
                      _fadeController.forward();
                      return WeatherWidget(
                        weather: weatherState.weather,
                      );
                    } else if (weatherState is WeatherError ||
                        weatherState is WeatherEmpty) {
                      String errorText =
                          'Se produjo un error al recuperar los datos meteorológicos.';
                      if (weatherState is WeatherError) {
                        if (weatherState.errorCode == 404) {
                          errorText =
                              'Tenemos problemas para buscar el clima para $_cityName';
                        }
                      }
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.error_outline,
                            color: Colors.redAccent,
                            size: 24,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            errorText,
                            style: TextStyle(
                                color: AppStateContainer.of(context)
                                    .theme
                                    .accentColor),
                          ),
                          FlatButton(
                            child: Text(
                              "Intenta de Nuevo",
                              style: TextStyle(
                                  color: AppStateContainer.of(context)
                                      .theme
                                      .accentColor),
                            ),
                            onPressed: _fetchWeatherWithCity,
                          )
                        ],
                      );
                    } else if (weatherState is WeatherLoading) {
                      return Center(
                        child: CircularProgressIndicator(
                          backgroundColor:
                              AppStateContainer.of(context).theme.primaryColor,
                        ),
                      );
                    }
                  }),
            ),
          ),
        ));
  }

  _fetchWeatherWithCity() {
    _weatherBloc.dispatch(FetchWeather(cityName: _cityName));
  }

  _fetchWeatherWithLocation() async {
    var permissionHandler = PermissionHandler();
    var permissionResult = await permissionHandler
        .requestPermissions([PermissionGroup.locationWhenInUse]);

    switch (permissionResult[PermissionGroup.locationWhenInUse]) {
      case PermissionStatus.denied:
      case PermissionStatus.unknown:
        print('Permiso de ubicación denegado');
        _showLocationDeniedDialog(permissionHandler);
        throw Error();
    }

    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
    _weatherBloc.dispatch(FetchWeather(
        longitude: position.longitude, latitude: position.latitude));
  }

  void _showLocationDeniedDialog(PermissionHandler permissionHandler) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text('La ubicación está deshabilitada',
                style: TextStyle(color: Colors.black)),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  'Ok!',
                  style: TextStyle(color: Colors.teal, fontSize: 16),
                ),
                onPressed: () {
                  permissionHandler.openAppSettings();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  //bottomSheet widget
  void _settingModalBottomSheet(context) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(35.0)),
        ),
        backgroundColor: Colors.grey[850],
        context: context,
        builder: (BuildContext bc) {
          return Container(
            height: 300,
            child: new Wrap(
              spacing: 20.0,
              runAlignment: WrapAlignment.spaceAround,
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                Text("Unidades"),
                Row(
                  children: <Widget>[
                    RaisedButton(
                      color: AppStateContainer.of(context).theme.accentColor,
                      child: Text("Celsius",
                          style: TextStyle(
                              color: AppStateContainer.of(context)
                                  .theme
                                  .primaryColor)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(35.0)),
                      ),
                      onPressed: () {
                        AppStateContainer.of(context).updateTemperatureUnit(
                            TemperatureUnit
                                .values[TemperatureUnit.celsius.index]);
                      },
                    ),
                    RaisedButton(
                      color: AppStateContainer.of(context).theme.accentColor,
                      child: Text(
                        "Fahrenheit",
                        style: TextStyle(
                            color: AppStateContainer.of(context)
                                .theme
                                .primaryColor),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(35.0)),
                      ),
                      onPressed: () {
                        AppStateContainer.of(context).updateTemperatureUnit(
                            TemperatureUnit
                                .values[TemperatureUnit.fahrenheit.index]);
                      },
                    ),
                    RaisedButton(
                      color: AppStateContainer.of(context).theme.accentColor,
                      child: Text("Kelvin",
                          style: TextStyle(
                              color: AppStateContainer.of(context)
                                  .theme
                                  .primaryColor)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(35.0)),
                      ),
                      onPressed: () {
                        AppStateContainer.of(context).updateTemperatureUnit(
                            TemperatureUnit
                                .values[TemperatureUnit.kelvin.index]);
                      },
                    ),
                  ],
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                ),
                Text("Ciudades"),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: TextField(
                    autofocus: false,
                    onChanged: (text) {
                      _cityName = text;
                    },
                    decoration: InputDecoration(
                        hintText: 'Ciudad',
                        hintStyle: TextStyle(
                            color: AppStateContainer.of(context)
                                .theme
                                .accentColor),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            _fetchWeatherWithLocation().catchError((error) {
                              _fetchWeatherWithCity();
                            });
                            Navigator.of(context).pop();
                          },
                          child: Icon(
                            Icons.location_on,
                            color:
                                AppStateContainer.of(context).theme.accentColor,
                            size: 16,
                          ),
                        )),
                    style: TextStyle(
                        color: AppStateContainer.of(context).theme.accentColor),
                    cursorColor:
                        AppStateContainer.of(context).theme.accentColor,
                  ),
                ),
                RaisedButton(
                    color: AppStateContainer.of(context).theme.accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(35.0)),
                    ),
                    onPressed: () {
                      _fetchWeatherWithCity();
                      Navigator.of(context).pop();
                    },
                    child: Text("Buscar",
                        style: TextStyle(
                            color: AppStateContainer.of(context)
                                .theme
                                .primaryColor)))
              ],
            ),
          );
        });
  }
}
