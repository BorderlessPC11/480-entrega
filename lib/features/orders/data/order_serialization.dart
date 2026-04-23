import 'package:cloud_firestore/cloud_firestore.dart' hide Order;

import '../../drive_home/domain/order.dart';

Order? orderFromFirestore(String docId, Map<String, dynamic> m) {
  final id = (m['id'] as String?)?.trim() ?? docId;
  final cat = _parseCategory(m['category']);
  final st = _parseStatus(m['status']);
  if (cat == null || st == null) return null;
  return Order(
    id: id,
    firestoreDocumentId: docId,
    category: cat,
    status: st,
    customerName: (m['customerName'] as String?)?.trim() ?? '—',
    primaryLabel: (m['primaryLabel'] as String?)?.trim() ?? '—',
    addressLine1: (m['addressLine1'] as String?)?.trim() ?? '—',
    addressLine2: (m['addressLine2'] as String?)?.trim() ?? '',
    destLine1: (m['destLine1'] as String?)?.trim() ?? '',
    destLine2: (m['destLine2'] as String?)?.trim() ?? '',
    destLat: (m['destLat'] as num?)?.toDouble(),
    destLng: (m['destLng'] as num?)?.toDouble(),
    solicitanteId: m['solicitanteId'] as String?,
    assignedTo: m['assignedTo'] as String?,
    isPool: m['isPool'] == true,
    etaMinutes: (m['etaMinutes'] as num?)?.toInt() ?? 0,
    distanceKm: (m['distanceKm'] as num?)?.toDouble() ?? 0,
    amountCents: (m['amountCents'] as num?)?.toInt() ?? 0,
    createdAt: _ts(m['createdAt']) ?? DateTime.now(),
    completedAt: m['completedAt'] != null ? _ts(m['completedAt']) : null,
    outcome: m['outcome'] as String?,
    durationMinutes: (m['durationMinutes'] as num?)?.toInt() ?? 0,
  );
}

Map<String, dynamic> orderToFirestoreMap(Order o) {
  return <String, dynamic>{
    'id': o.id,
    'category': o.category.name,
    'status': o.status.name,
    'customerName': o.customerName,
    'primaryLabel': o.primaryLabel,
    'addressLine1': o.addressLine1,
    'addressLine2': o.addressLine2,
    'destLine1': o.destLine1,
    'destLine2': o.destLine2,
    'destLat': o.destLat,
    'destLng': o.destLng,
    'solicitanteId': o.solicitanteId,
    'assignedTo': o.assignedTo,
    'isPool': o.isPool,
    'etaMinutes': o.etaMinutes,
    'distanceKm': o.distanceKm,
    'amountCents': o.amountCents,
    'createdAt': Timestamp.fromDate(o.createdAt),
    'completedAt':
        o.completedAt != null ? Timestamp.fromDate(o.completedAt!) : null,
    'outcome': o.outcome,
    'durationMinutes': o.durationMinutes,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}

OrderCategory? _parseCategory(Object? v) {
  if (v is! String) return null;
  for (final e in OrderCategory.values) {
    if (e.name == v) return e;
  }
  return null;
}

OrderStatus? _parseStatus(Object? v) {
  if (v is! String) return null;
  for (final e in OrderStatus.values) {
    if (e.name == v) return e;
  }
  return null;
}

DateTime? _ts(Object? v) {
  if (v is Timestamp) return v.toDate();
  if (v is DateTime) return v;
  return null;
}
