import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wcr_pmis_mobile/src/app/router/go_router_refresh.dart';
import 'package:wcr_pmis_mobile/src/features/auth/domain/entities/auth_session.dart';
import 'package:wcr_pmis_mobile/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:wcr_pmis_mobile/src/features/auth/presentation/pages/login_page.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/pages/add_issue_form_page.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/pages/add_project_form_page.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/pages/add_project_page.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/pages/add_utility_shifting_form_page.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/pages/ai_custom_report_page.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/pages/issues_page.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/pages/project_details_page.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/presentation/rfi_routes.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/pages/new_activities_update_page.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/pages/utility_shifting_page.dart';
import 'package:wcr_pmis_mobile/src/features/profile/presentation/pages/profile_page.dart';
import 'package:wcr_pmis_mobile/src/features/settings/presentation/pages/settings_page.dart';

final goRouterRefreshProvider = Provider<GoRouterRefresh>((ref) {
  final GoRouterRefresh notifier = GoRouterRefresh();
  ref.listen<AsyncValue<AuthSession?>>(authControllerProvider, (
    AsyncValue<AuthSession?>? previous,
    AsyncValue<AuthSession?> next,
  ) {
    notifier.notifyAuthChanged();
  });
  return notifier;
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final GoRouterRefresh refresh = ref.watch(goRouterRefreshProvider);
  return GoRouter(
    initialLocation: LoginPage.routePath,
    refreshListenable: refresh,
    redirect: (BuildContext context, GoRouterState state) {
      final ProviderContainer container = ProviderScope.containerOf(context);
      final bool loggedIn =
          container.read(authControllerProvider).valueOrNull != null;
      final String loc = state.matchedLocation;
      if (!loggedIn && loc == DashboardPage.routePath) {
        return LoginPage.routePath;
      }
      if (!loggedIn && loc == ProfilePage.routePath) {
        return LoginPage.routePath;
      }
      if (!loggedIn && loc == SettingsPage.routePath) {
        return LoginPage.routePath;
      }
      if (!loggedIn && loc == ProjectDetailsPage.routePath) {
        return LoginPage.routePath;
      }
      if (!loggedIn && loc == AddProjectPage.routePath) {
        return LoginPage.routePath;
      }
      if (!loggedIn && loc == AddProjectFormPage.routePath) {
        return LoginPage.routePath;
      }
      if (!loggedIn && loc == AddUtilityShiftingFormPage.routePath) {
        return LoginPage.routePath;
      }
      if (!loggedIn && loc == AiCustomReportPage.routePath) {
        return LoginPage.routePath;
      }
      if (!loggedIn && loc == IssuesPage.routePath) {
        return LoginPage.routePath;
      }
      if (!loggedIn && loc == AddIssueFormPage.routePath) {
        return LoginPage.routePath;
      }
      if (!loggedIn && loc == NewActivitiesUpdatePage.routePath) {
        return LoginPage.routePath;
      }
      if (!loggedIn && loc == UtilityShiftingPage.routePath) {
        return LoginPage.routePath;
      }
      if (!loggedIn && loc.startsWith('/rfi')) {
        return LoginPage.routePath;
      }
      if (loggedIn && loc == LoginPage.routePath) {
        return DashboardPage.routePath;
      }
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: LoginPage.routePath,
        name: LoginPage.routeName,
        builder: (BuildContext context, GoRouterState state) =>
            const LoginPage(),
      ),
      GoRoute(
        path: DashboardPage.routePath,
        name: DashboardPage.routeName,
        builder: (BuildContext context, GoRouterState state) =>
            const DashboardPage(),
      ),
      GoRoute(
        path: ProfilePage.routePath,
        name: ProfilePage.routeName,
        builder: (BuildContext context, GoRouterState state) =>
            const ProfilePage(),
      ),
      GoRoute(
        path: SettingsPage.routePath,
        name: SettingsPage.routeName,
        builder: (BuildContext context, GoRouterState state) =>
            const SettingsPage(),
      ),
      GoRoute(
        path: ProjectDetailsPage.routePath,
        name: ProjectDetailsPage.routeName,
        builder: (BuildContext context, GoRouterState state) {
          final String projectTypeName = state.extra is String
              ? state.extra! as String
              : 'Project';
          return ProjectDetailsPage(projectTypeName: projectTypeName);
        },
      ),
      GoRoute(
        path: AddProjectPage.routePath,
        name: AddProjectPage.routeName,
        builder: (BuildContext context, GoRouterState state) =>
            const AddProjectPage(),
      ),
      GoRoute(
        path: AddProjectFormPage.routePath,
        name: AddProjectFormPage.routeName,
        builder: (BuildContext context, GoRouterState state) =>
            const AddProjectFormPage(),
      ),
      GoRoute(
        path: AiCustomReportPage.routePath,
        name: AiCustomReportPage.routeName,
        builder: (BuildContext context, GoRouterState state) =>
            AiCustomReportPage(
              dataSource: ref.read(dashboardRemoteDataSourceProvider),
            ),
      ),
      GoRoute(
        path: AddUtilityShiftingFormPage.routePath,
        name: AddUtilityShiftingFormPage.routeName,
        builder: (BuildContext context, GoRouterState state) {
          final String? editId =
              state.uri.queryParameters['utility_shifting_id']?.trim();
          return AddUtilityShiftingFormPage(
            dataSource: ref.read(dashboardRemoteDataSourceProvider),
            utilityShiftingId:
                editId != null && editId.isNotEmpty ? editId : null,
          );
        },
      ),
      GoRoute(
        path: IssuesPage.routePath,
        name: IssuesPage.routeName,
        builder: (BuildContext context, GoRouterState state) =>
            IssuesPage(dataSource: ref.read(dashboardRemoteDataSourceProvider)),
      ),
      GoRoute(
        path: AddIssueFormPage.routePath,
        name: AddIssueFormPage.routeName,
        builder: (BuildContext context, GoRouterState state) {
          final AuthSession? session =
              ref.read(authControllerProvider).valueOrNull;
          return AddIssueFormPage(
            dataSource: ref.read(dashboardRemoteDataSourceProvider),
            session: session,
          );
        },
      ),
      GoRoute(
        path: NewActivitiesUpdatePage.routePath,
        name: NewActivitiesUpdatePage.routeName,
        builder: (BuildContext context, GoRouterState state) =>
            NewActivitiesUpdatePage(
              dataSource: ref.read(dashboardRemoteDataSourceProvider),
            ),
      ),
      GoRoute(
        path: UtilityShiftingPage.routePath,
        name: UtilityShiftingPage.routeName,
        builder: (BuildContext context, GoRouterState state) =>
            UtilityShiftingPage(
              dataSource: ref.read(dashboardRemoteDataSourceProvider),
            ),
      ),
      ...RfiRoutes.routes,
    ],
  );
});
