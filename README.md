# ToDo App 📝

Modern ve AI destekli bir iOS görev yönetim uygulaması.

## Özellikler ✨

- **Kullanıcı Yönetimi**
  - Kullanıcı kaydı ve girişi
  - Profil yönetimi ve fotoğraf yükleme
  - Firebase Authentication entegrasyonu
  - Kullanıcı verilerinin Firestore'da güvenli saklanması

- **Görev Yönetimi**
  - Görev oluşturma ve düzenleme
  - Görev başlığı ve detaylı açıklama ekleme
  - Görev bitiş tarihi belirleme
  - Görevleri tamamlandı olarak işaretleme
  - Görev silme
  - Görev hatırlatma bildirimleri
    - Görev bitiş saatinden 30 dakika önce otomatik hatırlatma
    - Her sabah 8:30'da günlük görev özeti bildirimi
    - OneSignal entegrasyonu ile güvenilir bildirim yönetimi

- **AI Asistan**
  - OpenAI GPT-3.5 Turbo entegrasyonu
  - Görev planlaması için AI destekli öneriler
  - 5 adımlı öğrenme planı oluşturma
  - Önerilen görevleri direkt ToDo listesine ekleme
  - Kullanıcı başına kotayla sınırlandırılmış AI kullanımı (10 mesaj)
  - Doğal dil işleme desteği

- **Kullanıcı Arayüzü**
  - Modern ve şık SwiftUI arayüzü
  - Karanlık/Aydınlık mod desteği
  - Özelleştirilmiş animasyonlar
  - Sezgisel kullanıcı deneyimi
  - Hoş geldin ekranı
  - Tab-based navigation

## Teknik Özellikler 🛠

- SwiftUI ile modern UI geliştirme
- MVVM (Model-View-ViewModel) mimari pattern
- Firebase ile gerçek zamanlı veri senkronizasyonu
- Güvenli kullanıcı kimlik doğrulama
- Environment variables ile güvenli API yönetimi
- Async/await ile asenkron işlem yönetimi
- OneSignal push notification sistemi
- Firebase Storage ile profil fotoğrafı yönetimi
- OpenAI API entegrasyonu ve kota yönetimi

## Gereksinimler 📋

- iOS 15.0 veya üzeri
- Xcode 13.0 veya üzeri
- Swift 5.5 veya üzeri
- Firebase hesabı
- OpenAI API anahtarı
- OneSignal hesabı

## Kurulum 🚀

1. Projeyi klonlayın:
```bash
git clone https://github.com/erennali/ToDoApp_AI.git
```

2. `.env` dosyasını oluşturun ve API anahtarlarını ekleyin:
```
API_KEY=your_openai_api_key_here
ONESIGNAL_APP_ID=your_onesignal_app_id_here
ONESIGNAL_REST_API_KEY=your_onesignal_api_key_here
```

3. Firebase yapılandırmasını tamamlayın:
   - GoogleService-Info.plist dosyasını projeye ekleyin
   - Firebase konsolunda gerekli ayarları yapın

4. OneSignal yapılandırmasını tamamlayın:
   - OneSignal iOS uygulamanızı oluşturun
   - Push notification sertifikalarını yapılandırın
   - Notification Service Extension'ı projenize ekleyin

5. Xcode ile projeyi açın ve çalıştırın

## Katkıda Bulunma 🤝

1. Projeyi fork edin
2. Feature branch oluşturun (`git checkout -b feature/YeniÖzellik`)
3. Değişikliklerinizi commit edin (`git commit -m 'Yeni özellik eklendi'`)
4. Branch'inizi push edin (`git push origin feature/YeniÖzellik`)
5. Pull Request oluşturun
