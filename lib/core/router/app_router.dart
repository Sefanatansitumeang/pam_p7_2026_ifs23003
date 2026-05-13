import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/home_screen.dart';
import '../../features/plants/plants_add_screen.dart';
import '../../features/plants/plants_detail_screen.dart';
import '../../features/plants/plants_edit_screen.dart';
import '../../features/plants/plants_screen.dart';
import '../../features/space/space_screen.dart';
import '../../features/space/space_add_screen.dart';
import '../../features/space/space_detail_screen.dart';
import '../../features/space/space_edit_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../constants/route_constants.dart';
import '../../shared/widgets/bottom_nav_widget.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: RouteConstants.home,
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(path: RouteConstants.home,    builder: (_, __) => const HomeScreen()),
        GoRoute(path: RouteConstants.plants,  builder: (_, __) => const PlantsScreen()),
        GoRoute(path: RouteConstants.space,   builder: (_, __) => const SpaceScreen()),
        GoRoute(path: RouteConstants.profile, builder: (_, __) => const ProfileScreen()),
      ],
    ),
    GoRoute(path: '/plants/add',        builder: (_, __) => const PlantsAddScreen()),
    GoRoute(path: '/plants/:id',        builder: (_, s) => PlantsDetailScreen(plantId: s.pathParameters['id'] ?? '')),
    GoRoute(path: '/plants/:id/edit',   builder: (_, s) => PlantsEditScreen(plantId: s.pathParameters['id'] ?? '')),
    GoRoute(path: '/space/add',         builder: (_, __) => const SpaceAddScreen()),
    GoRoute(path: '/space/:id',         builder: (_, s) => SpaceDetailScreen(objectId: s.pathParameters['id'] ?? '')),
    GoRoute(path: '/space/:id/edit',    builder: (_, s) => SpaceEditScreen(objectId: s.pathParameters['id'] ?? '')),
  ],
);

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavWidget(child: child),
    );
  }
}