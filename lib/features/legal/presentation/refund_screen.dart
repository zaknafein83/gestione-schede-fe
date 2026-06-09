import 'package:flutter/material.dart';

import 'legal_scaffold.dart';

/// Pagina pubblica "Politica di rimborso" — richiesta dal processore di
/// pagamento (Paddle) per la verifica del sito.
///
/// Il contenuto riprende e dettaglia il diritto di recesso già previsto dai
/// Termini di Servizio (§7), adattandolo al fatto che il pagamento sul web è
/// gestito da Paddle come Merchant of Record. Il downgrade post-rimborso NON
/// cancella le schede già create (coerente con la logica del backend).
class RefundScreen extends StatelessWidget {
  const RefundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalScaffold(
      title: 'Politica di rimborso',
      children: [
        legalP(
          'La presente Politica di rimborso disciplina i rimborsi per l\'acquisto '
          'Premium di PG 5e. È parte integrante dei Termini di Servizio e, in caso di '
          'dubbio, va letta insieme ad essi.',
        ),

        // ------------------------------------------------------------------
        legalH1('1. Rimborso entro 14 giorni'),
        legalP(
          'Concediamo all\'utente consumatore un diritto di rimborso più ampio del '
          'minimo di legge: per qualsiasi acquisto Premium puoi richiedere il rimborso '
          'completo entro 14 giorni dalla data dell\'acquisto, senza dover motivare la '
          'richiesta e indipendentemente dal fatto che tu abbia già utilizzato le '
          'funzionalità Premium nel periodo intercorso.',
        ),

        // ------------------------------------------------------------------
        legalH1('2. Come richiedere il rimborso'),
        legalH2('2.1 Acquisti effettuati sul sito web'),
        legalP(
          'Gli acquisti effettuati dal sito web sono elaborati da Paddle.com Market '
          'Limited ("Paddle"), che agisce come Merchant of Record. Per ottenere il '
          'rimborso puoi:',
        ),
        legalUl([
          'Scriverci a franksisca@gmail.com indicando l\'indirizzo email del tuo account e la data dell\'acquisto, e ce ne occuperemo noi tramite Paddle; oppure',
          'Utilizzare il link di gestione dell\'acquisto presente nella ricevuta inviata da Paddle al momento del pagamento.',
        ]),
        legalP(
          'Il rimborso viene effettuato sullo stesso strumento di pagamento utilizzato '
          'per l\'acquisto, di norma entro 14 giorni dalla ricezione della richiesta. '
          'Eventuali tempi di accredito dipendono dal circuito di pagamento.',
        ),
        legalH2('2.2 Acquisti effettuati tramite app store'),
        legalP(
          'Per gli acquisti effettuati tramite gli store di terze parti (Apple App '
          'Store, Google Play Store), quando disponibili, il rimborso è soggetto alle '
          'policy e ai canali del rispettivo store: in tali casi la richiesta va '
          'presentata direttamente allo store, poiché il Fornitore non ha modo di '
          'rimborsare autonomamente questi acquisti.',
        ),

        // ------------------------------------------------------------------
        legalH1('3. Effetti del rimborso'),
        legalP(
          'A seguito del rimborso, l\'account torna automaticamente al piano gratuito. '
          'Le schede personaggio e i contenuti eventualmente creati durante il periodo '
          'Premium NON vengono cancellati: restano nel tuo account. Tornano però ad '
          'applicarsi i limiti del piano gratuito (ad esempio per la creazione di '
          'nuove schede oltre quella inclusa e per la modifica del layout '
          'personalizzato della dashboard).',
        ),

        // ------------------------------------------------------------------
        legalH1('4. Contatti'),
        legalP(
          'Per qualsiasi richiesta relativa ai rimborsi, contattaci all\'indirizzo '
          'franksisca@gmail.com.',
        ),
      ],
    );
  }
}
