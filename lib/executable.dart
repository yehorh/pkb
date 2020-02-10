import 'src/commands/FindCommand.dart';
import 'package:args/command_runner.dart';

const configString = 'config';


Future<void> main(List<String> arguments) async {
  final runner = CommandRunner('pkb', 'Personal knowledge base');
  runner.addCommand(FindCommand());
  await runner.run(arguments);
}