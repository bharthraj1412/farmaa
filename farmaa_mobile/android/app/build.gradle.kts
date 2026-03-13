plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // Google services plugin — reads google-services.json
    id("com.google.gms.google-services")
}

android {
    namespace = "farmaa.app"
    compileSdk = 36
    ndkVersion = "29.0.14206865"

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }
    defaultConfig {
        // Must match the package_name in google-services.json
        applicationId = "farmaa.app"
        // Firebase & flutter_local_notifications require minSdk 23+
        minSdk = flutter.minSdkVersion
        targetSdk = 36
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

flutter {
    source = "../.."
}

dependencies {
    // Core library desugaring (required by flutter_local_notifications)
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

    // Firebase BoM — manages all Firebase SDK versions automatically
    implementation(platform("com.google.firebase:firebase-bom:34.9.0"))

    // Firebase Analytics (required)
    implementation("com.google.firebase:firebase-analytics")

    // Firebase Cloud Messaging (push notifications)
    implementation("com.google.firebase:firebase-messaging")
}
