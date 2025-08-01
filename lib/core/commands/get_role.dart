import 'package:mybot/core/constants/role.dart';
import 'package:mybot/core/services/google_sheets_service.dart';
import 'package:televerse/telegram.dart';
import 'package:televerse/televerse.dart';

void getRoleCommand(Bot bot, GoogleSheetsService sheetsService) {
  bot.command("getrole", (ctx) async {
    final userId = ctx.id.id;

    // уже админ? не надо
    if (isAdmin(userId)) {
      await ctx.reply("✅ Вы уже Администратор.");
      return;
    }

    final username = ctx.from?.username ?? 'Без имени';
    final superAdmins = getSuperAdmins();

    for (final adminId in superAdmins) {
      await bot.api.sendMessage(
        ChatID(adminId),
        "🛎️ Пользователь @$username (id: $userId) запрашивает права администратора.",
        replyMarkup: InlineKeyboardMarkup(
          inlineKeyboard: [
            [
              InlineKeyboardButton(
                text: "✅ Одобрить",
                callbackData: "approve_${userId}_$username",
              ),
              InlineKeyboardButton(
                text: "❌ Отклонить",
                callbackData: "reject_${userId}_$username",
              ),
            ],
          ],
        ),
      );
    }

    await ctx.reply(
      "🔔 Заявка на права администратора отправлена суперадмину.",
    );
    await sheetsService.logSilently(
      userName: ctx.from?.username ?? 'Unknown',
      role: getNameUserRole(userId),
      action: ctx.message?.text ?? '',
    );
  });
}
