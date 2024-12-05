import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../utils/colors.dart';
import '../../cubit/home_cubit.dart';
import '../widgets/web_payment_view.dart';

class SubscriptionScreen extends StatelessWidget {
  final HomeCubit homeCubit;
  const SubscriptionScreen({
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
            const Spacer(flex: 2),
            const Text(
              'Suscribirse',
              style: TextStyle(
                fontFamily: "Unbounded",
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            const Text(
              'Suscríbete hoy y descubre cómo acceder a los fondos que necesitas de manera rápida, sencilla y sin complicaciones. ',
              textAlign: TextAlign.justify,
              style: TextStyle(
                color: Color.fromARGB(255, 243, 248, 241),
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: MediaQuery.sizeOf(context).width * 0.9,
              child: const Text(
                '• Préstamos fáciles de obtener\n• Sin requisitos complejos\n• Aprobación rápida y sencilla\n• Transparencia total\n• Seguridad y confianza\n• Soporte disponible\n',
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontFamily: "Unbounded",
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Spacer(flex: 5),
            Text(
              'Suscríbete por',
              style: TextStyle(
                fontFamily: "Unbounded",
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              '19,000',
              style: TextStyle(
                fontFamily: "Unbounded",
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 25),
            GestureDetector(
              onTap: () async {
                final url =
                    await homeCubit.generateSubscriptionPayment(context);
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WebPaymentView(
                      paymentUrl: url,
                      homeCubit: homeCubit,
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
                        'Suscribirme',
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
            const SizedBox(height: 30),
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
