android {
    namespace = "com.example.flutter_admin_app"
    compileSdk = 35 // Perbarui ke versi 35

    defaultConfig {
        applicationId = "com.example.flutter_admin_app"
        minSdk = 21
        targetSdk = 35 // Perbarui ke versi 35
        versionCode = 1
        versionName = "1.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}