@echo off
echo ==============================================
echo 🌿 Rubber Leaf AI - Build and Host Web
echo ==============================================
echo.
echo Building Flutter Web App...
cd mobile_app
call flutter build web
if %ERRORLEVEL% NEQ 0 (
    echo Flutter build failed!
    pause
    exit /B %ERRORLEVEL%
)
echo Build complete.
echo.
echo Starting Flask Server on port 5000 to host everything...
cd ../backend
python app.py
pause
