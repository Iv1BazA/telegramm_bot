import 'dart:io';

import 'package:dotenv/dotenv.dart';

class EnvService {
  static final DotEnv _env = DotEnv(includePlatformEnvironment: true);

  static void load() {
    _env.load();
  }

  static String get(String key) {
    final value = _env[key];

    if (value == null) {
      throw Exception("Environment variable '$key' is not set.");
    }
    return value;
  }

  static bool appendIdTo(String key, int id) {
    final file = File('.env');
    if (!file.existsSync()) return false;

    final lines = file.readAsLinesSync();
    final index = lines.indexWhere((line) => line.startsWith("$key="));
    if (index == -1) return false;

    final current = lines[index].substring(key.length + 1);
    final ids = current.split(',').map((e) => e.trim()).toSet();
    ids.add(id.toString());

    lines[index] = "$key=${ids.join(',')}";
    file.writeAsStringSync(lines.join('\n'));

    return true;
  }
}
