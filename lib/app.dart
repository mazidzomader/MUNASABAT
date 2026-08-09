import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routing/app_router.dart';
import 'core/theme/theme_data.dart';

/// Root application widget.
///
/// Assembles [MaterialApp.router] with the Munasabat theme and go_router.
/// Wrapped in [ProviderScope] from [main.dart].
class MunasabatApp extends ConsumerWidget {
  const MunasabatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Munasabat',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: router,
    );
  }
}
