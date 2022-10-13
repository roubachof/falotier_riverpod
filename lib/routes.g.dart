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
