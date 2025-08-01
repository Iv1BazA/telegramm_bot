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
}
