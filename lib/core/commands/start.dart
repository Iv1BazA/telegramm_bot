import 'package:mybot/core/constants/config.dart';
import 'package:mybot/core/constants/role.dart';
import 'package:mybot/core/services/google_sheets_service.dart';
import 'package:televerse/telegram.dart';
import 'package:televerse/televerse.dart';

void startCommand(Bot bot, GoogleSheetsService sheetsService) {
  bot.command('start', (ctx) async {
    final userId = ctx.id;
    final userIntId = userId.id;
    final isCurrentAdmin = isAdmin(userIntId);
    final isCurrentSuperAdmin = isSuperAdmin(userIntId);
    final userName = ctx.from?.firstName ?? '';

    List<List<InlineKeyboardButton>> keyboard = [];

    if (isCurrentAdmin || isCurrentSuperAdmin) {
      // Полный доступ
      keyboard = [
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
        [
          InlineKeyboardButton(
            text: '❓ Помощь',
            callbackData: RequestsData.help,
          ),
        ],
      ];

      if (isCurrentSuperAdmin) {
        keyboard.add([
          InlineKeyboardButton(
            text: '📜 История',
            callbackData: RequestsData.history,
          ),
        ]);
      }
    } else {
      keyboard = [
        [
          InlineKeyboardButton(
            text: '📩 Запросить роль администратора',
            callbackData: RequestsData.getRole,
          ),
        ],
        [
          InlineKeyboardButton(
            text: '❓ Помощь',
            callbackData: RequestsData.help,
          ),
        ],
      ];
    }

    await ctx.reply(
      "👋 Привет, $userName!\nВыберите действие:",
      replyMarkup: InlineKeyboardMarkup(inlineKeyboard: keyboard),
    );

    await sheetsService.logSilently(
      userName: ctx.from?.username ?? 'Unknown',
      role: getNameUserRole(userIntId),
      action: ctx.message?.text ?? '',
    );
  });
}
