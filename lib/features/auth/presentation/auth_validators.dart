final _emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');

String? validateEmail(String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return 'Informe o email.';
  if (!_emailRegex.hasMatch(v)) return 'Email inválido.';
  return null;
}

String? validatePassword(String? value) {
  final v = value ?? '';
  if (v.isEmpty) return 'Informe a senha.';
  if (v.length < 6) return 'A senha deve ter pelo menos 6 caracteres.';
  return null;
}

String? validateConfirmPassword(String? value, String password) {
  final v = value ?? '';
  if (v.isEmpty) return 'Confirme a senha.';
  if (v != password) return 'As senhas não coincidem.';
  return null;
}
