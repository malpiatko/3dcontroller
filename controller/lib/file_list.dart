// add dependancy in pubspec.yaml

import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

class FileList extends StatefulWidget {
  const FileList({super.key});
  @override
  _FileListState createState() => _FileListState();
}

class _FileListState extends State<FileList> {
  var files = [];

  void _listofFiles() async {
    var directory = (await getApplicationDocumentsDirectory()).path;
    setState(() {
      files = io.Directory(directory)
          .listSync(); //use your folder name insted of resume.
    });
  }

  @override
  void initState() {
    super.initState();
    _listofFiles();
    // Make New Function
  }

  // Build Part
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
          itemCount: files.length,
          itemBuilder: (BuildContext context, int index) {
            return Text(basenameWithoutExtension(files[index].path));
          }),
    );
  }
}
