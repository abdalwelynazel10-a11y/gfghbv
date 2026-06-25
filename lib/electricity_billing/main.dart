import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import '../firebase_options.dart';
import 'core/billing_constants.dart';
import 'core/billing_theme.dart';
import 'providers/billing_app_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'services/billing_notification_service.dart';
import 'services/electricity_billing_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ElectricityBillingApp());
}

class ElectricityBillingApp extends StatelessWidget {
  const ElectricityBillingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => BillingAppProvider(
            repository: ElectricityBillingRepository(),
            notifications: BillingNotificationService(),
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: BillingConstants.appName,
        theme: BillingTheme.light(),
        darkTheme: BillingTheme.dark(),
        themeMode: ThemeMode.system,
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const BillingAuthGate(),
      ),
    );
  }
}

class BillingAuthGate extends StatelessWidget {
  const BillingAuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (!snapshot.hasData) return const BillingLoginScreen();
        return const _CollectorBootstrap(child: BillingDashboardScreen());
      },
    );
  }
}

class _CollectorBootstrap extends StatefulWidget {
  final Widget child;
  const _CollectorBootstrap({required this.child});

  @override
  State<_CollectorBootstrap> createState() => _CollectorBootstrapState();
}

class _CollectorBootstrapState extends State<_CollectorBootstrap> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<BillingAppProvider>().initialize());
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
