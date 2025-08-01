import 'package:mybot/core/commands/help.dart';
import 'package:mybot/core/commands/history.dart';
import 'package:mybot/core/commands/put.dart';
import 'package:mybot/core/commands/start.dart';
import 'package:mybot/core/commands/stats.dart';
import 'package:mybot/core/constants/config.dart';
import 'package:mybot/core/constants/states.dart';
import 'package:mybot/core/services/env_service.dart';
import 'package:mybot/core/services/google_sheets_service.dart';
import 'package:mybot/core/services/callback_service.dart';
import 'package:televerse/televerse.dart';

late GoogleSheetsService sheetsService;
final sessions = <int, SessionState>{};

void main() async {
  EnvService.load();
  sheetsService = await GoogleSheetsService.create();
  final bot = Bot(AppConfig.botId);

  // /START
  startCommand(bot, sheetsService);

  // /PUT
  putCommand(bot, sheetsService);

  // /HELP
  helpCommand(bot, sheetsService);

  //STATS
  statsCommand(bot, sheetsService);

  //HISTORY
  historyCommand(bot, sheetsService);

  // CALLBACK
  callBackService(bot, sheetsService);

  bot.onMessage((ctx) {
    print("Получено сообщение: ${ctx.message?.text}");
  });

  //для контроля сессии
  bot.onText((ctx) async {
    final id = ctx.id.id;
    if ((ctx.message?.text ?? '').startsWith('/')) return;

    if (sessions.containsKey(id)) {
      await handlePutText(ctx, sheetsService);
    }
  });

  bot.start();
}
