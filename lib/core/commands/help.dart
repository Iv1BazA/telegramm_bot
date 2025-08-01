import 'package:mybot/core/constants/role.dart';
import 'package:mybot/core/constants/role_enum.dart';
import 'package:mybot/core/services/google_sheets_service.dart';
import 'package:televerse/televerse.dart';

void helpCommand(Bot bot, GoogleSheetsService sheetsService) {
  bot.command('help', (ctx) async {
    await handleHelp(ctx, sheetsService);
  });
}

Future<void> handleHelp(Context ctx, GoogleSheetsService sheetsService) async {
  final id = ctx.id.id;
  final role = getUserRole(id);
  final roleName = getNameUserRole(id);

  final buffer = StringBuffer();
  buffer.writeln("🧾 Ваша роль: $roleName");

  if (role == RoleEnum.superAdmin) {
    buffer.writeln("\n✅ У вас полный доступ.");
  } else if (role == RoleEnum.admin) {
    buffer.writeln("\n✅ У вас чуть меньше доступа, чем у разработчика.");
  } else {
    buffer.writeln("\n⛔ У вас нет доступа к административным функциям.");
  }

  await ctx.reply(buffer.toString());

  await sheetsService.logSilently(
    userName: ctx.from?.username ?? ctx.from?.firstName ?? 'Unknown',
    role: roleName,
    action: ctx.message?.text ?? '',
  );
}
