import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void setupGlobalErrorHandling() {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (kDebugMode) {
      debugPrint('FlutterError: ${details.exceptionAsString()}');
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    if (kDebugMode) {
      debugPrint('Uncaught error: $error');
      debugPrint(stack.toString());
    }
    return true;
  };
}

Future<void> runAppSafely(Future<void> Function() bootstrap, Widget app) async {
  setupGlobalErrorHandling();

  await runZonedGuarded(
    () async {
      await bootstrap();
      runApp(app);
    },
    (error, stack) {
      if (kDebugMode) {
        debugPrint('Zone error: $error');
        debugPrint(stack.toString());
      }
    },
  );
}
