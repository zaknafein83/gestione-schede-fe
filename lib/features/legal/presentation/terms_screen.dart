import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import 'legal_scaffold.dart';

/// Termini di Servizio (ToS).
///
/// Versione italiana ufficiale. Stato attuale del Servizio: gratuito.
/// Le sezioni su funzionalità Premium sono predisposte per il futuro ma
/// dichiarano esplicitamente che oggi non c\'è un acquisto attivo.
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return LegalScaffold(
      title: l10n.legalTermsTitle,
      children: [
        legalP(
          'I presenti Termini di Servizio (di seguito "Termini") regolano l\'utilizzo dell\'applicazione '
          'PG 5e (di seguito anche "il Servizio") fornita da Francesco Sisca, residente in '
          'Corigliano-Rossano (CS), Italia (di seguito "il Fornitore"). L\'utilizzo del Servizio comporta '
          'l\'accettazione integrale dei presenti Termini.',
        ),

        // ------------------------------------------------------------------
        legalH1('1. Oggetto del Servizio'),
        legalP(
          'PG 5e è un\'applicazione che consente di creare e gestire schede personaggio per giochi di '
          'ruolo cartacei fantasy basati sul sistema 5e, includendo strumenti di calcolo, un dice roller, '
          'la tracciatura di vita/incantesimi/condizioni, l\'esportazione PDF e la condivisione in sola '
          'lettura di una scheda tramite link pubblico. Il Servizio è erogato in modalità "as-is", senza '
          'garanzie di disponibilità ininterrotta.',
        ),
        legalP(
          'Il Servizio NON è affiliato, sponsorizzato, approvato o connesso in alcun modo a Wizards of '
          'the Coast LLC. I contenuti relativi al gioco eventualmente richiamati derivano dal D&D 5.1 '
          'System Reference Document (SRD) pubblicato sotto licenza Creative Commons Attribution 4.0 '
          'International (CC BY 4.0).',
        ),

        // ------------------------------------------------------------------
        legalH1('2. Account e registrazione'),
        legalP(
          'Per accedere alle funzionalità complete del Servizio è necessario registrare un account '
          'fornendo un indirizzo email valido e una password. L\'utente è responsabile di:',
        ),
        legalUl([
          'Fornire informazioni veritiere al momento della registrazione.',
          'Mantenere riservate le proprie credenziali di accesso.',
          'Comunicare tempestivamente al Fornitore ogni utilizzo non autorizzato dell\'account.',
          'Avere un\'età sufficiente per stipulare un contratto secondo la legge italiana (almeno 14 anni con consenso dei genitori per il trattamento dati, o 16 anni in autonomia ex art. 8 GDPR e art. 2-quinquies Codice Privacy).',
        ]),

        // ------------------------------------------------------------------
        legalH1('3. Uso accettabile'),
        legalP(
          'L\'utente si impegna a non utilizzare il Servizio per:',
        ),
        legalUl([
          'Violare la legge applicabile o diritti di terzi (incluso, a titolo non esaustivo, diritto d\'autore, marchi, riservatezza, dignità personale).',
          'Caricare contenuti illeciti, diffamatori, offensivi, osceni, discriminatori, lesivi della dignità di terzi o protetti da copyright senza autorizzazione.',
          'Tentare di accedere senza autorizzazione a parti del sistema, ad account altrui, ad aree riservate; effettuare attività di scraping massivo, reverse engineering, bypass dei meccanismi di sicurezza o di rate limiting.',
          'Utilizzare il Servizio per scopi commerciali non espressamente autorizzati dal Fornitore.',
          'Utilizzare strumenti automatizzati che generino un carico anomalo sull\'infrastruttura.',
        ]),
        legalP(
          'Il Fornitore si riserva il diritto di sospendere o terminare account che violino i presenti '
          'Termini, anche senza preavviso, ferma restando ogni eventuale azione legale.',
        ),

        // ------------------------------------------------------------------
        legalH1('4. Contenuti dell\'utente'),
        legalP(
          'I dati e i contenuti che l\'utente carica nelle proprie schede personaggio (testo, immagini, '
          'note) rimangono di proprietà dell\'utente. L\'utente concede al Fornitore una licenza limitata, '
          'gratuita, non esclusiva e non trasferibile, strettamente necessaria a memorizzare, '
          'visualizzare e processare tali contenuti al solo scopo di erogare il Servizio.',
        ),
        legalP(
          'Quando l\'utente genera un link di condivisione pubblico di una scheda, dichiara di volerne '
          'rendere accessibile in sola lettura il contenuto a chiunque possieda il link, fino alla revoca. '
          'Il link può essere revocato in qualsiasi momento dal pannello della scheda.',
        ),

        // ------------------------------------------------------------------
        legalH1('5. Disponibilità del Servizio'),
        legalP(
          'Il Fornitore si impegna a mantenere il Servizio disponibile con la massima diligenza compatibile '
          'con la natura del progetto, ma non garantisce continuità di servizio, assenza di errori o '
          'compatibilità con configurazioni specifiche del dispositivo dell\'utente. Sono possibili '
          'interruzioni per manutenzione ordinaria o straordinaria. I dati dell\'utente sono protetti da '
          'backup periodici, senza tuttavia che questo costituisca garanzia assoluta di recuperabilità.',
        ),

        // ------------------------------------------------------------------
        legalH1('6. Servizi a pagamento (Premium)'),
        legalP(
          'Alla data di pubblicazione dei presenti Termini il Servizio è gratuito. In futuro potrà essere '
          'introdotta una funzionalità a pagamento ("Premium") soggetta alle seguenti condizioni:',
        ),
        legalUl([
          'Il prezzo, le modalità di acquisto e le funzionalità incluse verranno indicati al momento dell\'acquisto.',
          'L\'acquisto verrà eseguito tramite il sistema di pagamento del fornitore competente (in-app billing dell\'app store sui dispositivi mobili, processore di pagamento dedicato sul web). Le condizioni del fornitore di pagamento sono ulteriori rispetto ai presenti Termini.',
          'L\'acquisto Premium si configura come fornitura di "contenuto digitale" ex art. 45 e seguenti del Codice del Consumo (D. Lgs. 206/2005).',
        ]),

        // ------------------------------------------------------------------
        legalH1('7. Diritto di recesso'),
        legalP(
          'Il Fornitore concede all\'utente consumatore un diritto di recesso più ampio rispetto al minimo '
          'di legge: per qualsiasi acquisto Premium effettuato direttamente sulla piattaforma web del '
          'Servizio, l\'utente può richiedere il rimborso entro 14 giorni dalla data dell\'acquisto, senza '
          'necessità di motivare la richiesta e indipendentemente dall\'eventuale fruizione delle '
          'funzionalità a pagamento nel periodo intercorso.',
        ),
        legalP(
          'La richiesta di rimborso va inviata via email a franksisca@gmail.com indicando l\'indirizzo '
          'email dell\'account e la data dell\'acquisto. Il rimborso viene effettuato sullo stesso strumento '
          'di pagamento utilizzato per l\'acquisto, entro 14 giorni dalla ricezione della richiesta.',
        ),
        legalP(
          'Per gli acquisti effettuati tramite gli app store di terze parti (Apple App Store, Google Play '
          'Store), il rimborso è soggetto alle policy e ai canali del rispettivo store; il Fornitore non '
          'ha modo di rimborsare direttamente acquisti effettuati tramite tali canali.',
        ),

        // ------------------------------------------------------------------
        legalH1('8. Cessazione del rapporto'),
        legalP(
          'L\'utente può cessare in qualsiasi momento l\'utilizzo del Servizio cancellando il proprio '
          'account dalla sezione "Danger zone" del profilo. La cancellazione è immediata, irreversibile e '
          'comporta la rimozione di tutti i dati associati come descritto nell\'Informativa Privacy.',
        ),
        legalP(
          'Il Fornitore può sospendere o cessare il Servizio nel suo insieme, dandone preavviso '
          'ragionevole tramite il sito o l\'email registrata, e si impegna in tal caso a consentire '
          'l\'esportazione dei dati per un periodo ragionevole prima della cessazione.',
        ),

        // ------------------------------------------------------------------
        legalH1('9. Limitazione di responsabilità'),
        legalP(
          'Nei limiti consentiti dalla legge applicabile, il Fornitore non è responsabile per:',
        ),
        legalUl([
          'Danni indiretti, consequenziali, di immagine o di perdita di chance derivanti dall\'uso o dalla mancata disponibilità del Servizio.',
          'Perdita di dati derivante da malfunzionamenti, eventi di forza maggiore, attacchi informatici, errori dell\'utente o dei suoi dispositivi.',
          'Contenuti caricati dagli utenti e da essi resi pubblici tramite la funzione di condivisione.',
          'Servizi forniti da terzi (provider di hosting, email, app store) per i quali si rimanda alle rispettive condizioni.',
        ]),
        legalP(
          'Nulla nei presenti Termini esclude o limita la responsabilità del Fornitore per dolo o colpa '
          'grave, né limita i diritti che la legge applicabile riconosce inderogabilmente al consumatore.',
        ),

        // ------------------------------------------------------------------
        legalH1('10. Modifiche ai Termini'),
        legalP(
          'I presenti Termini possono essere modificati per adeguarli a evoluzioni del Servizio o della '
          'normativa. Le modifiche sostanziali saranno comunicate agli utenti registrati tramite email con '
          'almeno 15 giorni di preavviso. L\'utente che non intenda accettare le nuove condizioni può '
          'cessare l\'utilizzo del Servizio cancellando l\'account.',
        ),

        // ------------------------------------------------------------------
        legalH1('11. Legge applicabile e foro competente'),
        legalP(
          'I presenti Termini sono regolati dalla legge italiana. Per le controversie con utenti '
          'consumatori, è competente in via esclusiva il giudice del luogo di residenza o domicilio '
          'dell\'utente, se ubicati nel territorio italiano (art. 66-bis Codice del Consumo). '
          'Per le controversie con utenti non consumatori è competente in via esclusiva il Tribunale '
          'di Castrovillari (CS), foro del luogo di residenza del Fornitore (Corigliano-Rossano, CS).',
        ),

        // ------------------------------------------------------------------
        legalH1('12. Contatti'),
        legalP(
          'Per qualsiasi comunicazione relativa ai presenti Termini, contattare il Fornitore '
          'all\'indirizzo franksisca@gmail.com.',
        ),
      ],
    );
  }
}
