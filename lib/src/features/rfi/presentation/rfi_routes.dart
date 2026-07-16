import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/domain/entities/rfi_list_item.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/domain/inspection/inspection_item.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/domain/rfi_list_kind.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/domain/utils/rfi_list_item_mapper.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/domain/rfi_log/rfi_log_dashboard_filter.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/presentation/assign_executive/assign_executive_screen.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/presentation/inspection/inspection_list_screen.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/presentation/inspection/start_inspection_online_screen.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/presentation/inspection_reference/inspection_reference_screen.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/presentation/pages/create_rfi_page.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/presentation/pages/rfi_dashboard_page.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/presentation/pages/rfi_list_page.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/presentation/rfi_details/view_rfi_details_screen.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/presentation/rfi_log/rfi_log_screen.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/presentation/update_rfi/update_rfi_screen.dart';
import 'package:wcr_pmis_mobile/src/features/rfi/presentation/validation/validation_screen.dart';

abstract final class RfiRoutes {
  static const String dashboardPath = RfiDashboardPage.routePath;
  static const String dashboardName = RfiDashboardPage.routeName;

  static List<RouteBase> get routes => <RouteBase>[
        GoRoute(
          path: RfiDashboardPage.routePath,
          name: RfiDashboardPage.routeName,
          builder: (BuildContext context, GoRouterState state) =>
              const RfiDashboardPage(),
        ),
        GoRoute(
          path: CreateRfiPage.routePath,
          name: CreateRfiPage.routeName,
          builder: (BuildContext context, GoRouterState state) =>
              const CreateRfiPage(),
        ),
        GoRoute(
          path: RfiListPage.routePath,
          name: RfiListPage.routeName,
          builder: (BuildContext context, GoRouterState state) {
            final RfiListKind? kind = RfiListKindX.fromRouteSegment(
              state.pathParameters['kind'],
            );
            if (kind == null) {
              return const RfiDashboardPage();
            }
            return RfiListPage(kind: kind);
          },
        ),
        GoRoute(
          path: '/rfi/detail/:id',
          name: 'rfi-detail',
          builder: (BuildContext context, GoRouterState state) {
            final int id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
            return ViewRfiDetailsScreen(rfiId: id);
          },
        ),
        GoRoute(
          path: '/rfi/update',
          name: 'rfi-update',
          builder: (BuildContext context, GoRouterState state) {
            final RfiListItem item = state.extra! as RfiListItem;
            return UpdateRfiScreen(item: toPortedRfiListItem(item));
          },
        ),
        GoRoute(
          path: '/rfi/log',
          name: 'rfi-log',
          builder: (BuildContext context, GoRouterState state) {
            final RfiLogDashboardFilter filter =
                RfiLogDashboardFilterX.fromExtra(state.extra) ??
                    RfiLogDashboardFilter.none;
            return RfiLogScreen(dashboardFilter: filter);
          },
        ),
        GoRoute(
          path: '/rfi/validation',
          name: 'rfi-validation',
          builder: (BuildContext context, GoRouterState state) =>
              const ValidationScreen(),
        ),
        GoRoute(
          path: '/rfi/inspection',
          name: 'rfi-inspection',
          builder: (BuildContext context, GoRouterState state) {
            bool rescheduledOnly = false;
            final Object? extra = state.extra;
            if (extra is Map && extra['rescheduledOnly'] == true) {
              rescheduledOnly = true;
            } else if (extra is bool) {
              rescheduledOnly = extra;
            }
            return InspectionListScreen(rescheduledOnly: rescheduledOnly);
          },
        ),
        GoRoute(
          path: '/rfi/inspection/start',
          name: 'rfi-inspection-start',
          builder: (BuildContext context, GoRouterState state) {
            if (state.extra is Map<String, dynamic>) {
              final Map<String, dynamic> data =
                  state.extra! as Map<String, dynamic>;
              return StartInspectionOnlineScreen(
                item: data['item'] as InspectionItem,
                isOffline: data['isOffline'] as bool? ?? false,
              );
            }
            return StartInspectionOnlineScreen(
              item: state.extra! as InspectionItem,
            );
          },
        ),
        GoRoute(
          path: '/rfi/assign-executive',
          name: 'rfi-assign-executive',
          builder: (BuildContext context, GoRouterState state) =>
              const AssignExecutiveScreen(),
        ),
        GoRoute(
          path: '/rfi/inspection-reference',
          name: 'rfi-inspection-reference',
          builder: (BuildContext context, GoRouterState state) =>
              const InspectionReferenceScreen(),
        ),
      ];
}
