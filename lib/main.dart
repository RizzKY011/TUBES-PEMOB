import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/split/split_screen.dart';
import 'features/split/repository.dart';
import 'features/expense/expense_screen.dart';
import 'features/budget/budget_screen.dart';
import 'features/debt/debt_screen.dart';
import 'features/insights/insights_screen.dart';
import 'core/notifications/notifications.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/splash_screen.dart';
import 'features/auth/auth_screens.dart';
import 'features/home/home_screen.dart';
import 'features/auth/auth_service.dart';
import 'features/invoice/invoice_screen.dart';
import 'features/history/history_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SplitRepository().init();
  await AppNotifications.init();
  final bool loggedIn = await AuthService().isLoggedIn();
  runApp(MonasApp(initialRoute: loggedIn ? '/home' : '/splash'));
}

class MonasApp extends StatelessWidget {
  final String initialRoute;
  const MonasApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MONAS',
      theme: AppTheme.lightTheme,
      initialRoute: initialRoute,
      routes: <String, WidgetBuilder>{
        '/splash': (_) => const SplashScreen(),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/home': (_) => const HomeScreen(),
        '/invoice': (_) => const InvoiceScreen(),
        '/history': (_) => const HistoryScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;

  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          pinned: true,
          title: Text(title),
        ),
        const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Text('Coming soon...'),
          ),
        ),
      ],
    );
  }
}
