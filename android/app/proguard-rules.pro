# Keep all Awesome Notifications classes
-keep class me.carda.** { *; }

# Keep all com.google
-keep class com.google.**  { *; }

# Preserve annotations and metadata
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes RuntimeVisibleAnnotations


# Please add these rules to your existing keep rules in order to suppress warnings.
# This is generated automatically by the Android Gradle plugin.
-dontwarn com.google.j2objc.annotations.RetainedWith
-dontwarn com.google.j2objc.annotations.ReflectionSupport$Level
-dontwarn com.google.j2objc.annotations.ReflectionSupport
-dontwarn com.google.j2objc.annotations.Weak
-dontwarn java.lang.reflect.AnnotatedType

-dontwarn com.google.android.gms.common.annotation.NoNullnessRewrite
-dontwarn com.google.api.client.http.GenericUrl
-dontwarn com.google.api.client.http.HttpHeaders
-dontwarn com.google.api.client.http.HttpRequest
-dontwarn com.google.api.client.http.HttpRequestFactory
-dontwarn com.google.api.client.http.HttpResponse
-dontwarn com.google.api.client.http.HttpTransport
-dontwarn com.google.api.client.http.javanet.NetHttpTransport$Builder
-dontwarn com.google.api.client.http.javanet.NetHttpTransport
-dontwarn org.joda.time.Instant
