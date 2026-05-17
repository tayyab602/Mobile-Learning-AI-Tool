# Dev Assistant Flutter Mobile App

## Project Structure
```
dev_assistant_app/
├── lib/
│   ├── main.dart
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── resource_list_screen.dart
│   │   ├── resource_detail_screen.dart
│   │   └── chatbot_screen.dart
│   ├── services/
│   │   └── api_service.dart
│   ├── models/
│   │   ├── resource.dart
│   │   └── chat_response.dart
│   └── widgets/
│       ├── loading_widget.dart
│       ├── error_widget.dart
│       └── resource_card.dart
├── pubspec.yaml
└── README.md
```

## Setup Instructions

### 1. Create Flutter Project
```bash
flutter create dev_assistant_app
cd dev_assistant_app
```

### 2. Add Dependencies
Edit `pubspec.yaml` and add:
```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  intl: ^0.19.0
  url_launcher: ^6.1.0
```

Then run:
```bash
flutter pub get
```

### 3. Update Android Manifest
Open `android/app/src/main/AndroidManifest.xml` and add internet permission:
```xml
<uses-permission android:name="android.permission.INTERNET" />
```

### 4. Run App
```bash
flutter run
```

## Backend API Configuration

**For Android Emulator:**
```dart
static const String baseUrl = "http://10.0.2.2:3000";
```

**For Real Device on Same Wi-Fi:**
```dart
static const String baseUrl = "http://192.168.1.10:3000"; // Use your PC's IP
```

## Features

✅ Home Screen with category navigation  
✅ Resource List with filtering  
✅ Resource Detail with multimedia links  
✅ AI Chatbot Integration  
✅ Download PDF/Word Documents  
✅ View Images  
✅ Loading & Error States  
✅ Responsive UI  

## Testing

1. Start backend: `npm run dev` (in backend folder)
2. Run Flutter app: `flutter run`
3. Test each screen
4. Ask chatbot questions
5. Download resources

## Troubleshooting

- **Can't connect to backend**: Check `baseUrl` in `api_service.dart`
- **CORS error**: Ensure backend has `cors()` middleware enabled
- **No internet**: Add internet permission to AndroidManifest.xml
