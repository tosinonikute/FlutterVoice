import 'dart:io';
import 'dart:convert';
class FileToBase64 {
 
Future<String> convertToBase64(String filePath) async {
  final bytes = await File(filePath).readAsBytes();
  return base64Encode(bytes);
}
}
