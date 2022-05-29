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

void saveFile(String filename) async {
  File file = File(await getFilePath(filename)); // 1
  file.writeAsString(
      "This is my demo text that will be saved to : demoTextFile.txt"); // 2
}

void readFile(String filename) async {
  File file = File(await getFilePath(filename)); // 1
  String fileContent = await file.readAsString(); // 2

  print('File Content: $fileContent');
}
