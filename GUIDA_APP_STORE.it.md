# ClassScheduler — Guida passo-passo al rilascio su Apple App Store

Guida **lineare** e completa per portare ClassScheduler su iPhone/iPad e venderlo
sull'App Store, da fare **dopo** il lancio Android (vedi `GUIDA_PASSO_PASSO.it.md`).
Molte cose fatte per Android si riusano (backend Firebase, pagine legali,
RevenueCat, testi). Qui c'è solo la parte iOS.

**Legenda:** 🟢 lo puoi fare adesso · 🟡 dipende da un passo precedente ·
⏳ ha un tempo di attesa, avvialo presto · 💶 costa · ⚠️ irreversibile / delicato
· 🍎 richiede un Mac

> 📌 **Decisione (2026-09-12): lancio gratuito, iOS posticipato.** L'app lancia
> gratuita e solo su Android per validare il prodotto. Questa guida resta
> valida per quando affronterai iOS, ma con due differenze rispetto a quanto
> scritto sotto finché resti sul piano gratuito:
> - **TAPPA 4 (Abbonamento in-app) non serve** — l'app è sbloccata per tutti
>   (`AppConstants.subscriptionsEnabled = false`), niente prodotto da creare in
>   App Store Connect né da collegare a RevenueCat.
> - **0.2 (Paid Applications Agreement)** serve solo quando l'app avrà un
>   acquisto in-app da vendere: se resti gratis puoi saltarlo per ora.
> L'iscrizione **Apple Developer Program (99 $/anno, 0.1)** resta comunque
> necessaria per pubblicare *qualsiasi* app su iOS, a prescindere dal prezzo —
> e vale anche se in futuro preferisci affidarti a un publisher piuttosto che
> pubblicare tu stesso (un publisher userebbe comunque un proprio account, ma
> tu resti libero di valutare entrambe le strade quando ci arrivi). Il
> runbook per riattivare l'abbonamento su entrambe le piattaforme è in
> `REATTIVAZIONE_ABBONAMENTI.it.md`.

---

## Il vincolo numero 1: ti serve un Mac

Per firmare, archiviare e caricare un'app iOS **serve macOS + Xcode**. Non c'è
modo di aggirarlo da Windows. Hai tre opzioni:

| Opzione | Costo indicativo | Note |
|---|---|---|
| **Mac mini / MacBook Air usato** | 400–700 € una tantum | La più comoda a lungo termine se aggiorni spesso l'app. |
| **Mac in cloud** (MacInCloud, Scaleway Mac, AWS EC2 Mac) | 20–60 €/mese o a ore | Ti colleghi in desktop remoto. Ok per rilasci saltuari. |
| **CI con build iOS** (Codemagic, Bitrise, GitHub Actions macOS runner) | Codemagic ha un piano gratuito con ~500 min/mese | **Consigliata per te**: costruisce l'`.ipa` su un Mac in cloud e la carica su App Store Connect da sola. Ti serve comunque un Mac *una volta* per generare i certificati, oppure lasci fare a Codemagic la firma automatica. |

> Consiglio pratico: **Codemagic**. Colleghi il repo GitHub, gli dai le
> credenziali App Store Connect (una API key, si genera dal browser senza Mac) e
> lui gestisce firma + upload. Il resto di questa guida indica, dove serve, sia
> il percorso "Xcode su Mac" sia quello "Codemagic".

---

## Mappa generale (8 tappe)

| # | Tappa | Durata indicativa |
|---|---|---|
| 0 | Prerequisiti: Apple Developer Program, Mac/CI, decisioni | 1–3 giorni (⏳ verifica account) |
| 1 | Configurare il progetto iOS nel codice | mezza giornata |
| 2 | Apple Developer: App ID, capabilities, Sign in with Apple | 1–2 ore |
| 3 | App Store Connect: creare l'app + scheda + privacy | 1 giornata |
| 4 | Abbonamento in-app (App Store Connect + RevenueCat iOS) | mezza giornata |
| 5 | Prima build + upload + TestFlight interno | mezza giornata (🍎) |
| 6 | Beta esterna TestFlight | 1–2 settimane |
| 7 | Invio alla revisione Apple + pubblicazione | 24–48 h di review (fino a 7 gg) |
| 8 | Dopo la pubblicazione: aggiornamenti e manutenzione | continuo |

---

## TAPPA 0 — Prerequisiti

### 0.1 🟢💶⏳ Iscriviti all'Apple Developer Program
- Vai su <https://developer.apple.com/programs/enroll/>.
- Serve un **Apple ID** con autenticazione a due fattori attiva.
- Costo: **99 USD/anno** (circa 99 €/anno + IVA in Italia), **ricorrente** —
  se non rinnovi, l'app sparisce dallo Store.
- Iscrizione come **Individuo** (persona fisica): sullo Store comparirà il tuo
  **nome e cognome** come venditore. Se vuoi che compaia un nome commerciale
  serve un'**Organizzazione** (richiede P.IVA / codice DUNS, più lenta). Per il
  primo rilascio va bene Individuo, coerente con la scelta fatta per Google Play.
- ⏳ La verifica dell'identità può richiedere **da 24-48 h a diversi giorni**.
  Avviala subito.

✅ *Risultato atteso:* riesci ad accedere a <https://appstoreconnect.apple.com>
e vedi le sezioni "App", "Utenti e accesso", "Accordi, imposte e transazioni".

### 0.2 🟢💶⏳ Firma il "Paid Applications Agreement"
In App Store Connect → **Accordi, imposte e transazioni** (Agreements, Tax, and
Banking):
1. Accetta il contratto per le **app a pagamento** (serve perché vendi un
   abbonamento).
2. Compila **Informazioni bancarie** (IBAN dove ricevere i pagamenti).
3. Compila **Informazioni fiscali** — per l'Italia: modulo per residenti non-USA
   (W-8BEN) + dati fiscali italiani (codice fiscale / P.IVA se ce l'hai).

> ⚠️ Finché questo accordo è "in attesa" o incompleto **non puoi pubblicare
> un'app con acquisti in-app**. Sbrigalo in parallelo alla verifica dell'account.

### 0.3 🟢 Prepara il Mac o l'ambiente di build
- **Con Mac:** installa Xcode dall'App Store (diversi GB), aprilo una volta per
  far installare i componenti, poi:
  ```bash
  sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
  sudo xcodebuild -license accept
  brew install cocoapods    # oppure: sudo gem install cocoapods
  flutter doctor            # deve spuntare "Xcode" e "CocoaPods"
  ```
- **Con Codemagic/CI:** crea l'account, collega il repo GitHub, ma **non lanciare
  build finché non hai finito la Tappa 1 e 2**.

### 0.4 🟢 Decisioni da prendere ora
- **Prezzo iOS dell'abbonamento.** Apple usa fasce di prezzo fisse ("price
  tier"). L'equivalente di ~14,99 €/anno esiste come tier. Ricorda che **Apple
  trattiene il 15%** il primo anno di abbonamento continuativo per sviluppatore
  (poi resta 15% se l'utente supera 1 anno; 30% se sei sopra 1 M$/anno — non è il
  tuo caso). Il netto è simile a Google Play.
- **Un solo abbonamento** o anche un piano mensile? Per coerenza col lancio
  Android: solo annuale.
- **iPad sì/no.** L'app è `UISupportedInterfaceOrientations~ipad` completa, quindi
  gira anche su iPad. Se pubblichi "universale" devi fornire **anche gli
  screenshot iPad** (vedi 3.4). Se vuoi ridurre il lavoro puoi marcarla come solo
  iPhone (`TARGETED_DEVICE_FAMILY = 1`) per il primo rilascio e aggiungere iPad
  dopo.

---

## TAPPA 1 — Configurare il progetto iOS nel codice

Buona notizia: gran parte è già pronta nel repo.
- ✅ Bundle ID già impostato: **`com.classscheduler.classscheduler`** (identico ad
  Android e già registrato in Firebase — **non cambiarlo**).
- ✅ Nome visualizzato "ClassScheduler" già in `ios/Runner/Info.plist`
  (`CFBundleDisplayName`).
- ✅ `lib/firebase_options.dart` contiene già il blocco `ios` (appId
  `1:237070186843:ios:f2514a2404facff715027e`).
- ✅ Sign in with Apple **già implementato** in
  `lib/data/services/auth_service.dart` (`signInWithApple()`).
- ✅ Cancellazione account in-app già presente (`deleteAccount()`) — richiesta
  obbligatoria da Apple (linea guida 5.1.1(v)).
- ✅ Icona iOS: `flutter_launcher_icons` è già configurato con `ios: true` e
  `remove_alpha_ios: true` in `pubspec.yaml`.

Restano da fare questi passi.

### 1.1 🟢 Aggiungi l'app iOS in Firebase e scarica `GoogleService-Info.plist`
Il file **manca** in `ios/Runner/`.
1. Firebase Console → progetto **classscheduler-b2918** → ⚙️ Impostazioni progetto
   → scheda **Le tue app**.
2. Se l'app iOS non c'è già: **Aggiungi app → iOS**, bundle ID
   `com.classscheduler.classscheduler`, nickname "ClassScheduler iOS".
3. Scarica **`GoogleService-Info.plist`**.
4. Aprilo con Xcode (`ios/Runner.xcworkspace`), trascina il file **dentro il
   gruppo `Runner`**, spuntando "Copy items if needed" e target **Runner**.
   Deve finire in `ios/Runner/GoogleService-Info.plist` **ed essere elencato nel
   progetto Xcode** (non basta copiarlo col Finder).
5. Verifica che `iosClientId` / `iosBundleId` in `lib/firebase_options.dart`
   coincidano con quelli nel plist. (Oggi coincidono.)

> Senza Mac: puoi comunque scaricare il plist dal browser e committarlo in
> `ios/Runner/`, ma va **aggiunto al target in `project.pbxproj`**. Il modo
> pulito è usare la FlutterFire CLI (`dart pub global activate flutterfire_cli`
> e `flutterfire configure`) che aggiorna sia `firebase_options.dart` sia il
> progetto Xcode; richiede comunque un check finale su Mac/CI.

### 1.2 🟢 URL scheme per Google Sign-In (iOS)
`google_sign_in` su iOS ha bisogno del **`REVERSED_CLIENT_ID`** nell'`Info.plist`.
Aggiungi in `ios/Runner/Info.plist`, dentro il `<dict>` principale:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <!-- REVERSED_CLIENT_ID preso da GoogleService-Info.plist -->
      <string>com.googleusercontent.apps.237070186843-dcff0lk2mikv6o2prk6fvlvlahbohhpk</string>
    </array>
  </dict>
</array>
```

Controlla che la stringa sia **identica** al campo `REVERSED_CLIENT_ID` dentro il
`GoogleService-Info.plist` che hai appena scaricato (se Firebase ha rigenerato le
credenziali potrebbe essere diversa).

### 1.3 🟢 Capability "Sign in with Apple"
Serve un file entitlements. Crea `ios/Runner/Runner.entitlements`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>com.apple.developer.applesignin</key>
  <array>
    <string>Default</string>
  </array>
</dict>
</plist>
```

Poi, in Xcode (su Mac): target **Runner → Signing & Capabilities → + Capability →
Sign in with Apple**. Xcode collega da solo il file entitlements. Verifica che in
`project.pbxproj` compaia `CODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements`
per le config **Debug, Profile e Release**.

### 1.4 🟢 Dichiarazione crittografia (evita il blocco a ogni upload)
L'app usa solo HTTPS standard (Firebase). Aggiungi in `ios/Runner/Info.plist`:

```xml
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```

Così eviti il questionario sulla "compliance per l'esportazione" a ogni build.

### 1.5 🟢 Privacy Manifest (`PrivacyInfo.xcprivacy`)
Apple lo richiede. Flutter e i plugin recenti ne includono uno proprio, ma
**l'app deve averne uno a livello di target**. Crea
`ios/Runner/PrivacyInfo.xcprivacy` e aggiungilo al target Runner in Xcode:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>NSPrivacyTracking</key>
  <false/>
  <key>NSPrivacyTrackingDomains</key>
  <array/>
  <key>NSPrivacyCollectedDataTypes</key>
  <array>
    <dict>
      <key>NSPrivacyCollectedDataType</key>
      <string>NSPrivacyCollectedDataTypeEmailAddress</string>
      <key>NSPrivacyCollectedDataTypeLinked</key><true/>
      <key>NSPrivacyCollectedDataTypeTracking</key><false/>
      <key>NSPrivacyCollectedDataTypePurposes</key>
      <array><string>NSPrivacyCollectedDataTypePurposeAppFunctionality</string></array>
    </dict>
    <dict>
      <key>NSPrivacyCollectedDataType</key>
      <string>NSPrivacyCollectedDataTypeUserID</string>
      <key>NSPrivacyCollectedDataTypeLinked</key><true/>
      <key>NSPrivacyCollectedDataTypeTracking</key><false/>
      <key>NSPrivacyCollectedDataTypePurposes</key>
      <array><string>NSPrivacyCollectedDataTypePurposeAppFunctionality</string></array>
    </dict>
  </array>
  <key>NSPrivacyAccessedAPITypes</key>
  <array>
    <dict>
      <key>NSPrivacyAccessedAPIType</key>
      <string>NSPrivacyAccessedAPICategoryUserDefaults</string>
      <key>NSPrivacyAccessedAPITypeReasons</key>
      <array><string>CA92.1</string></array>
    </dict>
    <dict>
      <key>NSPrivacyAccessedAPIType</key>
      <string>NSPrivacyAccessedAPICategoryFileTimestamp</string>
      <key>NSPrivacyAccessedAPITypeReasons</key>
      <array><string>C617.1</string></array>
    </dict>
  </array>
</dict>
</plist>
```

(`UserDefaults` = `shared_preferences`; `FileTimestamp` = `path_provider`/export.
Se al primo upload Apple manda una mail su una "required reason API" non
dichiarata, aggiungi la categoria che ti segnala.)

### 1.6 🟢 Versione minima iOS
Firebase (`cloud_firestore` 5.x) richiede **iOS 13+**. Quando il `Podfile` viene
generato (prima `flutter build ios`), assicurati che in cima ci sia:

```ruby
platform :ios, '13.0'
```

e in Xcode `IPHONEOS_DEPLOYMENT_TARGET = 13.0` per il target Runner. Se usi
`sign_in_with_apple` 6.x va bene con iOS 13.

### 1.7 🟢 Testi legali e assistenza (riuso da Android)
Sono già online e vanno bene anche per iOS:
- Privacy: <https://matteopergoli.github.io/ClassScheduler/privacy.html>
- Termini: <https://matteopergoli.github.io/ClassScheduler/terms.html>
- Email supporto: `pergolimatteo@gmail.com`

Nei Termini, verifica che ci sia una riga generica sul fatto che gli acquisti
sono gestiti dallo store (Apple o Google) — Apple controlla che i termini non
citino **solo** Google Play.

### 1.8 🟢 Allinea `pubspec.yaml`
- `version: 1.0.0+3` va bene: su iOS diventa `CFBundleShortVersionString = 1.0.0`
  e `CFBundleVersion = 3`.
- ⚠️ **Ogni upload su App Store Connect deve avere un `build number` (il `+N`)
  più alto del precedente**, anche a parità di `1.0.0`. Tieni un contatore.
- Rigenera icone/splash una volta: `flutter pub get`, poi
  `dart run flutter_launcher_icons` e `dart run flutter_native_splash:create`.

### 1.9 🟡 Commit
```bash
git add -A
git commit -m "chore(ios): Firebase plist, URL scheme, Apple Sign-In entitlement, privacy manifest, encryption flag"
git push
```

---

## TAPPA 2 — Apple Developer: identificativi e capability

Tutto da <https://developer.apple.com/account> → **Certificates, Identifiers &
Profiles**. Questa parte si fa **da browser, senza Mac**.

### 2.1 🟢 App ID (Identifier)
1. **Identifiers → + → App IDs → App**.
2. Description: `ClassScheduler`. Bundle ID: **Explicit** →
   `com.classscheduler.classscheduler`.
3. **Capabilities**: spunta
   - **Sign In with Apple**
   - **In-App Purchase** (di solito già attiva di default)
   - **Push Notifications** solo se in futuro le userai (ora no).
4. Salva.

### 2.2 🟢 Firma: automatica (consigliata) o manuale
- **Automatica (Xcode "Automatically manage signing")**: in Xcode selezioni il
  tuo Team, Xcode crea da solo certificato di sviluppo, provisioning e, in fase
  di Archive, il certificato di **distribuzione**. È la via più semplice.
- **Codemagic / CI**: nella UI di Codemagic scegli "Automatic code signing" e
  colleghi la **App Store Connect API key** (vedi 2.3). Codemagic gestisce
  certificati e profili. In alternativa "Manual": carichi un
  `Distribution certificate (.p12)` + `App Store provisioning profile` che però
  per generarli senza Mac serve comunque `fastlane match` o un giro su un Mac.
- **Manuale su Mac**: Certificates → + → **Apple Distribution**; Profiles → + →
  **App Store** legato all'App ID sopra.

### 2.3 🟢 App Store Connect API key (per upload automatici / Codemagic / Transporter)
In **App Store Connect → Utenti e accesso → Integrazioni (chiavi API)**:
1. Genera una chiave con ruolo **App Manager**.
2. Scarica il file **`.p8`** (una sola volta!), annota **Key ID** e **Issuer ID**.
3. Servirà a Codemagic, a `xcrun altool`/`notarytool` o all'app **Transporter**
   per caricare l'`.ipa` senza aprire Xcode ogni volta.

---

## TAPPA 3 — App Store Connect: creare la scheda

### 3.1 🟢 Nuova app
App Store Connect → **App → + → Nuova app**:
- Piattaforma: **iOS**.
- Nome: **ClassScheduler** (deve essere unico su tutto lo Store; se occupato,
  serve una variante, es. "ClassScheduler – Orario").
- Lingua principale: **Italiano**.
- Bundle ID: scegli `com.classscheduler.classscheduler` dal menu (compare perché
  hai creato l'App ID alla Tappa 2).
- SKU: una stringa interna a piacere, es. `CLASSSCHEDULER-IOS-01`.
- Accesso utente completo.

### 3.2 🟢 Scheda "Informazioni sull'app"
- **Sottotitolo** (max 30 caratteri): es. "Orario scolastico automatico".
- **Categoria**: Primaria *Istruzione* (Education); secondaria opzionale
  *Produttività*.
- **Diritti (Content Rights)**: dichiara se contiene contenuti di terzi (no).
- **Age Rating**: compila il questionario → risultato atteso **4+**.

### 3.3 🟢 Scheda della versione 1.0
- **Descrizione**: riusa il testo della scheda Play, adattato (niente marchi
  Android). Max 4000 caratteri.
- **Parole chiave** (campo unico, max 100 caratteri, separate da virgola, senza
  spazi): es. `orario,scuola,insegnanti,lezioni,timetable,classi,docenti`.
- **URL di supporto**: la pagina GitHub Pages o una mailto.
- **URL marketing**: opzionale.
- **Testo promozionale** (170 caratteri, aggiornabile senza review): opzionale.
- **Copyright**: `2026 Matteo Pergoli`.

### 3.4 🟢 Screenshot (obbligatori, requisito rigido)
Apple pretende screenshot per **almeno** questi formati:
- **iPhone 6.9" o 6.7"** (es. iPhone 15/16 Pro Max) — 1290×2796 o 1320×2868 px.
- **iPhone 6.5"** (fallback per device più vecchi) — spesso puoi riusare i 6.7".
- **iPad Pro 13" (12.9")** — 2064×2752 px — **solo se pubblichi anche per iPad**.
Da 3 a 10 immagini per formato. Niente cornici del dispositivo obbligatorie, ma
niente contenuti fuorvianti.

Come farli senza faticare:
- Nel **Simulatore iOS** (su Mac/CI) apri l'app, `Cmd+S` salva lo screenshot alla
  risoluzione giusta.
- Oppure sul tuo iPhone reale via TestFlight (Tappa 5) e ritagli.
- Strumenti come *Fastlane snapshot* o siti di "app screenshot generator" per
  aggiungere cornice e testo.

### 3.5 🟢 App Privacy ("nutrition labels")
Sezione **Privacy dell'app** → "Modifica". Dichiara la raccolta dati coerente col
Privacy Manifest (1.5):
- **Dati di contatto → Indirizzo email**: raccolto, **collegato all'utente**, uso
  *Funzionalità dell'app*, **non** per tracciamento.
- **Identificatori → ID utente** (UID Firebase): raccolto, collegato, funzionalità
  dell'app, no tracciamento.
- Se in futuro aggiungi analytics/crashlytics, dichiara anche *Dati di utilizzo*
  e *Dati diagnostici*.
- **Tracciamento**: **No** (non usi IDFA né condividi dati con data broker).
- Inserisci l'URL della Privacy Policy.

### 3.6 🟢 "Account demo" per la revisione
Nel campo **Informazioni per la revisione** metti:
- Un **account di prova già attivo** (email + password di un utente Firebase che
  hai creato tu) così il revisore entra senza fare Sign in with Apple/Google.
- Una **nota**: "L'utente ha 1 generazione orario gratuita; per verificare
  l'abbonamento è stato concesso premium di cortesia all'account demo tramite
  `/entitlements/{uid}`." (Vedi `GUIDA_PASSO_PASSO.it.md` §4.6.)
- Telefono/email di contatto.

---

## TAPPA 4 — Abbonamento in-app (App Store Connect + RevenueCat)

⚠️ Gli ID prodotto **non** si condividono tra Google Play e App Store: devi
**ricreare l'abbonamento** lato Apple. L'`entitlement` RevenueCat
(`classscheduler_annual`) invece resta **lo stesso** e serve entrambe le
piattaforme.

### 4.1 🟢 Crea il gruppo e il prodotto di abbonamento
App Store Connect → la tua app → **Abbonamenti** (Subscriptions):
1. Crea un **Gruppo di abbonamenti**, es. `ClassScheduler Premium`.
2. Dentro, **+ Abbonamento**:
   - **Reference Name** (interno): `Annual Premium`.
   - **Product ID**: usa lo stesso schema di Android per chiarezza →
     `classscheduler_annual_1490`. ⚠️ Il Product ID è **definitivo**, non si
     riusa se cancellato.
   - **Durata**: 1 anno.
   - **Prezzo**: scegli la fascia più vicina a 14,99 €/anno per l'Italia (Apple
     propaga i prezzi negli altri Paesi, puoi rivederli).
   - **Localizzazione** (Italiano): nome visualizzato "Abbonamento annuale" e
     descrizione ("Orari illimitati, tutte le funzioni").
   - **Testo di revisione** + **screenshot del paywall** (obbligatorio: una
     schermata dove si vede il prezzo e il pulsante di acquisto).
3. Stato del prodotto: deve arrivare a **"Pronto per l'invio"**; verrà
   **rivisto insieme alla build 1.0**.

> Nota fiscale: in **Accordi, imposte e transazioni** puoi impostare la
> categoria IVA per app di istruzione. Per un abbonamento software generico
> lascia il default.

### 4.2 🟢 Configura RevenueCat per iOS
Dashboard RevenueCat → progetto ClassScheduler:
1. **Project settings → Apps → + New → App Store**.
   - Bundle ID `com.classscheduler.classscheduler`.
   - Carica la **App Store Connect API key** (`.p8` + Key ID + Issuer ID) così
     RevenueCat valida le ricevute e riceve le notifiche server-to-server.
   - Copia la **Public SDK Key** iOS (inizia con `appl_`).
2. **Products**: aggiungi `classscheduler_annual_1490` (store: App Store).
3. **Entitlements**: apri `classscheduler_annual` (già esistente per Android) e
   **allega** anche il prodotto iOS appena creato.
4. **Offerings**: nella offering di default, il package (es. `$rc_annual` o
   "Annual") deve contenere **sia** il prodotto Play **sia** quello App Store.
   Così il codice Flutter non cambia: chiede la stessa offering e RevenueCat
   serve il prodotto giusto per piattaforma.

### 4.3 🟢 Passa la chiave iOS in build
Il codice legge `RC_IOS_KEY` via `--dart-define` (vedi
`lib/core/constants/app_constants.dart`). In fase di build/CI:

```bash
flutter build ipa --release \
  --dart-define=RC_IOS_KEY=appl_LaTuaChiavePubblica \
  --dart-define=RC_ANDROID_KEY=goog_xxx
```

In **Codemagic** metti `RC_IOS_KEY` tra le *Environment variables* (gruppo
segreto) e aggiungilo agli args di `flutter build ipa`.

### 4.4 🟢 Sandbox testing
App Store Connect → **Utenti e accesso → Sandbox → Tester**: crea un tester
sandbox (email mai usata come Apple ID). Su un iPhone reale
(Impostazioni → App Store → Account Sandbox) potrai provare l'acquisto **senza
pagare**. Verifica: acquisto, ripristino acquisti, scadenza accelerata (in
sandbox 1 anno ≈ 1 ora).

---

## TAPPA 5 — Prima build, upload e TestFlight interno  🍎

### 5.1 🍎 Genera l'archivio
**Su Mac con Xcode:**
```bash
flutter pub get
cd ios && pod install && cd ..
flutter build ipa --release \
  --dart-define=RC_IOS_KEY=appl_xxx --dart-define=RC_ANDROID_KEY=goog_xxx
```
`flutter build ipa` produce `build/ios/ipa/classscheduler.ipa` e apre la
possibilità di validare/distribuire. In alternativa apri
`ios/Runner.xcworkspace`, scegli **Any iOS Device**, `Product → Archive`, poi
**Distribute App → App Store Connect → Upload**.

**Con Codemagic:** workflow iOS → step "Flutter build ipa" con i `--dart-define`
→ step "App Store Connect publishing" con la API key. Parte a ogni push o a mano.

### 5.2 🟢 L'upload arriva su App Store Connect
- La build compare in **TestFlight** dopo 5–30 min di "elaborazione".
- Se manca qualcosa Apple manda un'email (es. icona con canale alpha, privacy
  manifest, permesso non dichiarato). Correggi, alza il build number, ricarica.

### 5.3 🟢 Export Compliance
Alla prima build TestFlight potrebbe chiederti la conformità crittografia: avendo
messo `ITSAppUsesNonExemptEncryption=false` (1.4) rispondi che **non usi
crittografia non esente** e non serve altro.

### 5.4 🟢 Test interno (subito, senza revisione)
TestFlight → **Test interni** → crea un gruppo, aggiungi il tuo Apple ID (fino a
100 tester interni, devono essere in "Utenti e accesso"). Installa **TestFlight**
dall'App Store sul tuo iPhone e prova la build reale: login Apple, login Google,
generazione orario, acquisto sandbox, export PDF/Excel, cambio lingua.

---

## TAPPA 6 — Beta esterna TestFlight

Non è **obbligatoria** come su Google Play, ma fortemente consigliata.
1. TestFlight → **Test esterni** → nuovo gruppo (es. "Insegnanti").
2. Prima build di un gruppo esterno → **breve revisione Apple** (poche ore/1
   giorno).
3. Invita per email o con **link pubblico** (comodo per gli amici insegnanti,
   fino a 10.000 tester).
4. Le build TestFlight scadono dopo **90 giorni**.
5. Raccogli feedback (schermata + nota dai tester direttamente da TestFlight).

> Puoi riusare gli stessi insegnanti della beta Play. iOS e Android condividono
> lo stesso backend Firebase e lo stesso account: un utente che si logga su
> entrambe vede gli stessi dati.

---

## TAPPA 7 — Invio alla revisione e pubblicazione

### 7.1 🟢 Completa la versione 1.0
Nella pagina della versione in App Store Connect controlla che tutto sia verde:
- Screenshot per ogni formato richiesto.
- Descrizione, keyword, URL supporto.
- **Build** selezionata (quella caricata alla Tappa 5).
- **Abbonamento** in stato "Pronto per l'invio" e **allegato alla versione**
  (sezione "In-App Purchases and Subscriptions" della versione: aggiungi
  `classscheduler_annual_1490` così viene revisionato insieme).
- App Privacy compilata.
- Informazioni per la revisione + account demo (3.6).

### 7.2 🟢 Rilascio
Scegli:
- **Rilascio automatico** appena approvata, oppure
- **Rilascio manuale** (consigliato per il primo: pubblichi tu con un click
  quando sei pronto), oppure
- **Rilascio programmato** a una data.

Puoi anche impostare **rilascio graduale (phased release)**: 7 giorni a
percentuali crescenti di utenti — utile per intercettare crash.

### 7.3 🟢 "Invia per la revisione"
- Tempi tipici: **24–48 h**, a volte poche ore, occasionalmente fino a 7 giorni.
- Se **rifiutata**: nel **Resolution Center** trovi il motivo. Rispondi lì.
  Motivi frequenti per app come questa:
  - **3.1.1** — funzioni sbloccabili solo con IAP dello store (ok, è quello che
    fai; assicurati che non ci siano link a pagamenti esterni).
  - **2.1** — il revisore non riesce a provare il premium → serve l'account demo
    con premium di cortesia già attivo (3.6).
  - **4.0 / 2.3.10** — screenshot che mostrano Android o testo fuorviante.
  - **5.1.1(v)** — cancellazione account: già implementata, indica nel testo di
    revisione **dove** si trova (Impostazioni → Elimina account).
  - **Sign in with Apple mancante**: non è il tuo caso, è già presente ed è
    obbligatoria proprio perché offri Google come login di terze parti.

### 7.4 🟢 Approvata
Se hai scelto rilascio manuale, premi **"Rendi disponibile app"**. Entro qualche
ora è sull'App Store italiano. Gli altri Paesi: puoi lasciare solo Italia in
**Disponibilità (Prezzi e disponibilità → Disponibilità nei paesi/aree)**,
coerente col lancio Android.

---

## TAPPA 8 — Dopo la pubblicazione

### 8.1 Aggiornamenti
Per ogni nuova versione:
1. Alza `version:` in `pubspec.yaml` (es. `1.0.1+4`) — **build number sempre
   crescente**.
2. `flutter build ipa` + upload (o push su Codemagic).
3. In App Store Connect: **"+ Versione"**, note di rilascio, seleziona la nuova
   build, **Invia per la revisione**.
- Modifiche solo a testo promozionale, prezzo o disponibilità **non** richiedono
  una nuova build né revisione.

### 8.2 Monitoraggio
- **App Store Connect → Analytics / Vendite e tendenze**: download, incassi,
  conversione abbonamento.
- **App Store Connect → App → Valutazioni e recensioni**: puoi rispondere alle
  recensioni.
- **RevenueCat → Charts**: MRR, rinnovi, churn, incassi netti combinati
  Play+App Store.
- **Firebase → Crashlytics** (se lo aggiungi) per i crash.

### 8.3 Scadenze da ricordare
- **99 USD/anno** Apple Developer: se non rinnovi, l'app viene rimossa.
- Rispondere a eventuali email Apple su nuove "required reason API" o
  aggiornamenti SDK (Google/Firebase) entro le scadenze annunciate, altrimenti
  gli upload vengono bloccati.
- Ogni ~1 anno Xcode/iOS SDK minimo richiesto sale: potresti dover aggiornare la
  toolchain (Mac/CI) prima di poter caricare.

---

## Appendice A — Checklist rapida "sono pronto per l'invio?"

**Account**
- [ ] Apple Developer Program attivo e verificato
- [ ] Paid Applications Agreement firmato, dati bancari + fiscali completi

**Codice iOS**
- [ ] `ios/Runner/GoogleService-Info.plist` presente e nel target Xcode
- [ ] `CFBundleURLTypes` con `REVERSED_CLIENT_ID` in `Info.plist`
- [ ] `Runner.entitlements` con `com.apple.developer.applesignin` + capability in Xcode
- [ ] `ITSAppUsesNonExemptEncryption = false`
- [ ] `PrivacyInfo.xcprivacy` nel target
- [ ] `platform :ios, '13.0'` nel Podfile, deployment target 13.0
- [ ] Icona senza canale alpha (`remove_alpha_ios: true` → già ok)
- [ ] Build number `+N` più alto di qualsiasi upload precedente
- [ ] `--dart-define=RC_IOS_KEY=appl_...` passato in build

**Apple Developer**
- [ ] App ID `com.classscheduler.classscheduler` con Sign In with Apple + IAP
- [ ] App Store Connect API key `.p8` salvata (Key ID + Issuer ID)

**App Store Connect**
- [ ] App creata, categoria Istruzione, age rating 4+
- [ ] Descrizione, keyword, URL supporto
- [ ] Screenshot iPhone 6.7"/6.9" (+ iPad se universale)
- [ ] App Privacy compilata (email + user ID, no tracking)
- [ ] Abbonamento `classscheduler_annual_1490` "Pronto per l'invio" + screenshot paywall
- [ ] Abbonamento allegato alla versione 1.0
- [ ] Account demo + note per la revisione (dove sta l'abbonamento, dove si elimina l'account)

**RevenueCat**
- [ ] App "App Store" aggiunta, API key caricata
- [ ] Prodotto iOS dentro l'entitlement `classscheduler_annual`
- [ ] Offering di default con package multi-piattaforma

**Prove**
- [ ] TestFlight interno: login Apple, login Google, generazione, export
- [ ] Acquisto sandbox + ripristino acquisti funzionano
- [ ] Beta esterna con qualche insegnante fatta

---

## Appendice B — Differenze chiave Google Play ↔ App Store

| Tema | Google Play | App Store |
|---|---|---|
| Costo account | 25 $ una tantum | 99 $/anno |
| Serve un Mac | No | **Sì** (o CI con Mac, es. Codemagic) |
| Test obbligatorio pre-produzione | Sì (≥12 tester, 14 gg, account personale) | No (TestFlight consigliato ma non obbligatorio) |
| Tempi di revisione | ore–giorni | 24–48 h tipico |
| Commissione | 15% (primo 1 M$/anno) | 15% abbonamenti (dopo config Small Business / 1° anno) |
| ID prodotto IAP | propri | **da ricreare**, non condivisi |
| Sign in with Apple | non richiesto | **obbligatorio** se offri altri login social (già implementato) |
| Cancellazione account in-app | consigliata | **obbligatoria** (già implementata) |
| Privacy | Data safety form | App Privacy labels + `PrivacyInfo.xcprivacy` |
| Firma | keystore `.jks` tuo | certificati Apple + provisioning (meglio "automatic signing") |

---

## Appendice C — Percorso "senza comprare un Mac" (Codemagic)

1. Account su <https://codemagic.io>, collega il repo GitHub `ClassScheduler`.
2. Nuovo workflow **iOS** (o file `codemagic.yaml` nel repo).
3. **Code signing → iOS → Automatic**, collega la **App Store Connect API key**
   (`.p8`, Key ID, Issuer ID) e l'**Apple Developer Portal** (stesso account).
   Codemagic crea/gestisce certificato di distribuzione e provisioning.
4. Environment variables (gruppo cifrato): `RC_IOS_KEY`, `RC_ANDROID_KEY`.
5. Step di build:
   ```
   flutter build ipa --release \
     --dart-define=RC_IOS_KEY=$RC_IOS_KEY \
     --dart-define=RC_ANDROID_KEY=$RC_ANDROID_KEY \
     --export-options-plist=/Users/builder/export_options.plist
   ```
   (Codemagic genera l'`export_options.plist` con la firma automatica.)
6. Step **App Store Connect publishing**: `Submit to TestFlight` (e più avanti
   `Submit to App Store review`).
7. Gli **screenshot** restano il punto scomodo senza Mac: usa il **Simulatore in
   un job Codemagic** che salva le immagini come arteffatti, oppure prendili da
   un iPhone reale via TestFlight, oppure un servizio online di mockup.

> Un Mac (anche in cloud, poche ore) serve comunque **almeno una volta** se
> Codemagic non riesce a fare tutto in automatic signing, o per il primo
> `pod install` / debug di problemi di build nativi.
