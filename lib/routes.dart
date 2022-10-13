import 'package:falotier/presentation/street_lamps_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

part 'routes.g.dart';

@TypedGoRoute<StreetLampsRoute>(path: '/')
class StreetLampsRoute extends GoRouteData {
  const StreetLampsRoute();

  @override
  Widget build(BuildContext context) => const StreetLampsScreen();
}
