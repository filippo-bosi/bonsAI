import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  Future<Weather> GetWeatherdata(String place) async {
    try {
      final queryParameters = {
        'key': 'b668eae0f5cc4cd0b0f151420231101',
        'q': place,
      };
      final uri =
          Uri.http('api.weatherapi.com', '/v1/current.json', queryParameters);
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return Weather.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("We cannot gather Weather information");
      }
    } catch (e) {
      rethrow;
    }
  }
}

class Weather {
  final num temperature;
  final num humidity;
  final String condition;

  Weather({
    this.temperature = 0,
    this.humidity = 0,
    this.condition = "Sunny",
  });
  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      temperature: json['current']['temp_c'],
      humidity: json['current']['humidity'],
      condition: json['current']['condition']['text'],
    );
  }
}
