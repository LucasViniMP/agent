import 'models.dart';

class StaffLogin {
  final AppRole role;
  final String name;
  final String email;
  final String password;

  const StaffLogin({
    required this.role,
    required this.name,
    required this.email,
    required this.password,
  });
}

const staffLogins = [
  StaffLogin(
    role: AppRole.waiter,
    name: 'Lucas Vinicius',
    email: 'lucasmesmestre@gmail.com',
    password: '123456',
  ),
  StaffLogin(
    role: AppRole.counter,
    name: 'Gabriel Silva Pereira',
    email: 'gabrielmesamestre@gmail.com',
    password: '123456',
  ),
  StaffLogin(
    role: AppRole.kitchen,
    name: 'Felipe Deivid',
    email: 'felipemesamestre@gmail.com',
    password: '123456',
  ),
];

StaffLogin? staffLoginForRole(AppRole? role) {
  if (role == null) return null;

  for (final login in staffLogins) {
    if (login.role == role) return login;
  }

  return null;
}

StaffLogin? staffLoginForEmail(String email) {
  final normalizedEmail = email.trim().toLowerCase();

  for (final login in staffLogins) {
    if (login.email.toLowerCase() == normalizedEmail) return login;
  }

  return null;
}
