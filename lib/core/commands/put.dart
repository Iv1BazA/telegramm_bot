import 'package:mybot/core/constants/role.dart';
import 'package:mybot/core/constants/states.dart';
import 'package:mybot/core/services/google_sheets_service.dart';
import 'package:televerse/telegram.dart';
import 'package:televerse/televerse.dart';

final sessions = <int, SessionState>{};

void putCommand(Bot bot, GoogleSheetsService sheetsService) {
  bot.command('put', (ctx) async {
    final id = ctx.id.id;

    if (!isAdmin(id)) {
      await ctx.reply("🚫 У вас нет прав.");
      return;
    }

    await handlePut(ctx, sheetsService);
  });

  bot.onText((ctx) async {
    final id = ctx.id.id;
    if (sessions.containsKey(id)) {
      await handlePutText(ctx, sheetsService);
    }
  });
}

// Выбор листа
Future<void> handlePut(Context ctx, GoogleSheetsService sheetsService) async {
  final id = ctx.id.id;

  final sheets = await sheetsService.listSheets();
  final buttons = sheets.map((s) => KeyboardButton(text: s)).toList();

  sessions[id] = SessionState();

  await sheetsService.logSilently(
    userName: ctx.from?.username ?? ctx.from?.firstName ?? 'Unknown',
    role: getNameUserRole(id),
    action: ctx.message?.text ?? '',
  );

  await ctx.reply(
    "📄 Выберите лист:",
    replyMarkup: ReplyKeyboardMarkup(keyboard: [buttons], resizeKeyboard: true),
  );
}

Future<void> handlePutText(
  Context ctx,
  GoogleSheetsService sheetsService,
) async {
  final id = ctx.id.id;
  final text = ctx.message?.text ?? '';
  final session = sessions[id];

  // ⛔️ Обработка отмены
  if (text == '❌ Отмена') {
    sessions.remove(id);
    await ctx.reply("❌ Ввод отменён.", replyMarkup: ReplyKeyboardRemove());
    return;
  }

  // ⛔️ Если сессии нет — игнор
  if (session == null) return;

  await sheetsService.logSilently(
    userName: ctx.from?.username ?? ctx.from?.firstName ?? 'Unknown',
    role: getNameUserRole(id),
    action: text,
  );

  // 📄 Этап выбора листа
  if (session.selectedSheet == null) {
    session.selectedSheet = text;
    session.fields = await sheetsService.getColumnNames(text);

    if (session.fields == null || session.fields!.isEmpty) {
      await ctx.reply("⚠️ Ошибка: лист не содержит заголовков.");
      sessions.remove(id);
      return;
    }

    await ctx.reply(
      "✏️ Введите значение для: ${session.fields![0]}",
      replyMarkup: ReplyKeyboardMarkup(
        keyboard: [
          [KeyboardButton(text: '❌ Отмена')],
        ],
        resizeKeyboard: true,
      ),
    );
    return;
  }

  // ✍️ Ввод значений
  final field = session.fields![session.currentFieldIndex];
  session.values[field] = text;
  session.currentFieldIndex++;

  // ✅ Финальный шаг
  if (session.currentFieldIndex >= session.fields!.length) {
    await sheetsService.appendRow(
      session.selectedSheet!,
      session.fields!.map((f) => session.values[f] ?? '').toList(),
    );

    await ctx.reply("✅ Данные успешно добавлены в '${session.selectedSheet}'");

    await sheetsService.logSilently(
      userName: ctx.from?.username ?? ctx.from?.firstName ?? 'Unknown',
      role: getNameUserRole(id),
      action: "Добавил данные в лист ${session.selectedSheet}",
    );

    sessions.remove(id);
  } else {
    final nextField = session.fields![session.currentFieldIndex];
    await ctx.reply(
      "✏️ Введите значение для: $nextField",
      replyMarkup: ReplyKeyboardMarkup(
        keyboard: [
          [KeyboardButton(text: '❌ Отмена')],
        ],
        resizeKeyboard: true,
      ),
    );
  }
}
