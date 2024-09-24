// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $streetLampsRoute,
    ];

RouteBase get $streetLampsRoute => GoRouteData.$route(
      path: '/',
      factory: $StreetLampsRouteExtension._fromState,
      routes: [
        GoRouteData.$route(
          path: 'streetLampDetails/:id',
          factory: $StreetLampDetailsRouteExtension._fromState,
        ),
      ],
    );

extension $StreetLampsRouteExtension on StreetLampsRoute {
  static StreetLampsRoute _fromState(GoRouterState state) =>
      const StreetLampsRoute();

  String get location => GoRouteData.$location(
        '/',
      );

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  void replace(BuildContext context) => context.replace(location);
}

extension $StreetLampDetailsRouteExtension on StreetLampDetailsRoute {
  static StreetLampDetailsRoute _fromState(GoRouterState state) =>
      StreetLampDetailsRoute(
        state.pathParameters['id']!,
        $extra: state.extra as String?,
      );

  String get location => GoRouteData.$location(
        '/streetLampDetails/${Uri.encodeComponent(id)}',
      );

  void go(BuildContext context) => context.go(location, extra: $extra);

  Future<T?> push<T>(BuildContext context) =>
      context.push<T>(location, extra: $extra);

  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location, extra: $extra);

  void replace(BuildContext context) =>
      context.replace(location, extra: $extra);
}
