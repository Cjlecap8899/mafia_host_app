import 'dart:io';

final _ru = RegExp(r'[А-Яа-яЁё]');

void main() {
  final dir = Directory('lib');
  if (!dir.existsSync()) {
    stderr.writeln('No lib/ directory found');
    exit(1);
  }

  final files = dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .where((f) => !f.path.replaceAll('\\', '/').endsWith('/i18n.dart'));

  var count = 0;

  for (final f in files) {
    final lines = f.readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (_ru.hasMatch(line)) {
        // отсечем комментарии, чтобы не шумело
        final trimmed = line.trimLeft();
        if (trimmed.startsWith('//')) continue;

        count++;
        stdout.writeln('${f.path}:${i + 1}: $line');
      }
    }
  }

  stdout.writeln('\nFound $count lines with Cyrillic (excluding i18n.dart).');
}
