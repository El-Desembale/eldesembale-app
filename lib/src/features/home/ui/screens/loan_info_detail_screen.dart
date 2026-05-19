import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../utils/colors.dart';
import '../../../../utils/utils.dart';
import '../../cubit/home_cubit.dart';
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
  int? _selectedUpTo; // number of installments selected (1-based from next unpaid)

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
            floatingActionButton: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: FloatingActionButton(
                shape: const CircleBorder(),
                backgroundColor: UIColors.primeraGrey.withOpacity(0.15),
                onPressed: () {
                  context.pop();
                },
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 35,
                ),
              ),
            ),
            body: _body(context, state),
          );
        });
  }

  Widget _body(BuildContext context, HomeState state) {
    final loan = state.loans[widget.loanIndex];
    final installmentAmount = Utils.getTotalAmount(
      loan.amount,
      loan.installments,
      loan.interest,
      loan.paymentPeriod,
    );
    final pendingCount = loan.installments - loan.installmentsPaid;
    final selected = _selectedUpTo ?? 0;
    final totalToPay = installmentAmount * selected;

    return Container(
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 6, 16, 0),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  const Text(
                    'Total Prestado',
                    style: TextStyle(
                      color: Color.fromARGB(255, 243, 248, 241),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    NumberFormat("#,##0", "en_US").format(loan.amount),
                    style: const TextStyle(
                      fontFamily: "Unbounded",
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),
                      Column(children: [
                        const Text("Periodo Pago",
                            style: TextStyle(color: Color.fromARGB(255, 243, 248, 241), fontSize: 12)),
                        Text(loan.paymentPeriod,
                            style: const TextStyle(color: Colors.white, fontSize: 18)),
                      ]),
                      const Spacer(),
                      Container(width: 2, height: 50, color: Colors.white.withOpacity(0.5)),
                      const Spacer(),
                      Column(children: [
                        const Text("Cuotas",
                            style: TextStyle(color: Color.fromARGB(255, 243, 248, 241), fontSize: 12)),
                        Text("${loan.installmentsPaid}/${loan.installments}",
                            style: const TextStyle(color: Colors.white, fontSize: 18)),
                      ]),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Fechas de Pago',
                    style: TextStyle(
                      fontFamily: "Unbounded",
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),

            // Installment list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                itemCount: loan.installments,
                itemBuilder: (context, index) {
                  final dueDate = Utils.calculateInstallmentDate(
                    installmentIndex: index,
                    paymentPeriod: loan.paymentPeriod,
                    baseDate: loan.createdAt.toDate(),
                  );
                  final isPaid = index < loan.installmentsPaid;
                  final isPending = !isPaid;
                  // Which pending index is this? (0 = first unpaid)
                  final pendingIndex = index - loan.installmentsPaid;
                  // Selected = pendingIndex < selected (i.e. 1..selected)
                  final isSelected = isPending && pendingIndex < selected;

                  return Column(
                    children: [
                      if (index != 0)
                        Container(height: 1, color: Colors.white.withOpacity(0.1)),
                      GestureDetector(
                        onTap: isPending && loan.canPay
                            ? () {
                                setState(() {
                                  // Toggle: tap same last selected = deselect, else extend to here
                                  final newSelected = pendingIndex + 1;
                                  _selectedUpTo = _selectedUpTo == newSelected ? 0 : newSelected;
                                });
                              }
                            : null,
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color.fromRGBO(47, 255, 0, 0.08)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              // Check/select indicator
                              Icon(
                                isPaid
                                    ? Icons.check_circle
                                    : isSelected
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_unchecked,
                                color: isPaid
                                    ? const Color.fromRGBO(47, 255, 0, 1)
                                    : isSelected
                                        ? const Color.fromRGBO(47, 255, 0, 0.8)
                                        : Colors.white.withOpacity(0.3),
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
                                            ? Colors.white.withOpacity(0.4)
                                            : Colors.white,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Text(
                                      DateFormat('d MMMM, yyyy', 'es').format(dueDate),
                                      style: TextStyle(
                                        color: isPaid
                                            ? Colors.white.withOpacity(0.3)
                                            : Colors.white.withOpacity(0.6),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                NumberFormat("#,##0", "en_US").format(installmentAmount),
                                style: TextStyle(
                                  color: isPaid
                                      ? Colors.white.withOpacity(0.3)
                                      : isSelected
                                          ? const Color.fromRGBO(47, 255, 0, 1)
                                          : Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
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
                      Text(
                        'Selecciona las cuotas que deseas pagar',
                        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                        textAlign: TextAlign.center,
                      )
                    else
                      Text(
                        '$selected cuota${selected > 1 ? 's' : ''} seleccionada${selected > 1 ? 's' : ''} · ${NumberFormat("#,##0", "en_US").format(totalToPay)}',
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: selected == 0
                          ? null
                          : () async {
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
                                    installmentNumber: loan.installmentsPaid + selected,
                                    onSuccessfulPayment: () async {
                                      final status = await widget.homeCubit.updateLoanInstallments(
                                        loan,
                                        installmentsToPay: selected,
                                      );
                                      if (status) {
                                        widget.homeCubit.updateLoan(widget.loanIndex, installmentsToPay: selected);
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
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 62,
                        decoration: BoxDecoration(
                          color: selected == 0
                              ? Colors.white.withOpacity(0.1)
                              : const Color.fromRGBO(47, 255, 0, 1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 25),
                              child: Text(
                                selected == 0
                                    ? 'Pagar cuota'
                                    : 'Pagar $selected cuota${selected > 1 ? 's' : ''}',
                                style: TextStyle(
                                  color: selected == 0 ? Colors.white.withOpacity(0.3) : Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: Container(
                                width: 62,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: selected == 0
                                      ? Colors.white.withOpacity(0.05)
                                      : Colors.white.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.check_circle_outline_sharp,
                                  color: selected == 0 ? Colors.white.withOpacity(0.2) : Colors.black,
                                  size: 30,
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
          ],
        ),
      ),
    );
  }
}
