class HomeOverview {
  const HomeOverview({
    required this.projectsCount,
    required this.totalLength,
    required this.commissionedLength,
  });

  final int projectsCount;
  final double totalLength;
  final double commissionedLength;
}

class HomeProjectType {
  const HomeProjectType({required this.name, required this.cumulativeCount});

  final String name;
  final int cumulativeCount;
}

class HomeDashboardData {
  const HomeDashboardData({required this.overview, required this.projectTypes});

  final HomeOverview overview;
  final List<HomeProjectType> projectTypes;
}

class ProjectMajorItem {
  const ProjectMajorItem({
    required this.projectName,
    required this.item,
    required this.unit,
    required this.scope,
    required this.completed,
    required this.progressPercent,
    required this.tdc,
  });

  final String projectName;
  final String item;
  final String unit;
  final String scope;
  final String completed;
  final String progressPercent;
  final String tdc;
}

class ProjectDetailsData {
  const ProjectDetailsData({
    required this.projectTypeName,
    required this.projectNames,
    required this.items,
    required this.projectIdsByName,
  });

  final String projectTypeName;
  final List<String> projectNames;
  final List<ProjectMajorItem> items;
  final Map<String, String> projectIdsByName;
}
