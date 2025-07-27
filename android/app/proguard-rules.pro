# Ignore error-prone annotations
-dontwarn com.google.errorprone.annotations.**

# Ignore javax.annotation
-dontwarn javax.annotation.**
-dontwarn javax.annotation.concurrent.**

# Keep classes from Tink (si vous utilisez Tink)
-keep class com.google.crypto.tink.** { *; }
-keep interface com.google.crypto.tink.** { *; }

# Rules for Google HTTP Client and Joda-Time, referenced by Tink
-dontwarn com.google.api.client.http.**
-dontwarn org.joda.time.**
