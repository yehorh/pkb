import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;
import 'package:console/console.dart';
import 'dart:io';

import '../utils/ExtendedIterable.dart';

const interactiveString = 'interactive';
const regexpString = 'regexp';
const directoryString = 'directory';

class FindCommand extends Command {
  FindCommand() {
    argParser.addOption(directoryString, abbr: 'd');
    argParser.addFlag(interactiveString, abbr: 'i');
    argParser.addOption(regexpString, abbr: 'e');
  }

  @override
  String get description => 'Find info';

  @override
  String get name => 'find';

  @override
  void run() async {
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
    }
    ;

    print(argResults[directoryString]);
  }
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
