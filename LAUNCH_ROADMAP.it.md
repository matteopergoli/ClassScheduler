# ClassScheduler — Rotta di lancio

Dalla cartella di progetto allo scaffale del Play Store. Il codice funziona;
quello che manca ora non è programmazione, è la trafila di firma, negozio,
pagamenti e primi utenti. Questa è la mappa, in ordine, con le trappole
segnalate.

- **App**: Flutter · Firebase · RevenueCat
- **Mercato**: Italia, Android per primo
- **Versione**: 1.0.0+1

---

## 1. Dove sei adesso

Ho controllato il progetto.

- `flutter analyze lib` → **nessun errore**, solo ~180 avvisi cosmetici
  (`withOpacity` deprecata, variabili non usate). Non bloccano la pubblicazione.
- `flutter test` → **la maggior parte passa**, ma:
  - `AppConstants — SA parameters match SRS §8.2.2` **falliva** perché il test
    fissava ancora `saMaxRestarts == 3` mentre il codice (tarato apposta, con
    commento) usa `200`. **L'ho corretto io** nel test.
  - `ALG-T06 — maximum configuration performance run 2` fallisce **a
    intermittenza**: è un test a tempo, quando gira insieme a tutta la suite su
    una macchina carica sfora il limite. Lanciato da solo passa. Non è un bug
    dell'app, ma tienilo d'occhio su un dispositivo reale (AC-06).

### Pronto
- `android/` e `ios/` presenti e versionati
- Firebase configurato (progetto `classscheduler-b2918`)
- Regole Firestore scritte, isolamento per utente
- Cancellazione account (GDPR) implementata
- Localizzazione IT completa
- Suite di test presente (ALG-T, AC-01…16)

### Da sistemare a mano
- Pagine Privacy e Termini da pubblicare online
- Deploy delle regole Firestore in produzione
- Scheda Play Store (testi, icona, screenshot)
- Prodotto abbonamento da creare in Play Console + RevenueCat
- `tool/sa_tuning.dart` non compila più (script di supporto, non l'app)

### Blocca il lancio
- Chiave di firma release (keystore) — **ora predisposta**, va generata
- Chiavi RevenueCat: ancora segnaposto → niente abbonamenti finché non le metti
- Account Google Play Console (25 $ una tantum)

> **Strategia.** Per l'Italia, lancia **prima solo su Android**. iOS richiede un
> Mac, 99 $/anno e più burocrazia. Con Google Play parti con 25 $ una tantum,
> senza Mac, revisione più rapida. iOS lo aggiungi quando il prodotto ha
> trazione.

---

## 2. Cosa ho già preparato nel codice

Modifiche piccole e a basso rischio, nessuna tocca la logica dell'app o
l'algoritmo.

| File | Modifica | Perché |
|---|---|---|
| `android/app/build.gradle.kts` | Legge `android/key.properties` per la firma release; se il file non c'è, ripiega sul debug | Play Store rifiuta build firmate col debug. Il ripiego non rompe `flutter run` a chi clona senza segreti |
| `android/key.properties.example` | Nuovo: modello da copiare in `key.properties` | Ti guida a creare il keystore; il file reale resta fuori da git |
| `.gitignore` | Aggiunti `key.properties`, `*.jks`, `*.keystore`, `.env` | I segreti di firma non vanno **mai** nel repo |
| `lib/core/constants/app_constants.dart` | Chiavi RevenueCat da `--dart-define`, con segnaposto come default | Passi le chiavi vere in build senza versionarle |
| `AndroidManifest.xml` / `Info.plist` | Nome visibile → **ClassScheduler** (era `classscheduler` minuscolo) | È il nome sotto l'icona |
| `legal/privacy-policy.it.md`, `legal/terms-of-service.it.md` | Nuovi: bozze IT, GDPR-aware, tarate su cosa fa l'app | Obbligatorie per Play Store. **Da far rivedere** e pubblicare online |
| `GUIDA_PASSO_PASSO.it.md` | Nuovo: la sequenza lineare di tutti i passi operativi | La checklist meccanica, un punto alla volta |
| `test/integration/acceptance_test.dart` | Allineato `saMaxRestarts` a 200 | Il test era rimasto indietro rispetto a una modifica voluta |

> **Nota sull'applicationId.** In `app_constants.dart` il campo `packageName`
> dice `com.classscheduler.app`, ma l'ID reale (Firebase, `google-services.json`,
> OAuth) è `com.classscheduler.classscheduler`. Quel campo è cosmetico e
> inutilizzato: **non cambiare l'applicationId**, rifaresti registrazione
> Firebase e Google Sign-In.

---

## 3. Cosa committare

Un solo commit su `main`. I file segreti sono già esclusi da `.gitignore`,
quindi `git add -A` è sicuro.

```bash
git add -A
git commit -m "chore: production release prep (signing, secrets, legal, docs)"
git push
```

**Non committare mai:**
- `android/key.properties` (il file vero, con le password)
- Qualsiasi file `.jks` / `.keystore`
- Chiavi RevenueCat o service-account Firebase in chiaro

`google-services.json` e `firebase_options.dart` sono già versionati e va bene:
le chiavi API Firebase per client mobile **non sono segrete**, sono protette
dalle regole Firestore e dal vincolo SHA-1 + package name.

---

## 4. Fase 1 — Rilascio tecnico (settimana 1)

### a. Genera la chiave di firma

```bash
keytool -genkey -v -keystore %USERPROFILE%\classscheduler-upload.jks ^
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Poi copia `android/key.properties.example` → `android/key.properties` e inserisci
percorso e password.

> **Irreversibile.** Salva il `.jks` e le password in **due posti sicuri**
> (password manager + copia offline). Se li perdi non potrai *mai più* aggiornare
> l'app pubblicata. Attiva **Play App Signing** (predefinito): Google custodisce
> la chiave finale, tu gestisci solo la "upload key", recuperabile.

### b. Pubblica le pagine legali

Prendi `legal/privacy-policy.it.md` e `legal/terms-of-service.it.md`, falli
rivedere, mettili online a un URL pubblico stabile (GitHub Pages, pagina Notion
pubblica, Carrd — anche gratis). Aggiorna `privacyPolicyUrl` e `termsUrl` in
`app_constants.dart` se gli indirizzi sono diversi.

### c. Deploy di Firebase in produzione

```bash
firebase deploy --only firestore:rules,firestore:indexes
```

Verifica in console che `classscheduler-b2918` sia il progetto di produzione e
che Authentication abbia attivi Email/Password e Google. Passa il progetto al
piano **Blaze** (pay as you go) prima del lancio e imposta un **budget alert**.

### d. RevenueCat + abbonamento Play

1. Play Console → **Monetizzazione → Abbonamenti**: crea
   `classscheduler_annual_1490`, €14,99/anno.
2. RevenueCat: collega l'app Android, importa il prodotto, entitlement
   `classscheduler_annual`.
3. Copia la **Public SDK Key** Android.

### e. Build firmata

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
flutter test
flutter build appbundle --release ^
  --dart-define=RC_ANDROID_KEY=goog_LA_TUA_CHIAVE
```

Risultato: `build/app/outputs/bundle/release/app-release.aab`.

### f. Play Console

- Crea l'app: nome **ClassScheduler**, lingua predefinita italiano, gratuita con
  acquisti in-app
- Scheda Store: descrizione breve (80 caratteri) e lunga, icona 512×512, grafica
  in evidenza 1024×500, 2–8 screenshot telefono
- *Contenuti dell'app*: URL privacy, modulo **Data safety** (raccogli e-mail e ID
  utente, cifrati in transito, cancellabili su richiesta), classificazione
  PEGI 3, pubblico ≥ 18, nessuna pubblicità
- Carica l'`.aab` nel canale **Test interno** (istantaneo, fino a 100 tester)
- Quando è ora: promuovi la stessa release in **Produzione** — prima revisione
  1–7 giorni
- Fornisci un **account di test** con credenziali pronte nelle note per il
  revisore

---

## 5. Fase 2 — Account e fatturazione dei clienti

### Chi gestisce cosa

| Aspetto | Chi | Cosa fai tu |
|---|---|---|
| Registrazione / login | Firebase Auth | Niente: già funziona (email, Google, Apple) |
| Password dimenticata | Firebase Auth | Verifica il template email in console, in italiano |
| Incasso dei pagamenti | Google Play | Nulla: Google addebita il cliente e ti versa il netto |
| Fatture al cliente | Google Play | Nulla: la ricevuta la manda Google (è "merchant of record") |
| Rinnovi / disdette / rimborsi | Google Play | Gestiti dallo store; i rimborsi si chiedono a Google |
| Stato abbonamento nell'app | RevenueCat | Configuri l'entitlement una volta; l'app già lo legge |
| Prova gratuita (1 orario) | La tua app | Già implementata: `trialUsed` su Firestore, sopravvive alla reinstallazione |

### Le tue tasse e contabilità

Google ti accredita mensilmente il ricavato (meno la commissione, **15%** fino a
1 M$/anno). Quello che ricevi è **reddito da dichiarare**. In Italia, se
l'attività è continuativa serve una **partita IVA** (il regime forfettario è
spesso adatto per iniziare) e Google chiederà i tuoi dati fiscali nel *payments
profile*. Parlane con un commercialista **prima** del primo incasso.

Finché sei in beta con account premium regalati non incassi nulla e il tema non
si pone. Diventa urgente il giorno in cui attivi il prodotto in Produzione con
prezzo > 0.

### Account premium gratis per gli amici

Dal più pulito al più veloce:

1. **Codici promozionali Play** (consigliato): Play Console → Abbonamenti →
   genera codici promo. L'amico riscatta e ha l'abbonamento gratis per il periodo
   scelto. RevenueCat lo vede come utente pagante reale — test end-to-end
   perfetto.
2. **Concessione manuale in RevenueCat**: dal dashboard assegni l'entitlement
   `classscheduler_annual` a un utente per un anno. Veloce, ma salta il flusso di
   acquisto.
3. **Licenze tester Play**: per provare acquisti senza addebito reale (utile a te
   in sviluppo, non come "regalo").

---

## 6. Fase 3 — Beta testing con gli amici del settore (settimane 2–4)

Sono la risorsa più preziosa: docenti veri, con orari veri, che sanno dove fa
male.

### Come impostarlo
- Canale **Test interno** su Play Console: aggiungi le loro email Google, manda
  il link di opt-in
- Dai a ciascuno un **codice promo** per l'anno premium (testano anche il flusso
  abbonamento)
- Chat unica (WhatsApp/Telegram) per il gruppo — l'attrito di segnalare deve
  essere zero
- Ognuno prova con **la propria scuola reale**, non un caso finto

### Cosa chiedere di guardare
- L'orario generato è *usabile davvero* o solo "formalmente corretto"?
- Quanto tempo per inserire i dati della scuola? Dove si sono bloccati?
- Un vincolo che serviva e non c'era?
- Export PDF/Excel: lo porterebbero in sala docenti così com'è?

> **Patto chiaro.** Metti per iscritto lo scambio: **anno premium gratis** in
> cambio di **(1)** feedback strutturato entro una data e **(2)** una
> presentazione a colleghi / un post / una recensione sullo store. Gentile ma
> esplicito.

---

## 7. Fase 3 bis — Raccolta del feedback

Serve un canale *dentro* l'app, non solo la chat.

| Livello | Come | Sforzo |
|---|---|---|
| Minimo (subito) | Voce "Invia feedback" in Impostazioni che apre `mailto:` con oggetto precompilato (versione app, dispositivo) | ~1 ora, usa `url_launcher` che hai già |
| Consigliato | Un Google Form linkato dalle Impostazioni + link "Valuta l'app" alla scheda Play | Mezza giornata |
| Più avanti | Segnalazioni in una collection Firestore `feedback/` (con UID e versione), oppure Sentry per i crash | 1–2 giorni |

### Da tenere d'occhio comunque
- **Play Console → Vitals**: crash e ANR con stack trace. Gratis, già attivo.
- **Recensioni Play**: rispondi a tutte le prime, pubblicamente.
- **RevenueCat → Charts**: prove attivate, conversioni, disdette.

> **Privacy.** La QA checklist dice "nessun nome insegnante a terze parti". Se
> aggiungi Sentry o analytics, configura lo scrubbing dei dati e aggiorna
> informativa privacy e modulo Data safety.

---

## 8. Fase 4 — Marketing e pubblicità in Italia (dal lancio in poi)

Il prodotto è verticale e stagionale: si vende a **chi fa gli orari** (vicari,
docenti con incarico organizzativo, dirigenti di piccole scuole, paritarie,
scuole di musica e di lingue) e si vende **tra giugno e settembre**.

### Canali, in ordine di resa attesa
1. **Passaparola pilotato dagli amici beta**: ogni scuola ha una "persona degli
   orari" che parla con le colleghe di altre scuole. Chiedi introduzioni dirette.
2. **Gruppi Facebook di categoria** ("Vicari e collaboratori del DS", gruppi di
   animatori digitali, gruppi per ordine di scuola): rispondi a chi si lamenta
   degli orari, mostra il prodotto come soluzione. Non spam.
3. **Contenuto SEO**: 3–4 guide ("come costruire l'orario scolastico senza
   impazzire", "vincoli didattici e cattedre: gli errori tipici"). Intercetti chi
   cerca a luglio.
4. **Contatto diretto**: email brevi a segreterie di paritarie, scuole di musica,
   CFP, scuole di lingua della tua zona. Decisori rapidi, budget proprio.
5. **Video dimostrativo** di 60–90 s: dato → orario → export. Su Play Store, sito
   e gruppi.
6. **Ads a pagamento**: *solo dopo* aver visto una conversione organica decente.
   Google Ads su "software orario scolastico", budget piccolo e stagionale.

### Serve un minimo di presenza
- Una landing page (anche una schermata): problema, 3 screenshot, prezzo, link
  allo store, contatto
- Le pagine Privacy/Termini sullo stesso dominio
- Un indirizzo email di supporto che leggi davvero
- Screenshot e video curati: è un gestionale, deve trasmettere "mi fa
  risparmiare un weekend"

### Prezzo e prova
€14,99/anno è basso per un gestionale scolastico: vantaggio in adozione, ma
valuta un piano "scuola" più avanti. La prova da 1 orario è il tuo miglior
argomento di vendita: assicurati che il primo orario generato faccia dire "wow"
— se serve, guida l'utente con un caso di esempio precaricato.

> **Tempismo.** Se non arrivi in Produzione entro fine settembre, non perdere il
> 2026: usa l'autunno-inverno per beta, contenuti e lista d'attesa, e fai il
> lancio vero **ad aprile-maggio 2027**, prima della stagione.

---

## 9. Cose facili da dimenticare

- **Icona dell'app**: verifica che non sia ancora quella Flutter di default
  (`flutter_launcher_icons` la genera per tutte le densità)
- **Splash screen** personalizzata (`flutter_native_splash`)
- **Template email Firebase** (verifica, reset password) tradotti in italiano,
  mittente sensato, "action URL" personalizzato così non sembrano phishing
- **targetSdk**: Play impone un livello minimo aggiornato ogni anno; controlla il
  valore ereditato da Flutter prima di ogni release
- **Backup Firestore**: attiva le esportazioni pianificate
- **Piano Firebase Blaze** + **budget alert** su Google Cloud
- **Costi RevenueCat**: gratis sotto 2,5 k$/mese di ricavi tracciati, poi a pagamento
- **Numero di versione**: a ogni upload incrementa `version:` in `pubspec.yaml`
  (il numero dopo `+` deve sempre crescere)
- **Cosa succede quando l'abbonamento scade**: l'app deve tornare "in sola
  lettura" con garbo, senza cancellare dati — verificalo
- **Gestione offline** (AC-15): deve funzionare in aereo, riverifica su
  dispositivo reale
- **Marchio**: verifica veloce che "ClassScheduler" non sia già registrato in
  classe software/istruzione in UE
- **Limite 10 aule / 20 materie**: dichiaralo nella descrizione dello store
- **CI** (facoltativo): una GitHub Action con `flutter analyze` + `flutter test`
  a ogni push
- **Pulizia lint** (facoltativo): i ~180 avvisi `withOpacity` → `.withValues(alpha:)`
- **`tool/sa_tuning.dart`**: rotto (API cambiate). Da sistemare solo se vuoi
  ri-tarare l'annealing; l'app non lo usa

---

## 10. Un calendario possibile

| Quando | Obiettivo |
|---|---|
| Settimana 1 | Commit di prep · account Play Console · keystore · pagine legali online · deploy regole Firestore · Firebase su Blaze |
| Settimana 2 | Prodotto abbonamento in Play + RevenueCat · prima build firmata · app in Test interno · icona/splash definitive |
| Settimane 3–5 | Beta con gli amici · codici promo · canale feedback in app · itera sui problemi gravi |
| Settimana 6 | Scheda store completa · landing page · video demo · account di test per revisore |
| Settimana 7 | Promozione in Produzione · invio a revisione |
| Dal lancio | Rispondi a ogni recensione · gruppi Facebook · contenuti SEO · contatto diretto scuole · valuta ads a stagione |

---

*Documento di lavoro, generato il 30 agosto 2026 dallo stato del repository. Le
bozze legali in `legal/` vanno riviste da un professionista. Verifica sempre gli
importi di commissione, le soglie fiscali e i requisiti degli store, che cambiano
nel tempo.*
