import 'package:flutter/material.dart';
import 'route/route_helper.dart';
import 'config/configure_nonweb.dart'
    if (dart.library.html) 'config/configure_web.dart';

void main() {
  configureApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MyInfo Implementation Of Fundex',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routerConfig: RouteGenerator.router(context),
    );
  }
}
