import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;
import 'package:console/console.dart';
import 'dart:io';
import 'dart:convert';

import '../utils/ExtendedIterable.dart';

const interactiveString = 'interactive';
const regexpString = 'regexp';
const directoryString = 'directory';
const configString = 'config';

class FindCommand extends Command {
  FindCommand() {
    argParser.addOption(directoryString, abbr: 'd');
    argParser.addFlag(interactiveString, abbr: 'i');
    argParser.addOption(regexpString, abbr: 'e');
    argParser.addOption(configString, abbr: 'c');
  }

  @override
  String get description => 'Find info';

  @override
  String get name => 'find';

  @override
  void run() async {

//    LOAD CONFIG
//
//  https://stackoverflow.com/questions/11077223/what-order-of-reading-configuration-values
//    Command line.
//    Config file that's name is declared on the command line.
//    Environment vars
//    Local config file (if exists)
//    Global config file (if exists)

    Config config = Config();

    String configArg = argResults[configString];

    String configPath;
    if (configArg != null) {
      configPath = p.normalize(p.absolute(configArg));
    } else {
      configPath = getUserConfigFilePath();
    };

    var configEnv = loadConfigEnv();

    var config2 = await loadConfigFile(configPath);

//    OVERWRITE SEARCH DIRECTORY
    String pathArg = argResults[directoryString];
    if (pathArg == null) {
      pathArg = Directory.current.path;
    }
    String directoryPath = p.normalize(p.absolute(pathArg));

    var output = <Output>[];

    var isDir = await FileSystemEntity.isDirectory(directoryPath);

    if (isDir) {
      var list = Directory(directoryPath).listSync(recursive: true);
      for (var item in list) {
        RegExp exp = RegExp('${argResults["regexp"]}');
        if (item is File) {
          var list = item.readAsLinesSync();
          list.forEachIndex((element, index) {
            if (element.contains(exp)) {
              var output2 = Output(item, list[index]);
              output.add(output2);
            }
          });
        }
      }
      bool interactive = argResults[interactiveString];
      if (interactive) {
        Console.init();
        var items =
            output.map((item) => '${item.file.path}').toList();

        var chooser = Chooser<String>(items,
            message: "select string to open in editor: ");
        var choose = chooser.chooseSync();
        var argumentForApp = ["--goto", choose];
        await Process.start("code", argumentForApp);
        print(choose);
      } else {
        output.forEach((o) {
          print(o.file);
          print('${o.file.path}:${o.string}');
        });
      }
    } else {
      print('$directoryPath is not a directory');
    };

    print(argResults[directoryString]);
  }
}

class Config {
  String directory = "";
}

loadConfigEnv() {
  Map<String, String> envVars = Platform.environment;
  var directory = envVars['DIRECTORY'];
  print(directory);
}

String getUserConfigFilePath() {
  String os = Platform.operatingSystem;
  String home = "";
  Map<String, String> envVars = Platform.environment;
  if (Platform.isMacOS) {
    home = envVars['HOME'];
  } else if (Platform.isLinux) {
    home = envVars['HOME'];
  } else if (Platform.isWindows) {
    home = envVars['UserProfile'];
  }

  return '$home/.config/pkb/config.json';
}

void loadConfigFile(String configPath) async {
  var result;
  var isFile = await FileSystemEntity.isFile(configPath);
  if (isFile) {
    var file = File(configPath);
    var content = await file.readAsString();
    result = json.decode(content);
  }

  return result;
}

class Output {
  File file;
  String string;

  Output(this.file, this.string);

  @override
  String toString() {
    return file.toString();
  }
}
