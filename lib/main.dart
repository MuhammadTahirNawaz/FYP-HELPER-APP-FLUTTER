import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'utils/profiler.dart';

import 'app.dart';
import 'core/supported_platform.dart';
import 'firebase_options.dart';
import 'services/ad_service.dart';
import 'services/crypto_key_store.dart';
import 'services/push_notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CryptoKeyStore.initialize();
  await _initializeFirebaseIfSupported();
  await PushNotificationService.instance.initialize();
  await AdService.initialize();
  runApp(const FypHelperApp());
}

Future<void> _initializeFirebaseIfSupported() async {

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (kDebugMode) {
    await _writeFirebaseSmokeTest();
  }
}

Future<void> _writeFirebaseSmokeTest() async {
  try {
    await Profiler.profileAsync('Firebase RTDB Healthcheck Write', () async {
      await FirebaseDatabase.instance.ref('healthcheck').set({
        'status': 'ok',
        'checkedAt': ServerValue.timestamp,
        'platform': SupportedPlatform.name,
      });
    });
  } catch (error) {
    debugPrint('Firebase RTDB smoke test failed: $error');
  }
}
