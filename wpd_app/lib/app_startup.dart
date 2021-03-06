import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wpd_app/api/http_client.dart';
import 'package:wpd_app/models/user/user.dart';
import 'package:wpd_app/services/service_locator.dart';
import 'package:wpd_app/ui/screens/splash_screen.dart';
import 'package:wpd_app/view_models/auth_state_viewmodel.dart';
import 'package:wpd_app/view_models/favorite_viewmodel.dart';

abstract class AppStartup {
  static Future<User?> setup() async {
    final _requestRest = serviceLocator<RequestREST>();

    if (!kReleaseMode) {
      _requestRest.setUpLogger();
    }

    // Checking the auth
    if (Platform.isIOS || Platform.isAndroid) {
      final user = await _requestRest.checkToken();

      return user;
    }

    return null;
  }
}

class StartUpPage extends ConsumerStatefulWidget {
  const StartUpPage({Key? key}) : super(key: key);

  @override
  _StartUpPageState createState() => _StartUpPageState();
}

class _StartUpPageState extends ConsumerState<StartUpPage> {
  late Future<User?> startUpFuture;

  @override
  void initState() {
    super.initState();

    startUpFuture = AppStartup.setup();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: startUpFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          WidgetsBinding.instance?.addPostFrameCallback((_) {
            final appState = ref.read(AuthStateViewModelProvider.provider);

            // Checking the auth screen
            if (snapshot.data != null) {
              appState.setUpWithToken(snapshot.data);
            }
            appState.splashing = false;
          });
        }

        return const SplashScreen();
      },
    );
  }
}
