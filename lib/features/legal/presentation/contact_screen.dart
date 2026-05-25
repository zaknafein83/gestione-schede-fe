import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import 'legal_scaffold.dart';

/// Pagina contatti — necessaria per AdSense/store mobile/trasparenza generale,
/// e richiesta dal GDPR come canale per esercitare diritti non self-service
/// (limitazione, opposizione, rettifica complessa).
class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n   = AppL10n.of(context);
    final scheme = Theme.of(context).colorScheme;
    return LegalScaffold(
      title: l10n.legalContactTitle,
      children: [
        // Logo del Titolare: tinted col primary del theme (viola in entrambi
        // light/dark) per identificarlo come marchio del provider.
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(scheme.primary, BlendMode.srcIn),
              child: Image.asset(
                'assets/brand/brand-z.png',
                width: 96,
                height: 96,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),

        legalH1('Titolare del Servizio'),
        legalP(
          'Il Servizio PG 5e è fornito da Francesco Sisca (persona fisica), residente in '
          'Corigliano-Rossano (CS), Italia, Titolare del trattamento dei dati personali ai sensi del '
          'Regolamento (UE) 2016/679 (GDPR).',
        ),

        legalH1('Email di contatto'),
        legalP('franksisca@gmail.com'),
        legalP(
          'Utilizzare questo indirizzo per:',
        ),
        legalUl([
          'Segnalazioni di problemi tecnici e malfunzionamenti.',
          'Richieste relative all\'esercizio dei diritti GDPR non coperte dalle funzioni self-service dell\'app (limitazione del trattamento, opposizione, rettifica complessa).',
          'Comunicazioni relative al diritto di recesso su acquisti Premium effettuati tramite il web.',
          'Segnalazioni di contenuti inappropriati o violazioni dei Termini di Servizio.',
          'Informazioni di carattere generale sul Servizio.',
        ]),
        legalP(
          'La risposta a richieste relative ai diritti GDPR è fornita entro 30 giorni dalla ricezione, '
          'prorogabili di ulteriori 60 giorni in casi complessi (art. 12(3) GDPR).',
        ),

        legalH1('Autorità di controllo'),
        legalP(
          'Per esporre eventuali reclami relativi al trattamento dei dati personali, l\'utente può '
          'rivolgersi al:',
        ),
        legalP(
          'Garante per la protezione dei dati personali\n'
          'Piazza Venezia, 11 — 00187 Roma\n'
          'Sito web: www.garanteprivacy.it\n'
          'Centralino: +39 06 696771',
        ),

        legalH1('Cancellazione account'),
        legalP(
          'Per richieste relative alla cancellazione dell\'account: la funzione self-service è disponibile '
          'all\'interno dell\'app, nella sezione Profilo → Danger zone, ed è immediata e irreversibile. '
          'Per istruzioni dettagliate, anche per chi non riesce ad accedere all\'account, consultare la '
          'pagina informativa dedicata.',
        ),
      ],
    );
  }
}
