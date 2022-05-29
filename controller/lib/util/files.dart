import 'package:path_provider/path_provider.dart';
import 'dart:io';

Future<String> getFilePath() async {
  Directory appDocumentsDirectory =
      await getApplicationDocumentsDirectory(); // 1
  String appDocumentsPath = appDocumentsDirectory.path; // 2
  String filePath = '$appDocumentsPath/demoTextFile.txt'; // 3
  print(filePath);
  return filePath;
}

void saveFile() async {
  File file = File(await getFilePath()); // 1
  file.writeAsString(
      "This is my demo text that will be saved to : demoTextFile.txt"); // 2
}

void readFile() async {
  File file = File(await getFilePath()); // 1
  String fileContent = await file.readAsString(); // 2

  print('File Content: $fileContent');
}
