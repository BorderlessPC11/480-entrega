import 'package:flutter/material.dart';

enum OrderCategory {
  condominio,
  cobranca,
  recebimento,
  coleta,
  entrega,
}

enum OrderStatus {
  disponivel,
  emRota,
  atrasado,
  concluido,
}

@immutable
class Order {
  const Order({
    required this.id,
    required this.category,
    required this.status,
    required this.customerName,
    required this.primaryLabel,
    required this.addressLine1,
    required this.addressLine2,
    required this.etaMinutes,
    required this.distanceKm,
    required this.amountCents,
    required this.createdAt,
  });

  final String id;
  final OrderCategory category;
  final OrderStatus status;
  final String customerName;
  final String primaryLabel;
  final String addressLine1;
  final String addressLine2;
  final int etaMinutes;
  final double distanceKm;
  final int amountCents;
  final DateTime createdAt;

  String get amountBRL {
    final reais = amountCents / 100.0;
    final s = reais.toStringAsFixed(2).replaceAll('.', ',');
    return 'R\$ $s';
  }
}

