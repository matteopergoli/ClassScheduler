# ClassScheduler — Riattivazione dell'abbonamento a pagamento

## Contesto e decisione (2026-09-12)

Il primo anno di ClassScheduler esce **completamente gratuito, tutto sbloccato,
senza abbonamento**. Motivo: non c'è ancora una partita IVA aperta, e prima di
affrontarla ha senso capire se il prodotto vale abbastanza da giustificarla —
un anno di rilascio gratuito è il modo più semplice per scoprirlo.

Due strade possibili dopo il primo anno, non alternative tra loro:
1. **Riattivare l'abbonamento a pagamento** dentro l'app (questo documento).
2. **Affidarsi a un'azienda di publishing** che porti l'app anche su Apple
   (dove oggi non c'è modo di entrare senza Mac) in cambio di royalty — un
   percorso commerciale, non tecnico: non richiede modifiche al codice descritte
   qui, ma se il publisher userà comunque un modello ad abbonamento, questo
   stesso interruttore torna utile.

Questo documento copre **solo la via 1**: come e quando riaccendere
l'abbonamento nel codice, e cosa succede agli account esistenti quel giorno.

---

## Il meccanismo: un solo interruttore

Tutto il gating a pagamento è concentrato dietro **una costante**:

```dart
// lib/core/constants/app_constants.dart
static const bool subscriptionsEnabled = false;
```

Finché è `false`:
- **`GenerationService.generate()`** ([lib/domain/scheduler/generation_service.dart](lib/domain/scheduler/generation_service.dart))
  salta del tutto il controllo prova/abbonamento (passo 0) e non scrive mai
  `trialUsed` (passo 7) — ogni account genera orari senza limiti.
- **`TrialBanner`** ([lib/presentation/widgets/trial_banner.dart](lib/presentation/widgets/trial_banner.dart))
  non si mostra mai.
- **Impostazioni → "Abbonamento"** ([lib/presentation/settings/settings_screen.dart](lib/presentation/settings/settings_screen.dart))
  non compare come voce di menu.
- **RevenueCat non si inizializza mai**: nessun codice legge più
  `subscriptionServiceProvider` nel percorso normale dell'app, quindi
  `Purchases.configure(...)` non viene mai chiamato. Questo è voluto: durante
  il lancio gratuito non servono chiavi RevenueCat vere né prodotti live negli
  store.

Tutto il resto — `SubscriptionService`, `SubscriptionScreen`, le regole
Firestore su `/entitlements/{uid}`, la logica di `trialUsed` — **esiste già,
non è stato toccato**, aspetta solo che il flag torni `true`.

---

## Cosa succede agli account esistenti quando riattivi

Questo è il punto che avevi chiesto di garantire esplicitamente: **il giorno
in cui rimetti `subscriptionsEnabled = true`, ogni account che in quel momento
non ha un abbonamento RevenueCat attivo né un omaggio (`/entitlements`) valido
perde l'accesso alla generazione di nuovi orari**, a meno che non paghi la
quota annuale. Nessun "si salvano tutti quelli già iscritti": è una
conseguenza diretta e automatica del codice esistente, non serve scrivere
nulla di nuovo.

Perché succede senza bisogno di una migrazione o di uno script apposito:

- Durante l'anno gratuito, `trialUsed` **non viene mai scritto** (il passo 7 è
  saltato). Quindi ogni account che si è iscritto durante l'anno gratuito ha
  ancora `trialUsed = false` nel suo documento Firestore.
- Nel momento in cui riattivi il flag, `GenerationService` torna a fare il
  controllo del passo 0: *"hai già usato la prova E non hai un abbonamento
  attivo E non hai un omaggio? → bloccato"*.
- Per un account con `trialUsed = false`, questo controllo **lascia passare
  la primissima generazione** dopo la riattivazione (la prova gratuita "si
  consuma" a quel punto, come per un utente nuovo) — poi, dalla seconda
  generazione in poi, serve l'abbonamento.
- Chi invece aveva già consumato la prova **prima** di questa modifica (i
  beta tester della fase a pagamento originale, se ce ne sono stati) ha
  `trialUsed = true` da subito: per loro il blocco scatta **immediatamente**,
  senza nemmeno una generazione di cortesia.

In pratica: nessuno resta "abbonato gratis per sempre" solo per essersi
iscritto durante l'anno gratuito. Ogni utente, alla riattivazione, ha al più
una generazione di margine (se non l'aveva già usata) e poi deve pagare la
quota annuale come chiunque altro — esattamente il comportamento richiesto.

> Se invece un giorno vorrai **premiare** specificamente chi ti ha usato
> durante l'anno gratuito (es. i primi 50 iscritti, o chi ha generato almeno
> un orario), puoi farlo *manualmente e selettivamente* con lo stesso
> meccanismo già usato per i beta tester: un documento in
> `/entitlements/{uid}` con `premiumUntil` — vedi `GUIDA_PASSO_PASSO.it.md`
> §4.6. Non è automatico, è una scelta che fai account per account (o con uno
> script Admin SDK se sono tanti) **prima** di riattivare il flag.

---

## Prima di riattivare: avvisa gli utenti

Il codice non manda notifiche da solo. Se non avvisi nessuno, un utente attivo
si sveglierà un giorno con l'app che chiede l'abbonamento senza preavviso — 
cattiva esperienza, recensioni negative. Consigliato, con un anticipo di
**almeno 4–6 settimane**:

1. **In app, per tempo**: una nuova versione con un banner/changelog che dice
   "dal [data] ClassScheduler introduce un abbonamento annuale di €14,99; chi
   lo attiva entro il [data] ha [eventuale sconto/mese omaggio]". Non serve
   codice nuovo per il banner: basta un `AlertDialog` "cosa c'è di nuovo"
   mostrato una volta, oppure — più semplice — un'email agli utenti registrati
   (hai le email via Firebase Auth, esportabili dalla console).
2. **Decidi se dare un vantaggio ai primi utenti** (facoltativo): uno sconto
   promo Play (§4.4 di `GUIDA_PASSO_PASSO.it.md`) o un mese/anno omaggio via
   `/entitlements` per chi si è registrato durante il periodo gratuito.
3. **Aggiorna Privacy/Termini se necessario**: se introduci pagamenti,
   `legal/terms-of-service.it.md` deve menzionarli (probabilmente già li
   menziona, essendo stato scritto pensando a un modello a pagamento —
   verifica prima di ripubblicare).

---

## Runbook tecnico per riattivare

1. **Parla con un commercialista** (vedi TAPPA 0.5 di `GUIDA_PASSO_PASSO.it.md`)
   — a questo punto avrai un incasso reale da dichiarare, serve saperlo
   gestire *prima* del primo incasso.
2. **Rifai la TAPPA 4** di `GUIDA_PASSO_PASSO.it.md` (Play + RevenueCat) — è
   rimasta nella guida apposta, con tutti i passi (creare l'abbonamento in
   Play Console, collegare RevenueCat, chiave SDK). Se anche iOS è live nel
   frattempo, rifai anche la TAPPA 4 di `GUIDA_APP_STORE.it.md`.
3. **Nel codice**, in `lib/core/constants/app_constants.dart`:
   ```dart
   static const bool subscriptionsEnabled = true;
   ```
   Un solo cambio riga. Nessun'altra modifica è necessaria: banner, gate,
   voce Impostazioni, tutto torna a comportarsi come nella versione a
   pagamento originale.
4. **Aggiorna la scheda Play Store** (Play Console → Presenza sullo store):
   rimetti "contiene acquisti in-app" (l'inverso della modifica fatta al passo
   3.4 di `GUIDA_PASSO_PASSO.it.md` per il lancio gratuito), e aggiorna il
   modulo *Data safety* se necessario.
5. **Ricompila e ricarica** con le chiavi vere:
   ```bash
   flutter build appbundle --release --dart-define=RC_ANDROID_KEY=goog_...
   ```
   (e `--dart-define=RC_IOS_KEY=appl_...` se rilevante), poi carica come da
   passo 4.3/6.3 della guida.
6. **Rifai il giro di test end-to-end** prima del rollout: AC-09 (prova
   gratuita — ora si consuma davvero), AC-10 (ripristino acquisti), acquisto
   sandbox/license-tester. Sono nei test già presenti in
   `test/integration/acceptance_test.dart`.
7. **Rollout graduale** come per qualunque release (Play Console → Produzione
   → percentuale crescente), per intercettare per tempo eventuali
   segnalazioni.

### Se qualcosa va storto: rollback immediato

Rimetti `subscriptionsEnabled = false`, ricompila (non servono le chiavi
RevenueCat per tornare gratis), carica una release — il gate sparisce di
nuovo per tutti entro pochi minuti dall'aggiornamento.

---

## Checklist riassuntiva

- [ ] Utenti avvisati con almeno 4–6 settimane di anticipo
- [ ] (Facoltativo) omaggi/sconti decisi per i primi utenti, applicati via
      `/entitlements` o codici promo **prima** della riattivazione
- [ ] Commercialista consultato, partita IVA/regime pronti
- [ ] Abbonamento ricreato in Play Console (e App Store Connect se rilevante)
- [ ] RevenueCat ricollegato, entitlement `classscheduler_annual` attivo
- [ ] `AppConstants.subscriptionsEnabled = true`
- [ ] Scheda Play Store aggiornata (contiene acquisti in-app)
- [ ] Build ricompilata con `--dart-define` reali, testata end-to-end
- [ ] Rollout graduale, monitorato
