plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.synergizglobal.wcrpmis.wcr_pmis_mobile"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.synergizglobal.wcrpmis.wcr_pmis_mobile"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    flavorDimensions += "env"
    productFlavors {
        create("dev") {
            dimension = "env"
            applicationId = "com.synergizglobal.wcrpmis.mobile.dev"
            resValue("string", "app_name", "WCR PMIS Dev")
        }
        create("staging") {
            dimension = "env"
            applicationId = "com.synergizglobal.wcrpmis.mobile.staging"
            resValue("string", "app_name", "WCR PMIS Staging")
        }
        create("prod") {
            dimension = "env"
            applicationId = "com.synergizglobal.wcrpmis.mobile"
            resValue("string", "app_name", "WCR PMIS")
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
