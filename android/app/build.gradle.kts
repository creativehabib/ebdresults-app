import com.android.build.gradle.internal.api.BaseVariantOutputImpl

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.ebdresults.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.ebdresults.app"
        minSdk = flutter.minSdkVersion // অথবা flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        setProperty("archivesBaseName", "ebdresults")
    }

    buildTypes {
        release {
            // এখানে debug signing দেওয়া আছে, রিলিজের জন্য আপনার আসল কী-স্টোর ফাইল ব্যবহার করা উচিত
            signingConfig = signingConfigs.getByName("debug")

            // নিচের এই ৩টি লাইন প্রোগার্ড এরর ঠিক করতে সাহায্য করবে
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }

    applicationVariants.all {
        val variant = this
        if (variant.buildType.name == "release") {
            variant.outputs.forEach { output ->
                val outputImpl = output as BaseVariantOutputImpl
                outputImpl.outputFileName = "ebdresults-release.apk"
            }
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
