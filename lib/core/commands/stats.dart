import 'package:mybot/core/constants/role.dart';
import 'package:televerse/televerse.dart';

void statsCommand(Bot bot) {
  bot.command('stats', (ctx) async {
    final id = ctx.id.id;

    if (!isSuperAdmin(id)) {
      await ctx.reply("⛔ У вас нет доступа к статистике.");
      return;
    }

    await ctx.reply("📊 Заглушка для статистики. Здесь будут данные.");
  });
}

Future<void> handleStats(Context ctx) async {
  final id = ctx.id.id;

  if (!isSuperAdmin(id)) {
    await ctx.reply(
      "⛔ У вас нет доступа к статистике. \nНужна роль Super Admin",
    );
    return;
  }

  await ctx.reply("📊 Заглушка для статистики. Здесь будут данные.");
}
