import 'package:mybot/core/constants/role.dart';
import 'package:mybot/core/services/google_sheets_service.dart';
import 'package:televerse/televerse.dart';

void historyCommand(Bot bot, GoogleSheetsService sheetsService) {
  print('сработало');
  bot.command('history', (ctx) async {
    final id = ctx.id.id;
    print(id);
    if (!isSuperAdmin(id)) {
      await ctx.reply("❌ Нет доступа к логам.");
      return;
    }

    await ctx.reply("🔄 Загружаю логи за сегодня...");

    try {
      final logs = await sheetsService.getTodayLogs();

      if (logs.isEmpty) {
        await ctx.reply("Сегодня ещё не было действий.");
        return;
      }

      final messages = logs
          .map((log) {
            final name = log[0];
            final role = log[1];
            final action = log[2];
            final date = log[3];
            final time = log.length > 4 ? log[4] : '';
            return "👤 *$name* [$role]\n📌 $action\n🕒 $date $time";
          })
          .join("\n\n");

      await ctx.reply(
        "📝 *Логи за сегодня:*\n\n$messages",
        parseMode: ParseMode.markdown,
      );
    } catch (e) {
      await ctx.reply("⚠️ Ошибка при получении логов: $e");
    }

    await sheetsService.logSilently(
      userName: ctx.from?.username ?? 'Unknown',
      role: getNameUserRole(id),
      action: '/history',
    );
  });
}

Future<void> handleHistory(
  Context ctx,
  GoogleSheetsService sheetsService,
) async {
  final id = ctx.id.id;

  if (!isSuperAdmin(id)) {
    await ctx.reply("❌ У вас нет доступа к истории.");
    return;
  }

  await ctx.reply("🔄 Загружаю логи за сегодня...");

  try {
    final logs = await sheetsService.getTodayLogs();

    if (logs.isEmpty) {
      await ctx.reply("Сегодня ещё не было действий.");
      return;
    }

    final messages = logs
        .map((log) {
          final name = log[0];
          final role = log[1];
          final action = log[2];
          final date = log[3];
          final time = log.length > 4 ? log[4] : '';
          return "👤 *$name* [$role]\n📌 $action\n🕒 $date $time";
        })
        .join("\n\n");

    await ctx.reply(
      "📝 *Логи за сегодня:*\n\n$messages",
      parseMode: ParseMode.markdown,
    );
  } catch (e) {
    await ctx.reply("⚠️ Ошибка при получении логов: $e");
  }

  await sheetsService.logSilently(
    userName: ctx.from?.username ?? 'Unknown',
    role: getNameUserRole(id),
    action: 'Просмотр истории через кнопку',
  );
}
