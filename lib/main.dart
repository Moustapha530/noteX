import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:note_x/router.dart';

Future<void> main() async {
  final widgetsBinding =
      WidgetsFlutterBinding.ensureInitialized();

  FlutterNativeSplash.preserve(
    widgetsBinding: widgetsBinding,
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );

  await Future.delayed(
    const Duration(seconds: 1),
  );

  FlutterNativeSplash.remove();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      title: 'noteX',
    );
  }
}