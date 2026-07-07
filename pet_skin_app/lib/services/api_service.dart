import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;
import '../models/disease_result.dart';
import '../models/symptom_answer.dart';

/// The base URL of the FastAPI backend.
///
/// ─── IMPORTANT: Update this URL ───────────────────────────────────────────
///
/// • CLOUD DEPLOYMENT (for all users — recommended):
///     Use your Render.com URL, e.g. "https://petderm-ai.onrender.com"
///     Deploy the backend folder to Render.com (free) — see DEPLOYMENT.md
///
/// • LOCAL DEVELOPMENT on same Wi-Fi:
///     Use your PC's local IP, e.g. "http://192.168.8.102:8000"
///     (Find it with: ipconfig → look for IPv4 Address under Wi-Fi adapter)
///
/// • Android Emulator:
///     Use "http://10.0.2.2:8000"
///
/// • iOS Simulator:
///     Use "http://localhost:8000"
/// ──────────────────────────────────────────────────────────────────────────
const String _kBackendBaseUrl = 'https://petderm-ai.onrender.com';

const String _kConnectionErrorMsg =
    'Cannot connect to the server at $_kBackendBaseUrl.\n'
    'Make sure the FastAPI backend is running and the URL is correct.';

class ApiService {
  /// Sends the dog image + 6 symptom answer codes to the FastAPI backend
  /// and returns a [DiseaseResult] on success.
  ///
  /// Throws a [ApiException] on network errors or non-200 responses.
  static Future<DiseaseResult> diagnose({
    required String imagePath,
    required SymptomAnswers answers,
    required String petType,
  }) async {
    final uri = Uri.parse('$_kBackendBaseUrl/predict');

    // Build multipart request
    final request = http.MultipartRequest('POST', uri);

    // Determine the image type based on file extension
    final ext = p.extension(imagePath).toLowerCase().replaceAll('.', '');
    final mimeType = (ext == 'jpg' || ext == 'jpeg') ? 'jpeg' : 'png';

    // Attach the image file
    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        imagePath,
        contentType: MediaType('image', mimeType),
      ),
    );

    // Attach symptom answers as a JSON string
    final symptomsJson = jsonEncode({
      'q1': answers.q1Duration ?? 'E',
      'q2': answers.q2Scratching ?? 'A',
      'q3': answers.q3SkinLook ?? 'D',
      'q4': answers.q4Smell ?? 'A',
      'q5': answers.q5Environment ?? 'A',
      'q6': answers.q6Behavior ?? 'A',
    });
    request.fields['symptoms'] = symptomsJson;

    // Send pet type so backend routes to the correct model
    request.fields['pet_type'] = petType.toLowerCase();

    // Send with 30s timeout
    http.StreamedResponse streamedResponse;
    try {
      streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw const ApiException(
          'Request timed out. Check that the backend server is running.',
        ),
      );
    } on SocketException {
      throw const ApiException(_kConnectionErrorMsg);
    }

    final responseBody = await streamedResponse.stream.bytesToString();

    if (streamedResponse.statusCode != 200) {
      String detail = 'Unknown error';
      try {
        detail = jsonDecode(responseBody)['detail'] ?? detail;
      } catch (_) {}
      throw ApiException('Server error (${streamedResponse.statusCode}): $detail');
    }

    final json = jsonDecode(responseBody) as Map<String, dynamic>;
    return DiseaseResult.fromJson(json, petType: petType);
  }

  /// Quick connectivity test — returns true if the backend is reachable.
  static Future<bool> isServerReachable() async {
    try {
      final response = await http
          .get(Uri.parse('$_kBackendBaseUrl/health'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

/// Thrown when the API call fails for any reason.
class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}
