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
    this.destLine1 = '',
    this.destLine2 = '',
    this.destLat,
    this.destLng,
    this.criadaPorUid,
    this.assignedTo,
    this.isPool = false,
    this.completedAt,
    this.outcome,
    this.durationMinutes = 0,
    this.firestoreDocumentId,
  });

  final String id;
  final OrderCategory category;
  final OrderStatus status;
  final String customerName;
  final String primaryLabel;
  /// Origem (partida) — ex.: rua, número
  final String addressLine1;
  final String addressLine2;
  /// Destino (chegada) — vazio = só origem
  final String destLine1;
  final String destLine2;
  final double? destLat;
  final double? destLng;
  /// UID do admin que criou a ordem (no Firestore: `criadaPorUid`; legado: `solicitanteId`).
  final String? criadaPorUid;
  final String? assignedTo;
  final bool isPool;
  final DateTime? completedAt;
  final String? outcome;
  final int durationMinutes;
  /// id do documento no Firestore (diferente de [id] exibido na OS).
  final String? firestoreDocumentId;
  final int etaMinutes;
  final double distanceKm;
  final int amountCents;
  final DateTime createdAt;

  String get amountBRL {
    final reais = amountCents / 100.0;
    final s = reais.toStringAsFixed(2).replaceAll('.', ',');
    return 'R\$ $s';
  }

  Order copyWith({
    String? id,
    OrderCategory? category,
    OrderStatus? status,
    String? customerName,
    String? primaryLabel,
    String? addressLine1,
    String? addressLine2,
    String? destLine1,
    String? destLine2,
    double? destLat,
    double? destLng,
    String? criadaPorUid,
    String? assignedTo,
    bool? isPool,
    int? etaMinutes,
    double? distanceKm,
    int? amountCents,
    DateTime? createdAt,
    DateTime? completedAt,
    String? outcome,
    int? durationMinutes,
    String? firestoreDocumentId,
  }) {
    return Order(
      id: id ?? this.id,
      firestoreDocumentId: firestoreDocumentId ?? this.firestoreDocumentId,
      category: category ?? this.category,
      status: status ?? this.status,
      customerName: customerName ?? this.customerName,
      primaryLabel: primaryLabel ?? this.primaryLabel,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      destLine1: destLine1 ?? this.destLine1,
      destLine2: destLine2 ?? this.destLine2,
      destLat: destLat ?? this.destLat,
      destLng: destLng ?? this.destLng,
      criadaPorUid: criadaPorUid ?? this.criadaPorUid,
      assignedTo: assignedTo ?? this.assignedTo,
      isPool: isPool ?? this.isPool,
      etaMinutes: etaMinutes ?? this.etaMinutes,
      distanceKm: distanceKm ?? this.distanceKm,
      amountCents: amountCents ?? this.amountCents,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      outcome: outcome ?? this.outcome,
      durationMinutes: durationMinutes ?? this.durationMinutes,
    );
  }
}

