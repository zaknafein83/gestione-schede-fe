import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/admin/presentation/admin_screen.dart';
import '../features/auth/data/auth_controller.dart';
import '../features/auth/presentation/check_email_screen.dart';
import '../features/auth/presentation/forgot_password_screen.dart';
import '../features/auth/presentation/landing_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/auth/presentation/reset_password_screen.dart';
import '../features/auth/presentation/verify_email_screen.dart';
import '../features/characters/presentation/character_editor_screen.dart';
import '../features/characters/presentation/characters_list_screen.dart';
import '../features/characters/presentation/layout_editor_screen.dart';
import '../features/share/presentation/shared_character_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/legal/presentation/account_deletion_info_screen.dart';
import '../features/legal/presentation/contact_screen.dart';
import '../features/legal/presentation/cookies_screen.dart';
import '../features/legal/presentation/pricing_screen.dart';
import '../features/legal/presentation/privacy_screen.dart';
import '../features/legal/presentation/refund_screen.dart';
import '../features/legal/presentation/terms_screen.dart';
import '../features/misc/presentation/coming_soon_screen.dart';
import '../features/payment/presentation/billing_cancel_screen.dart';
import '../features/payment/presentation/billing_success_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/spells/presentation/spell_catalog_screen.dart';

/// Path raggiungibili senza essere autenticati.
const _publicPaths = {
  '/',
  '/login',
  '/register',
  '/check-email',
  '/verify-email',
  '/forgot-password',
  '/reset-password',
  '/coming-soon',
  '/privacy',
  '/terms',
  '/cookies',
  '/pricing',
  '/refund',
  '/contact',
  '/account-deletion-info',
  '/billing/success',
  '/billing/cancel',
  '/spells',
};

/// Path prefix che restano pubblici anche senza login (es. /share/...).
const _publicPrefixes = ['/share/'];

/// Router come provider — cosi' puo' leggere lo stato di auth e fare redirect
/// reattivi (login → /home, logout → /).
final appRouterProvider = Provider<GoRouter>((ref) {
  // Listenable che notifica al router quando lo stato auth cambia.
  final notifier = ValueNotifier<int>(0);
  ref.onDispose(notifier.dispose);
  ref.listen(authControllerProvider, (_, _) => notifier.value++);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: notifier,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      // In bootstrap (loading) lasciamo passare per evitare flicker.
      if (auth.isLoading) return null;

      // In Riverpod 3.x usiamo asData?.value (safe anche su AsyncError).
      final loggedIn = auth.asData?.value != null;
      final path     = state.matchedLocation;
      final isPublic = _publicPaths.contains(path) ||
                       _publicPrefixes.any(path.startsWith);

      if (!loggedIn && !isPublic) return '/login';

      // Se gia' loggato e va su login o landing, vai a home
      if (loggedIn && (path == '/login' || path == '/')) return '/home';

      // Guard /admin: solo se l'utente ha il ruolo ADMIN
      if (path.startsWith('/admin')) {
        final user = auth.asData?.value;
        if (user == null || !user.isAdmin) return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/',             builder: (_, _) => const LandingScreen()),
      GoRoute(path: '/login',        builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/register',     builder: (_, _) => const RegisterScreen()),
      GoRoute(path: '/home',         builder: (_, _) => const HomeScreen()),
      GoRoute(path: '/profile',      builder: (_, _) => const ProfileScreen()),
      GoRoute(path: '/admin',        builder: (_, _) => const AdminScreen()),
      GoRoute(path: '/characters',   builder: (_, _) => const CharactersListScreen()),
      GoRoute(
        path: '/characters/:id',
        builder: (_, state) => CharacterEditorScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/characters/:id/layout',
        builder: (_, state) => LayoutEditorScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/share/:token',
        builder: (_, state) =>
            SharedCharacterScreen(token: state.pathParameters['token']!),
      ),
      GoRoute(
        path: '/check-email',
        builder: (_, state) {
          final email = (state.extra as String?) ?? '';
          return CheckEmailScreen(email: email);
        },
      ),
      GoRoute(
        path: '/verify-email',
        builder: (_, state) {
          final token = state.uri.queryParameters['token'] ?? '';
          return VerifyEmailScreen(token: token);
        },
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (_, _) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (_, state) {
          final token = state.uri.queryParameters['token'] ?? '';
          return ResetPasswordScreen(token: token);
        },
      ),
      GoRoute(
        path: '/coming-soon',
        builder: (_, state) =>
            ComingSoonScreen(topic: state.uri.queryParameters['for']),
      ),
      GoRoute(path: '/privacy', builder: (_, _) => const PrivacyScreen()),
      GoRoute(path: '/terms',   builder: (_, _) => const TermsScreen()),
      GoRoute(path: '/cookies', builder: (_, _) => const CookiesScreen()),
      GoRoute(path: '/pricing', builder: (_, _) => const PricingScreen()),
      GoRoute(path: '/refund',  builder: (_, _) => const RefundScreen()),
      GoRoute(path: '/contact', builder: (_, _) => const ContactScreen()),
      GoRoute(
        path: '/account-deletion-info',
        builder: (_, _) => const AccountDeletionInfoScreen(),
      ),
      // Atterraggio post-checkout Stripe. Pubbliche perche' Stripe puo'
      // redirigere prima che il refresh del token JWT vada a buon fine.
      GoRoute(
        path: '/billing/success',
        builder: (_, state) =>
            BillingSuccessScreen(sessionId: state.uri.queryParameters['session_id']),
      ),
      GoRoute(
        path: '/billing/cancel',
        builder: (_, _) => const BillingCancelScreen(),
      ),
      // Catalogo SRD pubblico — consultabile anche da non loggati.
      GoRoute(
        path: '/spells',
        builder: (_, _) => const SpellCatalogScreen(),
      ),
    ],
  );
});
