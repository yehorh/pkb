import 'dart:io';

Future<void> main(List<String> arguments) async {
  var argumentForApp = ["--goto", "/home/yehorh/Documents/notes/skd.md:2"];
  await Process.start("code", argumentForApp);
}