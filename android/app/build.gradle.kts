import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

fun readAdmobAndroidAppId(): String {
    val propsFile = file("${rootProject.projectDir}/admob_app_ids.properties")
    if (!propsFile.exists()) {
        return "ca-app-pub-3940256099942544~3347511713"
    }
    val props = Properties()
    propsFile.inputStream().use { props.load(it) }
    return props.getProperty("ADMOB_APP_ID_ANDROID")?.trim()
        ?: "ca-app-pub-3940256099942544~3347511713"
}

android {
    namespace = "com.bhaktisadhana.bhakti_sadhana"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.bhaktisadhana.bhakti_sadhana"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["admobAppId"] = readAdmobAndroidAppId()
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
