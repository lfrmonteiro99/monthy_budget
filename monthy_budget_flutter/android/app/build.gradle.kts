import java.util.Base64

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.orcamentomensal.orcamento_mensal"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.orcamentomensal.orcamento_mensal"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Extract ADMOB_APP_ID from --dart-define for AndroidManifest placeholder.
        // dart-defines are passed as a comma-separated, base64-encoded list in
        // the Gradle property "dart-defines".
        val dartDefines: Map<String, String> = (project.findProperty("dart-defines") as? String)
            ?.split(",")
            ?.associate { encoded: String ->
                val decoded = String(Base64.getDecoder().decode(encoded))
                val parts = decoded.split("=", limit = 2)
                parts[0] to (parts.getOrNull(1) ?: "")
            } ?: emptyMap<String, String>()

        val admobAppId = dartDefines["ADMOB_APP_ID"] ?: ""
        manifestPlaceholders["admobAppId"] = admobAppId
    }

    val keystoreFile = rootProject.file("keystore.jks")
    if (keystoreFile.exists()) {
        signingConfigs {
            create("release") {
                storeFile = keystoreFile
                storePassword = System.getenv("KEYSTORE_PASSWORD") ?: ""
                keyAlias = System.getenv("KEY_ALIAS") ?: ""
                keyPassword = System.getenv("KEY_PASSWORD") ?: ""
            }
        }
        buildTypes {
            release {
                signingConfig = signingConfigs.getByName("release")
                isMinifyEnabled = true
                isShrinkResources = true
                proguardFiles(
                    getDefaultProguardFile("proguard-android-optimize.txt"),
                    "proguard-rules.pro"
                )
            }
        }
    } else {
        buildTypes {
            release {
                signingConfig = signingConfigs.getByName("debug")
                isMinifyEnabled = true
                isShrinkResources = true
                proguardFiles(
                    getDefaultProguardFile("proguard-android-optimize.txt"),
                    "proguard-rules.pro"
                )
            }
        }
    }

    applicationVariants.all {
        val variant = this
        variant.outputs
            .map { it as com.android.build.gradle.internal.api.BaseVariantOutputImpl }
            .forEach { output ->
                output.outputFileName = "gestao-mensal-v${variant.versionName}.apk"
            }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
