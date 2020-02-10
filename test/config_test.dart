import 'package:pkb/src/commands/FindCommand.dart' as t;
import 'package:test/test.dart';
import 'dart:async';
import 'dart:io';

void main() {
  test('Load config', () async {
    var tempDir = Directory.systemTemp.createTempSync();
    var tempFile = File('${tempDir.path}/tempConfig.json');

    var tempConfig = '''
    {
      "directory": "~/Documents"
    }
    ''';

    await tempFile.writeAsString(tempConfig);
    await t.loadConfigFile(tempFile.path);
  });

  test('Load config from env var', () {
    t.loadConfigEnv();
  });
}
