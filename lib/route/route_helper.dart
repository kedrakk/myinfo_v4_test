import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:test_myinfo_v4/pages/callback.dart';
import 'package:test_myinfo_v4/pages/homepage.dart';

class AppRoutes {
  static const String home = "/";
  static const String callback = "/callback";
}

class RouteGenerator {
  static GoRouter router(BuildContext context) {
    return GoRouter(
      routes: [
        GoRoute(
          path: AppRoutes.home,
          name: AppRoutes.home,
          builder: (context, state) => const MyHomePage(),
        ),
        GoRoute(
          path: AppRoutes.callback,
          name: AppRoutes.callback,
          builder: (context, state) {
            String code = state.queryParams['code'] ?? "";
            String error = state.queryParams['error'] ?? "";
            String errorDesc = state.queryParams['error_description'] ?? "";
            return CallBackPage(
              code: code,
              error: error,
              errorDesc: errorDesc,
            );
          },
        ),
      ],
      errorBuilder: (context, state) {
        return Scaffold(
          appBar: AppBar(),
          body: const Center(
            child: Text(
              "Route Not Found 404",
            ),
          ),
        );
      },
    );
  }
}
