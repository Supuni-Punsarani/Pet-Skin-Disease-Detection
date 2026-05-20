import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';

/// Call once at app startup before runApp().
Future<void> initFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}
