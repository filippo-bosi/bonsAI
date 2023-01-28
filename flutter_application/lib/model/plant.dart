import 'package:flutter/foundation.dart';

@immutable
class Plant {
  Plant({
    required this.commonName,
    required this.comfort,
  });

  Plant.fromJson(Map<String, Object?> json)
      : this(
          commonName: json['CommonName']! as String,
          comfort: json['comfort_level']! as String,
        );

  final String commonName;
  final String comfort;

  Map<String, Object?> toJson() {
    return {
      'CommonName': commonName,
      'comfort_level': comfort,
    };
  }
}
