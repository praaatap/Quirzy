<img width="1080" height="2400" alt="Screenshot_1764487236" src="https://github.com/user-attachments/assets/325e4c4a-c97e-41c0-a849-207c87b35fb9" />
# Quirzy - AI-Powered Quiz App 🚀

[![Flutter](https://img.shields.io/badge/Flutter-3.24-blue.svg)](https://flutter.dev) [![Firebase](https://img.shields.io/badge/Firebase-Firebase-orange.svg)](https://firebase.google.com) [![Google Play](https://img.shields.io/badge/Google_Play-Ready-green.svg)](https://play.google.com/store) [![Dart](https://img.shields.io/badge/Dart-3.5-blue.svg)](https://dart.dev)

**Quirzy** is a modern, AI-powered mobile quiz app that generates personalized quizzes from any topic. Perfect for students, professionals, and lifelong learners. Generate quizzes instantly using Google Gemini AI, track progress, challenge friends, and master any subject!

## ✨ **Key Features**


## Screen Shots
<img width="1080" height="2400" alt="Screenshot_1764487210" src="https://github.com/user-attachments/assets/f70516a5-f62f-4ef8-bfee-344848539de3" />

<img width="1080" height="2400" alt="Screenshot_1764487236" src="https://github.com/user-attachments/assets/23d4cc67-a29a-4390-8ccf-90f305a3754d" />

### 🎯 **AI Quiz Generation**
- Enter any topic → AI generates 5-45 questions instantly
- Customizable: Easy/Medium/Hard difficulty levels
- Adjustable question count (5,10,15,...,45) with slider
- Time limits per question (10-60 seconds)

### 📱 **Smart Quiz Experience**
- Real-time timer with visual progress bar
- Multiple choice, true/false, and fill-in-the-blank questions
- Instant feedback with explanations
- Detailed results with answer review

### 👥 **Social Challenges**
- Send 1v1 quiz challenges to friends
- Real-time push notifications via Firebase Cloud Messaging
- Accept/Reject/Cancel challenges with notifications

### 📊 **Progress Tracking**
- Quiz history with scores and timestamps
- Performance analytics (accuracy, avg time, best score)
- Stats dashboard with charts and trends

### 💰 **Monetization**
- **1 free quiz trial** → Rewarded ads unlock unlimited quizzes
- Google AdMob rewarded interstitial ads (test IDs included)
- Non-intrusive: Users choose to watch ads for rewards

### 🎨 **Modern UI/UX**
- Blue-themed design with minimal animations
- Dark/Light mode support
- Responsive layouts (SafeArea, no overflows)
- Smooth transitions and haptic feedback

### 🔒 **Privacy & Security**
- Full GDPR/CCPA compliant privacy policy (Play Store approved)
- Firebase Authentication (Google Sign-In)
- Encrypted data storage
- No data selling - privacy first
#### 🔐 Privacy Policy: https://quirzy-privacy-policy.xeyenx69.workers.dev/

## 🛠️ **Tech Stack**

```
Frontend: Flutter 3.24 + Dart 3.5
State Management: Riverpod
AI: Google Gemini API (quiz generation)
Auth: Firebase Auth + Google Sign-In
Backend: Node.js + Prisma + PostgreSQL
Database: Firebase Firestore + PostgreSQL
Push Notifications: Firebase Cloud Messaging
Ads: Google AdMob (Rewarded + Interstitial)
Fonts: Google Fonts (Inter, Poppins)
```

## 📱 **Screenshots**

```
[Add your screenshots here]
- Quiz generation screen
- Challenge friends screen  
- Results & stats dashboard
- Settings with customization
- Push notification example
```

## 🚀 **Quick Start (Development)**

### 1. **Clone & Setup**
```bash
git clone https://github.com/yourusername/quirzy.git
cd quirzy
flutter pub get
```

### 2. **Firebase Setup**
```bash
# Add google-services.json to android/app/
flutterfire configure
flutter pub add firebase_core firebase_auth firebase_messaging cloud_firestore
```

### 3. **AdMob Setup**
```bash
# Add your AdMob App ID to android/app/src/main/AndroidManifest.xml
flutter pub add google_mobile_ads
```

### 4. **Run App**
```bash
flutter clean
flutter pub get
flutter run
```

### 5. **Test Ads (Development)**
```dart
// Uses Google's TEST AD UNIT IDs automatically in debug mode
AdService().loadRewardedAd(); // Ready to test!
```

## 🔧 **Project Structure**

```
lib/
├── main.dart                    # App entry point
├── providers/                   # Riverpod state management
│   ├── auth_provider.dart       # Firebase Auth
│   └── quiz_provider.dart       # Quiz state
├── screen/
│   ├── auth/                    # Login/Signup
│   ├── quizPage/                # Quiz screens
│   ├── mainPage/                # Home + tabs
│   └── challenge/               # 1v1 challenges
├── services/
│   ├── api_service.dart         # Backend API calls
│   ├── ad_service.dart          # AdMob integration
│   └── notification_service.dart # FCM push
├── utils/
│   ├── constants.dart           # Colors, API URLs
│   └── theme.dart               # Blue theme
└── models/
    └── quiz_model.dart          # Quiz data models
```

## 🌐 **Backend APIs**

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/quiz/generate` | POST | AI quiz generation |
| `/api/challenges/send` | POST | Send challenge |
| `/api/challenges/my` | GET | My challenges |
| `/api/users/profile` | GET | User stats |
| `/api/notifications` | POST | Send push notification |

## 💳 **Monetization Strategy**

1. **Free Tier**: 1 quiz trial → rewarded ad → unlimited quizzes
2. **Ad Frequency**: 1 ad per 3 quizzes (user choice)
3. **Revenue**: ~$0.02-0.05 per rewarded ad completion
4. **Expected**: 10K downloads → ~$500/month passive income

## 📈 **Play Store Ready** ✅

- ✅ Privacy policy (full compliance) 
- ✅ Data Safety form completed
- ✅ COPPA compliant (13+ only)
- ✅ GDPR/CCPA disclosures
- ✅ App bundle optimized
- **Expected review**: 1-3 days

## 🤝 **Contributing**

1. Fork the repo
2. Create feature branch (`git checkout -b feature/amazing-quiz-types`)
3. Commit changes (`git commit -m 'Add amazing quiz types'`)
4. Push to branch (`git push origin feature/amazing-quiz-types`)
5. Open Pull Request



## 👨‍💻 **Author**

**Pratap**  

## 🎯 **Roadmap (Future Features)**

- [ ] Leaderboards & global rankings
- [ ] Quiz packs & premium templates
- [ ] Offline mode with sync
- [ ] Voice quiz mode
- [ ] AR quiz experience
- [ ] iOS App Store release

---

**⭐ Star this repo if you found it helpful!**

```
Made with ❤️ for students and learners worldwide
Deployed → Google Play Store (Coming Soon!)
```

---

**Deployed with:**
```
Flutter 3.24.3 • channel stable
Dart 3.5.1
Firebase (Production)
Google Gemini AI
AdMob (Monetized)
```

