import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/auth/auth_service.dart';
import '../data/profile_photo_storage.dart';
import '../data/user_profile_repository.dart';
import '../../auth/presentation/widgets/auth_primary_button.dart';
import '../../auth/presentation/widgets/auth_text_field.dart';

String? _validateName(String? v) {
  final t = (v ?? '').trim();
  if (t.length < 2) {
    return 'Informe pelo menos 2 caracteres';
  }
  if (t.length > 80) {
    return 'Máximo de 80 caracteres';
  }
  return null;
}

String? _validatePhone(String? v) {
  final t = (v ?? '').trim();
  if (t.isEmpty) return null;
  final digits = t.replaceAll(RegExp(r'\D'), '');
  if (digits.length < 10) {
    return 'Informe ao menos 10 dígitos ou deixe vazio';
  }
  if (digits.length > 15) {
    return 'Número muito longo';
  }
  return null;
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
    required this.userId,
    required this.initialDisplayName,
    this.initialPhone,
    this.initialPhotoUrl,
    required this.avatarInitials,
  });

  final String userId;
  final String initialDisplayName;
  final String? initialPhone;
  final String? initialPhotoUrl;
  final String avatarInitials;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _auth = AuthService();
  final _profileRepo = UserProfileRepository();
  final _photoStorage = ProfilePhotoStorage();

  XFile? _pickedImage;
  Uint8List? _previewBytes;
  bool _markPhotoForRemoval = false;

  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _name.text = widget.initialDisplayName;
    if (widget.initialPhone != null) {
      _phone.text = widget.initialPhone!;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  bool get _hasPhotoToRemove =>
      !_markPhotoForRemoval &&
      (_previewBytes != null ||
          (widget.initialPhotoUrl != null && widget.initialPhotoUrl!.isNotEmpty));

  Future<void> _pickFromGallery() async {
    setState(() => _error = null);
    final p = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 88,
    );
    if (p == null) return;
    final bytes = await p.readAsBytes();
    if (!mounted) return;
    if (bytes.length > 4 * 1024 * 1024) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Escolha uma imagem de até 4 MB.'),
        ),
      );
      return;
    }
    setState(() {
      _pickedImage = p;
      _previewBytes = bytes;
      _markPhotoForRemoval = false;
    });
  }

  void _removePhotoTapped() {
    setState(() {
      _pickedImage = null;
      _previewBytes = null;
      _markPhotoForRemoval = true;
    });
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _error = null;
      _loading = true;
    });
    if (!(_formKey.currentState?.validate() ?? false)) {
      if (mounted) {
        setState(() => _loading = false);
      }
      return;
    }
    try {
      if (_pickedImage != null) {
        final url =
            await _photoStorage.uploadProfilePhoto(widget.userId, _pickedImage!);
        await _auth.updatePhotoUrl(url);
      } else if (_markPhotoForRemoval) {
        await _photoStorage.deleteProfilePhoto(widget.userId);
        await _auth.updatePhotoUrl(null);
      }
      await _auth.updateDisplayName(_name.text);
      await _profileRepo.setPhone(widget.userId, _phone.text);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        final String msg;
        if (e is StateError) {
          msg = e.message;
        } else if (e is FirebaseException) {
          msg = e.message ?? e.code;
        } else {
          msg = _auth.messageForError(e);
        }
        setState(() {
          _error = msg;
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar perfil'),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Foto, nome e telefone exibidos no app.',
                      style: t.textTheme.bodyLarge?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.75),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Column(
                        children: [
                          _EditAvatar(
                            size: 104,
                            initials: widget.avatarInitials,
                            previewBytes: _previewBytes,
                            markRemoval: _markPhotoForRemoval,
                            networkUrl: widget.initialPhotoUrl,
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              FilledButton.tonalIcon(
                                onPressed: _loading ? null : _pickFromGallery,
                                icon: const Icon(Icons.photo_library_outlined, size: 20),
                                label: const Text('Galeria'),
                              ),
                              if (_hasPhotoToRemove)
                                TextButton.icon(
                                  onPressed: _loading ? null : _removePhotoTapped,
                                  icon: Icon(
                                    Icons.delete_outline,
                                    size: 20,
                                    color: cs.error,
                                  ),
                                  label: Text(
                                    'Remover foto',
                                    style: TextStyle(color: cs.error),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AuthTextField(
                              controller: _name,
                              label: 'Nome de exibição',
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.name],
                              validator: _validateName,
                            ),
                            const SizedBox(height: 14),
                            AuthTextField(
                              controller: _phone,
                              label: 'Telefone',
                              hint: '(00) 00000-0000 (opcional)',
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.done,
                              autofillHints: const [
                                AutofillHints.telephoneNumber,
                              ],
                              validator: _validatePhone,
                            ),
                            if (_error != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                _error!,
                                style: t.textTheme.bodySmall?.copyWith(
                                  color: cs.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                            const SizedBox(height: 18),
                            AuthPrimaryButton(
                              label: 'Salvar',
                              loading: _loading,
                              onPressed: _save,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EditAvatar extends StatelessWidget {
  const _EditAvatar({
    required this.size,
    required this.initials,
    this.previewBytes,
    required this.markRemoval,
    this.networkUrl,
  });

  final double size;
  final String initials;
  final Uint8List? previewBytes;
  final bool markRemoval;
  final String? networkUrl;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    Widget buildFallback() {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              cs.primary.withValues(alpha: 0.9),
              cs.tertiary.withValues(alpha: 0.8),
            ],
          ),
          border: Border.all(color: cs.outline.withValues(alpha: 0.6)),
        ),
        child: Center(
          child: Text(
            initials,
            style: t.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      );
    }

    if (markRemoval) {
      return buildFallback();
    }
    if (previewBytes != null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: cs.outline.withValues(alpha: 0.6)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.memory(
          previewBytes!,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    }
    if (networkUrl != null && networkUrl!.isNotEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: cs.outline.withValues(alpha: 0.6)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.network(
          networkUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => buildFallback(),
        ),
      );
    }
    return buildFallback();
  }
}
