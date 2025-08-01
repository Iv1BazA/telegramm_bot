import 'package:mybot/core/services/env_service.dart';

abstract class AppConfig {
  static String botId = EnvService.get('BOT_ID');
}

abstract class Requests {
  static String start = '/start';
  static String put = '/put';
  static String help = '/help';
  static String stats = '/stats';
}

abstract class RequestsData {
  static String start = 'start_data';
  static String put = 'put_data';
  static String help = 'help_data';
  static String stats = 'stats_data';
  static String history = 'history_data';
  static String dailyReport = 'daily_report_data';
  static String getRole = 'get_role_data';
}

final Map<String, String> commandAliases = {
  'Начать': '/start',
  '📥 Внести данные': '/put',
  '📊 Статистика': '/stats',
  '❓ Помощь': '/help',
};
