import 'dart:io';
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../../config/routes/routes.dart';
import '../../../../utils/design_tokens.dart';
import '../../../../utils/modalbottomsheet.dart';
import '../../../../config/auth/cubit/auth_cubit.dart';
import '../../../../core/di/injection_dependency.dart';
import '../../../shared/widgets/back_circle_button.dart';
import '../../../shared/widgets/primary_action_button.dart';
import '../../cubit/home_cubit.dart';
import '../../data/services/home_service.dart';
import '../widgets/web_payment_view.dart';

class SubscriptionScreen extends StatefulWidget {
  final HomeCubit homeCubit;
  final String? afterSuccessRoute;
  final bool returnSuccessResult;
  const SubscriptionScreen({
    super.key,
    required this.homeCubit,
    this.afterSuccessRoute,
    this.returnSuccessResult = false,
  });

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen>
    with WidgetsBindingObserver {
  bool _sendingProof = false;
  String? _proofMessage;
  bool _approvalFeedbackEnabled = false;
  bool _pendingManualReview = false;
  bool _manualProofSubmittedInSession = false;
  DateTime? _pendingSubmittedAt;
  String _pendingProofName = '';
  final List<StreamSubscription<dynamic>> _subscriptionWatchers = [];
  bool _handledApproval = false;
  Timer? _subscriptionRefreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.homeCubit.loadWompiConfig();
    _watchSubscriptionApproval();
    _startSubscriptionRefreshTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    for (final watcher in _subscriptionWatchers) {
      watcher.cancel();
    }
    _subscriptionRefreshTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshSubscriptionState();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      bloc: widget.homeCubit,
      builder: (BuildContext context, HomeState state) {
        return Scaffold(
          drawerEnableOpenDragGesture: false,
          extendBodyBehindAppBar: true,
          floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
          floatingActionButton: BackCircleButton(
            heroTag: 'subscription_back',
            onPressed: () => context.pop(),
          ),
          body: _body(context, state),
        );
      },
    );
  }

  Widget _body(BuildContext context, HomeState state) {
    final amountLabel =
        NumberFormat.decimalPattern('es_CO').format(state.subscriptionAmount);
    final hasTransferData = state.transferBankName.trim().isNotEmpty;
    const benefits = [
      'Préstamos fáciles de obtener',
      'Sin requisitos complejos',
      'Aprobación rápida y sencilla',
      'Transparencia total',
      'Soporte disponible',
    ];

    return Container(
      color: kBgScreen,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 92, 24, 28),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.sizeOf(context).height - 140,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Suscríbete',
                  style: TextStyle(
                    color: kTextPrimary,
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1.2,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Activa tu membresía y mantén acceso ágil a las solicitudes, pagos y soporte de la plataforma.',
                  style: TextStyle(
                    color: kTextSecondary,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: kSurfaceSoft,
                    borderRadius: BorderRadius.circular(kRadiusCard),
                    border: Border.all(color: kBorderFaint),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tu suscripción incluye',
                        style: TextStyle(
                          color: kTextPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...benefits.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 3),
                                width: 18,
                                height: 18,
                                decoration: const BoxDecoration(
                                  color: kPrimaryGreenSoft,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  size: 12,
                                  color: kPrimaryGreen,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  item,
                                  style: const TextStyle(
                                    color: kTextPrimary,
                                    fontSize: 15,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: kSurfaceFaint,
                    borderRadius: BorderRadius.circular(kRadiusCard),
                    border: Border.all(color: kBorderFaint),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: kPrimaryGreenSoft,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.info_outline_rounded,
                          color: kPrimaryGreen,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              '¿Por qué existe esta suscripción?',
                              style: TextStyle(
                                color: kTextPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Nos ayuda a sostener la operación de la plataforma y seguir ofreciéndote un servicio confiable y rápido.',
                              style: TextStyle(
                                color: kTextSecondary,
                                fontSize: 14,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: kPrimaryGreenSoft,
                    borderRadius: BorderRadius.circular(kRadiusCard),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Valor actual de la suscripción',
                        style: TextStyle(
                          color: kTextSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$$amountLabel COP',
                        style: const TextStyle(
                          color: kTextPrimary,
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (_pendingManualReview)
                  _PendingSubscriptionReviewCard(
                    submittedAt: _pendingSubmittedAt,
                    proofName: _pendingProofName,
                  )
                else ...[
                  if (hasTransferData) ...[
                    _TransferInstructionsCard(state: state),
                    const SizedBox(height: 20),
                  ],
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: kSurfaceSoft,
                      borderRadius: BorderRadius.circular(kRadiusCard),
                      border: Border.all(color: kBorderFaint),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '¿Ya pagaste por transferencia?',
                          style: TextStyle(
                            color: kTextPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Adjunta una foto o archivo del comprobante y el admin activará tu suscripción después de revisarlo.',
                          style: TextStyle(
                            color: kTextSecondary,
                            fontSize: 13,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Elige cómo quieres adjuntarlo',
                          style: TextStyle(
                            color: kTextSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _ProofOptionButton(
                          icon: Icons.camera_alt_outlined,
                          label: 'Tomar foto',
                          description: 'Usa la cámara para fotografiar el comprobante',
                          enabled: !_sendingProof,
                          onTap: () => _takeProofPhoto(context),
                        ),
                        const SizedBox(height: 12),
                        _ProofOptionButton(
                          icon: Icons.upload_file_outlined,
                          label: _sendingProof
                              ? 'Enviando comprobante...'
                              : 'Subir archivo',
                          description: 'Selecciona una imagen o PDF desde tu dispositivo',
                          enabled: !_sendingProof,
                          onTap: _pickProofFile,
                        ),
                        if (_proofMessage != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            _proofMessage!,
                            style: TextStyle(
                              color: _proofMessage!.contains('Error')
                                  ? const Color(0xFFFF766C)
                                  : kPrimaryGreen,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                if (!_pendingManualReview)
                  PrimaryActionButton(
                    margin: EdgeInsets.zero,
                    label: 'Continuar con el pago',
                    onTap: () async {
                      _approvalFeedbackEnabled = true;
                      final payment = await widget.homeCubit
                          .generateSubscriptionPayment(context);
                      if (!context.mounted) return;

                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WebPaymentView(
                            paymentUrl: payment.url,
                            homeCubit: widget.homeCubit,
                            reference: payment.reference,
                            amountInCents: payment.amountInCents,
                            onSuccessfulPayment: () async {
                              await widget.homeCubit.updateUserSubscription();
                              if (!context.mounted) return;

                              context.pop();
                              await _handleApprovedSubscription();
                            },
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _takeProofPhoto(BuildContext context) async {
    await context.push(
      AppRoutes.loanCamera,
      extra: {
        'onFileSelected': (File file) => _submitProof(file),
        'isSelfie': false,
      },
    );
  }

  Future<void> _pickProofFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'heic'],
      withData: true,
    );
    if (result == null) return;
    final file = await _platformFileToFile(result.files.first);
    if (file != null) {
      await _submitProof(file, fileName: result.files.first.name);
    }
  }

  Future<void> _submitProof(File file, {String? fileName}) async {
    setState(() {
      _sendingProof = true;
      _proofMessage = null;
    });

    try {
      final proofUrl = await uploadPaymentProof(file, 'subscription');
      if (proofUrl.isEmpty) {
        throw Exception('upload_failed');
      }
      final user = sl<AuthCubit>(instanceName: 'auth').state.user;
      final transactionId = const Uuid().v4();
      final inferredName = fileName ?? file.path.split('/').last;
      final inferredExtension = inferredName.contains('.')
          ? inferredName.split('.').last
          : '';
      await widget.homeCubit.savePaymentRecord(
        transactionId: transactionId,
        reference:
            'manual_subscription_${user.phone}_${DateTime.now().millisecondsSinceEpoch}',
        status: 'PENDING_REVIEW',
        amountInCents: widget.homeCubit.state.subscriptionAmount * 100,
        wompiFee: 0,
        source: 'manual',
        paymentType: 'subscription',
        proofUrl: proofUrl,
        proofName: inferredName,
        proofContentType: inferredExtension,
      );
      if (!mounted) return;
      setState(() {
        _approvalFeedbackEnabled = true;
        _sendingProof = false;
        _manualProofSubmittedInSession = true;
        _pendingManualReview = true;
        _pendingSubmittedAt = DateTime.now();
        _pendingProofName = inferredName;
        _proofMessage =
            'Comprobante enviado. Activaremos tu suscripción cuando sea validado.';
      });
      _startSubscriptionRefreshTimer();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _sendingProof = false;
        _proofMessage = 'Error enviando el comprobante. Intenta de nuevo.';
      });
    }
  }

  static Future<File?> _platformFileToFile(PlatformFile pf) async {
    if (pf.path != null) return File(pf.path!);
    if (pf.bytes != null) {
      final dir = await getTemporaryDirectory();
      final tmp = File('${dir.path}/${pf.name}');
      await tmp.writeAsBytes(pf.bytes!);
      return tmp;
    }
    return null;
  }

  Future<void> _showSubscriptionApprovedModal() async {
    if (!mounted) return;
    final nextRoute = widget.afterSuccessRoute ?? AppRoutes.loanInformation;

    await ModalbottomsheetUtils.subscriptionApprovedSheet(
      context,
      selectedAmount: widget.homeCubit.state.totalLoanAmount,
      onContinueLoan: () {
        if (!mounted) return;
        context.go(nextRoute);
      },
      onGoHome: () {
        if (!mounted) return;
        context.go(AppRoutes.home);
      },
    );
  }

  void _continueWithoutModal() {
    if (!mounted) return;
    final nextRoute = widget.afterSuccessRoute ?? AppRoutes.loanInformation;

    if (widget.returnSuccessResult) {
      context.pop(true);
      return;
    }

    context.go(nextRoute);
  }

  Future<void> _handleApprovedSubscription() async {
    final authCubit = sl<AuthCubit>(instanceName: 'auth');
    _handledApproval = true;
    await authCubit.login(
      user: authCubit.state.user.copyWith(isSubscribed: true),
    );
    if (!mounted) return;

    setState(() {
      _pendingManualReview = false;
      _manualProofSubmittedInSession = false;
      _pendingSubmittedAt = null;
      _pendingProofName = '';
      _proofMessage = null;
    });
    _startSubscriptionRefreshTimer();

    if (!_approvalFeedbackEnabled) {
      _continueWithoutModal();
      return;
    }

    await _showSubscriptionApprovedModal();
  }

  void _watchSubscriptionApproval() {
    final authCubit = sl<AuthCubit>(instanceName: 'auth');
    final user = authCubit.state.user;
    final watched = <String>{};
    final paymentWatched = <String>{};

    if (user.id.isNotEmpty) {
      final sub = FirebaseFirestore.instance
          .collection('users')
          .doc(user.id)
          .snapshots()
          .listen((snapshot) async {
        if (_handledApproval || !snapshot.exists || !mounted) return;
        final data = snapshot.data();
        if (data == null || data['isSubscribed'] != true) return;
        await _handleApprovedSubscription();
      });

      _subscriptionWatchers.add(sub);
    }

    void attachWatcher(String field, String value) {
      final normalized = '$field::$value';
      if (value.isEmpty || watched.contains(normalized)) return;
      watched.add(normalized);

      final sub = FirebaseFirestore.instance
          .collection('users')
          .where(field, isEqualTo: value)
          .snapshots()
          .listen((snapshot) async {
        if (_handledApproval || snapshot.docs.isEmpty || !mounted) return;
        final isSubscribed =
            snapshot.docs.any((doc) => doc.data()['isSubscribed'] == true);
        if (!isSubscribed) return;
        await _handleApprovedSubscription();
      });

      _subscriptionWatchers.add(sub);
    }

    attachWatcher('phone', user.phone);
    attachWatcher('email', user.email);

    final fullPhone = '+57${user.phone}'.replaceAll(' ', '');
    if (fullPhone != user.phone) {
      attachWatcher('phone', fullPhone);
    }

    void attachPaymentWatcher(String field, String value) {
      final normalized = '$field::$value';
      if (value.isEmpty || paymentWatched.contains(normalized)) return;
      paymentWatched.add(normalized);

      final sub = FirebaseFirestore.instance
          .collection('payments')
          .where(field, isEqualTo: value)
          .snapshots()
          .listen((snapshot) async {
        if (!mounted || snapshot.docs.isEmpty) return;

        final relevant = snapshot.docs.where((doc) {
          final data = doc.data();
          return _isSubscriptionPayment(data) && data['source'] == 'manual';
        }).toList();
        if (relevant.isEmpty) return;

        relevant.sort((a, b) {
          final aStatus = (a.data()['status'] as String?) ?? '';
          final bStatus = (b.data()['status'] as String?) ?? '';
          final statusCompare = _manualSubscriptionStatusPriority(bStatus)
              .compareTo(_manualSubscriptionStatusPriority(aStatus));
          if (statusCompare != 0) return statusCompare;

          final aDate = (a.data()['created_at'] as Timestamp?)?.toDate() ??
              DateTime.fromMillisecondsSinceEpoch(0);
          final bDate = (b.data()['created_at'] as Timestamp?)?.toDate() ??
              DateTime.fromMillisecondsSinceEpoch(0);
          return bDate.compareTo(aDate);
        });

        final latest = relevant.first.data();
        final status = (latest['status'] as String?) ?? '';

        if (status == 'PENDING_REVIEW') {
          if (_manualProofSubmittedInSession && !_pendingManualReview) {
            setState(() {
              _pendingManualReview = true;
              _pendingSubmittedAt =
                  (latest['created_at'] as Timestamp?)?.toDate();
              _pendingProofName = (latest['proof_name'] as String?) ?? '';
            });
            _startSubscriptionRefreshTimer();
          }
          return;
        }

        if (status == 'DECLINED') {
          setState(() {
            _pendingManualReview = false;
            _manualProofSubmittedInSession = false;
            _pendingSubmittedAt = null;
            _pendingProofName = '';
            _proofMessage =
                'Tu comprobante fue rechazado. Puedes adjuntar uno nuevo o pagar por Wompi.';
          });
          _startSubscriptionRefreshTimer();
          return;
        }

        if (status != 'APPROVED' || _handledApproval) return;
        await _handleApprovedSubscription();
      });

      _subscriptionWatchers.add(sub);
    }

    attachPaymentWatcher('user_phone', user.phone);
    attachPaymentWatcher('user_email', user.email);
    if (fullPhone != user.phone) {
      attachPaymentWatcher('user_phone', fullPhone);
    }
  }

  void _startSubscriptionRefreshTimer() {
    _subscriptionRefreshTimer?.cancel();
    if (_handledApproval) return;
    _subscriptionRefreshTimer = Timer.periodic(
      const Duration(seconds: 4),
      (_) => _refreshSubscriptionState(),
    );
  }

  Future<void> _refreshSubscriptionState() async {
    if (!mounted || _handledApproval) return;

    final authCubit = sl<AuthCubit>(instanceName: 'auth');
    final user = authCubit.state.user;

    try {
      final refreshedUser = await _refreshCurrentUserFromFirestore();
      if (refreshedUser?.isSubscribed == true) {
        await _handleApprovedSubscription();
        return;
      }

      final latestPayment = await _getLatestManualSubscriptionPayment(
        user.phone,
        user.email,
      );
      final latestStatus = (latestPayment?['status'] as String?) ?? '';
      if (latestStatus == 'APPROVED') {
        await _handleApprovedSubscription();
        return;
      }

      if (latestStatus == 'DECLINED') {
        if (_manualProofSubmittedInSession) {
          setState(() {
            _pendingManualReview = false;
            _manualProofSubmittedInSession = false;
            _pendingSubmittedAt = null;
            _pendingProofName = '';
            _proofMessage =
                'Tu comprobante fue rechazado. Puedes adjuntar uno nuevo o pagar por Wompi.';
          });
        }
        _startSubscriptionRefreshTimer();
        return;
      }

      final isSubscribed =
          await _fetchSubscriptionStatus(user.phone, user.email);
      if (isSubscribed) {
        await _handleApprovedSubscription();
        return;
      }
    } catch (_) {}
  }

  Future<dynamic> _refreshCurrentUserFromFirestore() async {
    final authCubit = sl<AuthCubit>(instanceName: 'auth');
    final authUser = authCubit.state.user;
    if (authUser.id.isEmpty) return null;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(authUser.id)
        .get();

    if (!userDoc.exists) return null;

    final data = userDoc.data();
    if (data == null) return null;

    final refreshedUser = authUser.copyWith(
      name: (data['name'] as String?) ?? authUser.name,
      lastName: (data['lastName'] as String?) ?? authUser.lastName,
      email: (data['email'] as String?) ?? authUser.email,
      phone: (data['phone'] as String?) ?? authUser.phone,
      isSubscribed: data['isSubscribed'] == true,
      riskProfile: (data['riskProfile'] as String?) ?? authUser.riskProfile,
      maxLoanAmount:
          (data['maxLoanAmount'] as num?)?.toInt() ?? authUser.maxLoanAmount,
      isBlockedForNewLoans:
          data['isBlockedForNewLoans'] as bool? ?? authUser.isBlockedForNewLoans,
    );

    await authCubit.login(user: refreshedUser);
    return refreshedUser;
  }

  Future<bool> _fetchSubscriptionStatus(String phone, String email) async {
    final matched = <String, Map<String, dynamic>>{};
    final authUser = sl<AuthCubit>(instanceName: 'auth').state.user;
    if (authUser.id.isNotEmpty) {
      final directDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(authUser.id)
          .get();
      if (directDoc.exists) {
        matched[directDoc.id] = directDoc.data()!;
      }
    }
    final normalizedPhone = phone.replaceAll(' ', '');
    final fullPhone = '+57$normalizedPhone';
    final normalizedEmail = email.trim().toLowerCase();

    Future<void> addMatches(String field, String value) async {
      if (value.isEmpty) return;
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .where(field, isEqualTo: value)
          .get();
      for (final doc in snap.docs) {
        matched[doc.id] = doc.data();
      }
    }

    await addMatches('phone', phone);
    await addMatches('phone', normalizedPhone);
    await addMatches('phone', fullPhone);
    await addMatches('email', email);
    if (normalizedEmail != email) {
      await addMatches('email', normalizedEmail);
    }

    return matched.values.any((data) => data['isSubscribed'] == true);
  }

  bool _isSubscriptionPayment(Map<String, dynamic> data) {
    final type = (data['type'] as String?)?.toLowerCase() ?? '';
    final reference = (data['reference'] as String?)?.toLowerCase() ?? '';
    return type == 'subscription' || reference.contains('subscription');
  }

  int _manualSubscriptionStatusPriority(String status) {
    switch (status) {
      case 'APPROVED':
        return 3;
      case 'PENDING_REVIEW':
        return 2;
      case 'DECLINED':
        return 1;
      default:
        return 0;
    }
  }

  Future<Map<String, dynamic>?> _getLatestManualSubscriptionPayment(
    String phone,
    String email,
  ) async {
    final matches = <String, QueryDocumentSnapshot<Map<String, dynamic>>>{};
    final normalizedPhone = phone.replaceAll(' ', '');
    final fullPhone = '+57$normalizedPhone';
    final normalizedEmail = email.trim().toLowerCase();

    Future<void> collect(String field, String value) async {
      if (value.isEmpty) return;
      final snap = await FirebaseFirestore.instance
          .collection('payments')
          .where(field, isEqualTo: value)
          .get();
      for (final doc in snap.docs) {
        final data = doc.data();
        if (_isSubscriptionPayment(data) && data['source'] == 'manual') {
          matches[doc.id] = doc;
        }
      }
    }

    await collect('user_phone', phone);
    await collect('user_phone', normalizedPhone);
    await collect('user_phone', fullPhone);
    await collect('user_email', email);
    if (normalizedEmail != email) {
      await collect('user_email', normalizedEmail);
    }

    if (matches.isEmpty) return null;
    final docs = matches.values.toList()
      ..sort((a, b) {
        final aStatus = (a.data()['status'] as String?) ?? '';
        final bStatus = (b.data()['status'] as String?) ?? '';
        final statusCompare = _manualSubscriptionStatusPriority(bStatus)
            .compareTo(_manualSubscriptionStatusPriority(aStatus));
        if (statusCompare != 0) return statusCompare;

        final aDate = (a.data()['created_at'] as Timestamp?)?.toDate() ??
            DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = (b.data()['created_at'] as Timestamp?)?.toDate() ??
            DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });
    return docs.first.data();
  }
}

class _TransferInstructionsCard extends StatelessWidget {
  final HomeState state;

  const _TransferInstructionsCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final accountLine = [
      state.transferAccountType.trim(),
      state.transferAccountNumber.trim(),
    ].where((value) => value.isNotEmpty).join(' · ');
    final holderLine = [
      state.transferAccountHolder.trim(),
      state.transferAccountDocument.trim(),
    ].where((value) => value.isNotEmpty).join(' · ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kSurfaceSoft,
        borderRadius: BorderRadius.circular(kRadiusCard),
        border: Border.all(color: kBorderFaint),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Datos para transferencia',
            style: TextStyle(
              color: kTextPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Si prefieres transferir en vez de pagar por Wompi, usa estos datos y luego adjunta tu comprobante.',
            style: TextStyle(
              color: kTextSecondary,
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          _TransferDetailRow(
            label: 'Banco',
            value: state.transferBankName,
          ),
          if (accountLine.isNotEmpty) ...[
            const SizedBox(height: 8),
            _TransferDetailRow(
              label: 'Cuenta',
              value: accountLine,
            ),
          ],
          if (state.transferKey.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            _TransferDetailRow(
              label: 'Llave',
              value: state.transferKey,
            ),
          ],
          if (holderLine.isNotEmpty) ...[
            const SizedBox(height: 8),
            _TransferDetailRow(
              label: 'Titular',
              value: holderLine,
            ),
          ],
          if (state.transferNotes.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            _TransferDetailRow(
              label: 'Notas',
              value: state.transferNotes,
            ),
          ],
        ],
      ),
    );
  }
}

class _TransferDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _TransferDetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(
              color: kTextSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(
              color: kTextPrimary,
              fontSize: 13,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingSubscriptionReviewCard extends StatelessWidget {
  final DateTime? submittedAt;
  final String proofName;

  const _PendingSubscriptionReviewCard({
    required this.submittedAt,
    required this.proofName,
  });

  @override
  Widget build(BuildContext context) {
    final submittedLabel = submittedAt == null
        ? ''
        : DateFormat('d MMM yyyy', 'es_CO').format(submittedAt!);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kSurfaceSoft,
        borderRadius: BorderRadius.circular(kRadiusCard),
        border: Border.all(color: const Color(0x334EA8FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Suscripción en validación',
            style: TextStyle(
              color: kTextPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ya recibimos tu comprobante manual. Mientras lo validamos, no necesitas volver a pagar ni adjuntarlo otra vez.',
            style: TextStyle(
              color: kTextSecondary,
              fontSize: 13,
              height: 1.45,
            ),
          ),
          if (proofName.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Comprobante: $proofName',
              style: const TextStyle(
                color: kTextPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          if (submittedLabel.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Enviado el $submittedLabel',
              style: const TextStyle(
                color: kTextSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProofOptionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final bool enabled;
  final VoidCallback onTap;

  const _ProofOptionButton({
    required this.icon,
    required this.label,
    required this.description,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: enabled
              ? Colors.white.withValues(alpha: 0.07)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: enabled
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.white.withValues(alpha: 0.06),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: kPrimaryGreenSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: kPrimaryGreen, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: enabled
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.55),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
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
