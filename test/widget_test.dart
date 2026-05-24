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
  testWidgets('Landing renderizza "Benvenuto" quando non autenticato', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(_UnauthenticatedAuthController.new),
        ],
        child: const DndSheetsApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Benvenuto'), findsOneWidget);
    expect(find.text('Crea un account'), findsOneWidget);
    expect(find.text('Accedi'), findsOneWidget);
  });
}
