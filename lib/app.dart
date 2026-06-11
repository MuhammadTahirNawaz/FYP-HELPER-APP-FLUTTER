import 'package:flutter/material.dart';

import 'core/app_providers.dart';
import 'core/app_router.dart';
import 'theme/app_theme.dart';

class FypHelperApp extends StatelessWidget {
  const FypHelperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppProviders(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        initialRoute: AppRouter.initialRoute,
        routes: AppRouter.routes,
      ),
    );
  }
}
