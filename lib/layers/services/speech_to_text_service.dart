import 'package:dio/dio.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:voice_summary/layers/services/audio_player_service.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:flutter/services.dart' show rootBundle;

class SpeechToTextService {
  final Dio _dio = Dio();
  final logger = Logger();
  static const int _maxSyncDuration = 60; // 60 seconds max for sync API

  Future<String?> transcribeAudio(String filePath) async {
    try {
      final apiKey = dotenv.env['GOOGLE_SPEECH_API_KEY'];
      final projectId = dotenv.env['GOOGLE_CLOUD_PROJECT_ID'];
      final bucketName = dotenv.env['GOOGLE_CLOUD_BUCKET_NAME'];

      if (apiKey == null || projectId == null || bucketName == null) {
        throw Exception('Required environment variables not found');
      }

      // Get audio duration
      final audioFile = File(filePath);
      final audioBytes = await audioFile.readAsBytes();
      Logger().i('Audio duration: ${audioFile.length}');
      final audioDuration = await _getAudioDuration(filePath);
      Logger().i('Audio duration: $audioDuration');
      // Choose between sync and async API based on duration
      if (audioDuration <= _maxSyncDuration) {
        Logger().i('Transcribing short audio');
        return await _transcribeShortAudio(audioBytes, apiKey);
      } else {
        Logger().i('Transcribing long audio');
        return await _transcribeLongAudio(
          audioFile,
          projectId,
          bucketName,
          apiKey,
        );
      }
    } catch (e) {
      logger.e('Error in transcribeAudio: $e');
      rethrow;
    }
  }

  Future<int> _getAudioDuration(String audioFilePath) async {
    final AudioPlayerService audioPlayerService = AudioPlayerService();
    try {
      final duration = await audioPlayerService.getDuration(audioFilePath);
      return duration;
    } catch (e) {
      logger.e('Error in _getAudioDuration: $e');
      rethrow;
    }
  }

  Future<String?> _transcribeShortAudio(
    List<int> audioBytes,
    String apiKey,
  ) async {
    final client = await getAuthClient();
    final token = (await client.credentials.accessToken).data;
    client.close();

    final base64Audio = base64Encode(audioBytes);
    final url = 'https://speech.googleapis.com/v1/speech:recognize';

    final data = {
      'config': {
        "encoding": "LINEAR16",
        "sampleRateHertz": 16000,
        "languageCode": "en-US",
        "enableAutomaticPunctuation": true,
      },
      'audio': {'content': base64Audio},
    };

    final response = await _dio.post(
      url,
      data: data,
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to transcribe audio: ${response.data}');
    }

    if (response.data['results'] == null || response.data['results'].isEmpty) {
      throw Exception('No transcription results found');
    }
    Logger().i('Transcription results: ${response.data['results']}');
    return response.data['results'][0]['alternatives'][0]['transcript'];
  }

  Future<String?> _transcribeLongAudio(
    File audioFile,
    String projectId,
    String bucketName,
    String apiKey,
  ) async {
    String? gcsPath;
    try {
      // Get auth token
      final client = await getAuthClient();
      final token = (await client.credentials.accessToken).data;
      client.close();

      // Upload to GCS
      gcsPath = await _uploadToGCS(audioFile, bucketName, projectId);
      final gcsUri = 'gs://$bucketName/$gcsPath';
      Logger().i('GCS URI: $gcsUri');

      // Start long-running recognition
      final url =
          'https://speech.googleapis.com/v1/speech:longrunningrecognize';
      final data = {
        'config': {
          "encoding": "LINEAR16",
          "sampleRateHertz": 16000,
          "languageCode": "en-US",
          "enableAutomaticPunctuation": true,
          "model": "default",
          "useEnhanced": true,
          "audioChannelCount": 1,
          "enableWordTimeOffsets": true,
          "enableSpokenPunctuation": true,
          "enableSpokenEmojis": true,
        },
        'audio': {'uri': gcsUri},
      };

      Logger().i(
        'Starting long-running recognition with config: ${json.encode(data)}',
      );

      final response = await _dio.post(
        url,
        data: data,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to start long-running recognition: ${response.data}',
        );
      }

      final operationName = response.data['name'];
      Logger().i('Operation name: $operationName');

      // Poll for results
      return await _pollForResults(operationName, token);
    } on DioException catch (e) {
      Logger().w('Error in _transcribeLongAudio: ${e.response?.data}');
      throw Exception(
        'Failed to transcribe audio: ${e.response?.data['error']['message'] ?? 'Unknown error'}',
      );
    } catch (e) {
      Logger().e('Error in _transcribeLongAudio: $e');
      rethrow;
    } finally {
      if (gcsPath != null) {
        await _deleteFromGCS(bucketName, gcsPath);
      }
    }
  }

  Future<String?> _pollForResults(String operationName, String token) async {
    final url = 'https://speech.googleapis.com/v1/operations/$operationName';
    int attempts = 0;
    const maxAttempts = 300; // 5 minutes maximum wait time

    while (attempts < maxAttempts) {
      attempts++;
      Logger().i('Polling attempt $attempts for results...');

      final response = await _dio.get(
        url,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to get operation status: ${response.data['error']['message'] ?? 'Unknown error'}',
        );
      }

      if (response.data['done'] == true) {
        if (response.data['error'] != null) {
          throw Exception(
            'Operation failed: ${response.data['error']['message']}',
          );
        }

        Logger().i(
          'Raw transcription results: ${response.data['response']['results']}',
        );
        final results = response.data['response']['results'] as List;
        if (results.isEmpty) {
          throw Exception('No transcription results found');
        }

        // Sort results by start time to ensure correct order
        results.sort((a, b) {
          final aStartTime = a['alternatives'][0]['words'][0]['startTime'];
          final bStartTime = b['alternatives'][0]['words'][0]['startTime'];
          return aStartTime.compareTo(bStartTime);
        });

        // Combine all results into a single transcript
        final transcript =
            results
                .map((result) {
                  final alternatives = result['alternatives'] as List;
                  if (alternatives.isEmpty) return '';
                  final transcript = alternatives[0]['transcript'] as String;
                  Logger().i('Segment transcript: $transcript');
                  return transcript;
                })
                .join(' ')
                .trim();

        Logger().i('Final combined transcript: $transcript');
        return transcript;
      }

      // Wait before polling again
      await Future.delayed(const Duration(seconds: 1));
    }

    throw Exception('Transcription timed out after $maxAttempts attempts');
  }

  Future<String> _uploadToGCS(
    File file,
    String bucketName,
    String projectId,
  ) async {
    final client = await getAuthClient();
    final token = (await client.credentials.accessToken).data;
    client.close();

    try {
      final fileName = 'audio_${DateTime.now().millisecondsSinceEpoch}.wav';
      final url =
          'https://storage.googleapis.com/upload/storage/v1/b/$bucketName/o?uploadType=media&name=$fileName';

      final fileBytes = await file.readAsBytes();

      Logger().i('Uploading to GCS: $fileName');
      final response = await _dio.post(
        url,
        data: fileBytes,
        options: Options(
          headers: {
            'Content-Type': 'audio/wav',
            'Content-Length': fileBytes.length.toString(),
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to upload: ${response.data}');
      }

      return fileName;
    } on DioException catch (e) {
      Logger().w('Error in _uploadToGCS: ${e.response?.data}');
      throw Exception(
        'Failed to upload file to GCS: ${e.response?.data['error']['message'] ?? 'Unknown error'}',
      );
    } catch (e) {
      Logger().e('Error in _uploadToGCS: $e');
      rethrow;
    }
  }

  Future<void> _deleteFromGCS(String bucketName, String fileName) async {
    final client = await getAuthClient();
    final token = (await client.credentials.accessToken).data;
    client.close();

    try {
      final url =
          'https://storage.googleapis.com/storage/v1/b/$bucketName/o/$fileName';

      final response = await _dio.delete(
        url,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode != 204) {
        logger.w(
          'Failed to delete file from GCS: ${response.data['error']['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      logger.w('Failed to delete file from GCS: $e');
    }
  }

  Future<AutoRefreshingAuthClient> getAuthClient() async {
    try {
      // Load the credentials file from assets
      final jsonString = await rootBundle.loadString(
        'assets/valid-meridian-393116-81d642dd96c3.json',
      );
      final jsonKey = json.decode(jsonString);
      final accountCredentials = ServiceAccountCredentials.fromJson(jsonKey);
      const scopes = ['https://www.googleapis.com/auth/cloud-platform'];
      final client = await clientViaServiceAccount(accountCredentials, scopes);
      return client;
    } catch (e) {
      logger.e('Error getting auth client: $e');
      rethrow;
    }
  }
}
