# ClassScheduler — Guida passo-passo al primo rilascio

Questa è la sequenza **lineare** da seguire, un punto alla volta. Non saltare
avanti: alcuni passi hanno tempi di attesa (verifica account, test chiuso
obbligatorio) e vanno avviati presto.

Per la **strategia** (marketing, pricing, feedback) vedi `LAUNCH_ROADMAP.it.md`.
Questa guida è solo "cosa faccio, in che ordine".

**Legenda:** 🟢 lo puoi fare adesso · 🟡 dipende da un passo precedente ·
⏳ ha un tempo di attesa, avvialo presto · 💶 costa · ⚠️ irreversibile / delicato

---

## Mappa generale (7 tappe)

| # | Tappa | Durata indicativa |
|---|---|---|
| 0 | Preparazione (commit, account, decisioni) | 1 giorno di lavoro + ⏳ attese |
| 1 | Pagine legali online + Firebase in produzione | mezza giornata |
| 2 | Chiave di firma + icona + prima build | mezza giornata |
| 3 | App su Play Console (scheda + dichiarazioni) | 1 giornata |
| 4 | Abbonamento (Play + RevenueCat) | mezza giornata |
| 5 | **Test chiuso con ≥ 12 tester per ≥ 14 giorni** (obbligatorio) | 2–3 settimane |
| 6 | Richiesta accesso a Produzione + pubblicazione | 1–7 giorni di revisione |

> ⚠️ **La sorpresa più grande per chi parte oggi:** con un account sviluppatore
> Play **personale** (non "società"), Google obbliga a un **test chiuso con
> almeno 12 tester che restano iscritti per almeno 14 giorni** *prima* di poter
> chiedere l'accesso alla pubblicazione in Produzione. I tuoi amici insegnanti
> sono esattamente questi tester. Quindi la beta non è un "extra": è un
> passaggio obbligato. Organizzati per averne **12, non 3**. (Verifica il testo
> esatto del requisito quando apri Play Console: Google lo aggiorna.)

---

## TAPPA 0 — Preparazione

### 0.1 🟢 Committa le modifiche già pronte
Nel terminale, dentro la cartella del progetto:

```bash
git add -A
git commit -m "chore: production release prep (signing, secrets, legal, docs)"
git push
```

✅ *Risultato atteso:* `git status` dice "working tree clean".

### 0.2 🟢💶⏳ Apri l'account Google Play Console
1. Vai su <https://play.google.com/console/signup>.
2. Scegli account **personale** (per iniziare va bene).
3. Paga la quota **una tantum di 25 $**.
4. Completa la **verifica d'identità** (documento). Google può metterci
   **da qualche ora fino a diversi giorni**.

✅ *Risultato atteso:* accedi a Play Console e vedi la dashboard vuota, senza
banner rossi di "verifica in sospeso".

> Consiglia: usa un indirizzo Gmail **dedicato all'attività** (es.
> `classscheduler.app@gmail.com`), non quello personale. Ti servirà anche come
> email di supporto e come proprietario di Firebase/RevenueCat.

### 0.3 🟢 Registra un dominio e prepara dove mettere le pagine legali
Serve un URL pubblico e stabile per Privacy e Termini (obbligatorio per Play).
Opzioni:
- **Gratis:** repository GitHub + **GitHub Pages** (ti guido alla Tappa 1).
- **~10–15 €/anno:** un dominio tuo (es. `classscheduler.app`) con una
  paginetta. Più professionale, utile anche per il marketing.

Decidi ora quale strada; l'attivazione la fai alla Tappa 1.

### 0.4 🟢 Fai rivedere le bozze legali
Apri `legal/privacy-policy.it.md` e `legal/terms-of-service.it.md`, compila i
campi tra `[parentesi quadre]` (nome, email, città) e falle leggere a qualcuno
che se ne intende (avvocato, commercialista, o anche un collega esperto). Sono
bozze ragionevoli ma la responsabilità legale è tua.

### 0.5 🟢⏳ Parla con un commercialista
Domanda precisa da fargli: *"Vendo un abbonamento ad app tramite Google Play,
Google incassa e mi versa il netto mensile. Cosa mi serve in Italia — partita
IVA, che regime, come dichiaro?"*. Non blocca i passi tecnici, ma va avviato
ora perché serve **prima del primo incasso reale**.

### 0.6 🟢 Verifica veloce sul nome
Cerca "ClassScheduler" su <https://euipo.europa.eu/eSearch/> (marchi UE) e sul
Play Store. Se esiste già un'app identica per nome nel settore istruzione,
meglio saperlo adesso.

---

## TAPPA 1 — Pagine legali online + Firebase in produzione

### 1.1 🟢 Pubblica Privacy e Termini con GitHub Pages
Le pagine sono **già pronte** nella cartella `docs/` del progetto
(`index.html`, `privacy.html`, `terms.html`). Devi solo caricarle e accendere
GitHub Pages.

1. Nel terminale, dalla cartella del progetto:
   ```bash
   git add -A
   git commit -m "docs: pagine privacy e termini per GitHub Pages"
   git push
   ```
2. Sul sito github.com apri il tuo repo → **Settings** (in alto) →
   **Pages** (menu a sinistra).
3. Sotto **Build and deployment → Source** scegli **Deploy from a branch**.
4. **Branch:** `main` · **Folder:** `/docs` · premi **Save**.
5. Aspetta 1–2 minuti, poi ricarica la pagina Settings → Pages: comparirà
   "Your site is live at …".

Gli indirizzi delle due pagine saranno:
- `https://matteopergoli.github.io/ClassScheduler/privacy.html`
- `https://matteopergoli.github.io/ClassScheduler/terms.html`

✅ *Risultato atteso:* apri quei due URL in una finestra in incognito e vedi le
pagine impaginate.

### 1.2 🟡 Aggiorna gli URL nell'app
In `lib/core/constants/app_constants.dart` sostituisci:

```dart
static const String privacyPolicyUrl = 'https://matteopergoli.github.io/ClassScheduler/privacy.html';
static const String termsUrl          = 'https://matteopergoli.github.io/ClassScheduler/terms.html';
```

Poi committa (`git commit -am "chore: URL legali reali"`).

### 1.3 🟢💶 Porta Firebase al piano Blaze
1. <https://console.firebase.google.com> → progetto **classscheduler-b2918**.
2. In basso a sinistra, **Upgrade** → piano **Blaze** (pay as you go). Serve una
   carta. Con i volumi di una app appena nata la spesa è tipicamente **0–pochi €**.
3. Subito dopo: **Budget alert**. Vai su Google Cloud Console →
   Billing → Budgets & alerts → crea un budget di es. 10 €/mese con avviso via
   email al 50/90/100%.

✅ *Risultato atteso:* il progetto Firebase mostra "Blaze" e hai un budget attivo.

### 1.4 Pubblica le regole di sicurezza e gli indici Firestore

Questo passo si fa **online, sul sito di Firebase** (console.firebase.google.com),
oppure da terminale con la Firebase CLI. Sul tuo PC la CLI non è installata,
quindi la via più veloce è il sito. Sono due cose distinte: **regole** e **indici**.

**A) Regole di sicurezza — falla SUBITO (è la protezione dei dati)** 🟢
1. <https://console.firebase.google.com> → progetto **classscheduler-b2918**.
2. Menù a sinistra: **Build → Firestore Database** → scheda **Rules** (Regole).
3. Apri il file `firestore.rules` del progetto, **seleziona tutto, copia**.
4. Incolla nel riquadro sul sito **sostituendo** quello che c'è → premi
   **Publish** (Pubblica).

✅ *Risultato atteso:* in cima compare "Last published: oggi". Se prima c'era
scritto qualcosa come `allow read, write: if true;` (modalità test), ora non
c'è più: il database è chiuso e ogni utente vede solo i propri dati.

**B) Indici — puoi farli ora oppure durante la beta** 🟡
Servono 8 indici composti (elencati in `firestore.indexes.json`). Senza, alcune
schermate danno un errore a runtime. Due modi:

- *Il più semplice:* **non farli adesso.** Durante il test, quando una schermata
  ha bisogno di un indice, Firestore mostra un errore con un **link diretto**:
  cliccalo, si apre la console già compilata, premi **Create**. Ne creerai
  qualcuno in pochi minuti mentre provi l'app.
- *Tutti in una volta (serve la CLI):* installa Node.js da <https://nodejs.org>,
  poi nel terminale del progetto:
  ```bash
  npm install -g firebase-tools
  firebase login
  firebase deploy --only firestore:rules,firestore:indexes
  ```
  Ho già preparato `firebase.json` e `.firebaserc`, quindi il comando funziona
  senza altra configurazione. La creazione degli indici lato Google richiede
  qualche minuto dopo il "Deploy complete!".

> Per ora fai solo la parte **A**. La parte B la gestisci quando parte la beta.

### 1.5 Controlla e sistema l'accesso degli utenti (Authentication)

Tutto sul sito: <https://console.firebase.google.com> → progetto
**classscheduler-b2918** → menù a sinistra **Build → Authentication**.
Tre sotto-passi.

#### 1.5.a 🟢 Verifica i metodi di accesso attivi
Scheda **Sign-in method** (Metodo di accesso). Devi vedere **abilitati**:
- **Email/Password** → deve essere "Enabled".
- **Google** → deve essere "Enabled". Se lo apri, controlla che il campo
  "Nome pubblico del progetto" sia `ClassScheduler` e che ci sia una email di
  assistenza selezionata.
- **Apple** → per ora **lascialo com'è** (spento va bene): serve solo quando
  farai la versione iOS.

Se Email/Password o Google risultano disabilitati, clicca sulla riga → attiva →
**Save**.

✅ *Risultato atteso:* nella lista, accanto a Email/Password e Google c'è scritto
"Enabled".

#### 1.5.b 🟢 Impronte SHA per il login Google su Android
Il login con Google su Android funziona **solo** se Firebase conosce l'"impronta
digitale" (SHA-1 / SHA-256) del certificato con cui l'app è firmata. Ne servono
di più, in momenti diversi:

| Impronta | Da dove viene | Quando aggiungerla |
|---|---|---|
| Debug | Il tuo PC (keystore di debug di Flutter) | **ora**, per provare l'app in sviluppo |
| Upload key | Il keystore che generi al passo **2.1** | dopo il passo 2.1 |
| App signing key | Generata da Google quando attivi Play App Signing (passo **2.4**) | **dopo il passo 2.4** — è quella che quasi tutti dimenticano, e senza il login Google si rompe in produzione |

**Ora** aggiungi solo quella di debug. In PowerShell, dal progetto — il modo più
semplice (mostra debug e release insieme):
```powershell
cd android
.\gradlew signingReport
```
oppure con keytool per percorso completo (su PowerShell serve `&` e
`$env:USERPROFILE`, non `%USERPROFILE%`):
```powershell
& "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" -list -v -keystore "$env:USERPROFILE\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```
Copia le righe **SHA1** e **SHA-256** (variante `debug`). Poi in Firebase Console:
**Impostazioni progetto** (ingranaggio in alto a sinistra) → scheda **Generali**
→ sezione **Le tue app** → app Android `com.classscheduler.classscheduler` →
**Aggiungi impronta digitale** → incolla SHA-1, salva, ripeti per SHA-256.

> 📌 Segnati questo: **dopo il passo 2.4** dovrai tornare qui e aggiungere le
> impronte della "App signing key" (le trovi in Play Console → Test e release →
> **Firma dell'app** → "Certificato della chiave di firma dell'app"). Se lo
> salti, il login Google funziona in test ma **fallisce per gli utenti veri**.

#### 1.5.c 🟢 Traduci in italiano le email automatiche
Firebase invia da solo le email di "reimposta password" e "verifica indirizzo".
Di default sono in inglese. Scheda **Templates** (Modelli):
1. In alto scegli la lingua del modello: **italiano**.
2. Apri **Reimpostazione della password** → **Verifica indirizzo email** →
   per ciascuno imposta **Nome mittente** = `ClassScheduler` e controlla che il
   testo sia in italiano. Salva.
3. L'indirizzo mittente resta `noreply@classscheduler-b2918.firebaseapp.com`:
   per il lancio va bene, personalizzare il dominio si può fare più avanti.

✅ *Risultato atteso:* i modelli mostrano testo italiano e mittente
"ClassScheduler".

---

## TAPPA 2 — Chiave di firma + icona + prima build

### 2.1 🟢⚠️ Genera la chiave di firma (una volta per sempre)
In **PowerShell**, da una cartella qualsiasi (il file finisce in `C:\Users\pergo\`),
tutto su una riga (`keytool` non è nel PATH → percorso completo):
```powershell
& "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe" -genkey -v -keystore "$env:USERPROFILE\classscheduler-upload.jks" -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```
Ti chiede in sequenza: una **password** per il keystore (digitala 2 volte),
nome/cognome, unità e organizzazione (Invio per saltare), città (`San Miniato`),
provincia (`Pisa`), **codice paese** (`IT`), conferma (`sì`), e infine la
password della chiave → premi **Invio** per usare la stessa del keystore.
**Annota tutto.**

Poi:
```powershell
copy android\key.properties.example android\key.properties
notepad android\key.properties
```
Compila:
- `storeFile=C:/Users/pergo/classscheduler-upload.jks` (barre `/`, non `\`)
- `storePassword=` la password scelta sopra
- `keyAlias=upload`
- `keyPassword=` la stessa password (se hai premuto Invio all'ultima domanda)

> ⚠️ **Backup ADESSO.** Copia il file `classscheduler-upload.jks` e le password
> in **due posti sicuri** (es. password manager + chiavetta/USB o cloud
> privato). Se li perdi **non potrai mai più aggiornare l'app pubblicata**.
> `key.properties` e `*.jks` sono già esclusi da git: non finiranno nel repo.

✅ *Verifica:* `git status` **non** deve elencare `key.properties` né file `.jks`.

### 2.2 Icona e splash screen

**Icona — ✅ FATTA.** Un mini-orario su gradiente viola del brand. L'art è
generata da `test/generate_icon.dart` (`assets/icon/`), applicata ad Android e
iOS con `flutter_launcher_icons` (config in `pubspec.yaml`). Per rigenerarla dopo
una modifica: `flutter test test/generate_icon.dart` poi
`dart run flutter_launcher_icons`. Per cambiarne il disegno, chiedi.

**Splash screen — ✅ FATTA.** Sfondo viola del brand con il logo-orario al
centro, via `flutter_native_splash` (config in `pubspec.yaml`, art
`assets/icon/splash_logo.png`). Applicata ad Android (incl. Android 12+) e iOS.
Per rigenerarla dopo una modifica dell'art: `dart run flutter_native_splash:create`.

### 2.3 🟡 Crea l'app (guscio) su Play Console
1. Play Console → **Crea app**.
2. Nome: **ClassScheduler** · Lingua predefinita: **Italiano (Italia)**.
3. App o gioco: **App** · Gratuita o a pagamento: **Gratuita**.
4. Dichiarazioni iniziali (linee guida + leggi USA export): accetta.

✅ *Risultato atteso:* l'app compare nella lista con stato "Bozza".

### 2.4 🟡 Prima build firmata e primo caricamento
Anche senza le chiavi RevenueCat: la prova gratuita funziona lo stesso,
mancherà solo l'acquisto (lo aggiungi alla Tappa 4).

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
flutter test
flutter build appbundle --release
```
✅ *Risultato atteso:* `√ Built build\app\outputs\bundle\release\app-release.aab`.

Poi in Play Console: **Test → Test interno → Crea release → carica l'`.aab`**.
Se ti chiede di attivare **Play App Signing**, **accetta** (è il comportamento
consigliato: Google custodisce la chiave finale, tu gestisci solo la upload key).

✅ *Risultato atteso:* la release "interna" risulta caricata, senza errori
bloccanti sull'`.aab`.

---

## TAPPA 3 — Scheda Play Store + dichiarazioni

Nel menu di sinistra di Play Console, lavora su queste sezioni finché non
diventano tutte ✅ verdi.

### 3.1 🟡 "Dashboard" → completa il percorso guidato
Play Console ti mostra una checklist "Configura la tua app". Seguila voce per
voce. Le principali:

### 3.2 🟡 Contenuti dell'app (Policy → App content)
- **Informativa sulla privacy:** incolla l'URL della Tappa 1.
- **Accesso all'app:** se serve un login per vedere tutto, fornisci
  **credenziali di un account di test** (creane uno vero) nelle note.
- **Annunci:** dichiara **"No, non contiene annunci"**.
- **Sicurezza dei dati (Data safety):** compila il modulo. In sintesi per questa
  app: raccogli **Indirizzo email** e **ID utente**; dati **cifrati in transito**;
  l'utente **può chiederne la cancellazione**; non condividi dati con terzi per
  pubblicità.
- **Classificazione dei contenuti:** compila il questionario → risultato atteso
  **PEGI 3 / Everyone**.
- **Pubblico di destinazione:** **solo adulti (18+)**; l'app non è rivolta a
  bambini.
- Le altre voci (app di notizie, COVID, funzionalità finanziarie, governo):
  rispondi **No**.

### 3.3 🟡 Scheda del Play Store (Store presence → Main store listing)
- **Nome app:** ClassScheduler
- **Descrizione breve:** max 80 caratteri (es. "Genera in automatico l'orario
  scolastico rispettando i tuoi vincoli").
- **Descrizione completa:** cosa fa, per chi, i limiti noti (max 10 aule / 20
  materie), che serve un account per la sincronizzazione.
- **Icona:** PNG 512×512.
- **Immagine in evidenza:** 1024×500.
- **Screenshot telefono:** almeno 2 (meglio 4–8). Falli belli: schermata dati →
  orario generato → export.

### 3.4 🟡 Paese e prezzo
- **Distribuzione:** seleziona **solo Italia** per ora.
- Gratuita (l'abbonamento è un acquisto in-app, si configura alla Tappa 4).

---

## TAPPA 4 — Abbonamento (Play + RevenueCat)

### 4.1 🟡 Crea l'abbonamento in Play Console
**Monetizza → Prodotti → Abbonamenti → Crea abbonamento.**
- **ID prodotto:** `classscheduler_annual_1490` (deve essere **esatto**: è quello
  scritto nel codice).
- **Piano base:** rinnovo automatico, periodo **1 anno**, prezzo **€ 14,99** per
  l'Italia.
- Attiva l'abbonamento e il piano base.

### 4.2 🟡 Collega Google Play a RevenueCat
1. <https://app.revenuecat.com> → crea Project "ClassScheduler" → aggiungi
   **app Android** con package `com.classscheduler.classscheduler`.
2. RevenueCat ti chiede un **service account Google** con accesso a Play:
   segui la loro guida (crei il service account in Google Cloud, lo inviti in
   Play Console con permesso "Visualizza dati finanziari" + "Gestisci ordini",
   incolli il JSON in RevenueCat).
3. In RevenueCat: **Products** → importa `classscheduler_annual_1490`.
4. **Entitlements** → crea `classscheduler_annual` → associa il prodotto.
5. **Offerings** → crea un offering di default con quel prodotto.
6. Copia la **Public SDK Key** Android (in *API keys*, inizia con `goog_`).

### 4.3 🟡 Ricompila con la chiave RevenueCat e ricarica
```bash
flutter build appbundle --release ^
  --dart-define=RC_ANDROID_KEY=goog_LA_TUA_CHIAVE
```
Carica il nuovo `.aab` sul track **Test interno** (numero di versione già
gestito da `pubspec.yaml`; per le release successive incrementalo, es. `1.0.1+2`).

### 4.4 🟡 Prepara i tester per gli acquisti
- **Monetizza → Configurazione → Tester delle licenze:** aggiungi le email dei
  tuoi tester → potranno "comprare" senza pagamento reale.
- **Codici promozionali** (per regalare l'anno premium agli amici): li generi
  dalla pagina dell'abbonamento, sezione promozioni.

### 4.5 🟡 Prova tu l'acquisto end-to-end
Installa la build di test sul tuo telefono (dal link di opt-in del track
interno), fai il flusso: prova gratuita → paywall → acquisto (da license
tester) → l'app sblocca le generazioni. Poi **Ripristina acquisti** da un
secondo dispositivo o dopo reinstallazione.

✅ *Risultato atteso:* acquisto completato, generazioni sbloccate, ripristino ok.
In RevenueCat → **Customers** vedi il tuo acquisto.

---

## TAPPA 5 — Test chiuso obbligatorio (≥ 12 tester, ≥ 14 giorni)

### 5.1 🟡 Crea il track "Test chiuso"
Play Console → **Test → Test chiuso → crea track** (o usa "Closed testing –
Alpha"). Promuovi la release che hai già caricato.

### 5.2 🟡 Aggiungi i tester
- Crea una **lista email** con **almeno 12 indirizzi Gmail** (i tuoi amici
  insegnanti + colleghi/parenti disposti ad aiutare).
- Manda a ciascuno il **link di opt-in** del track. Devono aprirlo, accettare, e
  installare l'app dal Play Store.

✅ *Verifica:* Play Console mostra il conteggio dei tester "opted in". Deve
arrivare **≥ 12** e restare tale.

### 5.3 🟡 Fai partire davvero l'uso
- Dai a ognuno un **codice promo** per l'anno premium.
- Chat unica del gruppo (WhatsApp/Telegram) per raccogliere segnalazioni.
- Chiedi di provare con **la loro scuola vera**.
- Aggiungi in app un canale feedback minimo: voce "Invia feedback" in
  Impostazioni con `mailto:` precompilato (posso implementartelo, ~1 ora).

### 5.4 🟡 Itera per ≥ 14 giorni
Correggi i bug seri, carica nuove build sul track (incrementando la versione).
Il contatore dei 14 giorni richiede che i tester **restino iscritti**; non
rimuoverli.

---

## TAPPA 6 — Produzione

### 6.1 🟡 Richiedi l'accesso alla Produzione
Quando hai soddisfatto il requisito (≥ 12 tester per ≥ 14 giorni), in Play
Console compare la possibilità di **richiedere l'accesso alla pubblicazione in
produzione**. Compila il breve form (com'è andato il test, ecc.). Google
risponde di solito in **pochi giorni**.

### 6.2 🟡 Ultimo giro di checklist

**Cose rimandate che ORA vanno chiuse:**
- [ ] **Indici Firestore (passo 1.4.B):** creati tutti gli 8, oppure verificato
      durante la beta che nessuna schermata dà più l'errore "requires an index".
- [ ] **Impronte SHA della App signing key (passo 1.5.b):** aggiunte in Firebase
      Console dopo il primo caricamento su Play. Verifica: il login con Google
      funziona su una build **scaricata dal Play Store** (non solo in locale).
- [ ] **URL legali (passo 1.2):** `privacyPolicyUrl` e `termsUrl` in
      `app_constants.dart` puntano alle pagine vere e pubblicate.
- [ ] **Chiavi RevenueCat di produzione** passate con `--dart-define` nella build
      finale (passo 4.3).
- [ ] **Icona e splash** non più quelli di default (passo 2.2).

**Verifiche su un telefono reale** (punti critici di `QA_CHECKLIST.md`):
AC-06 performance, AC-09 prova gratuita, AC-10 ripristino acquisti,
AC-13 cancellazione account, AC-15 generazione offline.

Assicurati infine che tutte le sezioni "Contenuti dell'app" e "Scheda" in Play
Console siano ✅ verdi.

### 6.3 🟡 Crea la release di Produzione
**Produzione → Crea release** → riusa lo stesso `.aab` testato → note di
versione in italiano → **rollout graduale** (inizia col 20%, poi sali).
Invia in revisione (1–7 giorni la prima volta).

### 6.4 🟢 Dopo la pubblicazione
- Rispondi a **tutte** le prime recensioni.
- Controlla ogni 2–3 giorni **Play Console → Qualità → Android vitals** (crash).
- Controlla **RevenueCat → Charts** (prove, conversioni, disdette).
- Attiva le **esportazioni pianificate** di Firestore (backup dati utenti).

---

## Cosa posso fare io per te (chiedimelo)

- ~~Preparare la cartella `docs/` con Privacy e Termini in HTML per GitHub Pages.~~ ✅ fatto
- ~~Configurare icona (`flutter_launcher_icons`) e splash (`flutter_native_splash`).~~ ✅ fatto
- Implementare la voce "Invia feedback" nelle Impostazioni.
- Aggiungere una GitHub Action che lancia `flutter analyze` + `flutter test` a
  ogni push.
- Scrivere una bozza di descrizione breve/lunga per lo Store.
