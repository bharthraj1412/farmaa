# Farmaa Mobile — Android Configuration

## android/app/build.gradle Changes

Make the following updates to `android/app/build.gradle`:

```gradle
android {
    compileSdkVersion 34

    defaultConfig {
        applicationId "com.farmaa.mobile"
        minSdkVersion 21      // Android 5.0+ (covers Android 8.0+ requirement)
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }
}
```

## Internet Permission (android/app/src/main/AndroidManifest.xml)

Add inside `<manifest>`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.VIBRATE"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```

## Network Security (for HTTP to local backend during dev)

Create `android/app/src/main/res/xml/network_security_config.xml`:
```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <domain-config cleartextTrafficPermitted="true">
        <domain includeSubdomains="true">10.0.2.2</domain>
        <domain includeSubdomains="true">192.168.0.0</domain>
    </domain-config>
</network-security-config>
```

Add to `<application>` in AndroidManifest.xml:
```xml
android:networkSecurityConfig="@xml/network_security_config"
```

## Razorpay (android/app/build.gradle)

Razorpay requires minimum SDK 19; our minSdk 21 satisfies this.

## App Icon

Replace `android/app/src/main/res/mipmap-*/ic_launcher.png` with your Farmaa logo files,
or use `flutter_launcher_icons` package for automatic generation.
