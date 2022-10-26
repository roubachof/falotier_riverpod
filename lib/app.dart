import 'package:falotier/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class App extends StatelessWidget {
  App({Key? key}) : super(key: key);

  final _router = GoRouter(routes: $appRoutes);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp.router(
        routerConfig: _router,
        title: 'falotier',
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
        ),
      ),
    );
  }
}
