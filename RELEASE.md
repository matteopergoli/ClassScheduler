# RELEASE.md — come pubblicare ClassScheduler

Guida operativa alla build e alla pubblicazione. Per la strategia (marketing,
beta, pricing) vedi il documento di roadmap separato.

Per il primo lancio in Italia la scelta consigliata è **solo Android / Google
Play**: non serve un Mac, non serve l'iscrizione Apple da 99 $/anno, la
revisione è più rapida. iOS si aggiunge in un secondo momento.

---

## 0. Prerequisiti una tantum

| Cosa | Note |
|---|---|
| Account Google Play Console | 25 $ una tantum. Registrarsi come "sviluppatore" (persona fisica va bene per iniziare). |
| Dominio + pagine legali online | Serve un URL pubblico per Privacy Policy e Termini (vedi `legal/`). Va bene anche GitHub Pages gratis. |
| Keystore di firma | Generato una volta, **da conservare per sempre** (vedi sotto). |
| Chiavi RevenueCat di produzione | Dal cruscotto RevenueCat, una per piattaforma. |

---

## 1. Generare il keystore di firma (una volta sola)

```bash
keytool -genkey -v -keystore %USERPROFILE%\classscheduler-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Poi copia `android/key.properties.example` in `android/key.properties` e
compila i valori reali.

> ⚠️ **Backup del keystore + password in almeno due posti sicuri** (password
> manager + copia offline). Se lo perdi non potrai più aggiornare l'app su
> Play Store. `android/key.properties` e i file `.jks` sono git-ignored: non
> finiranno mai nel repository.

Con Play App Signing attivo (consigliato, di default), questo è solo la
*upload key*: Google ri-firma l'app con la sua chiave. Se un giorno perdi la
upload key, Google può resettarla — ma non perdere comunque nulla.

---

## 2. Preparare i file legali online

1. Pubblica `legal/privacy-policy.it.md` e `legal/terms-of-service.it.md` come
   pagine web (GitHub Pages, Notion pubblico, un sito qualsiasi).
2. Aggiorna gli URL in `lib/core/constants/app_constants.dart`
   (`privacyPolicyUrl`, `termsUrl`) se diversi da `https://classscheduler.app/...`.
3. Fai revisionare i testi (sono bozze).

---

## 3. Configurare RevenueCat + Google Play Billing

1. In **Play Console → Monetizza → Prodotti → Abbonamenti**: crea un
   abbonamento con ID prodotto `classscheduler_annual_1490`, prezzo €14,99/anno,
   periodo di prova a scelta (o gestisci la prova lato app come già fai).
2. In **RevenueCat**: collega l'app Android, importa il prodotto, crea
   l'entitlement `classscheduler_annual`, associa il prodotto all'entitlement.
3. Copia le **Public SDK Key** di RevenueCat (Android e, in futuro, iOS).

---

## 4. Build dell'App Bundle firmato

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
flutter analyze lib
flutter test

flutter build appbundle --release ^
  --dart-define=RC_ANDROID_KEY=goog_LA_TUA_CHIAVE ^
  --dart-define=RC_IOS_KEY=appl_LA_TUA_CHIAVE
```

Output: `build/app/outputs/bundle/release/app-release.aab`

Per aggiornamenti futuri: incrementa `version:` in `pubspec.yaml`
(es. `1.0.1+2` — il numero dopo `+` è il `versionCode` e deve sempre crescere).

---

## 5. Prima pubblicazione su Play Console

1. **Crea l'app** — nome "ClassScheduler", italiano come lingua predefinita,
   gratuita con acquisti in-app.
2. **Scheda del Play Store**: descrizione breve/lunga, icona 512×512,
   feature graphic 1024×500, almeno 2–8 screenshot per telefono.
3. **Contenuti dell'app**: informativa privacy (URL), modulo *Data safety*
   (dichiara: e-mail e ID utente raccolti, cifratura in transito, cancellazione
   su richiesta), classificazione contenuti (PEGI 3), target ≥ 18, no annunci.
4. **Track di test**: carica l'`.aab` prima su **Test interno** (fino a 100
   tester via e-mail o link) — è istantaneo e ti serve per i tuoi amici beta.
5. Quando sei pronto: promuovi la stessa release su **Produzione**.
   Prima revisione tipicamente 1–7 giorni.

---

## 6. Checklist pre-invio (estratto da QA_CHECKLIST.md)

- [ ] `flutter test` verde
- [ ] `android/key.properties` presente e build firmata con la release key
- [ ] `--dart-define` con le chiavi RevenueCat di produzione
- [ ] URL privacy e termini raggiungibili
- [ ] Provato un acquisto reale in track di test (licenza tester Play)
- [ ] Provata la cancellazione account → dati rimossi da Firestore
- [ ] `versionCode` incrementato rispetto all'ultima release

---

## 7. iOS (più avanti)

Richiede: Mac con Xcode, Apple Developer Program (99 $/anno),
`GoogleService-Info.plist` da FlutterFire, capability *Sign in with Apple*,
prodotto IAP in App Store Connect, *privacy nutrition labels*.
Comando: `flutter build ipa --release --dart-define=...` poi upload con Xcode
o Transporter.
