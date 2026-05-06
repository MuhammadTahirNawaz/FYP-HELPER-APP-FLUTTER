import 'package:flutter/material.dart';

class AdminUser {
  const AdminUser({
    required this.name,
    required this.role,
    required this.status,
  });

  final String name;
  final String role;
  final String status;
}

class AdminMockStore {
  AdminMockStore._();

  static final AdminMockStore instance = AdminMockStore._();

  final ValueNotifier<List<AdminUser>> users = ValueNotifier<List<AdminUser>>(
    <AdminUser>[],
  );
  final ValueNotifier<List<String>> projects = ValueNotifier<List<String>>(
    <String>[],
  );

  void addUser(AdminUser user) {
    final updated = List<AdminUser>.from(users.value);
    updated.insert(0, user);
    users.value = updated;
  }

  void addProject(String projectName) {
    final updated = List<String>.from(projects.value);
    updated.insert(0, projectName);
    projects.value = updated;
  }
}
