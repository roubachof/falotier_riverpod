import 'package:falotier/presentation/home/street_lamps_screen.dart';
import 'package:falotier/presentation/street_lamp_details/street_lamp_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part 'routes.g.dart';

@TypedGoRoute<StreetLampsRoute>(
  path: '/',
  routes: [
    TypedGoRoute<StreetLampDetailsRoute>(
      path: 'streetLampDetails/:id',
    )
  ],
)
class StreetLampsRoute extends GoRouteData {
  const StreetLampsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const StreetLampsScreen();
}

class StreetLampDetailsRoute extends GoRouteData {
  const StreetLampDetailsRoute(this.id, {this.$extra});

  final String id;
  final String? $extra;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    assert($extra != null);

    return StreetLampDetailsScreen(
      streetLampId: id,
      streetName: $extra!,
    );
  }
}
