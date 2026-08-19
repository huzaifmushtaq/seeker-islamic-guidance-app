plugins {
    id("com.android.application")

    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration

    // Flutter Gradle Plugin must be applied after
    // Android and Kotlin plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.seeker.guidance"

    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    // ============================================================
    // JAVA / CORE LIBRARY DESUGARING
    // Required by flutter_local_notifications
    // ============================================================

    compileOptions {
        isCoreLibraryDesugaringEnabled = true

        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    // ============================================================
    // DEFAULT CONFIGURATION
    // ============================================================

    defaultConfig {
        applicationId = "com.seeker.guidance"

        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion

        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // ============================================================
    // BUILD TYPES
    // ============================================================

    buildTypes {
        release {
            // Using debug signing for now so that
            // flutter run --release works during development.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

// ================================================================
// KOTLIN
// ================================================================

kotlin {
    compilerOptions {
        jvmTarget =
            org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

// ================================================================
// FLUTTER
// ================================================================

flutter {
    source = "../.."
}

// ================================================================
// DEPENDENCIES
// ================================================================

dependencies {
    // Required for flutter_local_notifications
    // and Java 8+ API desugaring.
    coreLibraryDesugaring(
        "com.android.tools:desugar_jdk_libs:2.1.4"
    )
}