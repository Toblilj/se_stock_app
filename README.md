# SE Stock App

Modern inventeringsapp med **realtids-synkronisering** via Firebase.  
Byggd för lagerhantering på flera platser (Malmö, Helsingborg, Göteborg m.fl.).

## Funktioner

- **Realtidsuppdateringar** – flera personer kan inventera samtidigt och se ändringar direkt
- Välj mellan olika lagerplatser
- Lägg till och uppdatera produkter enkelt
- CSV-export av inventering
- Data sparas både i molnet (Firebase) och lokalt på telefonen
- Enkel och läsvänlig mobil UI
- Fungerar offline och synkroniseras när du är online igen

## Kom igång

### Installation på telefon

1. Gå till [senaste releasen](https://github.com/Toblilj/se_stock_app/releases/latest)
2. Ladda ner `app-release.apk`
3. Öppna filen på din Android-telefon och installera (tillåt okända källor)

### För utvecklare

```bash
git clone https://github.com/Toblilj/se_stock_app.git
cd se_stock_app
flutter pub get
flutter run