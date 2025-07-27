
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../screens/main_screen.dart';
import '../screens/home_screen.dart';
import '../screens/add_besoin_screen.dart';
import '../screens/add_besoin_apart_screen.dart';
import '../screens/edit_besoin_screen.dart';
import '../screens/monthly_summary_screen.dart';
import '../screens/dashboard_screen.dart';
import '../../domain/besoin.dart';

final GoRouter appRouter = GoRouter(
  routes: <GoRoute>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const MainScreen();
      },
      routes: <GoRoute>[
        GoRoute(
          path: 'add',
          builder: (BuildContext context, GoRouterState state) {
            return const AddBesoinScreen();
          },
        ),
        GoRoute(
          path: 'add-apart',
          builder: (BuildContext context, GoRouterState state) {
            return const AddBesoinApartScreen();
          },
        ),
        GoRoute(
          path: 'edit',
          builder: (BuildContext context, GoRouterState state) {
            final besoin = state.extra as Besoin; // Cast the extra to Besoin
            return EditBesoinScreen(besoin: besoin);
          },
        ),
        GoRoute(
          path: 'summary',
          builder: (BuildContext context, GoRouterState state) {
            return const MonthlySummaryScreen();
          },
        ),
        GoRoute(
          path: 'dashboard',
          builder: (BuildContext context, GoRouterState state) {
            return const DashboardScreen();
          },
        ),
      ],
    ),
  ],
);
