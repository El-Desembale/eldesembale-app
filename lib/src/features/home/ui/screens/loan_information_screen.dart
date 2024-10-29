import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../config/routes/routes.dart';
import '../../../../utils/colors.dart';
import '../../cubit/home_cubit.dart';

class LoanInformationScreen extends StatelessWidget {
  final HomeCubit homeCubit;
  const LoanInformationScreen({
    super.key,
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
      },
    );
  }

  Widget _body(BuildContext context, HomeState state) {
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
              'Detalles del Préstamo',
              style: TextStyle(
                fontFamily: "Unbounded",
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            const Text(
              'Total Prestado',
              style: TextStyle(
                color: Color.fromARGB(255, 243, 248, 241),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              NumberFormat("#,##0", "en_US").format(state.totalLoanAmount),
              style: const TextStyle(
                fontFamily: "Unbounded",
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
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
                      state.paymentPeriod,
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
                  height: 80,
                  color: Colors.white,
                ),
                const Spacer(),
                Column(
                  children: [
                    const Text(
                      "Número Cuotas",
                      style: TextStyle(
                        color: const Color.fromARGB(255, 243, 248, 241),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      "${state.selectedInstallments}",
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
            const SizedBox(height: 20),
            const Text(
              'Fechas de Pago',
              style: TextStyle(
                fontFamily: "Unbounded",
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.3,
              child: SingleChildScrollView(
                child: Column(
                  children: List.generate(state.selectedInstallments, (index) {
                    DateTime date = DateTime.now();
                    if (state.paymentPeriod == 'Mensual') {
                      date =
                          DateTime.now().add(Duration(days: 30 * (index + 1)));
                    } else {
                      date =
                          DateTime.now().add(Duration(days: 15 * (index + 1)));
                    }

                    return SizedBox(
                      height: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('d MMMM, yyyy', 'es').format(date),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            NumberFormat("#,##0", "en_US").format(
                              getTotalAmount(
                                state.totalLoanAmount,
                                state.selectedInstallments,
                                state.limits.interest,
                                state.paymentPeriod,
                              ),
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                context.push(AppRoutes.loanDataCollect);
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
                        'Hacer la solicitud',
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
                          Icons.arrow_forward,
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
