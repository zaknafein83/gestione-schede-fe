// Logica della pagina di checkout Paddle. Estratta da checkout.html (script
// esterno) cosi' la Content-Security-Policy puo' vietare script-src 'unsafe-inline'.
(function () {
  var params = new URLSearchParams(window.location.search);
  var uid = params.get('uid');
  var email = params.get('email');

  function fail(title, message) {
    document.getElementById('spinner').classList.add('hidden');
    document.getElementById('title').textContent = title;
    document.getElementById('msg').textContent = message;
    document.getElementById('backBtn').classList.remove('hidden');
  }

  // uid = ObjectId Mongo dell'utente (24 hex). Validiamo il formato prima di
  // passarlo a Paddle come custom_data, per non inquinare l'audit trail con
  // valori arbitrari presi dalla query string.
  if (!uid || !/^[a-f0-9]{24}$/i.test(uid)) {
    fail('Sessione non valida', 'Apri il checkout dall\'app cliccando "Acquista".');
    return;
  }
  // email e' opzionale (solo prefill del form Paddle); se malformata, ignorala.
  if (email && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    email = null;
  }

  fetch('/api/billing/config', { headers: { 'Accept': 'application/json' } })
    .then(function (r) { return r.json(); })
    .then(function (cfg) {
      // Validazione della shape della risposta: senza questi campi
      // Paddle.Initialize/open fallirebbe in modo opaco.
      if (!cfg || !cfg.enabled) {
        fail('Pagamenti non disponibili', 'Il checkout non è ancora attivo. Riprova più tardi.');
        return;
      }
      if (typeof cfg.clientToken !== 'string' || !cfg.clientToken ||
          typeof cfg.priceId !== 'string' || !cfg.priceId) {
        fail('Configurazione non valida', 'Il checkout non è configurato correttamente. Riprova più tardi.');
        return;
      }
      if (cfg.environment === 'sandbox') {
        Paddle.Environment.set('sandbox');
      }
      Paddle.Initialize({ token: cfg.clientToken });
      Paddle.Checkout.open({
        items: [{ priceId: cfg.priceId, quantity: 1 }],
        customer: email ? { email: email } : undefined,
        customData: { user_id: uid },
        settings: {
          displayMode: 'overlay',
          theme: 'light',
          locale: 'it',
          successUrl: window.location.origin + '/billing/success'
        }
      });
      // L'overlay è aperto sopra questa pagina; offriamo comunque un'uscita.
      document.getElementById('title').textContent = 'Completa il pagamento';
      document.getElementById('msg').textContent =
        'Segui le istruzioni nella finestra di checkout. Se l\'hai chiusa, ricarica la pagina.';
      document.getElementById('backBtn').classList.remove('hidden');
    })
    .catch(function () {
      fail('Errore di caricamento', 'Non è stato possibile avviare il checkout. Riprova più tardi.');
    });
})();
