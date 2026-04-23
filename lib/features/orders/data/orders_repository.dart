import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/user/user_role.dart';
import '../../drive_home/data/mock_orders.dart';
import '../../drive_home/domain/order.dart';
import '../../history/data/mock_history.dart';
import '../../history/domain/history_item.dart';
import '../../map/data/mock_rides.dart';
import '../../map/domain/ride_map_item.dart';
import 'order_serialization.dart';

const _kSeedFlagDoc = 'config/seed_ran_v1';
const _kOrders = 'orders';

class OrdersRepository {
  OrdersRepository({FirebaseFirestore? db, FirebaseAuth? auth})
      : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection(_kOrders);

  Stream<List<Order>> watchOrders() {
    return _col.snapshots().map((s) {
      final list = <Order>[];
      for (final d in s.docs) {
        final o = orderFromFirestore(d.id, d.data());
        if (o != null) {
          list.add(o);
        }
      }
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return List<Order>.from(list);
    });
  }

  List<Order> filterForEntregador(List<Order> all, String? myUid) {
    if (myUid == null) return const [];
    return all.where((o) {
      if (o.status == OrderStatus.concluido) return false;
      if (o.assignedTo == myUid) return true;
      if (o.assignedTo == null) {
        return o.status == OrderStatus.disponivel ||
            o.status == OrderStatus.atrasado;
      }
      return false;
    }).toList();
  }

  List<Order> filterForSolicitante(List<Order> all, String uid) {
    return all
        .where(
          (o) =>
              o.solicitanteId == uid && o.status != OrderStatus.concluido,
        )
        .toList();
  }

  List<Order> filterHistoryForUser(
    List<Order> all,
    String uid,
    UserRole role,
  ) {
    final h = all.where((o) {
      if (o.status != OrderStatus.concluido) return false;
      if (role == UserRole.solicitante) {
        return o.solicitanteId == uid;
      }
      return o.assignedTo == uid;
    }).toList();
    h.sort(
      (a, b) => (b.completedAt ?? b.createdAt)
          .compareTo(a.completedAt ?? a.createdAt),
    );
    return h;
  }

  List<RideMapItem> ordersToRideItems(List<Order> all) {
    final out = <RideMapItem>[];
    for (final o in all) {
      if (o.destLat == null || o.destLng == null) continue;
      if (o.status == OrderStatus.concluido) continue;
      out.add(
        RideMapItem(
          id: o.id,
          label: o.primaryLabel,
          pickupAddress: '${o.addressLine1} — ${o.addressLine2}'.trim(),
          destinationAddress: o.destLine1.isNotEmpty
              ? '${o.destLine1} — ${o.destLine2}'.trim()
              : o.addressLine1,
          destinationLatLng: LatLng(o.destLat!, o.destLng!),
          scheduledAt: o.createdAt,
        ),
      );
    }
    return out;
  }

  Future<void> createFromSolicitante({
    required String solicitanteId,
    required String customerName,
    required String primaryLabel,
    required String addressLine1,
    required String addressLine2,
    required String destLine1,
    required String destLine2,
    required OrderCategory category,
    required int amountCents,
    int etaMinutes = 20,
    double distanceKm = 5.0,
    double? destLat,
    double? destLng,
  }) async {
    final ref = _col.doc();
    final displayId = 'OS-${ref.id.replaceAll('-', '').substring(0, 6).toUpperCase()}';
    final now = DateTime.now();
    var o = Order(
      id: displayId,
      firestoreDocumentId: ref.id,
      category: category,
      status: OrderStatus.disponivel,
      customerName: customerName,
      primaryLabel: primaryLabel,
      addressLine1: addressLine1,
      addressLine2: addressLine2,
      destLine1: destLine1,
      destLine2: destLine2,
      destLat: destLat,
      destLng: destLng,
      solicitanteId: solicitanteId,
      isPool: false,
      etaMinutes: etaMinutes,
      distanceKm: distanceKm,
      amountCents: amountCents,
      createdAt: now,
    );
    final m = orderToFirestoreMap(o);
    m['id'] = displayId;
    await ref.set(m);
  }

  Future<void> acceptOrderForEntregador(String firestoreDocumentId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _col.doc(firestoreDocumentId).update({
      'assignedTo': uid,
      'status': OrderStatus.emRota.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> ensureSeededFromMocks() async {
    final flag = _db.doc(_kSeedFlagDoc);
    final snap = await flag.get();
    if (snap.exists) return;

    final rides = mockRideMapItems();
    var idx = 0;
    final batch = _db.batch();
    for (final o in mockOrders()) {
      final r = idx < rides.length ? rides[idx] : null;
      idx++;
      final merged = o.copyWith(
        destLine1: r == null
            ? o.addressLine1
            : r.destinationAddress.split(' - ').first.trim(),
        destLine2: r == null ? o.addressLine2 : '',
        destLat: r?.destinationLatLng.latitude,
        destLng: r?.destinationLatLng.longitude,
        isPool: true,
        solicitanteId: null,
        firestoreDocumentId: null,
      );
      final ref = _col.doc();
      var m = orderToFirestoreMap(merged.copyWith(firestoreDocumentId: ref.id));
      m['id'] = merged.id;
      m['solicitanteId'] = null;
      m['isPool'] = true;
      batch.set(ref, m);
    }
    for (final hi in mockHistoryItems()) {
      final ord = _orderFromHistoryItem(hi);
      final ref = _col.doc();
      var m = orderToFirestoreMap(ord);
      m['id'] = ord.id;
      m['solicitanteId'] = null;
      m['isPool'] = true;
      batch.set(ref, m);
    }
    batch.set(flag, {
      'createdAt': FieldValue.serverTimestamp(),
      'version': 1,
    });
    await batch.commit();
  }

  Order _orderFromHistoryItem(HistoryItem it) {
    return Order(
      id: it.id,
      firestoreDocumentId: null,
      category: it.category,
      status: OrderStatus.concluido,
      customerName: it.customerName,
      primaryLabel: _categoryPrimaryLabel(it.category),
      addressLine1: it.addressLine1,
      addressLine2: it.addressLine2,
      destLine1: '',
      destLine2: '',
      destLat: null,
      destLng: null,
      etaMinutes: 0,
      distanceKm: 0,
      amountCents: it.amountCents,
      createdAt: it.completedAt,
      completedAt: it.completedAt,
      outcome: it.outcome.name,
      durationMinutes: it.durationMinutes,
      isPool: true,
    );
  }

  String _categoryPrimaryLabel(OrderCategory c) {
    return switch (c) {
      OrderCategory.condominio => 'CONDOMÍNIO',
      OrderCategory.cobranca => 'COBRANÇA',
      OrderCategory.recebimento => 'RECEBIMENTO',
      OrderCategory.coleta => 'COLETA',
      OrderCategory.entrega => 'ENTREGA',
    };
  }
}
