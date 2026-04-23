import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:borderless_app/app/app_theme.dart';
import 'package:flutter/services.dart';
import 'package:borderless_app/features/drive_home/domain/order.dart';
import 'package:borderless_app/features/map/services/geocoding_service.dart';
import 'package:borderless_app/features/orders/data/orders_repository.dart';

/// Aba "Nova rota" — cria OS no Firestore.
class CreateOrderTab extends StatefulWidget {
  const CreateOrderTab({super.key});

  @override
  State<CreateOrderTab> createState() => _CreateOrderTabState();
}

class _CreateOrderTabState extends State<CreateOrderTab> {
  final _form = GlobalKey<FormState>();
  final _repo = OrdersRepository();
  final _geocode = GeocodingService();
  final _customer = TextEditingController();
  final _label = TextEditingController();
  final _a1 = TextEditingController();
  final _a2 = TextEditingController();
  final _d1 = TextEditingController();
  final _d2 = TextEditingController();
  final _amount = TextEditingController(text: '25,00');
  OrderCategory _cat = OrderCategory.entrega;
  bool _loading = false;
  String? _err;

  @override
  void dispose() {
    _customer.dispose();
    _label.dispose();
    _a1.dispose();
    _a2.dispose();
    _d1.dispose();
    _d2.dispose();
    _amount.dispose();
    super.dispose();
  }

  int _parseAmountCents() {
    final t = _amount.text.replaceAll(' ', '').replaceAll('.', '').replaceAll(',', '.');
    final v = double.tryParse(t) ?? 0;
    return (v * 100).round();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_form.currentState?.validate() ?? false)) return;
    setState(() {
      _loading = true;
      _err = null;
    });
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() {
        _loading = false;
        _err = 'Não autenticado';
      });
      return;
    }
    try {
      final dest =
          '${_d1.text.trim()}, ${_d2.text.trim()}, São Paulo, SP, Brasil';
      final res = await _geocode.geocodeAddress(dest);
      if (!mounted) return;
      if (res.error != null) {
        setState(() {
          _loading = false;
          _err = res.error;
        });
        return;
      }
      final ll = res.latLng;
      await _repo.createFromSolicitante(
        solicitanteId: uid,
        customerName: _customer.text.trim(),
        primaryLabel: _label.text.trim().isEmpty
            ? _defaultLabelFor(_cat)
            : _label.text.trim(),
        addressLine1: _a1.text.trim(),
        addressLine2: _a2.text.trim(),
        destLine1: _d1.text.trim(),
        destLine2: _d2.text.trim(),
        category: _cat,
        amountCents: _parseAmountCents(),
        destLat: ll?.latitude,
        destLng: ll?.longitude,
      );
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rota publicada. Entregadores verão a OS na lista.')),
        );
        _a1.clear();
        _a2.clear();
        _d1.clear();
        _d2.clear();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _err = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Form(
      key: _form,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppTheme.spaceLg,
          AppTheme.spaceLg,
          AppTheme.spaceLg,
          AppTheme.bottomFormScrollPadding,
        ),
        children: [
          Text(
            'Nova rota',
            style: t.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppTheme.spaceSm - 2),
          Text(
            'Preencha endereço inicial, final, tipo e valor. A OS fica visível para entregadores.',
            style: t.textTheme.bodyMedium?.copyWith(
              color: t.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppTheme.spaceLg),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spaceLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Tipo (tag)', style: t.textTheme.labelLarge),
                  const SizedBox(height: AppTheme.spaceSm - 2),
                  DropdownButtonFormField<OrderCategory>(
                    value: _cat,
                    items: [
                      for (final c in OrderCategory.values)
                        DropdownMenuItem(
                          value: c,
                          child: Text(_defaultLabelFor(c)),
                        ),
                    ],
                    onChanged: (v) => setState(() => _cat = v ?? _cat),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _customer,
                    decoration: const InputDecoration(labelText: 'Nome / identificação'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
                  ),
                  const SizedBox(height: AppTheme.spaceSm),
                  TextFormField(
                    controller: _label,
                    decoration: const InputDecoration(
                      labelText: 'Rótulo (opcional)',
                      hintText: 'Ex.: ENTREGA',
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceMd),
                  Text('Endereço inicial (partida)', style: t.textTheme.labelLarge),
                  const SizedBox(height: AppTheme.spaceXs),
                  TextFormField(
                    controller: _a1,
                    decoration: const InputDecoration(labelText: 'Linha 1 (rua, nº)'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
                  ),
                  TextFormField(
                    controller: _a2,
                    decoration: const InputDecoration(labelText: 'Linha 2 (bairro, ref.)'),
                  ),
                  const SizedBox(height: AppTheme.spaceMd),
                  Text('Endereço final (destino)', style: t.textTheme.labelLarge),
                  const SizedBox(height: AppTheme.spaceXs),
                  TextFormField(
                    controller: _d1,
                    decoration: const InputDecoration(labelText: 'Linha 1 (rua, nº)'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
                  ),
                  TextFormField(
                    controller: _d2,
                    decoration: const InputDecoration(labelText: 'Linha 2 (bairro)'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Obrigatório' : null,
                  ),
                  const SizedBox(height: AppTheme.spaceMd),
                  TextFormField(
                    controller: _amount,
                    decoration: const InputDecoration(
                      labelText: 'Valor (R\$)',
                      prefixText: 'R\$ ',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_err != null) ...[
            const SizedBox(height: AppTheme.spaceSm),
            Text(
              _err!,
              style: TextStyle(color: t.colorScheme.error, fontWeight: FontWeight.w600),
            ),
          ],
          const SizedBox(height: AppTheme.spaceXl),
          FilledButton(
            onPressed: _loading ? null : _submit,
            child: _loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Publicar rota'),
          ),
        ],
      ),
    );
  }
}

String _defaultLabelFor(OrderCategory c) {
  return switch (c) {
    OrderCategory.condominio => 'Condomínio',
    OrderCategory.cobranca => 'Cobrança',
    OrderCategory.recebimento => 'Recebimento',
    OrderCategory.coleta => 'Coleta',
    OrderCategory.entrega => 'Entrega',
  };
}
