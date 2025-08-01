import 'package:mybot/core/constants/role.dart';
import 'package:mybot/core/services/google_sheets_service.dart';
import 'package:televerse/televerse.dart';

void statsCommand(Bot bot, GoogleSheetsService sheetsService) {
  bot.command('stats', (ctx) async {
    await handleStats(ctx, sheetsService);
  });
}

Future<void> handleStats(Context ctx, GoogleSheetsService sheetsService) async {
  final id = ctx.id.id;

  await sheetsService.logSilently(
    userName: ctx.from?.username ?? ctx.from?.firstName ?? 'Unknown',
    role: getNameUserRole(id),
    action: '/stats',
  );

  if (!isSuperAdmin(id)) {
    await ctx.reply(
      "⛔ У вас нет доступа к статистике. \nНужна роль Super Admin.",
    );
    return;
  }

  await ctx.reply("📊 Заглушка для статистики. Здесь будут данные.");
}
