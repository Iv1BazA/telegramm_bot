import 'package:mybot/core/commands/help.dart';
import 'package:mybot/core/commands/put.dart';
import 'package:mybot/core/commands/stats.dart';
import 'package:mybot/core/commands/history.dart';
import 'package:mybot/core/constants/config.dart';
import 'package:mybot/core/constants/role.dart';
import 'package:mybot/core/constants/role_enum.dart';
import 'package:mybot/core/services/google_sheets_service.dart';
import 'package:televerse/telegram.dart';
import 'package:televerse/televerse.dart';

void callBackService(Bot bot, GoogleSheetsService sheetsService) {
  bot.onCallbackQuery((ctx) async {
    final data = ctx.callbackQuery?.data;
    final userId = ctx.callbackQuery?.from.id;

    if (data == null || userId == null) return;

    await ctx.api.answerCallbackQuery(ctx.callbackQuery!.id);

    // 👇 Обработка запросов на админку
    if (data.startsWith("approve_") || data.startsWith("reject_")) {
      if (!isSuperAdmin(userId)) {
        await ctx.reply("⛔ Недостаточно прав.");
        return;
      }

      if (data.startsWith("approve_")) {
        final payload = data.replaceFirst("approve_", "");
        final parts = payload.split("_");

        if (parts.length < 2) {
          await ctx.reply("⚠️ Ошибка: неверный формат callback-данных.");
          return;
        }

        final userIdStr = parts[0];
        final requesterUsername = parts.sublist(1).join("_");

        await _approveUser(userIdStr, requesterUsername, ctx, sheetsService);
      } else if (data.startsWith("reject_")) {
        final payload = data.replaceFirst("reject_", "");
        final parts = payload.split("_");

        if (parts.length < 2) {
          await ctx.reply("⚠️ Ошибка: неверный формат callback-данных.");
          return;
        }

        final userIdStr = parts[0];
        final requesterUsername = parts.sublist(1).join("_");

        await ctx.reply(
          "❌ Заявка от пользователя @$requesterUsername (id: $userIdStr) отклонена.",
        );
      }

      return;
    }

    if (data == RequestsData.put) {
      if (isAdmin(userId)) {
        await handlePut(ctx, sheetsService);
      } else {
        await ctx.reply("⛔ У вас нет доступа.");
      }
    } else if (data == RequestsData.stats) {
      if (isSuperAdmin(userId)) {
        await handleStats(ctx, sheetsService);
      } else {
        await ctx.reply("⛔ Доступ запрещён.");
      }
    } else if (data == RequestsData.help) {
      await handleHelp(ctx, sheetsService);
    } else if (data == RequestsData.getRole) {
      final userId = ctx.from?.id;
      final username = ctx.from?.username ?? 'Без имени';
      final superAdmins = getSuperAdmins();

      if (userId == null) return;

      if (isAdmin(userId)) {
        await ctx.reply("✅ Вы уже Администратор.");
        return;
      }

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
    } else if (data == RequestsData.history) {
      if (isSuperAdmin(userId)) {
        await handleHistory(ctx, sheetsService);
      } else {
        await ctx.reply("⛔ У вас нет доступа к истории.");
      }
    } else {
      await ctx.reply("⚠️ Неизвестное действие.");
    }
  });
}

Future<void> _approveUser(
  String userIdStr,
  String requesterUsername,
  Context ctx,
  GoogleSheetsService sheetsService,
) async {
  final userId = int.tryParse(userIdStr);
  if (userId == null) {
    await ctx.reply("⚠️ Ошибка: некорректный ID.");
    return;
  }

  await sheetsService.inputRoleAdmin(
    role: RoleEnum.admin.label,
    userName: requesterUsername,
    userId: userId,
  );

  await RoleClass.initialize(sheetsService);

  await ctx.reply("✅ Пользователь $userId добавлен в админы.");
  await ctx.api.sendMessage(
    ChatID(userId),
    "🎉 Вам одобрили права администратора! Перезапустите /start для новых возможностей.",
  );
}
