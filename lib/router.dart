import 'package:go_router/go_router.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/dashboard/screens/student_dashboard_screen.dart';
import 'features/dashboard/screens/company_dashboard_screen.dart';
import 'features/projects/screens/projects_screen.dart';
import 'features/projects/screens/project_detail_screen.dart';
import 'features/projects/screens/create_project_screen.dart';
import 'features/projects/screens/edit_project_screen.dart';
import 'features/opportunities/screens/opportunities_screen.dart';
import 'features/opportunities/screens/opportunity_detail_screen.dart';
import 'features/opportunities/screens/company_opportunities_screen.dart';
import 'features/opportunities/screens/opportunity_form_screen.dart';
import 'features/applications/screens/applicants_screen.dart';
import 'features/messages/screens/conversations_screen.dart';
import 'features/messages/screens/chat_screen.dart';
import 'features/notifications/screens/notifications_screen.dart';
import 'features/profile/screens/student_profile_screen.dart';
import 'features/profile/screens/company_profile_screen.dart';
import 'features/profile/screens/edit_profile_screen.dart';
import 'shared/widgets/main_shell.dart';

class AppRouter {
  static GoRouter? _router;
  static AuthProvider? _lastAuth;

  static GoRouter build(AuthProvider auth) {
    if (_router != null && identical(_lastAuth, auth)) return _router!;
    _lastAuth = auth;
    _router = _buildRouter(auth);
    return _router!;
  }

  static GoRouter _buildRouter(AuthProvider auth) {
    return GoRouter(
      refreshListenable: auth,
      initialLocation: '/login',
      redirect: (context, state) {
        final isLoggedIn = auth.isAuthenticated;
        final path = state.matchedLocation;
        final isAuthRoute = path == '/login' ||
            path == '/register/student' ||
            path == '/register/company';

        if (!isLoggedIn && !isAuthRoute) return '/login';
        if (isLoggedIn && isAuthRoute) {
          return auth.isStudent ? '/dashboard' : '/company-dashboard';
        }
        return null;
      },
      routes: [
        // Auth routes (outside shell)
        GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
        GoRoute(path: '/register/student', builder: (_, _) => const RegisterScreen(isStudent: true)),
        GoRoute(path: '/register/company', builder: (_, _) => const RegisterScreen(isStudent: false)),

        ShellRoute(
          builder: (ctx, state, child) => MainShell(child: child),
          routes: [
            // ── STUDENT ──────────────────────────────────────────
            GoRoute(path: '/dashboard', builder: (_, _) => const StudentDashboardScreen()),

            GoRoute(path: '/projects', builder: (_, _) => const ProjectsScreen()),
            GoRoute(path: '/projects/create', builder: (_, _) => const CreateProjectScreen()),
            GoRoute(
              path: '/projects/:id',
              builder: (_, state) => ProjectDetailScreen(id: int.parse(state.pathParameters['id']!)),
            ),
            GoRoute(
              path: '/projects/:id/edit',
              builder: (_, state) => EditProjectScreen(
                projectId: int.parse(state.pathParameters['id']!),
                project: (state.extra as Map<String, dynamic>?) ?? {},
              ),
            ),

            GoRoute(path: '/opportunities', builder: (_, _) => const OpportunitiesScreen()),
            GoRoute(
              path: '/opportunities/:id',
              builder: (_, state) => OpportunityDetailScreen(id: int.parse(state.pathParameters['id']!)),
            ),

            // Profile – student
            GoRoute(path: '/profile/student', builder: (_, _) => const StudentProfileScreen()),
            GoRoute(
              path: '/profile/student/edit',
              builder: (_, state) => EditProfileScreen(
                isCompany: false,
                existing: state.extra as Map<String, dynamic>?,
              ),
            ),

            // ── COMPANY ──────────────────────────────────────────
            GoRoute(path: '/company-dashboard', builder: (_, _) => const CompanyDashboardScreen()),

            GoRoute(path: '/company/opportunities', builder: (_, _) => const CompanyOpportunitiesScreen()),
            GoRoute(path: '/company/opportunities/create', builder: (_, _) => const OpportunityFormScreen()),
            GoRoute(
              path: '/company/opportunities/edit/:id',
              builder: (_, state) => OpportunityFormScreen(
                existing: state.extra as Map<String, dynamic>?,
              ),
            ),

            GoRoute(
              path: '/applicants/:opportunityId',
              builder: (_, state) => ApplicantsScreen(
                opportunityId: int.parse(state.pathParameters['opportunityId']!),
              ),
            ),

            // Profile – company
            GoRoute(path: '/profile/company', builder: (_, _) => const CompanyProfileScreen()),
            GoRoute(
              path: '/profile/company/edit',
              builder: (_, state) => EditProfileScreen(
                isCompany: true,
                existing: state.extra as Map<String, dynamic>?,
              ),
            ),

            // ── SHARED ───────────────────────────────────────────
            GoRoute(path: '/messages', builder: (_, _) => const ConversationsScreen()),
            GoRoute(
              path: '/messages/:applicationId',
              builder: (_, state) => ChatScreen(
                applicationId: int.parse(state.pathParameters['applicationId']!),
              ),
            ),

            GoRoute(path: '/notifications', builder: (_, _) => const NotificationsScreen()),
          ],
        ),
      ],
    );
  }
}
