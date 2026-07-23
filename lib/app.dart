import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app_flutter_verificarlo/config/theme.dart';
import 'package:app_flutter_verificarlo/presentation/providers/auth_provider.dart';
import 'package:app_flutter_verificarlo/presentation/screens/login_screen.dart';
import 'package:app_flutter_verificarlo/presentation/screens/dashboard_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = auth.status == AuthStatus.authenticated;
      final isLoginRoute = state.matchedLocation == '/login';

      if (auth.status == AuthStatus.unknown) return null;

      if (!isLoggedIn && !isLoginRoute) return '/login';
      if (isLoggedIn && isLoginRoute) return '/';

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (_, __) => const DashboardScreen(),
      ),
    ],
  );
});

class VerificarloApp extends ConsumerWidget {
  const VerificarloApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'VerifiCARLO Inspector',
      theme: AppTheme.theme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
