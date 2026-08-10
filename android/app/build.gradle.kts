plugins {
    id("com.android.application")
    // Add the Google services Gradle plugin
    id("com.google.gms.google-services")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.apforestacademy.lms"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.apforestacademy.lms"
        // Firebase requires minSdk 23+; flutter_map also benefits from 23+
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

dependencies {
    // Import the Firebase BoM for consistent Firebase library versions
    implementation(platform("com.google.firebase:firebase-bom:34.17.0"))

    // Firebase Analytics (required by BoM)
    implementation("com.google.firebase:firebase-analytics")

    // Firebase Auth
    implementation("com.google.firebase:firebase-auth")

    // Firestore
    implementation("com.google.firebase:firebase-firestore")

    // Firebase Storage
    implementation("com.google.firebase:firebase-storage")

    // Firebase Cloud Messaging (notifications)
    implementation("com.google.firebase:firebase-messaging")
}

flutter {
    source = "../.."
}
