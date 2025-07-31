import 'package:mybot/core/commands/help.dart';
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
  startCommand(bot);

  // /PUT
  putCommand(bot, sheetsService);

  // /HELP
  helpCommand(bot);

  //STATS
  statsCommand(bot);

  // CALLBACK
  callBackService(bot, sheetsService);

  //для контроля сессии
  bot.onText((ctx) async {
    final id = ctx.id.id;

    if (sessions.containsKey(id)) {
      await handlePutText(ctx, sheetsService);
    }
  });

  bot.start();
}
