import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "xtra.budget.manager"
    compileSdk = 36
    ndkVersion = "28.0.13004108"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_21.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "xtra.budget.manager"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 25
        targetSdk = 36
        versionCode = flutter.versionCode.toInt() // Ensure this is an Int
        versionName = flutter.versionName
    }

    signingConfigs {
        // Use create() instead of just the name for Kotlin script
        create("release") {
            // Use getProperty() for properties and assignment (=) for setters
            val storeFileStr = keystoreProperties.getProperty("storeFile")
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
            storeFile = if (storeFileStr != null) rootProject.file(storeFileStr) else null
            storePassword = keystoreProperties.getProperty("storePassword")
        }
    }

    buildTypes {
        // Use getByName() to configure existing build types
        getByName("release") {
            // Use assignment (=) and getByName()
            signingConfig = signingConfigs.getByName("release")
        }
    }

//    buildTypes {
//        getByName("release") {
//            // TODO: Add your own signing config for the release build.
//            // Signing with the debug keys for now, so `flutter run --release` works.
//            signingConfig = signingConfigs.getByName("debug")
//        }
//    }
}

flutter {
    source = "../.."
}
