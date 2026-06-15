import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wcr_pmis_mobile/src/app/router/go_router_refresh.dart';
import 'package:wcr_pmis_mobile/src/features/auth/domain/entities/auth_session.dart';
import 'package:wcr_pmis_mobile/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:wcr_pmis_mobile/src/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:wcr_pmis_mobile/src/features/auth/presentation/pages/login_page.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/issues/add_issue_form_page.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/projects/add_project_form_page.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/projects/add_project_page.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/contracts/contract_form_page.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/contracts/contracts_page.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/contractors/contractor_form_page.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/contractors/contractors_page.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/utility_shifting/add_utility_shifting_form_page.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/reports/ai_custom_report_page.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/home/dashboard_page.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/issues/issues_page.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/projects/project_details_page.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/projects/project_summary_page.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/presentation/rfi_routes.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/activities/new_activities_update_page.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/quality_inspections/add_quality_inspection_form_page.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/domain/utils/quality_inspection_user_access.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/quality_inspections/quality_inspections_page.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/dms/dms_page.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/utility_shifting/utility_shifting_page.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/structures/structure_form_list_page.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/structures/structure_form_page.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/structures/structures_page.dart';
import 'package:wcr_pmis_mobile/src/features/dashboard/presentation/structures/update_structure_work_form_page.dart';
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
      if (!loggedIn && loc == ProjectSummaryPage.routePath) {
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
      if (!loggedIn && loc == QualityInspectionsPage.routePath) {
        return LoginPage.routePath;
      }
      if (!loggedIn && loc == DmsPage.routePath) {
        return LoginPage.routePath;
      }
      if (!loggedIn && loc == AddQualityInspectionFormPage.routePath) {
        return LoginPage.routePath;
      }
      if (!loggedIn && loc == StructuresPage.routePath) {
        return LoginPage.routePath;
      }
      if (!loggedIn && loc == StructureFormPage.addRoutePath) {
        return LoginPage.routePath;
      }
      if (!loggedIn && loc == StructureFormPage.editRoutePath) {
        return LoginPage.routePath;
      }
      if (!loggedIn && loc == StructureFormListPage.routePath) {
        return LoginPage.routePath;
      }
      if (!loggedIn && loc == UpdateStructureWorkFormPage.routePath) {
        return LoginPage.routePath;
      }
      if (!loggedIn && loc == ContractorsPage.routePath) {
        return LoginPage.routePath;
      }
      if (!loggedIn && loc == ContractorFormPage.routePath) {
        return LoginPage.routePath;
      }
      if (!loggedIn && loc == ContractsPage.routePath) {
        return LoginPage.routePath;
      }
      if (!loggedIn && loc == ContractFormPage.routePath) {
        return LoginPage.routePath;
      }
      if (loggedIn &&
          (loc == QualityInspectionsPage.routePath ||
              loc == AddQualityInspectionFormPage.routePath)) {
        final QualityInspectionUserAccess access = container.read(
          qualityInspectionAccessProvider,
        );
        if (!access.canAccessModule) {
          return DashboardPage.routePath;
        }
      }
      if (!loggedIn && loc.startsWith('/rfi')) {
        return LoginPage.routePath;
      }
      if (loggedIn && loc == LoginPage.routePath) {
        return DashboardPage.routePath;
      }
      if (loggedIn && loc == ForgotPasswordPage.routePath) {
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
        path: ForgotPasswordPage.routePath,
        name: ForgotPasswordPage.routeName,
        builder: (BuildContext context, GoRouterState state) =>
            const ForgotPasswordPage(),
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
        path: ProjectSummaryPage.routePath,
        name: ProjectSummaryPage.routeName,
        builder: (BuildContext context, GoRouterState state) {
          final ProjectSummaryArgs args = state.extra is ProjectSummaryArgs
              ? state.extra! as ProjectSummaryArgs
              : const ProjectSummaryArgs(
                  projectTypeName: '',
                  projectName: '',
                  projectId: '',
                );
          return ProjectSummaryPage(args: args);
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
      GoRoute(
        path: QualityInspectionsPage.routePath,
        name: QualityInspectionsPage.routeName,
        builder: (BuildContext context, GoRouterState state) =>
            QualityInspectionsPage(
              dataSource: ref.read(dashboardRemoteDataSourceProvider),
            ),
      ),
      GoRoute(
        path: DmsPage.routePath,
        name: DmsPage.routeName,
        builder: (BuildContext context, GoRouterState state) =>
            DmsPage(dataSource: ref.read(dashboardRemoteDataSourceProvider)),
      ),
      GoRoute(
        path: AddQualityInspectionFormPage.routePath,
        name: AddQualityInspectionFormPage.routeName,
        builder: (BuildContext context, GoRouterState state) {
          final String? editId =
              state.uri.queryParameters['inspection_id']?.trim();
          return AddQualityInspectionFormPage(
            dataSource: ref.read(dashboardRemoteDataSourceProvider),
            inspectionId: editId != null && editId.isNotEmpty ? editId : null,
          );
        },
      ),
      GoRoute(
        path: StructuresPage.routePath,
        name: StructuresPage.routeName,
        builder: (BuildContext context, GoRouterState state) =>
            StructuresPage(
              dataSource: ref.read(dashboardRemoteDataSourceProvider),
            ),
      ),
      GoRoute(
        path: StructureFormListPage.routePath,
        name: StructureFormListPage.routeName,
        builder: (BuildContext context, GoRouterState state) =>
            StructureFormListPage(
              dataSource: ref.read(dashboardRemoteDataSourceProvider),
            ),
      ),
      GoRoute(
        path: UpdateStructureWorkFormPage.routePath,
        name: UpdateStructureWorkFormPage.routeName,
        builder: (BuildContext context, GoRouterState state) {
          final String? structureId =
              state.uri.queryParameters['structure_id']?.trim();
          return UpdateStructureWorkFormPage(
            dataSource: ref.read(dashboardRemoteDataSourceProvider),
            structureId: structureId ?? '',
          );
        },
      ),
      GoRoute(
        path: ContractsPage.routePath,
        name: ContractsPage.routeName,
        builder: (BuildContext context, GoRouterState state) =>
            ContractsPage(
              dataSource: ref.read(dashboardRemoteDataSourceProvider),
            ),
      ),
      GoRoute(
        path: ContractFormPage.routePath,
        name: ContractFormPage.routeName,
        builder: (BuildContext context, GoRouterState state) {
          final String? contractId =
              state.uri.queryParameters['contract_id']?.trim();
          final Map<String, dynamic>? initialRecord =
              state.extra is Map<String, dynamic>
              ? Map<String, dynamic>.from(state.extra! as Map<String, dynamic>)
              : null;
          return ContractFormPage(
            dataSource: ref.read(dashboardRemoteDataSourceProvider),
            contractId:
                contractId != null && contractId.isNotEmpty ? contractId : null,
            initialRecord: initialRecord,
          );
        },
      ),
      GoRoute(
        path: ContractorsPage.routePath,
        name: ContractorsPage.routeName,
        builder: (BuildContext context, GoRouterState state) =>
            ContractorsPage(
              dataSource: ref.read(dashboardRemoteDataSourceProvider),
            ),
      ),
      GoRoute(
        path: ContractorFormPage.routePath,
        name: ContractorFormPage.routeName,
        builder: (BuildContext context, GoRouterState state) {
          final String? contractorId =
              state.uri.queryParameters['contractor_id']?.trim();
          return ContractorFormPage(
            dataSource: ref.read(dashboardRemoteDataSourceProvider),
            contractorId:
                contractorId != null && contractorId.isNotEmpty
                    ? contractorId
                    : null,
          );
        },
      ),
      GoRoute(
        path: StructureFormPage.addRoutePath,
        name: StructureFormPage.addRouteName,
        builder: (BuildContext context, GoRouterState state) =>
            StructureFormPage(
              dataSource: ref.read(dashboardRemoteDataSourceProvider),
              mode: StructureFormMode.add,
            ),
      ),
      GoRoute(
        path: StructureFormPage.editRoutePath,
        name: StructureFormPage.editRouteName,
        builder: (BuildContext context, GoRouterState state) {
          final String? projectId =
              state.uri.queryParameters['project_id']?.trim();
          return StructureFormPage(
            dataSource: ref.read(dashboardRemoteDataSourceProvider),
            mode: StructureFormMode.edit,
            initialProjectId:
                projectId != null && projectId.isNotEmpty ? projectId : null,
          );
        },
      ),
      ...RfiRoutes.routes,
    ],
  );
});
