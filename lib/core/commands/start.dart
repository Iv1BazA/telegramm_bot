import 'package:mybot/core/constants/config.dart';
import 'package:mybot/core/constants/role.dart';
import 'package:televerse/telegram.dart';
import 'package:televerse/televerse.dart';

void startCommand(Bot bot) {
  bot.command('start', (ctx) async {
    final userId = ctx.id;
    final isCurrentAdmin = isAdmin(userId.id);
    final userName = ctx.from?.firstName ?? '';

    print("$userName написал: ${ctx.message?.text}");

    await ctx.reply(
      "👋 Привет, уважаемый $userName!\nВыберите действие:",
      replyMarkup: InlineKeyboardMarkup(
        inlineKeyboard: [
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
        ],
      ),
    );
  });
}
