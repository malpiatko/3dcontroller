import 'package:path_provider/path_provider.dart';
import 'dart:io';

Future<String> getFilePath(String filename) async {
  Directory appDocumentsDirectory =
      await getApplicationDocumentsDirectory(); // 1
  String appDocumentsPath = appDocumentsDirectory.path; // 2
  String filePath = '$appDocumentsPath/$filename'; // 3
  print(filePath);
  return filePath;
}

void saveToFile(String filename, String content) async {
  File file = File(await getFilePath(filename)); // 1
  file.writeAsString(content); // 2
}

Future<String> readFile(String filename) async {
  File file = File(await getFilePath(filename)); // 1
  String fileContent = await file.readAsString(); // 2
  print('File Content: $fileContent');
  return fileContent;
}
