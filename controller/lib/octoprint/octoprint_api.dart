import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class OctoprintAPI {
  void command(String command) async {
    sendRequest('api/printer/command', <String, dynamic>{
      'command': command,
    });
  }

  void commands(List commands) async {
    sendRequest('api/printer/command', <String, dynamic>{
      'commands': commands,
    });
  }

  void changeFeedRate(double rate) async {
    sendRequest('/api/printer/printhead',
        <String, dynamic>{"command": "feedrate", "factor": rate});
  }

  void changeFlowRate(double rate) async {
    sendRequest('/api/printer/tool',
        <String, dynamic>{"command": "flowrate", "factor": rate});
  }

  List<String> jogExtrudeCommand(double x, double y, double z, double e) {
    var cmds = ['G91', 'G1 X$x Y$y Z$z E$e F1000'];
    commands(cmds);
    return cmds;
  }

  List<String> jogCommand(double x, double y, double z) {
    var cmds = ['G91', 'G0 X$x Y$y Z$z'];
    commands(cmds);
    return cmds;
  }

  void jobCommand(String command) async {
    sendRequest('api/job', <String, String>{
      'command': command,
      // for pause and restart
      'action': 'toggle',
    });
  }

  void sendRequest(String url, Map<String, dynamic> body) async {
    final response =
        await http.post(Uri.parse('http://raspberrypi.local:5000/' + url),
            // Send authorization headers to the backend.
            headers: <String, String>{
              HttpHeaders.authorizationHeader:
                  'Bearer B4C94C14478D4C718D184847677DA64F',
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(body));

    print(response.statusCode);
    if (response.statusCode != 204) {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to issue command');
    }
  }
}
