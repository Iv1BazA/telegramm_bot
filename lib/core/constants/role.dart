import 'package:mybot/core/constants/role_enum.dart';
import 'package:mybot/core/services/env_service.dart';

abstract class RoleClass {
  static final Map<int, RoleEnum> userRoles = _loadRoles();

  static Map<int, RoleEnum> _loadRoles() {
    final admins = EnvService.get('ADMINS');
    final superAdmins = EnvService.get('SUPER_ADMINS');

    final adminIds = admins
        .split(',')
        .where((e) => e.trim().isNotEmpty)
        .map(int.parse);
    final superAdminIds = superAdmins
        .split(',')
        .where((e) => e.trim().isNotEmpty)
        .map(int.parse);

    final map = <int, RoleEnum>{};

    for (var id in adminIds) {
      map[id] = RoleEnum.admin;
    }
    for (var id in superAdminIds) {
      map[id] = RoleEnum.superAdmin;
    }

    return map;
  }
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
