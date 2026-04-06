# Rubber Leaf Disease Prediction - Setup Guide

This guide explains how to connect and run your newly created M.Tech project components.

## 1. Backend API (Flask)
- Ensure the model `best_model.h5` is in `/backend/model/`.
- To start the server:
  ```bash
  cd backend
  python app.py
  ```
- The server runs on `http://0.0.0.0:5000`.

## 2. Firebase Setup (Crucial for Mobile App)
1. Go to the [Firebase Console](https://console.firebase.google.com/).
2. Create a new project called "RubberLeafProject".
3. Add an **Android app** to your project.
   - Use package name: `com.rubberleaf.mobile_app`
4. Download the `google-services.json` file.
5. Move it to: `mobile_app/android/app/`
6. In Firebase Console, enable:
   - **Authentication**: Email/Password method.
   - **Cloud Firestore**: Start in test mode for now.

## 3. Running the Flutter App
- Connect your phone or start an emulator.
- Run:
  ```bash
  cd mobile_app
  flutter run
  ```

## 4. Troubleshooting
- **API Connection**: If using a real Android phone, change `localhost` or `10.0.2.2` in `lib/services/api_service.dart` to your computer's actual local IP address (e.g., `192.168.1.x`).
- **Permissions**: Ensure your AndroidManifest.xml has `<uses-permission android:name="android.permission.INTERNET" />`.
