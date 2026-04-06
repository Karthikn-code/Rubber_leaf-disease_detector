import 'dart:convert';
import 'package:http/http.dart' as http;

enum DiseaseRisk { low, medium, high }

class WeatherData {
  final double temp;
  final double humidity;
  final String condition;
  final DiseaseRisk risk;

  WeatherData({required this.temp, required this.humidity, required this.condition, required this.risk});
}

class WeatherService {
  // Logic based on rubber tree pathology:
  // Phytophthora & Anthracnose thrive in:
  // - High Humidity (>80%)
  // - Warm Temperatures (25-28°C)
  static DiseaseRisk calculateRisk(double temp, double humidity) {
    if (humidity > 80 && temp >= 24 && temp <= 29) return DiseaseRisk.high;
    if (humidity > 70) return DiseaseRisk.medium;
    return DiseaseRisk.low;
  }

  static Future<WeatherData> getMockWeather(double lat, double lon) async {
    // Simulated delay for realistic feel
    await Future.delayed(const Duration(milliseconds: 800));
    
    // We provide realistic weather data for rubber growing regions (e.g., humid tropical)
    // but allow for variation to test the UI.
    const temp = 27.5;
    const humidity = 84.0; 
    
    return WeatherData(
      temp: temp,
      humidity: humidity,
      condition: 'Tropical Humid',
      risk: calculateRisk(temp, humidity),
    );
  }

  // Future implementation for real API:
  // static Future<WeatherData> fetchWeather(double lat, double lon) async {
  //   final apiKey = 'YOUR_API_KEY';
  //   final url = 'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric';
  //   ...
  // }
}
