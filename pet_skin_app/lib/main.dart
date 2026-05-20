import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
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

class PetSkinApp extends StatelessWidget {
  const PetSkinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PetDerm AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/signin': (context) => const SignInScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/home': (context) => const HomeScreen(),
        '/select-pet': (context) => const SelectPetScreen(),
        '/upload-image': (context) => const UploadImageScreen(),
        '/view-image': (context) => const ViewImageScreen(),
        '/question1': (context) => const SymptomQuestion1Screen(),
        '/question2': (context) => const SymptomQuestion2Screen(),
        '/question3': (context) => const SymptomQuestion3Screen(),
        '/processing': (context) => const AiProcessingScreen(),
        '/result': (context) => const ResultScreen(),
        '/treatment': (context) => const TreatmentScreen(),
        '/vet': (context) => const VetLocationScreen(),
        '/history': (context) => const HistoryScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
