# Rubber Tree Disease Detection System
## Final Presentation Slides Outline

Use this outline to create your PowerPoint/Google Slides presentation.

---

### Slide 1: Title Slide
- **Project Title:** Rubber Tree Leaf Disease Detection System using Deep Learning
- **Subtitle:** An AI-powered cross-platform mobile application
- **Name:** Your Name / Team Name
- **Institution:** Your University/College string

---

### Slide 2: Problem Statement
- **The Issue:** Rubber trees are highly susceptible to foliar diseases (Anthracnose, Corynespora, Powdery Mildew).
- **The Impact:** Late diagnosis causes severe yield loss and economic damage to local farmers.
- **The Gap:** Manual lab diagnosis is slow, expensive, and unavailable deep in rural fields.

---

### Slide 3: Proposed Solution
- A **Smartphone Application** that instantly diagnoses leaf diseases using the phone camera.
- Powered by a **Convolutional Neural Network (CNN)** for high accuracy.
- Features **TensorFlow Lite integration** for Offline use (no internet required).
- Includes an **Analytics Dashboard** for Officers to track regional outbreaks.

---

### Slide 4: System Architecture
- **Frontend / Client:**
  - Built with **Flutter** (Dart).
  - Clean, split-view interface mapping severity levels to UI colors.
- **Backend API:**
  - Python **Flask** Server acting as the AI Gateway.
- **AI Core Pipeline:**
  - **OpenCV** for dynamic image resizing and RGB normalization.
  - **MobileNetV2** Transfer Learning Model.

---

### Slide 5: Role-Based Access (Multi-user System)
- **1. Farmer Profile:**
  - Quick Camera/Gallery upload.
  - Receives specific, actionable **Treatment & Prevention** instructions.
- **2. Agricultural Officer Profile:**
  - Access to a **Regional Analytics Dashboard**.
  - Animated bar charts showing disease frequency and 14-day tracking.

---

### Slide 6: The AI Model & Training
- **Dataset:** Mendeley Rubber Leaf Dataset V4 (8 Distinct Classes).
- **Optimizations:** Data Augmentation (rotation, zoom, flips) to prevent overfitting.
- **Result Output:** 
  - Achieved **> 94% Validation Accuracy**.
  - Output maps to a Confidence Score (0-100%).

---

### Slide 7: Offline Capabilities & Deployment
- Overcoming rural connectivity issues was a priority.
- The heavy 52MB `.h5` model was **quantized** into a 2.4MB `.tflite` (TensorFlow Lite) format.
- Wrapped into the Flutter application for instant, on-device predictions requiring 0 milliseconds of network ping.

---

### Slide 8: Report Generation Module (Phase 5)
- App users can generate a standardized **A4 PDF Report**.
- Includes the uploaded leaf image, exact AI confidence metrics, and verbatim scientific treatments.
- Leverages OS-level share dialogs so farmers can instantly WhatsApp or Email the report to chemical distributors.

---

### Slide 9: Future Enhancements
- Geolocation tracking (Heatmaps) of scanned diseased crops.
- Multi-lingual UI for regional farmers (e.g., Hindi, Tamil, Malayalam).

---

### Slide 10: Conclusion & Q&A
- By merging Mobile Accessibility with Deep Learning, this system effectively bridges the gap between agricultural lab science and rural crop management.
- **Thank You.**
- **Questions?**
