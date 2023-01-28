import 'package:flutter/foundation.dart';

@immutable
class Sensor {
  Sensor({
    required this.humidity,
    required this.temperature,
    required this.soil_moisture,
    required this.light_level,
    required this.commonName,
    required this.comfort,
    required this.waterNeeds,
    required this.plantType,
    required this.location,
  });

  Sensor.fromJson(Map<String, Object?> json)
      : this(
          humidity: json['humidity']! as double,
          temperature: json['temperature']! as double,
          soil_moisture: json['soil_moisture']! as double,
          light_level: json['light_level']! as double,
          commonName: json['CommonName']! as String,
          comfort: json['comfort_level']! as String,
          waterNeeds: json['waterNeeds']! as String,
          plantType: json['plantType']! as String,
          location: json['location']! as String,
        );

  final double humidity;
  final double temperature;
  final double soil_moisture;
  final double light_level;
  final String commonName;
  final String comfort;
  final String waterNeeds;
  final String plantType;
  final String location;

  Map<String, Object?> toJson() {
    return {
      'humidity': humidity,
      'temperature': temperature,
      'soil_moisture': soil_moisture,
      'light_level': light_level,
      'CommonName': commonName,
      'comfort_level': comfort,
      'plantType': plantType,
      'waterNeeds': waterNeeds,
      'location': location,
    };
  }
}
