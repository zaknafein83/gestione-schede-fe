import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import 'legal_scaffold.dart';

/// Informativa privacy ex art. 13 GDPR (Reg. UE 2016/679).
///
/// La versione italiana e' quella ufficiale; in altre lingue lo scaffold mostra
/// un avviso. Testo scritto a mano sulla base di:
///   - dati realmente raccolti dal backend (cfr. cascade delete in
///     ProfileService.deleteAccount per la lista completa delle collection)
///   - sub-processor effettivi (Resend, OVH, GitHub)
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return LegalScaffold(
      title: l10n.legalPrivacyTitle,
      children: [
        legalP(
          'La presente informativa descrive come PG 5e (di seguito anche "il Servizio") '
          'tratta i dati personali degli utenti, in osservanza del Regolamento (UE) 2016/679 '
          '(GDPR) e del D. Lgs. 196/2003 ("Codice Privacy") come modificato dal D. Lgs. 101/2018.',
        ),

        // ------------------------------------------------------------------
        legalH1('1. Titolare del trattamento'),
        legalP(
          'Titolare del trattamento è Francesco Sisca (persona fisica), residente in Corigliano-Rossano (CS), '
          'Italia, contattabile all\'indirizzo email franksisca@gmail.com. '
          'Non è designato un Responsabile della Protezione dei Dati (DPO) in quanto non sussistono '
          'i presupposti previsti dall\'art. 37 GDPR.',
        ),

        // ------------------------------------------------------------------
        legalH1('2. Categorie di dati trattati'),
        legalP('Il Servizio tratta le seguenti categorie di dati personali:'),
        legalH2('2.1 Dati forniti volontariamente dall\'utente'),
        legalUl([
          'Indirizzo email — necessario per registrazione, accesso e verifica account.',
          'Password — conservata esclusivamente in forma di hash crittografico (algoritmo Argon2id); la password in chiaro non è mai conservata né tracciata.',
          'Nome visualizzato e biografia — opzionali, modificabili dall\'utente.',
          'Immagine del profilo (avatar) — opzionale, caricata dall\'utente.',
          'Schede personaggio: tutti i dati inseriti dall\'utente per descrivere i propri personaggi del gioco di ruolo (statistiche, equipaggiamento, incantesimi, note, immagini del personaggio).',
          'Token di condivisione: identificativi opachi generati per la condivisione in sola lettura di una scheda con terzi tramite link pubblico; revocabili in qualunque momento.',
        ]),
        legalH2('2.2 Dati ricevuti dal fornitore di autenticazione OAuth (opzionale)'),
        legalP(
          'Se l\'utente sceglie di registrarsi o accedere tramite l\'opzione "Continua con Google", '
          'il Servizio riceve da Google LLC i seguenti dati associati all\'account Google dell\'utente:',
        ),
        legalUl([
          'Identificativo univoco dell\'account Google ("sub") — usato come chiave per riconoscere l\'utente nei successivi accessi.',
          'Indirizzo email associato all\'account Google e relativo stato di verifica — utilizzato come email dell\'account Servizio.',
          'Nome dell\'account Google ("name") — utilizzato come nome visualizzato di default; modificabile dall\'utente in qualunque momento.',
        ]),
        legalP(
          'L\'eventuale URL della foto profilo Google non viene importato né conservato dal Servizio. '
          'Il flusso di autenticazione avviene tramite il protocollo standard OAuth 2.0 / OpenID Connect; '
          'il Servizio non ha accesso alla password dell\'account Google né ad altri dati dell\'account.',
        ),

        legalH2('2.3 Dati raccolti automaticamente'),
        legalUl([
          'Cronologia dei tiri di dado effettuati con il dice roller (mantenuta in sessione, non condivisa con terzi).',
          'Token di sessione (access token e refresh token) — necessari per mantenere l\'utente autenticato; archiviati sul dispositivo dell\'utente in storage sicuro.',
          'Indirizzo IP — utilizzato esclusivamente in memoria per limitare il numero di richieste agli endpoint di autenticazione (anti-abuse), non persistito.',
          'Log tecnici del server web (data e ora della richiesta, indirizzo IP, path richiesto, user agent) — conservati per un periodo limitato e utilizzati per finalità di sicurezza e diagnostica.',
          'Registro azioni amministrative ("admin_actions"): se l\'utente è amministratore di sistema, le azioni effettuate verso altri utenti vengono registrate (timestamp, azione, ID utente bersaglio) per finalità di tracciabilità e sicurezza.',
        ]),
        legalP(
          'Il Servizio non tratta dati appartenenti a categorie particolari (art. 9 GDPR) né dati '
          'di natura giudiziaria (art. 10 GDPR). Si raccomanda agli utenti di non inserire informazioni '
          'di tale natura nei campi liberi (es. biografia, note di scheda).',
        ),

        // ------------------------------------------------------------------
        legalH1('3. Finalità del trattamento e base giuridica'),
        legalUl([
          'Erogazione del Servizio (creazione e gestione dell\'account, salvataggio delle schede, autenticazione, condivisione di una scheda tramite link) — base giuridica: esecuzione di un contratto di cui l\'utente è parte, ex art. 6(1)(b) GDPR.',
          'Invio di email transazionali (verifica indirizzo email, reset password) — base giuridica: esecuzione del contratto, ex art. 6(1)(b) GDPR.',
          'Sicurezza del Servizio (rate limiting, log di accesso, audit log azioni amministrative) — base giuridica: legittimo interesse del Titolare a proteggere il Servizio e gli utenti da abusi, ex art. 6(1)(f) GDPR.',
          'Adempimento di obblighi di legge a cui il Titolare sia eventualmente soggetto — base giuridica: art. 6(1)(c) GDPR.',
        ]),
        legalP(
          'Il Servizio non effettua attività di marketing diretto, profilazione, decisioni automatizzate '
          'che producano effetti giuridici sull\'utente, né tracciamento pubblicitario.',
        ),

        // ------------------------------------------------------------------
        legalH1('4. Modalità del trattamento e conservazione'),
        legalP(
          'I dati sono trattati con strumenti informatici, con misure tecniche e organizzative volte a '
          'garantirne la riservatezza, l\'integrità e la disponibilità. Le credenziali di accesso sono '
          'memorizzate esclusivamente in forma cifrata; le comunicazioni tra il dispositivo dell\'utente e '
          'i server avvengono in HTTPS con certificato TLS valido.',
        ),
        legalP('I dati sono conservati per i seguenti periodi:'),
        legalUl([
          'Account e schede personaggio: fino a quando l\'utente richiede la cancellazione tramite l\'apposita funzione in-app. Una volta richiesta, la cancellazione è immediata e in cascata su tutti i dati associati (schede, immagini, sessioni, registro tiri di dado, token di condivisione, token di verifica e reset).',
          'Token di verifica email: 24 ore dall\'emissione.',
          'Token di reset password: 1 ora dall\'emissione.',
          'Token di refresh sessione: durata configurata nel sistema; revocabili al logout o alla cancellazione.',
          'Log tecnici del web server: periodo limitato (tipicamente fino a 14 giorni) per finalità di sicurezza.',
          'Registro azioni amministrative: conservato per finalità di tracciabilità; può essere conservato anche dopo la cancellazione dell\'utente bersaglio per documentare le azioni del personale amministrativo.',
          'Copie di backup cifrate: conservate per un periodo limitato (massimo 90 giorni) ai soli fini di disaster recovery; allo scadere del periodo le copie sono distrutte.',
        ]),

        // ------------------------------------------------------------------
        legalH1('5. Destinatari dei dati'),
        legalP(
          'I dati possono essere comunicati alle seguenti categorie di soggetti, designati responsabili '
          'del trattamento ex art. 28 GDPR:',
        ),
        legalUl([
          'Resend, Inc. (con sede negli Stati Uniti d\'America) — fornitore del servizio di invio email transazionali. Tratta esclusivamente l\'indirizzo email del destinatario e il contenuto dell\'email transazionale (verifica account, reset password).',
          'OVH Groupe SAS (con sede in Francia, Unione Europea) — fornitore dell\'infrastruttura di hosting (server virtuale) e del registrar del dominio. I dati sono archiviati su server siti nell\'Unione Europea.',
          'GitHub, Inc. (con sede negli Stati Uniti d\'America) — fornitore del registry da cui vengono distribuite le immagini software del Servizio. Non riceve dati personali degli utenti durante il funzionamento del Servizio.',
          'Google LLC (con sede negli Stati Uniti d\'America) — fornitore del servizio di autenticazione OAuth 2.0 / OpenID Connect, attivato solo se l\'utente sceglie di usare "Continua con Google". Tratta l\'identificativo dell\'account Google, l\'indirizzo email e il nome dell\'utente al solo scopo di consentire l\'autenticazione.',
        ]),
        legalP(
          'I dati non sono ceduti, venduti, comunicati o diffusi ad altri soggetti, salvo obblighi di legge.',
        ),

        // ------------------------------------------------------------------
        legalH1('6. Trasferimenti extra-UE'),
        legalP(
          'I dati possono essere trasferiti verso paesi al di fuori dello Spazio Economico Europeo, '
          'in particolare gli Stati Uniti d\'America, esclusivamente verso fornitori (Resend, GitHub, Google) che '
          'aderiscono all\'EU-US Data Privacy Framework (Decisione di adeguatezza della Commissione UE '
          'del 10 luglio 2023) e che hanno sottoscritto Standard Contractual Clauses con il Titolare.',
        ),

        // ------------------------------------------------------------------
        legalH1('7. Diritti dell\'interessato'),
        legalP(
          'In conformità agli articoli da 15 a 22 del GDPR, l\'utente ha il diritto di:',
        ),
        legalUl([
          'Accedere ai propri dati (art. 15): scaricabili in formato JSON dalla sezione "Esporta i miei dati" del profilo.',
          'Rettificare dati inesatti (art. 16): modificabili direttamente dalla sezione Profilo.',
          'Cancellare i propri dati ("diritto all\'oblio", art. 17): la cancellazione completa dell\'account è disponibile nella sezione "Danger zone" del profilo ed è immediata.',
          'Limitare il trattamento (art. 18): contattare il Titolare.',
          'Portabilità dei dati (art. 20): esportabili in formato JSON dalla funzione di esportazione.',
          'Opporsi al trattamento (art. 21): contattare il Titolare.',
          'Non essere sottoposti a decisioni automatizzate (art. 22): non applicabile in quanto il Servizio non effettua tali trattamenti.',
        ]),

        // ------------------------------------------------------------------
        legalH1('8. Modalità di esercizio dei diritti'),
        legalP(
          'I diritti sopra elencati possono essere esercitati gratuitamente:',
        ),
        legalUl([
          'Tramite le funzioni self-service disponibili nell\'app (Profilo → Esporta i miei dati / Danger zone → Cancella account).',
          'Per le richieste non coperte dalle funzioni in-app (es. limitazione, opposizione, rettifica complessa), inviando un\'email a franksisca@gmail.com. La risposta è fornita entro 30 giorni dalla ricezione della richiesta, prorogabili di ulteriori 60 giorni in casi complessi (art. 12(3) GDPR).',
        ]),

        // ------------------------------------------------------------------
        legalH1('9. Reclamo all\'Autorità di controllo'),
        legalP(
          'Fatto salvo ogni altro ricorso amministrativo o giurisdizionale, qualora l\'utente ritenga '
          'che il trattamento dei propri dati violi il GDPR, ha il diritto di proporre reclamo al Garante '
          'per la protezione dei dati personali (www.garanteprivacy.it) o all\'Autorità di controllo '
          'dello Stato membro UE in cui risiede o lavora abitualmente.',
        ),

        // ------------------------------------------------------------------
        legalH1('10. Modifiche all\'informativa'),
        legalP(
          'La presente informativa può essere aggiornata nel tempo per adeguarla a evoluzioni normative '
          'o tecniche del Servizio. La data di ultimo aggiornamento è indicata in cima alla pagina. '
          'In caso di modifiche sostanziali, gli utenti registrati verranno informati tramite email all\'indirizzo '
          'fornito al momento della registrazione.',
        ),
      ],
    );
  }
}
