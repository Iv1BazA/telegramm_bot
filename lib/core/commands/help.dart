import 'package:mybot/core/constants/role.dart';
import 'package:mybot/core/constants/role_enum.dart';
import 'package:televerse/televerse.dart';

void helpCommand(Bot bot) {
  bot.command('help', (ctx) async {
    await handleHelp(ctx);
  });
}

Future<void> handleHelp(Context ctx) async {
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
}
