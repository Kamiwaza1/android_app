# Kiosk WebView (Android / Google TV)

Tam ekran (immersive) kiosk modunda çalışan basit bir WebView tarayıcı.
Uygulama açıldığında ayarlanan başlangıç URL'sine gider. Menü, bar vs yoktur.

## Özellikler
- Web içeriği tam ekran
- Android TV / Google TV LEANBACK launch desteği
- Başlangıç URL kalıcı (SharedPreferences)
- 3 saniye içinde uzaktan kumandada OK (DPAD_CENTER) 5 kez basınca gizli URL ayar popup'ı açılır
- Geri tuşu engellenir (uygulamadan çıkışı cihaz yönetecek)

## Başlangıç URL Değiştirme
1. Uygulama içindeyken kumanda/klavyede `OK`/`Enter` tuşuna 3 saniye içinde art arda 5 kez basın.
2. Açılan dialoga yeni `https://...` adresini girip Kaydet'e basın.
3. Sayfa otomatik yeniden yüklenir.

## Geliştirme Kurulumu
PowerShell üzerinde:
```powershell
flutter pub get
flutter run -d android
```

Belirli bir TV emulator / cihaz id'si varsa:
```powershell
flutter devices
flutter run -d <deviceId>
```

## Release APK (sideload)
```powershell
flutter build apk --release
```
APK çıktısı: `build\app\outputs\flutter-apk\app-release.apk`

## Notlar / Kısıtlar
- Tam kiosk için (home tuşunu engellemek vb.) kurumsal cihaz yönetimi (MDM) veya Android Managed Profile gerekebilir.
- `android:screenOrientation="landscape"` Manifest içindedir, gerekirse kaldırıp otomatik döndürme sağlanabilir.
- Sertifika hataları, popup engelleri WebView limitlerine tabidir.

## Değişiklikler (Özet)
- `pubspec.yaml`: `webview_flutter`, `shared_preferences` eklendi.
- `lib/main.dart`: WebView kiosk uygulaması.
- `AndroidManifest.xml`: TV özellikleri, LEANBACK intent, izinler, immersive ayarlar.

## Lisans
Proje iç uso amaçlıdır; gerekirse lisans ekleyin.
