import 'package:flutter/material.dart';
import 'package:task_management/model/project.dart';
import 'package:task_management/provider/project_provider.dart';
import 'package:task_management/pages/project_edit_page.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final ProjectProvider projectProvider;
  const ProjectCard({
    super.key,
    required this.project,
    required this.projectProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 1,
        color: project.color,
        child: ListTile(
          onTap: () =>
              _navigateProjectEditPage(context, projectProvider, project),
          title: Text(
            "Project: ${project.title}",
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ));
  }

  Future<void> _navigateProjectEditPage(
      BuildContext context, ProjectProvider projectProvider,
      [Project? project]) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            ProjectEditPage(project: project, projectProvider: projectProvider),
      ),
    );
  }
}
