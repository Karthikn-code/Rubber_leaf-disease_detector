# Rubber Leaf Disease Detector 🌱

A comprehensive AI-powered application designed to detect, diagnose, and provide actionable treatments for various diseases affecting rubber tree leaves. It features a modern mobile frontend built with Flutter and a robust backend API powered by Python/Flask, utilizing a customized MobileNetV2 architecture.

## Features ✨
- **On-Device Real-Time Scanning**: Instantly detects diseases over a live camera feed with zero latency using TensorFlow Lite natively on the mobile device.
- **Detailed Pathology Results**: Provides comprehensive insights including symptoms, root causes, localized treatments, preventions, and economic impacts.
- **Multilingual Support**: Fully localized in English, Tamil, Malayalam, Kannada, and Hindi to support rural farmers.
- **Offline Mode**: Ensures operational stability in remote plantation areas with poor internet connectivity.
- **PDF Export Engine**: Generate, share, and print comprehensive diagnostic reports dynamically formatted with localized fonts.
- **Weather Threat Assessment**: Integration with weather APIs to provide early warnings for disease proliferation risks based on temperature and humidity.
- **Analytics Dashboard**: Automatic backend logging to monitor disease trends and outbreak severity.

## Tech Stack 🛠
- **Frontend**: Flutter, Dart, Camera plugins, TFLite Flutter
- **Backend & AI**: Python 3, Flask, TensorFlow, OpenCV, Numpy

## Setup Instructions 🚀

### 1. Mobile App Setup (Flutter)
Ensure you have the Flutter SDK installed.
```bash
cd mobile_app
flutter pub get
flutter build apk # To build for Android
flutter run # To run on your connected device
```

### 2. Backend Setup (Flask / Python)
Ensure you have Python 3.9+ installed and running.
```bash
cd backend
python -m venv venv
# Activate virtual environment (Windows)
.\venv\Scripts\activate
# Install requirements
pip install -r requirements.txt
# Run the server
python app.py
```

# Rubber_leaf-disease_detector