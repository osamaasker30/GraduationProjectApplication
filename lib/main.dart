import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_provider.dart';
import 'router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  timeago.setLocaleMessages('tr', timeago.TrMessages());
  runApp(const KariyerKoprusuApp());
}

class KariyerKoprusuApp extends StatefulWidget {
  const KariyerKoprusuApp({super.key});

  @override
  State<KariyerKoprusuApp> createState() => _KariyerKoprusuAppState();
}

class _KariyerKoprusuAppState extends State<KariyerKoprusuApp> {
  late final AuthProvider _auth;
  late final Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _auth = AuthProvider();
    // Run tryAutoLogin ONCE here, not inside build()
    _initFuture = _auth.tryAutoLogin();
  }

  @override
  void dispose() {
    _auth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthProvider>.value(
      value: _auth,
      child: FutureBuilder<void>(
        future: _initFuture,
        builder: (ctx, snapshot) {
          // Show splash/loading while checking stored token
          if (snapshot.connectionState != ConnectionState.done) {
            return MaterialApp(
              theme: AppTheme.darkTheme,
              debugShowCheckedModeBanner: false,
              home: const _SplashScreen(),
            );
          }

          // After init done, build the app with router
          return Consumer<AuthProvider>(
            builder: (ctx, auth, _) {
              return MaterialApp.router(
                title: 'Kariyer Köprüsü',
                theme: AppTheme.darkTheme,
                debugShowCheckedModeBanner: false,
                routerConfig: AppRouter.build(auth),
              );
            },
          );
        },
      ),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(Icons.work_outline, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 24),
            const Text(
              'Kariyer Köprüsü',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(color: AppTheme.primary),
          ],
        ),
      ),
    );
  }
}
