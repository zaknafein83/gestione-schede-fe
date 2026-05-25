import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import 'legal_scaffold.dart';

/// Politica sui Cookie.
///
/// PG 5e non utilizza cookie HTTP né tecnologie di tracciamento di terze parti.
/// Le credenziali di sessione (token JWT + refresh token) sono memorizzate in
/// storage sicuro lato client (flutter_secure_storage) e sono "strettamente
/// necessarie" all\'erogazione del Servizio: in base al Provvedimento del
/// Garante 10/06/2021 ("Linee guida cookie") e all\'art. 5(3) Direttiva
/// 2002/58/CE (e-Privacy) come modificata, NON è richiesto consenso
/// preventivo per questo tipo di storage.
class CookiesScreen extends StatelessWidget {
  const CookiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppL10n.of(context);
    return LegalScaffold(
      title: l10n.legalCookiesTitle,
      children: [
        legalP(
          'La presente politica spiega quali tecnologie di archiviazione locale (cookie e tecnologie '
          'analoghe, di seguito complessivamente "cookie") sono utilizzate da PG 5e e con quali finalità.',
        ),

        // ------------------------------------------------------------------
        legalH1('1. In sintesi'),
        legalP(
          'PG 5e NON utilizza cookie pubblicitari, di profilazione, di tracciamento, di analytics o di '
          'terze parti. Per questo motivo non viene mostrato alcun banner di consenso preventivo: le '
          'tecnologie di archiviazione utilizzate sono esclusivamente "tecniche" e "strettamente '
          'necessarie" al funzionamento del Servizio, e come tali esenti dall\'obbligo di consenso '
          'preventivo ai sensi dell\'art. 122 D. Lgs. 196/2003 ("Codice Privacy") e del Provvedimento del '
          'Garante del 10 giugno 2021 ("Linee guida cookie e altri strumenti di tracciamento").',
        ),

        // ------------------------------------------------------------------
        legalH1('2. Tecnologie di archiviazione utilizzate'),
        legalH2('2.1 Token di sessione (storage sicuro del browser/app)'),
        legalP(
          'Al login, il Servizio salva sul dispositivo dell\'utente due token:',
        ),
        legalUl([
          'Un access token (JWT firmato), che identifica le richieste autenticate. Vita breve.',
          'Un refresh token, che consente di mantenere la sessione attiva e ottenere nuovi access token senza dover riautenticare l\'utente. Memorizzato in storage sicuro del browser/app (flutter_secure_storage).',
        ]),
        legalP(
          'Questi token sono indispensabili per riconoscere l\'utente in sessione e proteggere l\'accesso '
          'ai suoi dati. Vengono rimossi automaticamente al logout o alla cancellazione dell\'account, e '
          'possono essere rimossi manualmente dall\'utente svuotando i dati del sito/applicazione dal '
          'proprio browser o dispositivo.',
        ),

        legalH2('2.2 Preferenze locali'),
        legalP(
          'Il Servizio salva localmente alcune preferenze di interfaccia (ad esempio il tema chiaro/scuro '
          'e la lingua selezionata) per offrire un\'esperienza coerente tra le sessioni. Questi dati non '
          'lasciano il dispositivo dell\'utente e non sono mai associati ad alcun identificativo personale.',
        ),

        // ------------------------------------------------------------------
        legalH1('3. Cookie di terze parti'),
        legalP(
          'Il Servizio non incorpora cookie di terze parti, non utilizza piattaforme di analytics '
          '(es. Google Analytics, Meta Pixel), non integra widget social, non visualizza annunci '
          'pubblicitari.',
        ),
        legalP(
          'Qualora in futuro vengano introdotte tecnologie che richiedono il consenso (es. analytics di '
          'terze parti o pubblicità), verrà attivato un sistema di gestione del consenso conforme al GDPR '
          'e al Provvedimento Garante 10/06/2021 e la presente politica verrà aggiornata di conseguenza.',
        ),

        // ------------------------------------------------------------------
        legalH1('4. Log tecnici del server'),
        legalP(
          'Il server web del Servizio registra log tecnici (data, ora, indirizzo IP, percorso richiesto, '
          'user agent) per finalità di sicurezza e diagnostica. Tali log non costituiscono cookie e sono '
          'gestiti come descritto nell\'Informativa Privacy.',
        ),

        // ------------------------------------------------------------------
        legalH1('5. Come rimuovere i dati salvati localmente'),
        legalP(
          'L\'utente può rimuovere in qualunque momento i dati salvati localmente dal Servizio sul proprio '
          'dispositivo:',
        ),
        legalUl([
          'Effettuando il logout dall\'app (cancella automaticamente i token).',
          'Cancellando i dati del sito/applicazione dalle impostazioni del proprio browser o sistema operativo.',
          'Cancellando l\'account dalla sezione "Danger zone" del profilo (rimuove anche i dati lato server).',
        ]),

        // ------------------------------------------------------------------
        legalH1('6. Riferimenti normativi'),
        legalUl([
          'Regolamento (UE) 2016/679 (GDPR).',
          'D. Lgs. 30 giugno 2003, n. 196 ("Codice in materia di protezione dei dati personali"), come modificato dal D. Lgs. 101/2018.',
          'Direttiva 2002/58/CE ("e-Privacy"), come modificata.',
          'Provvedimento del Garante per la protezione dei dati personali del 10 giugno 2021 ("Linee guida cookie").',
        ]),

        // ------------------------------------------------------------------
        legalH1('7. Contatti'),
        legalP(
          'Per qualsiasi richiesta relativa alla presente politica, contattare il Titolare del trattamento '
          'all\'indirizzo franksisca@gmail.com.',
        ),
      ],
    );
  }
}
