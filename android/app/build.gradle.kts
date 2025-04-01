plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.int_movil"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    // Combina compileOptions en un solo bloque
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true // Habilita desugaring
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.int_movil"
        minSdk = 23
        targetSdk = 34
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug") // Configura la firma aquí si es necesario
        }
    }
}

dependencies {
    implementation("com.google.firebase:firebase-messaging:23.0.0") // Firebase Cloud Messaging
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:1.2.2") // Desugaring
    // Otras dependencias si las tienes
}

flutter {
    source = "../.."
}
