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

### 1.4 🟢 Fai il deploy di regole e indici Firestore
```bash
firebase login
firebase deploy --only firestore:rules,firestore:indexes
```

✅ *Risultato atteso:* il comando termina con "Deploy complete!". In console,
`Firestore → Rules` mostra la data di oggi.

### 1.5 🟢 Controlla Authentication
In `Firebase Console → Authentication`:
- **Sign-in method:** Email/Password e Google devono essere **abilitati**.
- **Templates:** apri "Reimposta password" e "Verifica indirizzo email", metti
  la lingua **italiano** e un nome mittente sensato ("ClassScheduler").

---

## TAPPA 2 — Chiave di firma + icona + prima build

### 2.1 🟢⚠️ Genera la chiave di firma (una volta per sempre)
```bash
keytool -genkey -v -keystore %USERPROFILE%\classscheduler-upload.jks ^
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```
Ti chiede: una password per il keystore, i tuoi dati (nome, org, città, paese
`IT`), e conferma. **Annota tutto.**

Poi:
```bash
copy android\key.properties.example android\key.properties
```
Apri `android/key.properties` e compila `storeFile` (percorso completo del
`.jks`), `storePassword`, `keyAlias` (`upload`), `keyPassword`.

> ⚠️ **Backup ADESSO.** Copia il file `classscheduler-upload.jks` e le password
> in **due posti sicuri** (es. password manager + chiavetta/USB o cloud
> privato). Se li perdi **non potrai mai più aggiornare l'app pubblicata**.
> `key.properties` e `*.jks` sono già esclusi da git: non finiranno nel repo.

✅ *Verifica:* `git status` **non** deve elencare `key.properties` né file `.jks`.

### 2.2 🟢 Metti un'icona vera (ora è quella di default di Flutter)
Ti serve un'immagine quadrata **1024×1024 px** PNG del logo (fondo pieno, senza
angoli arrotondati — li mette il sistema). Se non ce l'hai, fattene fare una
semplice (anche solo iniziali "CS" su fondo colorato).

Quando ce l'hai, chiedimi di configurare `flutter_launcher_icons` e
`flutter_native_splash`: aggiungo i pacchetti, il blocco di config e genero
icona + splash per Android in un colpo.

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
Assicurati che tutte le sezioni "Contenuti dell'app" e "Scheda" siano ✅.
Ricontrolla su un telefono reale i punti critici della tua `QA_CHECKLIST.md`
(in particolare AC-06 performance, AC-09 prova, AC-10 ripristino, AC-13
cancellazione account, AC-15 offline).

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
- Aggiungere e configurare `flutter_launcher_icons` + `flutter_native_splash`
  (mi serve il PNG 1024×1024).
- Implementare la voce "Invia feedback" nelle Impostazioni.
- Aggiungere una GitHub Action che lancia `flutter analyze` + `flutter test` a
  ogni push.
- Scrivere una bozza di descrizione breve/lunga per lo Store.
