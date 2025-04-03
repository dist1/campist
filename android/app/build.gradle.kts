plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin") // Flutter Gradle Plugin must be applied after Android & Kotlin plugins
}

android {
    namespace = "com.example.campist_flutter"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.campist_flutter"
        minSdk = 23 // ✅ Corrected: Define minSdk directly
        targetSdk = 33 // ✅ Corrected: Define targetSdk directly
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true // ✅ Added inside `defaultConfig`
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug") // ⚠️ Change this for production builds
        }
    }
}

flutter {
    source = "../.."
}