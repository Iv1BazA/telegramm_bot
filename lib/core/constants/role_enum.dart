enum RoleEnum {
  superAdmin(label: 'Super Admin'),
  admin(label: 'Admin'),
  user(label: 'User');

  final String label;

  const RoleEnum({required this.label});
}
