import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../utils/design_tokens.dart';
import '../../../../utils/utils.dart';
import '../../cubit/home_cubit.dart';
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
    final paidInstallments = loan.installmentsPaid.clamp(0, loan.installments);
    final remainingInstallments =
        (loan.installments - paidInstallments).clamp(0, loan.installments);
    final progress =
        loan.installments == 0 ? 0.0 : paidInstallments / loan.installments;
    final selected = _selectedUpTo ?? 0;
    // Modelo nuevo: se cobra el total_cliente del desglose persistido por cuota.
    final totalToPay = loan.sumInstallments(paidInstallments, selected).toDouble();

    return Container(
      decoration: const BoxDecoration(color: kBgScreen),
      child: SafeArea(
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
                            NumberFormat("#,##0", "en_US").format(loan.amount),
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
                                    color: kTextSecondary, fontSize: 12),
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
                        Container(width: 1, height: 54, color: kBorderFaint),
                        Expanded(
                          child: Column(
                            children: [
                              const Text(
                                "Cuotas",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: kTextSecondary, fontSize: 12),
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
                                borderRadius: BorderRadius.circular(999),
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
                            valueColor: const AlwaysStoppedAnimation<Color>(
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
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: loan.installments,
                itemBuilder: (context, index) {
                  // Fecha y monto desde el desglose persistido (si existe); si no, legacy.
                  final cuota = (loan.pricing != null &&
                          index < loan.pricing!.installments.length)
                      ? loan.pricing!.installments[index]
                      : null;
                  final dueDate = cuota?.fechaVencimiento ??
                      Utils.calculateInstallmentDate(
                        installmentIndex: index,
                        paymentPeriod: loan.paymentPeriod,
                        baseDate: loan.createdAt.toDate(),
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
                      if (index != 0) Container(height: 1, color: kBorderFaint),
                      GestureDetector(
                        onTap: isPending && loan.canPay
                            ? () {
                                setState(() {
                                  // Toggle: tap same last selected = deselect, else extend to here
                                  final newSelected = pendingIndex + 1;
                                  _selectedUpTo = _selectedUpTo == newSelected
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                        ? Colors.white.withValues(alpha: 0.3)
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
            ),

            // Pay button
            if (loan.canPay)
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 12, 30, 20),
                child: Column(
                  children: [
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
                    PrimaryActionButton(
                      label: selected == 0
                          ? 'Pagar cuota'
                          : 'Pagar $selected cuota${selected > 1 ? 's' : ''}',
                      icon: Icons.check_circle_outline_sharp,
                      enabled: selected > 0,
                      margin: EdgeInsets.zero,
                      onTap: () async {
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
                              loanId: loan.id,
                              installmentNumber:
                                  loan.installmentsPaid + selected,
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
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Desglose del crédito para el cliente: Capital, Interés, Plataforma (Wompi absorbido),
/// Administrativo y Total. No muestra Wompi como concepto independiente.
class _DesgloseCard extends StatelessWidget {
  final LoanPricing pricing;
  const _DesgloseCard({required this.pricing});

  @override
  Widget build(BuildContext context) {
    final f = NumberFormat("#,##0", "en_US");
    final plataformaCliente = pricing.plataformaTotal + pricing.wompiTotal;
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
          row('Interés', pricing.interesTotal),
          row('Plataforma *', plataformaCliente),
          row('Administrativo', pricing.administrativoTotal),
          const SizedBox(height: 8),
          Container(height: 1, color: kBorderFaint),
          const SizedBox(height: 8),
          row('Total a pagar', pricing.totalCliente, strong: true),
          const SizedBox(height: 8),
          const Text(
            '* Incluye gastos de plataforma y el costo de procesamiento del pago.',
            style: TextStyle(color: kTextSecondary, fontSize: 10, height: 1.4),
          ),
        ],
      ),
    );
  }
}
