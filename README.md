# Focus Dot App

## 📌 Description

Focus Dot is a Flutter-based Android app that utilizes real-time face detection to determine if a user is looking at the screen. A small dot in the center of the screen **grows in size** when the user maintains eye contact and **resets** when the user looks away.

This project originally used TensorFlow Lite (`tflite`) but has been optimized to use **Google ML Kit's Face Detection API**, ensuring smoother performance and stability.

---

## 🎯 Use Cases

- **Focus Training** 🧠: Helps users stay attentive by providing real-time feedback.
- **Eye Tracking Studies** 👀: Can be used for research on user attention and engagement.
- **Distraction Detection** ⚠️: Useful for apps that require continuous focus, such as reading apps or learning tools.
- **Gaming & AR Applications** 🎮: Can be extended to interactive experiences requiring eye contact.

---

## ✨ Features

✅ Real-time face detection using **Google ML Kit**\
✅ Uses front camera for detection\
✅ Dynamic dot size based on attention level\
✅ Works without displaying camera feed\
✅ Optimized for performance and stability\
✅ Runs on all Android devices with **SDK 21+**

---

## 🚀 Installation & Setup

### 1️⃣ Clone the Repository

```sh
git clone https://github.com/swapnil-sriv/focus-dot-app.git
cd focus-dot-app
```

### 2️⃣ Install Dependencies

```sh
flutter pub get
```

### 3️⃣ Run the App

```sh
flutter run
```

### 4️⃣ Build APK

```sh
flutter build apk
```

---

## 🔧 Configuration

### **Android Setup**

Ensure that your `android/app/build.gradle` contains the required configurations:

```gradle
android {
    compileSdkVersion 33
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 33
    }
}
```

Also, add **camera permissions** in `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.CAMERA"/>
```

---

## 🛠️ Tech Stack

- **Flutter** (UI framework)
- **Dart** (Programming language)
- **Camera** (`camera` package for capturing frames)
- **Google ML Kit** (`google_mlkit_face_detection` for face tracking)

---

## 📸 Screenshots


![Screenshot 1](https://github.com/swapnil-sriv/focus-dot/blob/main/focus-dot1.png?raw=true)
![Screenshot 2](https://github.com/swapnil-sriv/focus-dot/blob/main/focus-dot2.png?raw=true)



---

## 📜 License

This project is open-source and available under the **MIT License**.

---

## 🤝 Contributing

Want to improve this project? Feel free to fork and submit a pull request! 🙌

---

## 📝 Author

Developed by **Swapnil**\
📧 Contact: [swapnilsriv441@gmail.com](mailto\:swapnilsriv441@gmail.com)\
💼 LinkedIn: [https://www.linkedin.com/in/swapnil-srivastava-b702a9265](https://www.linkedin.com/in/swapnil-srivastava-b702a9265)

