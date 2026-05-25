import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum DashboardViewMode { grid, list }

class DashboardViewModeController extends StateNotifier<DashboardViewMode> {
  DashboardViewModeController() : super(DashboardViewMode.list) {
    Future<void>.microtask(_load);
  }

  static const String _key = 'dashboard_view_mode';

  Future<void> _load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String value = prefs.getString(_key) ?? 'list';
    state = value == 'list' ? DashboardViewMode.list : DashboardViewMode.grid;
  }

  Future<void> setMode(DashboardViewMode mode) async {
    state = mode;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode == DashboardViewMode.list ? 'list' : 'grid');
  }
}

final dashboardViewModeProvider =
    StateNotifierProvider<DashboardViewModeController, DashboardViewMode>(
      (ref) => DashboardViewModeController(),
    );
