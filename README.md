<p align="center">
    <a href="https://github.com/mazidzomader/Munasabat" target="_blank">
        <img src="https://github.com/mazidzomader/ScrapRepo/blob/main/Munasabat%20Hero%20Banner.png" alt="Munasabat" />
    </a>
</p>

<div align="center">

# Munasabat

### Smart Wedding Planning & Guest Management Platform

*Munasabat* is a Flutter-based wedding planning and guest management application designed to simplify every stage of organizing a wedding. From event planning and guest invitations to QR-based check-in and wedding memories, the platform provides an all-in-one digital solution for hosts, guests, and administrators.

</div>

---

> 📌 Project developed as part of **CSE489: Android App Development** at **BRAC University**, Summer 2026.

---

<div align="center">

<img src="https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white"/>
<img src="https://img.shields.io/badge/Dart-0175C2?logo=dart&logoColor=white"/>
<img src="https://img.shields.io/badge/Firebase-FFCA28?logo=firebase&logoColor=black"/>
<img src="https://img.shields.io/badge/OpenStreetMap-7EBC6F?logo=openstreetmap&logoColor=white"/>
<img src="https://img.shields.io/badge/Riverpod-000000?logo=dart&logoColor=white"/>
<br>
<img src="https://img.shields.io/badge/SSLCommerz%20Payments-00A651?logoColor=white"/>
<img src="https://img.shields.io/badge/QR%20Code-000000"/>
<img src="https://img.shields.io/badge/Push%20Notifications-orange"/>
<img src="https://img.shields.io/badge/Android-Mobile-green"/>

</div>

## How to Run Locally (Developer Setup)

This guide covers how to set up the Munasabat project on your local machine, including setting up your own Firebase backend.

### 1. Prerequisites
- **Flutter SDK** installed (run `flutter doctor` to ensure everything is set up).
- **Firebase CLI** installed (`npm install -g firebase-tools`).
- **FlutterFire CLI** installed (`dart pub global activate flutterfire_cli`).

### 2. Initial Setup
Clone the repository and install all Flutter dependencies:
```bash
git clone <your-repo-url>
cd munasabat
flutter pub get
```

### 3. Firebase Configuration
Since the app relies heavily on Firebase (Auth, Firestore), you need to connect it to your own Firebase project:

1. **Create a Project:** Go to the [Firebase Console](https://console.firebase.google.com/) and create a new project (e.g., `munasabat-dev`).
2. **Enable Authentication:** In the Firebase console, go to **Authentication -> Sign-in method** and enable **Email/Password**.
3. **Enable Firestore:** Go to **Firestore Database** and create a database. Go to the **Rules** tab and paste the following temporary dev rules:
   ```text
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /{document=**} {
         // Temporarily allows anyone logged into the app to read/write data
         allow read, write: if request.auth != null;
       }
     }
   }
   ```
4. **Connect Flutter to Firebase:** Open your terminal in the root of the project and run:
   ```bash
   firebase login
   flutterfire configure
   ```
   Select the Firebase project you just created, and choose the platforms (Android, Web). This will automatically generate the `lib/firebase_options.dart` file and configure `android/app/google-services.json`.

### 4. Android Fingerprints (Required for Auth)
If you are testing on Android, you must provide your SHA-1 and SHA-256 fingerprints to Firebase:
1. Generate the keys by running:
   ```bash
   cd android
   ./gradlew signingReport
   ```
2. Copy the `SHA1` and `SHA-256` from the `debug` keystore.
3. Go back to Firebase Console -> **Project Settings** -> select the Android app at the bottom -> Add Fingerprints.

### 5. Run the App
Once everything is configured, you can launch the app:
```bash
flutter run
```
*(You can select Chrome for web testing, or an Android Emulator/Physical Device).*


## License
<p align="center">
Licensed under the MIT License, Copyright © 2026-present.
</p>
