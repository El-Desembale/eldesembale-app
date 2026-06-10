import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../config/auth/cubit/auth_cubit.dart';
import '../../../../core/di/injection_dependency.dart';
import '../../../../utils/design_tokens.dart';
import '../../data/support_chat_service.dart';

class SupportChatScreen extends StatefulWidget {
  const SupportChatScreen({super.key});

  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  final _service = SupportChatService(sl(instanceName: 'firebaseDatabase'));
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _imagePicker = ImagePicker();
  bool _sending = false;
  String _error = '';
  String _lastSeenMessageId = '';
  final List<_PendingSupportAttachment> _pendingAttachments = [];

  @override
  void initState() {
    super.initState();
    final user = sl<AuthCubit>(instanceName: 'auth').state.user;
    if (user.phone.isNotEmpty) {
      _service.markSeenByCustomer(user.phone).catchError((_) {});
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _markSeenIfNeeded(List<SupportMessageModel> messages, String phone) {
    if (messages.isEmpty) return;
    final lastMessage = messages.last;
    if (lastMessage.senderRole == 'admin' && _lastSeenMessageId != lastMessage.id) {
      _lastSeenMessageId = lastMessage.id;
      _service.markSeenByCustomer(phone).catchError((_) {});
    }
  }

  Future<void> _send(AuthState authState) async {
    final text = _controller.text.trim();
    if ((text.isEmpty && _pendingAttachments.isEmpty) || _sending) return;
    setState(() {
      _sending = true;
      _error = '';
    });
    try {
      final fullName = [authState.user.name, authState.user.lastName]
          .where((part) => part.trim().isNotEmpty)
          .join(' ');
      final attachments = <SupportAttachmentModel>[];
      for (final pending in _pendingAttachments) {
        final uploaded = await _service.uploadAttachment(
          phone: authState.user.phone,
          file: pending.file,
          fileName: pending.name,
        );
        attachments.add(uploaded);
      }
      await _service.sendMessage(
        phone: authState.user.phone,
        customerName: fullName,
        customerEmail: authState.user.email,
        text: text,
        attachments: attachments,
      );
      _controller.clear();
      setState(() {
        _pendingAttachments.clear();
      });
    } catch (_) {
      setState(() {
        _error = 'No se pudo enviar el mensaje o los adjuntos. Intenta de nuevo.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _sending = false;
        });
      }
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Ahora';
    const months = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic'
    ];
    final month = months[date.month - 1];
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.day.toString().padLeft(2, '0')} $month · $hour:$minute';
  }

  String _formatBytes(int size) {
    if (size <= 0) return '0 B';
    const units = ['B', 'KB', 'MB', 'GB'];
    final index = (size > 0 ? (size.bitLength / 10).floor() : 0).clamp(0, units.length - 1);
    final value = size / (1 << (index * 10));
    final digits = value >= 10 || index == 0 ? 0 : 1;
    return '${value.toStringAsFixed(digits)} ${units[index]}';
  }

  Future<void> _pickImages() async {
    final files = await _imagePicker.pickMultiImage(imageQuality: 85);
    if (files.isEmpty) return;
    for (final file in files) {
      _addPendingAttachment(File(file.path), file.name);
    }
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'webp', 'heic', 'doc', 'docx', 'xls', 'xlsx', 'txt'],
      withData: true,
    );
    if (result == null) return;
    for (final file in result.files) {
      final resolved = await _platformFileToFile(file);
      if (resolved != null) {
        _addPendingAttachment(resolved, file.name);
      }
    }
  }

  Future<void> _showAttachmentOptions() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: kBgScreenAlt,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Adjuntar al chat',
                  style: TextStyle(
                    color: kTextPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Puedes enviar imágenes y archivos para que soporte revise tu caso.',
                  style: TextStyle(
                    color: kTextSecondary.withValues(alpha: 0.8),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 24),
                _AttachmentOptionButton(
                  icon: Icons.photo_library_outlined,
                  label: 'Elegir imágenes',
                  description: 'Selecciona fotos desde tu galería',
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    await _pickImages();
                  },
                ),
                const SizedBox(height: 12),
                _AttachmentOptionButton(
                  icon: Icons.attach_file_outlined,
                  label: 'Elegir archivos',
                  description: 'PDF, Word, Excel, texto e imágenes',
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    await _pickFiles();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addPendingAttachment(File file, String name) {
    final exists = _pendingAttachments.any(
      (attachment) => attachment.name == name && attachment.file.path == file.path,
    );
    if (exists) return;
    setState(() {
      _error = '';
      _pendingAttachments.add(_PendingSupportAttachment(file: file, name: name));
    });
  }

  void _removePendingAttachment(_PendingSupportAttachment attachment) {
    setState(() {
      _pendingAttachments.remove(attachment);
    });
  }

  bool _isImageAttachmentName(String name) {
    final lower = name.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.heic');
  }

  static Future<File?> _platformFileToFile(PlatformFile pf) async {
    if (pf.path != null) return File(pf.path!);
    if (pf.bytes == null) return null;
    final tempDir = Directory.systemTemp;
    final file = File('${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}_${pf.name}');
    await file.writeAsBytes(pf.bytes!);
    return file;
  }

  @override
  Widget build(BuildContext context) {
    final authState = sl<AuthCubit>(instanceName: 'auth').state;
    final user = authState.user;
    final fullName = [user.name, user.lastName]
        .where((part) => part.trim().isNotEmpty)
        .join(' ');

    return Scaffold(
      backgroundColor: kBgScreen,
      appBar: AppBar(
        backgroundColor: kBgScreen,
        foregroundColor: kTextPrimary,
        elevation: 0,
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ayuda',
              style: TextStyle(
                color: kTextPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Chatea con soporte desde la app',
              style: TextStyle(
                color: kTextSecondary.withValues(alpha: 0.8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 10, 24, 14),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    kPrimaryGreen.withValues(alpha: 0.18),
                    kBgScreenAlt,
                  ],
                ),
                borderRadius: BorderRadius.circular(kRadiusCard),
                border: Border.all(color: kPrimaryGreen.withValues(alpha: 0.2)),
              ),
              child: StreamBuilder<SupportThreadModel?>(
                stream: _service.watchThread(user.phone),
                builder: (context, snapshot) {
                  final thread = snapshot.data;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Soporte disponible',
                        style: TextStyle(
                          color: kTextPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Escríbenos dudas sobre pagos, desembolsos o el estado de tu solicitud. Tu historial queda guardado para seguir la conversación después.',
                        style: TextStyle(
                          color: kTextSecondary.withValues(alpha: 0.82),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _pill(
                            thread?.customerUnreadCount != null &&
                                    thread!.customerUnreadCount > 0
                                ? '${thread.customerUnreadCount} respuestas nuevas'
                                : 'Sin respuestas pendientes',
                          ),
                          _pill(fullName.isEmpty ? user.phone : fullName),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: kBgScreenAlt,
                borderRadius: BorderRadius.circular(kRadiusCard),
                border: Border.all(color: kBorderFaint),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: StreamBuilder<List<SupportMessageModel>>(
                      stream: _service.watchMessages(user.phone),
                      builder: (context, snapshot) {
                        final messages = snapshot.data ?? const <SupportMessageModel>[];
                        _markSeenIfNeeded(messages, user.phone);
                        _scrollToBottom();
                        if (messages.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 28),
                              child: Text(
                                'Todavía no hay mensajes. Cuéntanos qué necesitas y el equipo de soporte te responderá aquí.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: kTextSecondary.withValues(alpha: 0.85),
                                  height: 1.6,
                                ),
                              ),
                            ),
                          );
                        }
                        return ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(18),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            final isCustomer = message.senderRole == 'customer';
                            return Align(
                              alignment: isCustomer
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.72,
                                ),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: isCustomer ? kPrimaryGreen : kSurfaceSoft,
                                  borderRadius: BorderRadius.circular(18),
                                  border: isCustomer
                                      ? null
                                      : Border.all(color: kBorderFaint),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isCustomer
                                          ? 'Tú'
                                          : (message.senderName.isEmpty
                                              ? 'Soporte'
                                              : message.senderName),
                                      style: TextStyle(
                                        color: isCustomer
                                            ? kBgScreen
                                            : kTextSecondary.withValues(alpha: 0.82),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (message.text.isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                        message.text,
                                        style: TextStyle(
                                          color: isCustomer ? kBgScreen : kTextPrimary,
                                          height: 1.5,
                                        ),
                                      ),
                                    ],
                                    if (message.attachments.isNotEmpty) ...[
                                      SizedBox(height: message.text.isNotEmpty ? 12 : 8),
                                      ...message.attachments.map(
                                        (attachment) => Padding(
                                          padding: const EdgeInsets.only(bottom: 10),
                                          child: _MessageAttachmentCard(
                                            attachment: attachment,
                                            isCustomer: isCustomer,
                                            formatBytes: _formatBytes,
                                          ),
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 8),
                                    Text(
                                      _formatDate(message.createdAt),
                                      style: TextStyle(
                                        color: isCustomer
                                            ? kBgScreen.withValues(alpha: 0.72)
                                            : kTextSecondary.withValues(alpha: 0.7),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: kBorderFaint)),
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _controller,
                          maxLines: 4,
                          minLines: 3,
                          style: const TextStyle(color: kTextPrimary),
                          decoration: InputDecoration(
                            hintText: 'Escribe tu mensaje para soporte',
                            hintStyle: TextStyle(
                              color: kTextSecondary.withValues(alpha: 0.6),
                            ),
                            filled: true,
                            fillColor: kSurfaceSoft,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.all(16),
                          ),
                        ),
                        if (_pendingAttachments.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 88,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _pendingAttachments.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 10),
                              itemBuilder: (context, index) {
                                final attachment = _pendingAttachments[index];
                                final isImage = _isImageAttachmentName(attachment.name);
                                return _PendingAttachmentCard(
                                  attachment: attachment,
                                  isImage: isImage,
                                  formatBytes: _formatBytes,
                                  onRemove: () => _removePendingAttachment(attachment),
                                );
                              },
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _error.isNotEmpty
                                    ? _error
                                    : 'Tu mensaje llegará al panel de soporte del admin.',
                                style: TextStyle(
                                  color: _error.isNotEmpty
                                      ? kDangerSoft
                                      : kTextSecondary.withValues(alpha: 0.8),
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton.filledTonal(
                              onPressed: _sending ? null : _showAttachmentOptions,
                              style: IconButton.styleFrom(
                                backgroundColor: kSurfaceSoft,
                                foregroundColor: kTextPrimary,
                              ),
                              icon: const Icon(Icons.attach_file_rounded),
                            ),
                            const SizedBox(width: 12),
                            FilledButton(
                              onPressed: _sending ||
                                      (_controller.text.trim().isEmpty &&
                                          _pendingAttachments.isEmpty)
                                  ? null
                                  : () => _send(authState),
                              style: FilledButton.styleFrom(
                                backgroundColor: kPrimaryGreen,
                                foregroundColor: kBgScreen,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(_sending ? 'Enviando...' : 'Enviar'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _pill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: kSurfaceSoft,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: kBorderFaint),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: kTextSecondary.withValues(alpha: 0.88),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _PendingSupportAttachment {
  final File file;
  final String name;

  const _PendingSupportAttachment({
    required this.file,
    required this.name,
  });
}

class _AttachmentOptionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final Future<void> Function() onTap;

  const _AttachmentOptionButton({
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kSurfaceSoft,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kBorderFaint),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: kPrimaryGreen.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: kPrimaryGreen),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: kTextPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: kTextSecondary.withValues(alpha: 0.82),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingAttachmentCard extends StatelessWidget {
  final _PendingSupportAttachment attachment;
  final bool isImage;
  final String Function(int) formatBytes;
  final VoidCallback onRemove;

  const _PendingAttachmentCard({
    required this.attachment,
    required this.isImage,
    required this.formatBytes,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kSurfaceSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kBorderFaint),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 48,
              height: 48,
              color: kPrimaryGreen.withValues(alpha: 0.12),
              child: isImage
                  ? Image.file(attachment.file, fit: BoxFit.cover)
                  : const Icon(Icons.insert_drive_file_outlined, color: kPrimaryGreen),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  attachment.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: kTextPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatBytes(attachment.file.lengthSync()),
                  style: TextStyle(
                    color: kTextSecondary.withValues(alpha: 0.82),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.close_rounded, color: kTextPrimary, size: 18),
          ),
        ],
      ),
    );
  }
}

class _MessageAttachmentCard extends StatelessWidget {
  final SupportAttachmentModel attachment;
  final bool isCustomer;
  final String Function(int) formatBytes;

  const _MessageAttachmentCard({
    required this.attachment,
    required this.isCustomer,
    required this.formatBytes,
  });

  bool get _isImage =>
      attachment.kind == 'image' || attachment.contentType.startsWith('image/');

  @override
  Widget build(BuildContext context) {
    if (_isImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          attachment.url,
          width: 220,
          height: 180,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: 220,
            height: 120,
            color: isCustomer ? kBgScreen.withValues(alpha: 0.08) : kSurfaceFaint,
            alignment: Alignment.center,
            child: Text(
              attachment.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isCustomer ? kBgScreen : kTextPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCustomer ? kBgScreen.withValues(alpha: 0.08) : kSurfaceFaint,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            Icons.insert_drive_file_outlined,
            color: isCustomer ? kBgScreen : kTextPrimary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attachment.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isCustomer ? kBgScreen : kTextPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatBytes(attachment.size),
                  style: TextStyle(
                    color: isCustomer
                        ? kBgScreen.withValues(alpha: 0.72)
                        : kTextSecondary.withValues(alpha: 0.76),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
