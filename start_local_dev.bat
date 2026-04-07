@echo off
echo ==============================================
echo 🌿 Rubber Leaf AI - Local Development Starter
echo ==============================================
echo.
echo Starting Flask Backend on port 5000...
cd backend
start /B python app.py
echo Backend started in background.
echo.
echo Launching Flutter Windows App...
cd ../mobile_app
flutter run -d windows
echo.
echo Flutter App closed. 
echo Stopping backend server...
taskkill /F /IM python.exe /T
echo Done!
pause
