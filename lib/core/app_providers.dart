import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../repositories/admin_repository.dart';
import '../repositories/auth_repository.dart';
import '../repositories/group_repository.dart';
import '../repositories/user_repository.dart';
import '../services/student_workflow_service.dart';
import '../state/session_provider.dart';

/// Root dependency injection for repositories and app-wide state.
class AppProviders extends StatelessWidget {
  const AppProviders({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthRepository>(create: (_) => AuthRepository()),
        Provider<UserRepository>(create: (_) => UserRepository()),
        Provider<GroupRepository>(create: (_) => GroupRepository()),
        Provider<StudentWorkflowService>(
          create: (context) => StudentWorkflowService(
            groupRepository: context.read<GroupRepository>(),
          ),
        ),
        Provider<AdminRepository>(create: (_) => AdminRepository()),
        ChangeNotifierProvider<SessionProvider>(
          create: (context) => SessionProvider(
            authRepository: context.read<AuthRepository>(),
            userRepository: context.read<UserRepository>(),
          )..bootstrap(),
        ),
      ],
      child: child,
    );
  }
}
