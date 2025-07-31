import 'package:mybot/core/constants/role.dart';
import 'package:mybot/core/constants/states.dart';
import 'package:mybot/core/services/google_sheets_service.dart';
import 'package:televerse/telegram.dart';
import 'package:televerse/televerse.dart';

void putCommand(Bot bot, GoogleSheetsService sheetsService) {
  bot.command('put', (ctx) async {
    final id = ctx.id;
    print("${ctx.from?.firstName ?? ""} написал: ${ctx.message?.text} ");
    if (!isAdmin(id.id)) {
      await ctx.reply("У вас нет прав.");
      return;
    }

    final sheets = await sheetsService.listSheets();
    final buttons = sheets.map((s) => KeyboardButton(text: s)).toList();

    sessions[id.id] = SessionState();

    await ctx.reply(
      "Выберите лист:",
      replyMarkup: ReplyKeyboardMarkup(
        keyboard: [buttons],
        resizeKeyboard: true,
      ),
    );
  });

  bot.onText((ctx) async {
    final id = ctx.id.id;
    final text = ctx.message?.text ?? '';
    print('User message from id: $id message: $text');
    final session = sessions[id];

    if (session == null) return;

    if (session.selectedSheet == null) {
      session.selectedSheet = text;
      session.fields = await sheetsService.getColumnNames(text);

      if (session.fields == null || session.fields!.isEmpty) {
        ctx.reply("Ошибка: лист не содержит заголовков.");
        sessions.remove(id);
        return;
      }

      ctx.reply(
        "Введите значение для: ${session.fields![0]}",
        replyMarkup: ReplyKeyboardRemove(),
      );

      return;
    }

    final field = session.fields![session.currentFieldIndex];
    session.values[field] = text;
    session.currentFieldIndex++;

    if (session.currentFieldIndex >= session.fields!.length) {
      await sheetsService.appendRow(
        session.selectedSheet!,
        session.fields!.map((f) => session.values[f] ?? '').toList(),
      );
      ctx.reply("✅ Данные успешно добавлены в '${session.selectedSheet}'");
      sessions.remove(id);
    } else {
      final nextField = session.fields![session.currentFieldIndex];
      ctx.reply("Введите значение для: $nextField");
    }
  });
}

final sessions = <int, SessionState>{};

Future<void> handlePut(Context ctx, GoogleSheetsService sheetsService) async {
  final id = ctx.id.id;

  final sheets = await sheetsService.listSheets();
  final buttons = sheets.map((s) => KeyboardButton(text: s)).toList();

  sessions[id] = SessionState();

  await ctx.reply(
    "Выберите лист:",
    replyMarkup: ReplyKeyboardMarkup(keyboard: [buttons], resizeKeyboard: true),
  );
}

// для обработки текстов в main (где бот.onText)
Future<void> handlePutText(
  Context ctx,
  GoogleSheetsService sheetsService,
) async {
  final id = ctx.id.id;
  final text = ctx.message?.text ?? '';
  final session = sessions[id];

  if (session == null) return;

  if (session.selectedSheet == null) {
    session.selectedSheet = text;
    session.fields = await sheetsService.getColumnNames(text);

    if (session.fields == null || session.fields!.isEmpty) {
      await ctx.reply("Ошибка: лист не содержит заголовков.");
      sessions.remove(id);
      return;
    }

    await ctx.reply(
      "Введите значение для: ${session.fields![0]}",
      replyMarkup: ReplyKeyboardRemove(),
    );
    return;
  }

  final field = session.fields![session.currentFieldIndex];
  session.values[field] = text;
  session.currentFieldIndex++;

  if (session.currentFieldIndex >= session.fields!.length) {
    await sheetsService.appendRow(
      session.selectedSheet!,
      session.fields!.map((f) => session.values[f] ?? '').toList(),
    );
    await ctx.reply("✅ Данные успешно добавлены в '${session.selectedSheet}'");
    sessions.remove(id);
  } else {
    final nextField = session.fields![session.currentFieldIndex];
    await ctx.reply("Введите значение для: $nextField");
  }
}
