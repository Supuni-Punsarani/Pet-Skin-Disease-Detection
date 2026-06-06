import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_links/app_links.dart';
import 'theme/app_theme.dart';
import 'providers/diagnosis_provider.dart';
import 'providers/auth_provider.dart';
import 'services/firebase_service.dart';
import 'screens/splash_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/home_screen.dart';
import 'screens/select_pet_screen.dart';
import 'screens/upload_image_screen.dart';
import 'screens/view_image_screen.dart';
import 'screens/symptom_question1_screen.dart';
import 'screens/symptom_question2_screen.dart';
import 'screens/symptom_question3_screen.dart';
import 'screens/ai_processing_screen.dart';
import 'screens/result_screen.dart';
import 'screens/treatment_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/vet_location_screen.dart';
import 'screens/history_screen.dart';
import 'screens/reset_password_confirm_screen.dart';

/// Global navigator key so deep-link handler can push routes without context.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise Firebase before runApp
  await initFirebase();

  // Disable Google Fonts runtime network fetching (works offline, uses bundled fonts)
  GoogleFonts.config.allowRuntimeFetching = false;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..init()),
        ChangeNotifierProvider(create: (_) => DiagnosisProvider()),
      ],
      child: const PetSkinApp(),
    ),
  );
}

class PetSkinApp extends StatefulWidget {
  const PetSkinApp({super.key});

  @override
  State<PetSkinApp> createState() => _PetSkinAppState();
}

class _PetSkinAppState extends State<PetSkinApp> {
  late final AppLinks _appLinks;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    // Handle the link that launched the app (cold start)
    try {
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        _handleDeepLink(initialLink);
      }
    } catch (_) {}

    // Handle links while the app is already running (warm start)
    _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    });
  }

  /// Routes an incoming deep-link URI to the correct screen.
  ///
  /// Firebase password reset links look like:
  ///   petderm://resetPassword?oobCode=XXXX&mode=resetPassword
  void _handleDeepLink(Uri uri) {
    final mode = uri.queryParameters['mode'];
    final oobCode = uri.queryParameters['oobCode'] ?? '';

    if (mode == 'resetPassword' && oobCode.isNotEmpty) {
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => ResetPasswordConfirmScreen(oobCode: oobCode),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PetDerm AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      navigatorKey: navigatorKey,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        final uri = Uri.parse(settings.name ?? '/');

        if (uri.path == '/resetPassword') {
          final oobCode = uri.queryParameters['oobCode'] ?? '';
          return MaterialPageRoute(
            builder: (context) => ResetPasswordConfirmScreen(oobCode: oobCode),
            settings: settings,
          );
        }

        Widget builder;
        switch (uri.path) {
          case '/':
            builder = const SplashScreen();
            break;
          case '/signin':
            builder = const SignInScreen();
            break;
          case '/signup':
            builder = const SignUpScreen();
            break;
          case '/forgot-password':
            builder = const ForgotPasswordScreen();
            break;
          case '/home':
            builder = const HomeScreen();
            break;
          case '/select-pet':
            builder = const SelectPetScreen();
            break;
          case '/upload-image':
            builder = const UploadImageScreen();
            break;
          case '/view-image':
            builder = const ViewImageScreen();
            break;
          case '/question1':
            builder = const SymptomQuestion1Screen();
            break;
          case '/question2':
            builder = const SymptomQuestion2Screen();
            break;
          case '/question3':
            builder = const SymptomQuestion3Screen();
            break;
          case '/processing':
            builder = const AiProcessingScreen();
            break;
          case '/result':
            builder = const ResultScreen();
            break;
          case '/treatment':
            builder = const TreatmentScreen();
            break;
          case '/vet':
            builder = const VetLocationScreen();
            break;
          case '/history':
            builder = const HistoryScreen();
            break;
          case '/settings':
            builder = const SettingsScreen();
            break;
          default:
            builder = const SplashScreen();
        }

        return MaterialPageRoute(
          builder: (context) => builder,
          settings: settings,
        );
      },
    );
  }
}
