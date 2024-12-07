import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../utils/colors.dart';
import '../../cubit/home_cubit.dart';
import '../widgets/web_payment_view.dart';

class LoanInfoDetailScreen extends StatelessWidget {
  final int loanIndex;
  final HomeCubit homeCubit;
  const LoanInfoDetailScreen({
    super.key,
    required this.loanIndex,
    required this.homeCubit,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
        bloc: homeCubit,
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
    final totalAmount = getTotalAmount(
      state.loans[loanIndex].amount,
      state.loans[loanIndex].installments,
      state.loans[loanIndex].interest,
      state.loans[loanIndex].paymentPeriod,
    );
    return Container(
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 6, 16, 0),
      ),
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 30,
          right: 30,
        ),
        height: MediaQuery.sizeOf(context).height,
        width: MediaQuery.sizeOf(context).width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            const Text(
              'Total Prestado',
              style: TextStyle(
                color: Color.fromARGB(255, 243, 248, 241),
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 0),
            Text(
              NumberFormat("#,##0", "en_US")
                  .format(state.loans[loanIndex].amount),
              style: const TextStyle(
                fontFamily: "Unbounded",
                color: Colors.white,
                fontSize: 45,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Column(
                  children: [
                    const Text(
                      "Periodo Pago",
                      style: TextStyle(
                        color: Color.fromARGB(255, 243, 248, 241),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      state.loans[loanIndex].paymentPeriod,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  width: 2,
                  height: 60,
                  color: Colors.white.withOpacity(0.5),
                ),
                const Spacer(),
                Column(
                  children: [
                    const Text(
                      "Número Cuotas",
                      style: TextStyle(
                        color: Color.fromARGB(255, 243, 248, 241),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      "${state.loans[loanIndex].installments} Coutas",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              'Fechas de Pago',
              style: TextStyle(
                fontFamily: "Unbounded",
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.45,
              child: SingleChildScrollView(
                child: Column(
                  children: List.generate(state.loans[loanIndex].installments,
                      (index) {
                    DateTime date = DateTime.now();
                    if (state.loans[loanIndex].paymentPeriod == 'Mensual') {
                      date =
                          DateTime.now().add(Duration(days: 30 * (index + 1)));
                    } else {
                      date =
                          DateTime.now().add(Duration(days: 15 * (index + 1)));
                    }

                    return Column(
                      children: [
                        if (index != 0)
                          Container(
                            height: 1,
                            color: Colors.white.withOpacity(0.15),
                          ),
                        SizedBox(
                          height: 60,
                          child: Row(
                            children: [
                              Text(
                                DateFormat('d MMMM, yyyy', 'es').format(date),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                NumberFormat("#,##0", "en_US").format(
                                  totalAmount,
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Icon(
                                Icons.check_circle_outline,
                                color:
                                    state.loans[loanIndex].installmentsPaid >=
                                            index
                                        ? const Color.fromRGBO(47, 255, 0, 1)
                                        : Colors.white.withOpacity(0.5),
                                size: 30,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () async {
                final url = await homeCubit.generatePayment(
                    context, totalAmount.truncate());

                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WebPaymentView(
                      paymentUrl: url,
                      onSuccessfulPayment: () async {
                        final status = await homeCubit.updateLoanInstallments(
                          state.loans[loanIndex],
                        );
                        if (status) {
                          homeCubit.updateLoan(loanIndex);
                        }
                        context.pop();
                        context.pop();
                      },
                    ),
                  ),
                );
              },
              child: Container(
                height: 62,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(47, 255, 0, 1),
                  borderRadius: BorderRadius.circular(48),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 25),
                      child: Text(
                        'Pagar Couta',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Container(
                        width: 62,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(255, 255, 255, 0.5),
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: const Icon(
                          Icons.check_circle_outline_sharp,
                          color: Colors.black,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  double getTotalAmount(
    double totalLoan,
    int selectedInstallments,
    double interest,
    paymentPeriod,
  ) {
    double loanInterest = 0.0;
    if (paymentPeriod == "Mensual") {
      loanInterest = totalLoan * (interest / 100);
    } else {
      loanInterest = totalLoan * ((interest / 2) / 100);
    }
    final double capital = totalLoan / selectedInstallments;
    return loanInterest + capital;
  }
}
