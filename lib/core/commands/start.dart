import 'package:mybot/core/constants/config.dart';
import 'package:mybot/core/constants/role.dart';
import 'package:mybot/core/services/google_sheets_service.dart';
import 'package:televerse/telegram.dart';
import 'package:televerse/televerse.dart';

void startCommand(Bot bot, GoogleSheetsService sheetsService) {
  bot.command('start', (ctx) async {
    final userId = ctx.id;
    final isCurrentAdmin = isAdmin(userId.id);
    final isCurrentSuperAdmin = isSuperAdmin(userId.id);
    final userName = ctx.from?.firstName ?? '';

    print("$userName написал: ${ctx.message?.text}");

    // Базовые кнопки
    final keyboard = [
      [
        InlineKeyboardButton(
          text: '📥 Внести данные',
          callbackData: RequestsData.put,
        ),
      ],
      [
        InlineKeyboardButton(
          text: '📊 Статистика',
          callbackData: RequestsData.stats,
        ),
      ],
      [InlineKeyboardButton(text: '❓ Помощь', callbackData: RequestsData.help)],
    ];

    // Добавим кнопку Истории, если суперадмин
    if (isCurrentSuperAdmin) {
      keyboard.add([
        InlineKeyboardButton(
          text: '📜 История',
          callbackData: RequestsData.history,
        ),
      ]);
    }

    await ctx.reply(
      "👋 Привет, уважаемый $userName!\nВыберите действие:",
      replyMarkup: InlineKeyboardMarkup(inlineKeyboard: keyboard),
    );

    await sheetsService.logSilently(
      userName: ctx.from?.username ?? 'Unknown',
      role: getNameUserRole(userId.id),
      action: ctx.message?.text ?? '',
    );
  });
}
