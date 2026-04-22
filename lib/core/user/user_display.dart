import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';

/// Nome apresentável: [User.displayName] ou parte local do email, etc.
String? userDisplayLabel(User? u) {
  if (u == null) return null;
  final n = u.displayName?.trim();
  if (n != null && n.isNotEmpty) return n;
  final e = u.email;
  if (e != null && e.isNotEmpty) {
    return e.split('@').first;
  }
  if (u.uid.isNotEmpty) return u.uid;
  return null;
}

String _firstCharUpper(String s) {
  if (s.isEmpty) return '';
  return s[0].toUpperCase();
}

/// Iniciais para avatar (2 letras ou 1) a partir de nome, email ou uid.
String userInitials(User? u) {
  if (u == null) return '?';
  final name = u.displayName?.trim();
  if (name != null && name.isNotEmpty) {
    final parts = name.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${_firstCharUpper(parts[0])}${_firstCharUpper(parts[1])}';
    }
    if (name.length >= 2) {
      return name.substring(0, 2).toUpperCase();
    }
    return _firstCharUpper(name);
  }
  final e = u.email;
  if (e != null && e.isNotEmpty) {
    final local = e.split('@').first;
    if (local.length >= 2) {
      return local.substring(0, 2).toUpperCase();
    }
    if (local.isNotEmpty) {
      return _firstCharUpper(local);
    }
  }
  if (u.uid.isNotEmpty) {
    return u.uid.substring(0, math.min(2, u.uid.length)).toUpperCase();
  }
  return '?';
}
