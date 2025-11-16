import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherHelper {
  // Using OpenWeatherMap API (free tier)
  // You can get a free API key from https://openweathermap.org/api
  // For demo purposes, using a placeholder - replace with your API key
  static const String _apiKey =
      'YOUR_API_KEY_HERE'; // Replace with your API key
  static const String _baseUrl =
      'https://api.openweathermap.org/data/2.5/weather';

  /// Get weather for a location
  static Future<Map<String, dynamic>?> getWeather({
    double? latitude,
    double? longitude,
    String? cityName,
  }) async {
    try {
      String url;
      if (latitude != null && longitude != null) {
        url =
            '$_baseUrl?lat=$latitude&lon=$longitude&appid=$_apiKey&units=metric';
      } else if (cityName != null) {
        url = '$_baseUrl?q=$cityName&appid=$_apiKey&units=metric';
      } else {
        return null;
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'temperature': data['main']['temp']?.round(),
          'description': data['weather'][0]['description'],
          'icon': data['weather'][0]['icon'],
          'humidity': data['main']['humidity'],
          'windSpeed': data['wind']['speed'],
          'city': data['name'],
        };
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Get weather icon URL
  static String getWeatherIconUrl(String iconCode) {
    return 'https://openweathermap.org/img/wn/$iconCode@2x.png';
  }
}
