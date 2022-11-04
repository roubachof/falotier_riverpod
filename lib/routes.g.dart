// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routes.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<GoRoute> get $appRoutes => [
      $streetLampsRoute,
    ];

GoRoute get $streetLampsRoute => GoRouteData.$route(
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

  void go(BuildContext context) => context.go(location, extra: this);

  void push(BuildContext context) => context.push(location, extra: this);
}

extension $StreetLampDetailsRouteExtension on StreetLampDetailsRoute {
  static StreetLampDetailsRoute _fromState(GoRouterState state) =>
      StreetLampDetailsRoute(
        state.params['id']!,
        $extra: state.extra as String?,
      );

  String get location => GoRouteData.$location(
        '/streetLampDetails/${Uri.encodeComponent(id)}',
      );

  void go(BuildContext context) => context.go(location, extra: this);

  void push(BuildContext context) => context.push(location, extra: this);
}
