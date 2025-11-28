plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.creator.base_flutter"
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
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.creator.base_flutter"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // Ensure common ABIs are packaged so native libs like libibmpv.so are available
        //ndk {
        //    // include common ABIs; adjust as needed for your target devices
        //    abiFilters += listOf("armeabi-v7a", "arm64-v8a", "x86_64")
        //}
    }
    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
    // Ensure native libraries are preserved when packaging (helps with some AGP/Flutter integrations)
    //packagingOptions {
    //    jniLibs {
    //        // Use legacy packaging to avoid unexpected stripping of .so in some build pipelines
    //        useLegacyPackaging = true
    //    }
    //    // If multiple copies exist, prefer the first found for these libs
    //    pickFirst("**/libibmpv.so")
    //    pickFirst("**/libmpv.so")
    //}
}

flutter {
    source = "../.."
}
