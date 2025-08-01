import 'package:cron/cron.dart';
import 'package:mybot/core/services/env_service.dart';
import 'package:mybot/core/services/google_sheets_service.dart';
import 'package:televerse/televerse.dart';

void scheduleDailyReport(Bot bot, GoogleSheetsService sheetsService) {
  final cron = Cron();

  cron.schedule(Schedule.parse('00 21 * * *'), () async {
    // Получаем список ID из .env
    final adminIdsRaw = EnvService.get('ADMINS');
    final superAdminIdsRaw = EnvService.get('SUPER_ADMINS');

    final adminIds = _parseIds(adminIdsRaw);
    final superAdminIds = _parseIds(superAdminIdsRaw);

    // Объединяем и удаляем дубликаты
    final allIds = {...adminIds, ...superAdminIds}.toList();

    for (final id in allIds) {
      try {
        await bot.api.sendMessage(
          ChatID(id),
          '🌇 *Добрый вечер!*\n\n📈 Вот твой отчёт за сегодня по сделкам...\n\n⚠️ Но подожди... *Bytrix* ведь не привязан 😅\n\n🔧 Пожалуйста, настрой Webhook и не забудь передать его разработчику!',
          parseMode: ParseMode.markdown,
        );

        await sheetsService.logSilently(
          userName: 'Bot',
          role: 'Super Admin',
          action: '/report',
        );
      } catch (e) {
        print("❌ Ошибка при отправке пользователю $id: $e");
      }
    }

    print("✅ Ежедневная рассылка завершена.");
  });
}

List<int> _parseIds(String? raw) {
  if (raw == null || raw.trim().isEmpty) return [];
  return raw
      .split(',')
      .map((e) => int.tryParse(e.trim()))
      .whereType<int>()
      .toList();
}
