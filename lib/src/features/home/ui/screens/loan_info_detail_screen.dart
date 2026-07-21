import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../config/routes/routes.dart';
import '../../../../utils/design_tokens.dart';
import '../../cubit/home_cubit.dart';
import '../../data/services/home_service.dart';
import '../../domain/loan_calc.dart';
import '../../../shared/widgets/back_circle_button.dart';
import '../../../shared/widgets/primary_action_button.dart';
import '../widgets/web_payment_view.dart';

class LoanInfoDetailScreen extends StatefulWidget {
  final int loanIndex;
  final HomeCubit homeCubit;
  const LoanInfoDetailScreen({
    super.key,
    required this.loanIndex,
    required this.homeCubit,
  });

  @override
  State<LoanInfoDetailScreen> createState() => _LoanInfoDetailScreenState();
}

class _LoanInfoDetailScreenState extends State<LoanInfoDetailScreen> {
  // Index of the last selected installment to pay (inclusive).
  // null = none selected. 0 = pay cuota installmentsPaid+1 only, etc.
  int?
      _selectedUpTo; // number of installments selected (1-based from next unpaid)
  bool _sendingProof = false;
  String? _proofMessage;

  @override
  void initState() {
    super.initState();
    widget.homeCubit.loadWompiConfig();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
        bloc: widget.homeCubit,
        builder: (BuildContext context, HomeState state) {
          return Scaffold(
            drawerEnableOpenDragGesture: false,
            extendBodyBehindAppBar: true,
            resizeToAvoidBottomInset: false,
            floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
            floatingActionButton: BackCircleButton(
              heroTag: 'loan_detail_back',
              onPressed: () {
                context.pop();
              },
            ),
            body: _body(context, state),
          );
        });
  }

  Widget _body(BuildContext context, HomeState state) {
    final loan = state.loans[widget.loanIndex];
    final hasTransferData = state.transferBankName.trim().isNotEmpty;
    final paidInstallments = loan.installmentsPaid.clamp(0, loan.installments);
    final remainingInstallments =
        (loan.installments - paidInstallments).clamp(0, loan.installments);
    final progress =
        loan.installments == 0 ? 0.0 : paidInstallments / loan.installments;
    final selected = _selectedUpTo ?? 0;
    // Modelo nuevo: se cobra el total_cliente del desglose persistido por cuota.
    final totalToPay =
        loan.sumInstallments(paidInstallments, selected).toDouble();

    return Container(
      decoration: const BoxDecoration(color: kBgScreen),
      child: SafeArea(
        child: Column(
          children: [
            // La cabecera y la lista de cuotas van en un scroll para que no
            // desborden cuando la sección de pago (transferencia + comprobante)
            // crece; el botón de pago queda fijo abajo.
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 22),
                            decoration: BoxDecoration(
                              color: kSurfaceSoft,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: kBorderFaint),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'Total Prestado',
                                  style: TextStyle(
                                    color: kTextSecondary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    NumberFormat("#,##0", "en_US")
                                        .format(loan.amount),
                                    style: const TextStyle(
                                      color: kTextPrimary,
                                      fontSize: 30,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (loan.status == 'rejected' &&
                              loan.rejectionReason.isNotEmpty) ...[
                            const SizedBox(height: 18),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: kDangerSoft.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: kDangerSoft.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Motivo del rechazo',
                                    style: TextStyle(
                                      color: Color(0xFFFF766C),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    loan.rejectionReason,
                                    style: const TextStyle(
                                      color: kTextPrimary,
                                      fontSize: 14,
                                      height: 1.45,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 18),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 14),
                            decoration: BoxDecoration(
                              color: kSurfaceSoft,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(color: kBorderFaint),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      const Text(
                                        "Periodo Pago",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: kTextSecondary,
                                            fontSize: 12),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        loan.paymentPeriod,
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: kTextPrimary,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                    width: 1, height: 54, color: kBorderFaint),
                                Expanded(
                                  child: Column(
                                    children: [
                                      const Text(
                                        "Cuotas",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: kTextSecondary,
                                            fontSize: 12),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "$paidInstallments/${loan.installments}",
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: kTextPrimary,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: kSurfaceSoft,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: kBorderFaint),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: kPrimaryGreenSoft,
                                        borderRadius:
                                            BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        'Pagadas $paidInstallments/${loan.installments}',
                                        style: const TextStyle(
                                          color: kPrimaryGreen,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      remainingInstallments == 0
                                          ? 'Crédito al día'
                                          : 'Te faltan $remainingInstallments',
                                      style: const TextStyle(
                                        color: kTextSecondary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(999),
                                  child: LinearProgressIndicator(
                                    value: progress.toDouble(),
                                    minHeight: 8,
                                    backgroundColor: kBorderFaint,
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                      kPrimaryGreenMuted,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Desglose del crédito (vista cliente: Wompi absorbido en Plataforma)
                          if (loan.pricing != null) ...[
                            const SizedBox(height: 14),
                            _DesgloseCard(pricing: loan.pricing!),
                          ],
                          const SizedBox(height: 20),
                          const Text(
                            'Fechas de Pago',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: kTextPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),

                    // Installment list
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: loan.installments,
                      itemBuilder: (context, index) {
                        // El cronograma siempre parte del desembolso real.
                        final dueDate = installmentDueDate(
                          loan.disbursedAt?.toDate() ?? loan.createdAt.toDate(),
                          index,
                          loan.paymentPeriod,
                        );
                        final cuotaMonto = loan.cuotaAmount(index);
                        final isPaid = index < loan.installmentsPaid;
                        final isPending = !isPaid;
                        // Which pending index is this? (0 = first unpaid)
                        final pendingIndex = index - loan.installmentsPaid;
                        // Selected = pendingIndex < selected (i.e. 1..selected)
                        final isSelected = isPending && pendingIndex < selected;

                        return Column(
                          children: [
                            if (index != 0)
                              Container(height: 1, color: kBorderFaint),
                            GestureDetector(
                              onTap: isPending && loan.canPay
                                  ? () {
                                      setState(() {
                                        // Toggle: tap same last selected = deselect, else extend to here
                                        final newSelected = pendingIndex + 1;
                                        _selectedUpTo =
                                            _selectedUpTo == newSelected
                                                ? 0
                                                : newSelected;
                                      });
                                    }
                                  : null,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? kPrimaryGreenSoft
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      isPaid
                                          ? Icons.check_circle
                                          : isSelected
                                              ? Icons.radio_button_checked
                                              : Icons.radio_button_unchecked,
                                      color: isPaid
                                          ? kPrimaryGreen
                                          : isSelected
                                              ? kPrimaryGreenMuted
                                              : kTextSecondary,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Cuota ${index + 1}',
                                            style: TextStyle(
                                              color: isPaid
                                                  ? Colors.white
                                                      .withValues(alpha: 0.4)
                                                  : kTextPrimary,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            DateFormat('d MMMM, yyyy', 'es')
                                                .format(dueDate),
                                            style: TextStyle(
                                              color: isPaid
                                                  ? Colors.white
                                                      .withValues(alpha: 0.3)
                                                  : kTextSecondary,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Flexible(
                                      child: Text(
                                        NumberFormat("#,##0", "en_US")
                                            .format(cuotaMonto),
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          color: isPaid
                                              ? Colors.white
                                                  .withValues(alpha: 0.3)
                                              : isSelected
                                                  ? kPrimaryGreen
                                                  : kTextPrimary,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Pay button
            if (loan.canPay)
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 12, 30, 20),
                child: Column(
                  children: [
                    if (_proofMessage != null) ...[
                      Text(
                        _proofMessage!,
                        style: TextStyle(
                          color: _proofMessage!.contains('Error')
                              ? const Color(0xFFFF766C)
                              : kPrimaryGreen,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                    ],
                    if (selected == 0)
                      const Text(
                        'Selecciona las cuotas que deseas pagar',
                        style: TextStyle(color: kTextSecondary, fontSize: 13),
                        textAlign: TextAlign.center,
                      )
                    else
                      Text(
                        '$selected cuota${selected > 1 ? 's' : ''} seleccionada${selected > 1 ? 's' : ''} · ${NumberFormat("#,##0", "en_US").format(totalToPay)}',
                        style:
                            const TextStyle(color: kTextPrimary, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    const SizedBox(height: 10),
                    if (hasTransferData) ...[
                      _TransferInstructionsCard(state: state),
                      const SizedBox(height: 10),
                    ],
                    PrimaryActionButton(
                      label: selected == 0
                          ? 'Pagar cuota'
                          : 'Pagar $selected cuota${selected > 1 ? 's' : ''}',
                      icon: Icons.check_circle_outline_sharp,
                      enabled: selected > 0,
                      margin: EdgeInsets.zero,
                      onTap: () async {
                        // Comisión Wompi exacta de las cuotas seleccionadas (desde el
                        // desglose persistido); null para créditos legacy → se estima.
                        int? selectedWompiFee;
                        if (loan.pricing != null) {
                          var fee = 0;
                          for (var i = loan.installmentsPaid;
                              i < loan.installmentsPaid + selected &&
                                  i < loan.pricing!.installments.length;
                              i++) {
                            fee += loan.pricing!.installments[i].comisionWompi;
                          }
                          selectedWompiFee = fee;
                        }
                        final payment = await widget.homeCubit.generatePayment(
                          context,
                          totalToPay.truncate(),
                        );
                        if (!context.mounted) return;
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WebPaymentView(
                              paymentUrl: payment.url,
                              homeCubit: widget.homeCubit,
                              reference: payment.reference,
                              amountInCents: payment.amountInCents,
                              wompiFee: selectedWompiFee,
                              loanId: loan.id,
                              installmentNumber:
                                  loan.installmentsPaid + selected,
                              installmentsToPay: selected,
                              onSuccessfulPayment: () async {
                                final status = await widget.homeCubit
                                    .updateLoanInstallments(
                                  loan,
                                  installmentsToPay: selected,
                                );
                                if (status) {
                                  widget.homeCubit.updateLoan(
                                    widget.loanIndex,
                                    installmentsToPay: selected,
                                  );
                                }
                                setState(() => _selectedUpTo = 0);
                                if (context.mounted) {
                                  context.pop();
                                  context.pop();
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Adjunta el comprobante con una de estas opciones',
                      style: TextStyle(
                        color: kTextSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    _ProofOptionButton(
                      icon: Icons.camera_alt_outlined,
                      label: 'Tomar foto',
                      description:
                          'Usa la cámara para fotografiar el comprobante',
                      enabled: selected > 0 && !_sendingProof,
                      onTap: () => _takeProofPhoto(
                        context,
                        loan,
                        selected,
                        totalToPay.truncate(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _ProofOptionButton(
                      icon: Icons.upload_file_outlined,
                      label: _sendingProof
                          ? 'Enviando comprobante...'
                          : 'Subir archivo',
                      description:
                          'Selecciona una imagen o PDF desde tu dispositivo',
                      enabled: selected > 0 && !_sendingProof,
                      onTap: () => _pickProofFile(
                        loan,
                        selected,
                        totalToPay.truncate(),
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

  Future<void> _takeProofPhoto(
    BuildContext context,
    dynamic loan,
    int selectedInstallments,
    int totalToPay,
  ) async {
    await context.push(
      AppRoutes.loanCamera,
      extra: {
        'onFileSelected': (File file) => _submitProof(
              loan,
              selectedInstallments,
              totalToPay,
              file,
            ),
        'isSelfie': false,
      },
    );
  }

  Future<void> _pickProofFile(
    dynamic loan,
    int selectedInstallments,
    int totalToPay,
  ) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'heic'],
      withData: true,
    );
    if (result == null) return;
    final file = await _platformFileToFile(result.files.first);
    if (file != null) {
      await _submitProof(
        loan,
        selectedInstallments,
        totalToPay,
        file,
        fileName: result.files.first.name,
      );
    }
  }

  Future<void> _submitProof(
    dynamic loan,
    int selectedInstallments,
    int totalToPay,
    File file, {
    String? fileName,
  }) async {
    setState(() {
      _sendingProof = true;
      _proofMessage = null;
    });

    try {
      final proofUrl = await uploadPaymentProof(file, 'installment');
      if (proofUrl.isEmpty) {
        throw Exception('upload_failed');
      }
      final inferredName = fileName ?? file.path.split('/').last;
      final inferredExtension =
          inferredName.contains('.') ? inferredName.split('.').last : '';
      await widget.homeCubit.savePaymentRecord(
        transactionId: '${loan.id}_${DateTime.now().millisecondsSinceEpoch}',
        reference:
            'manual_payment_${loan.id}_${DateTime.now().millisecondsSinceEpoch}',
        status: 'PENDING_REVIEW',
        amountInCents: totalToPay * 100,
        wompiFee: 0,
        source: 'manual',
        loanId: loan.id,
        installmentNumber: loan.installmentsPaid + selectedInstallments,
        installmentsToPay: selectedInstallments,
        proofUrl: proofUrl,
        proofName: inferredName,
        proofContentType: inferredExtension,
      );
      if (!mounted) return;
      setState(() {
        _sendingProof = false;
        _proofMessage =
            'Comprobante enviado. El admin actualizará tus cuotas cuando lo valide.';
        _selectedUpTo = 0;
      });
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kSurfaceSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kBorderFaint),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Transferencia manual',
            style: TextStyle(
              color: kTextPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Si vas a transferir en vez de Wompi, usa esta cuenta y luego adjunta el comprobante.',
            style: TextStyle(
              color: kTextSecondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          _TransferDetailRow(
            label: 'Banco',
            value: state.transferBankName,
          ),
          if (accountLine.isNotEmpty) ...[
            const SizedBox(height: 6),
            _TransferDetailRow(label: 'Cuenta', value: accountLine),
          ],
          if (state.transferKey.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            _TransferDetailRow(label: 'Llave', value: state.transferKey),
          ],
          if (holderLine.isNotEmpty) ...[
            const SizedBox(height: 6),
            _TransferDetailRow(label: 'Titular', value: holderLine),
          ],
          if (state.transferNotes.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            _TransferDetailRow(label: 'Notas', value: state.transferNotes),
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
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(
              color: kTextPrimary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
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

/// Desglose del crédito para el cliente: Capital e Intereses como un único concepto
/// (incluye plataforma, administrativo y procesamiento del pago de forma transparente).
/// El detalle discriminado es exclusivo del admin.
class _DesgloseCard extends StatelessWidget {
  final LoanPricing pricing;
  const _DesgloseCard({required this.pricing});

  @override
  Widget build(BuildContext context) {
    final f = NumberFormat("#,##0", "en_US");
    final interesesCliente = pricing.totalCliente - pricing.capital;
    Widget row(String label, int value, {bool strong = false}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: strong ? kTextPrimary : kTextSecondary,
                fontSize: strong ? 14 : 13,
                fontWeight: strong ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            Text(
              '\$${f.format(value)}',
              style: TextStyle(
                color: strong ? kPrimaryGreen : kTextPrimary,
                fontSize: strong ? 15 : 13,
                fontWeight: strong ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: kSurfaceSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorderFaint),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Desglose del crédito',
            style: TextStyle(
              color: kTextSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          row('Capital', pricing.capital),
          row('Intereses *', interesesCliente),
          const SizedBox(height: 8),
          Container(height: 1, color: kBorderFaint),
          const SizedBox(height: 8),
          row('Total a pagar', pricing.totalCliente, strong: true),
          const SizedBox(height: 8),
          const Text(
            '* Incluye el costo total del servicio de crédito.',
            style: TextStyle(color: kTextSecondary, fontSize: 10, height: 1.4),
          ),
        ],
      ),
    );
  }
}
