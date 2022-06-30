import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'package:scidart/numdart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io' as io;

import '../octoprint/octoprint_api.dart';
import '../util/files.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '3D Controller',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: '3D Controller'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double step = 5.0;
  bool extrudeToggle = false;
  bool recordToggle = false;
  List<String> sentRequests = [];
  double flowRate = 1;
  double feedRate = 1;
  String filename = '';
  String fileToRun = '';
  var files = [];

  static const _gap = SizedBox(width: 10);

  void _extrude(bool value) {
    setState(() {
      extrudeToggle = value;
    });
  }

  void _record(bool value) {
    setState(() {
      recordToggle = value;
    });
  }

  void moveVertically(double z) {
    var sentCommands = OctoprintAPI().jogCommand(0, 0, -step * z);
    if (recordToggle) {
      setState(() {
        sentRequests.addAll(sentCommands);
      });
    }
  }

  void moveHorizontally(double x, double y) {
    List<String> sentCommands;
    if (extrudeToggle) {
      sentCommands = OctoprintAPI().jogExtrudeCommand(
          step * x, -step * y, 0, hypotenuse(x * step, y * step));
    } else {
      sentCommands = OctoprintAPI().jogCommand(step * x, -step * y, 0);
    }

    if (recordToggle) {
      setState(() {
        sentRequests.addAll(sentCommands);
      });
    }
  }

  void _repeatSavedMovements() async {
    var file = await readFile('$fileToRun.txt');
    print(file);
    OctoprintAPI().commands(file.split(', '));
    setState(() {
      sentRequests = [];
      extrudeToggle = false;
    });
  }

  void _saveMovements() {
    print(filename);
    String movements = sentRequests.join(', ');
    saveToFile('$filename.txt', movements);
    setState(() {
      filename = '';
      sentRequests = [];
    });
  }

  void _changeFeedRate(double value) {
    setState(() {
      feedRate = value;
    });
    OctoprintAPI().changeFeedRate(value);
  }

  void _changeFlowRate(double value) {
    setState(() {
      flowRate = value;
    });
    OctoprintAPI().changeFlowRate(value);
  }

  void _getFile(String filename) {
    readFile(filename);
  }

  void _clearMovements() {
    setState(() {
      sentRequests = [];
      extrudeToggle = false;
    });
  }

  void _jobCommand(String command) {
    OctoprintAPI().jobCommand(command);
  }

  void _listofFiles() async {
    var directory = (await getApplicationDocumentsDirectory()).path;
    setState(() {
      files = io.Directory(directory)
          .listSync(); //use your folder name insted of resume.
    });
  }

  @override
  Widget build(BuildContext context) {
    _listofFiles();
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: CustomScrollView(
        primary: false,
        physics: const NeverScrollableScrollPhysics(),
        slivers: <Widget>[
          SliverPadding(
            padding: const EdgeInsets.all(10),
            sliver: SliverGrid.count(
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              crossAxisCount: 3,
              children: <Widget>[
                Container(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        Row(
                          //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Text('Extrude'),
                            _gap,
                            Switch(
                                value: extrudeToggle,
                                activeColor: Color(0xFF6200EE),
                                onChanged: (bool value) {
                                  _extrude(value);
                                }),
                          ],
                        ),
                        Text('Flow rate:$flowRate'),
                        Slider(
                          min: 0.75,
                          max: 1.25,
                          value: flowRate,
                          onChanged: (value) {},
                          onChangeEnd: (value) {
                            _changeFlowRate(value);
                            setState(() {
                              flowRate = value;
                            });
                          },
                        ),
                        Text('Feed rate:$feedRate'),
                        Slider(
                          min: 0.5,
                          max: 2,
                          value: feedRate,
                          onChanged: (value) {},
                          onChangeEnd: (value) {
                            _changeFeedRate(value);
                          },
                        )
                      ],
                    )),
                Column(children: [
                  Row(
                    //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Text('Record movement'),
                      _gap,
                      Switch(
                          value: recordToggle,
                          activeColor: Color(0xFF6200EE),
                          onChanged: (bool value) {
                            _record(value);
                          }),
                    ],
                  ),
                  Row(children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'File to run',
                        ),
                        onChanged: (text) {
                          setState(() {
                            fileToRun = text;
                          });
                          ;
                        },
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _repeatSavedMovements();
                        // Respond to button press
                      },
                      child: const Text('Repeat movements'),
                    ),
                  ]),
                  ElevatedButton(
                    onPressed: () {
                      _clearMovements();
                      // Respond to button press
                    },
                    child: const Text('Clear movements'),
                  ),
                  ElevatedButton(
                    child: Text("Save Movements"),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              scrollable: true,
                              content: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Form(
                                  child: Column(
                                    children: <Widget>[
                                      TextFormField(
                                        decoration: InputDecoration(
                                          labelText: 'File name',
                                        ),
                                        onChanged: (text) {
                                          setState(() {
                                            filename = text;
                                          });
                                          ;
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              actions: [
                                ElevatedButton(
                                    child: Text("Save"),
                                    onPressed: () {
                                      _saveMovements();
                                    })
                              ],
                            );
                          });
                    },
                  ),
                  const Text('Saved files'),
                  Expanded(
                    child: ListView.builder(
                        itemCount: files.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Text(
                              basenameWithoutExtension(files[index].path));
                        }),
                  ),
                  /*ElevatedButton(
                    onPressed: () {
                      _getFile();
                      // Respond to button press
                    },
                    child: const Text('Read file'),
                  ),*/
                ]),
                Column(children: [
                  ElevatedButton(
                    onPressed: () {
                      _jobCommand('start');
                    },
                    child: const Text('Start'),
                  ),
                  _gap,
                  ElevatedButton(
                    onPressed: () {
                      _jobCommand('pause');
                    },
                    child: const Text('Pause'),
                  ),
                  _gap,
                  ElevatedButton(
                    onPressed: () {
                      _jobCommand('pause');
                    },
                    child: const Text('Restart'),
                  ),
                ]),
                Container(
                  child: Text(sentRequests.join(', ')),
                ),
                Joystick(
                  mode: JoystickMode.all,
                  period: const Duration(milliseconds: 100),
                  listener: (details) {
                    moveHorizontally(details.x, details.y);
                  },
                ),
                Joystick(
                  period: const Duration(milliseconds: 100),
                  mode: JoystickMode.vertical,
                  listener: (details) {
                    moveVertically(details.y);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
