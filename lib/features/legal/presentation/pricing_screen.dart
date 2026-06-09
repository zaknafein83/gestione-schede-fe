import 'package:flutter/material.dart';

import 'legal_scaffold.dart';

/// Pagina pubblica "Prezzi" — richiesta dal processore di pagamento (Paddle)
/// per la verifica del sito, e utile agli utenti per capire cosa include il
/// piano gratuito e cosa sblocca il Premium.
///
/// Stato del Servizio: piano gratuito + un upgrade Premium "lifetime" una
/// tantum. Il pagamento sul web è gestito da Paddle come Merchant of Record.
/// Numeri allineati al backend: piano gratuito = 1 scheda
/// (`app.free-tier.max-characters`), Premium = schede illimitate + dashboard
/// personalizzabile (editor layout).
class PricingScreen extends StatelessWidget {
  const PricingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LegalScaffold(
      title: 'Prezzi',
      children: [
        legalP(
          'PG 5e è gratuito. Per chi vuole di più è disponibile un upgrade Premium '
          'una tantum ("lifetime"): si paga una sola volta e l\'accesso resta a vita, '
          'senza abbonamenti né rinnovi automatici.',
        ),

        // ------------------------------------------------------------------
        legalH1('Piano Gratuito'),
        legalP('Senza alcun costo, ogni utente registrato ha:'),
        legalUl([
          '1 scheda personaggio.',
          'Tutti gli strumenti di gioco: dice roller, tracciatura di punti vita, incantesimi e condizioni.',
          'Accesso al catalogo incantesimi SRD 5.1 (italiano/inglese).',
          'Esportazione della scheda in PDF.',
          'Condivisione di una scheda in sola lettura tramite link pubblico.',
        ]),

        // ------------------------------------------------------------------
        legalH1('Premium — 4,99 € una tantum'),
        legalP(
          'Un unico pagamento di 4,99 € (IVA inclusa ove applicabile) sblocca per sempre, '
          'sullo stesso account:',
        ),
        legalUl([
          'Schede personaggio illimitate.',
          'Dashboard personalizzabile: editor drag & drop del layout della scheda (per gli utenti gratuiti il layout è disponibile in sola lettura).',
          'Tutte le funzionalità del piano gratuito.',
          'Accesso a vita, nessun abbonamento e nessun rinnovo automatico.',
        ]),
        legalP(
          'Il prezzo è espresso in euro (EUR). Eventuali nuove funzionalità Premium '
          'introdotte in futuro saranno incluse senza costi aggiuntivi per chi ha già '
          'acquistato il Premium.',
        ),

        // ------------------------------------------------------------------
        legalH1('Pagamento e fatturazione'),
        legalP(
          'L\'acquisto Premium effettuato dal sito web è gestito da Paddle.com Market '
          'Limited ("Paddle"), che agisce come Merchant of Record (rivenditore '
          'ufficiale): Paddle elabora il pagamento, applica e versa le imposte dovute '
          '(IVA/sales tax) ed emette la ricevuta/fattura. Al momento del pagamento si '
          'applicano, in aggiunta ai Termini di Servizio di PG 5e, i termini e '
          'l\'informativa di Paddle.',
        ),
        legalP(
          'Sui dispositivi mobili (quando disponibili) l\'acquisto Premium avverrà '
          'tramite il sistema di pagamento dello store (Apple App Store / Google Play '
          'Store), secondo le condizioni del rispettivo store.',
        ),

        // ------------------------------------------------------------------
        legalH1('Rimborsi'),
        legalP(
          'Puoi richiedere il rimborso dell\'acquisto Premium entro 14 giorni, secondo '
          'quanto indicato nella Politica di rimborso. Per i dettagli completi consulta '
          'la pagina dedicata ai rimborsi e i Termini di Servizio.',
        ),

        // ------------------------------------------------------------------
        legalH1('Contatti'),
        legalP(
          'Per qualsiasi domanda su prezzi, acquisti o fatturazione, scrivi a '
          'franksisca@gmail.com.',
        ),
      ],
    );
  }
}
