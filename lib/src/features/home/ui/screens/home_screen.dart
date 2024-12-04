import 'package:desembale/src/config/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../utils/colors.dart';
import '../../cubit/home_cubit.dart';
import '../widgets/drawer.dart';

class HomeScreen extends StatefulWidget {
  final HomeCubit homeCubit;
  const HomeScreen({
    super.key,
    required this.homeCubit,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  initState() {
    widget.homeCubit.getLimits();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      bloc: widget.homeCubit,
      builder: (BuildContext context, HomeState state) {
        return Scaffold(
          key: _scaffoldKey,
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
                _scaffoldKey.currentState?.openDrawer();
              },
              child: const Icon(
                Icons.menu,
                color: Colors.white,
                size: 35,
              ),
            ),
          ),
          drawer: const DrawerWidget(),
          body: Stack(
            children: [
              _body(context, state),
            ],
          ),
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
        child: state.isLoading
            ? SizedBox(
                height: MediaQuery.sizeOf(context).height,
                width: MediaQuery.sizeOf(context).width,
                child: const Center(
                  child: SizedBox(
                    height: 50,
                    width: 50,
                    child: CircularProgressIndicator(
                      color: Colors.grey,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  const Text(
                    '¿Cuánto necesitas?',
                    style: TextStyle(
                      fontFamily: "Unbounded",
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  GestureDetector(
                    onHorizontalDragUpdate: (details) {
                      widget.homeCubit.updateSegmentFromPosition(
                        context,
                        details.localPosition.dx,
                      );
                    },
                    onTapDown: (details) {
                      widget.homeCubit.updateSegmentFromPosition(
                        context,
                        details.localPosition.dx,
                      );
                    },
                    child: SizedBox(
                      height: 70,
                      child: Row(
                        children: List.generate(
                          50,
                          (index) {
                            bool isSelected =
                                index <= state.limits.selectedSegment;
                            bool isLastSelected =
                                index == state.limits.selectedSegment;
                            bool isNearLimit =
                                index == state.limits.selectedSegment - 1 ||
                                    index == state.limits.selectedSegment - 2;
                            return Expanded(
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 2),
                                color: isLastSelected
                                    ? UIColors.primeraGrey
                                    : isSelected
                                        ? (isNearLimit
                                            ? UIColors.primeraGrey
                                                .withOpacity(0.4)
                                            : UIColors.primeraGrey
                                                .withOpacity(0.2))
                                        : UIColors.primeraGrey
                                            .withOpacity(0.05),
                                height: index == state.limits.selectedSegment
                                    ? 90
                                    : 60,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    NumberFormat("#,##0", "en_US")
                        .format(state.totalLoanAmount),
                    style: const TextStyle(
                      fontFamily: "Unbounded",
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Periodo de Pago',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      widget.homeCubit.updatePaymentPeriod('Quincenal');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 25,
                      ),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 21, 28, 16),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: state.paymentPeriod == 'Quincenal'
                              ? Colors.white
                              : Colors.transparent,
                        ),
                      ),
                      child: Center(
                        child: Row(
                          children: [
                            const Text(
                              'Quincenal',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            state.paymentPeriod == 'Quincenal'
                                ? const Icon(
                                    Icons.check_circle_outline_rounded,
                                    color: Colors.white,
                                    size: 30,
                                  )
                                : const SizedBox(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      widget.homeCubit.updatePaymentPeriod('Mensual');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 25,
                      ),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 21, 28, 16),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: state.paymentPeriod == 'Mensual'
                              ? Colors.white
                              : Colors.transparent,
                        ),
                      ),
                      child: Center(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Mensual',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            state.paymentPeriod == 'Mensual'
                                ? const Icon(
                                    Icons.check_circle_outline_rounded,
                                    color: Colors.white,
                                    size: 30,
                                  )
                                : const SizedBox(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Número de Cuotas',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children:
                          List.generate(state.limits.maxInstallments, (index) {
                        int number = index + 1;
                        return GestureDetector(
                          onTap: () {
                            widget.homeCubit.updateInstallments(number);
                          },
                          child: Container(
                            height: 70,
                            width: 40,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                            ),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: state.selectedInstallments == number
                                  ? Colors.white
                                  : const Color.fromARGB(255, 21, 28, 16),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Text(
                              '$number',
                              style: TextStyle(
                                color: state.selectedInstallments == number
                                    ? const Color.fromARGB(255, 21, 28, 16)
                                    : Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 30),
                  GestureDetector(
                    onTap: () {
                      context.push(AppRoutes.loanInformation);
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
                              'Continuar con solicitud',
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
}
