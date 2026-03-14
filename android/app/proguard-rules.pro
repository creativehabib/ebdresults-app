# Jackson library rules
-keep class com.fasterxml.jackson.** { *; }
-dontwarn com.fasterxml.jackson.**

# OpenTelemetry rules
-keep class io.opentelemetry.** { *; }
-dontwarn io.opentelemetry.**

# Google AutoValue
-keep class com.google.auto.value.** { *; }
-dontwarn com.google.auto.value.**