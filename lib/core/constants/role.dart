import 'package:mybot/core/constants/role_enum.dart';
import 'package:mybot/core/services/google_sheets_service.dart';

abstract class RoleClass {
  static Map<int, RoleEnum> userRoles = {};

  static Future<void> initialize(GoogleSheetsService service) async {
    userRoles = await service.loadRolesFromSheet();
  }
}

List<int> getSuperAdmins() {
  return RoleClass.userRoles.entries
      .where((entry) => entry.value == RoleEnum.superAdmin)
      .map((entry) => entry.key)
      .toList();
}

bool isAdmin(int userId) {
  final role = getUserRole(userId);
  return role == RoleEnum.admin || role == RoleEnum.superAdmin;
}

bool isSuperAdmin(int userId) {
  return getUserRole(userId) == RoleEnum.superAdmin;
}

RoleEnum getUserRole(int userId) {
  return RoleClass.userRoles[userId] ?? RoleEnum.user;
}

String getNameUserRole(int userId) {
  final role = getUserRole(userId);
  return role.label;
}
