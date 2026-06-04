import 'package:flutter/material.dart';

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
  bool _sending = false;
  String _error = '';
  String _lastSeenMessageId = '';

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
    if (text.isEmpty || _sending) return;
    setState(() {
      _sending = true;
      _error = '';
    });
    try {
      final fullName = [authState.user.name, authState.user.lastName]
          .where((part) => part.trim().isNotEmpty)
          .join(' ');
      await _service.sendMessage(
        phone: authState.user.phone,
        customerName: fullName,
        customerEmail: authState.user.email,
        text: text,
      );
      _controller.clear();
    } catch (_) {
      setState(() {
        _error = 'No se pudo enviar el mensaje. Intenta de nuevo.';
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
                                    const SizedBox(height: 6),
                                    Text(
                                      message.text,
                                      style: TextStyle(
                                        color: isCustomer ? kBgScreen : kTextPrimary,
                                        height: 1.5,
                                      ),
                                    ),
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
                            FilledButton(
                              onPressed: _sending ? null : () => _send(authState),
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
