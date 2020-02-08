import 'package:pkb/executable.dart' as executable;
import 'package:test/test.dart';

void main() {
  test('Find function', () {
    executable.main(["find", "--directory", "~/Documents/note", "-e", "1c"]);
  });
}
