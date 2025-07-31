import 'package:mybot/core/commands/help.dart';
import 'package:mybot/core/commands/put.dart';
import 'package:mybot/core/commands/stats.dart';
import 'package:mybot/core/constants/config.dart';
import 'package:mybot/core/services/google_sheets_service.dart';
import 'package:televerse/televerse.dart';
import 'package:mybot/core/constants/role.dart';

void callBackService(Bot bot, GoogleSheetsService sheetsService) {
  bot.onCallbackQuery((ctx) async {
    final data = ctx.callbackQuery?.data;
    final userId = ctx.callbackQuery?.from.id;

    if (data == null || userId == null) return;

    await ctx.api.answerCallbackQuery(ctx.callbackQuery!.id);

    if (data == RequestsData.put) {
      if (isAdmin(userId)) {
        await handlePut(ctx, sheetsService);
      } else {
        await ctx.reply("⛔ У вас нет доступа.");
      }
    } else if (data == RequestsData.stats) {
      if (isSuperAdmin(userId)) {
        await handleStats(ctx);
      } else {
        await ctx.reply("⛔ Доступ запрещён.");
      }
    } else if (data == RequestsData.help) {
      await handleHelp(ctx);
    } else {
      await ctx.reply("⚠️ Неизвестное действие.");
    }
  });
}
