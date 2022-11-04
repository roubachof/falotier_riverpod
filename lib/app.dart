import 'package:falotier/routes.dart';
import 'package:falotier_design/falotier_design.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class App extends StatelessWidget {
  App({Key? key}) : super(key: key);

  final _router = GoRouter(routes: $appRoutes);

  @override
  Widget build(BuildContext context) {
    final themeData = AppThemeData.regular();
    return ProviderScope(
      child: AppTheme(
        data: themeData,
        child: MaterialApp.router(
          routerConfig: _router,
          title: 'falotier',
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
          ),
        ),
      ),
    );
  }
}
