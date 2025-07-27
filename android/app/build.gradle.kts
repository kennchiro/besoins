plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.besoins"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.besoins"
        minSdk = flutter.minSdkVersion
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

   buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    buildFeatures {
        compose = false // Ensure Compose is not enabled if not used
        viewBinding = true
    }

    // Force Material 3
    lint {
        abortOnError = false
    }
    packagingOptions {
        resources {
            excludes.add("META-INF/AL2.0") // Corrected syntax
            excludes.add("META-INF/LGPL2.1") // Corrected syntax
        }
    }
    // Add this to force Material 3
    configurations.all {
        resolutionStrategy {
            force("com.google.android.material:material:1.12.0") // Force a recent Material 3 version
        }
    }
}

flutter {
    source = "../.."
}
