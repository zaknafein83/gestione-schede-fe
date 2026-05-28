import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dndsheets_frontend/features/auth/data/auth_controller.dart';
import 'package:dndsheets_frontend/features/auth/models/auth_models.dart';
import 'package:dndsheets_frontend/main.dart';

/// Sostituisce AuthController in modo che il bootstrap non tocchi
/// flutter_secure_storage (non disponibile nell'env di test Flutter standard).
class _UnauthenticatedAuthController extends AuthController {
  @override
  Future<UserDto?> build() async => null;
}

void main() {
  testWidgets('Landing render: hero e CTA visibili senza auth', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(_UnauthenticatedAuthController.new),
        ],
        child: const DndSheetsApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Eyebrow del hero — testo univoco della landing fantasy attuale.
    expect(find.text('Cronache di un avventuriero 5e'), findsOneWidget);
    // CTA primaria "Entra nella tua biblioteca" (l10n: landingCtaOpenWeb).
    expect(find.text('Entra nella tua biblioteca'), findsOneWidget);
  });
}
