import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final location = GoRouterState.of(context).matchedLocation;

    // ── Student nav (5 items) ──────────────────────────────────
    const studentItems = [
      NavigationDestination(
        icon: Icon(Icons.dashboard_outlined),
        selectedIcon: Icon(Icons.dashboard),
        label: 'Panel',
      ),
      NavigationDestination(
        icon: Icon(Icons.work_outline),
        selectedIcon: Icon(Icons.work),
        label: 'Fırsatlar',
      ),
      NavigationDestination(
        icon: Icon(Icons.notifications_outlined),
        selectedIcon: Icon(Icons.notifications),
        label: 'Bildirimler',
      ),
      NavigationDestination(
        icon: Icon(Icons.chat_bubble_outline),
        selectedIcon: Icon(Icons.chat_bubble),
        label: 'Mesajlar',
      ),
      NavigationDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: 'Profil',
      ),
    ];

    // ── Company nav (5 items) ─────────────────────────────────
    const companyItems = [
      NavigationDestination(
        icon: Icon(Icons.dashboard_outlined),
        selectedIcon: Icon(Icons.dashboard),
        label: 'Panel',
      ),
      NavigationDestination(
        icon: Icon(Icons.work_outline),
        selectedIcon: Icon(Icons.work),
        label: 'İlanlarım',
      ),
      NavigationDestination(
        icon: Icon(Icons.notifications_outlined),
        selectedIcon: Icon(Icons.notifications),
        label: 'Bildirimler',
      ),
      NavigationDestination(
        icon: Icon(Icons.chat_bubble_outline),
        selectedIcon: Icon(Icons.chat_bubble),
        label: 'Mesajlar',
      ),
      NavigationDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: 'Profil',
      ),
    ];

    final studentRoutes = [
      '/dashboard',
      '/opportunities',
      '/notifications',
      '/messages',
      '/profile/student',
    ];

    final companyRoutes = [
      '/company-dashboard',
      '/company/opportunities',
      '/notifications',
      '/messages',
      '/profile/company',
    ];

    final routes = auth.isStudent ? studentRoutes : companyRoutes;
    final items  = auth.isStudent ? studentItems  : companyItems;

    int selectedIdx = 0;
    for (int i = 0; i < routes.length; i++) {
      if (location.startsWith(routes[i])) {
        selectedIdx = i;
        break;
      }
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
          ),
        ),
        child: NavigationBar(
          selectedIndex: selectedIdx,
          onDestinationSelected: (i) => context.go(routes[i]),
          destinations: items,
          backgroundColor: AppTheme.surface,
          height: 64,
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        ),
      ),
    );
  }
}
