import 'package:desembale/src/config/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final TextEditingController _amountController = TextEditingController();

  @override
  initState() {
    widget.homeCubit.getLimits();
    _amountController.text = NumberFormat('#,##0', 'en_US')
        .format(widget.homeCubit.state.totalLoanAmount.toInt());
    super.initState();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _syncController(double amount) {
    final formatted = NumberFormat('#,##0', 'en_US').format(amount.toInt());
    if (_amountController.text != formatted) {
      _amountController.text = formatted;
    }
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
    final minInstallments = state.limits.minInstallments;
    final maxInstallments = state.limits.maxInstallments;
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
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: MediaQuery.of(context).padding.top + 72),
                  const Text(
                    '¿Cuánto necesitas?',
                    style: TextStyle(
                      fontFamily: "Unbounded",
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Input manual de monto
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '\$',
                          style: TextStyle(
                            fontFamily: 'Unbounded',
                            color: Colors.white.withOpacity(0.35),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              _AmountInputFormatter(
                                  max: state.limits.maxAmmount),
                            ],
                            style: const TextStyle(
                              fontFamily: 'Unbounded',
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: (value) {
                              final raw = value.replaceAll(',', '');
                              final amount = double.tryParse(raw) ??
                                  state.limits.minAmmount.toDouble();
                              widget.homeCubit.updateAmountDirectly(amount);
                            },
                          ),
                        ),
                        Text(
                          'COP',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.3),
                            fontSize: 11,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Slider de monto
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: const Color.fromRGBO(47, 255, 0, 1),
                      inactiveTrackColor: Colors.white.withOpacity(0.1),
                      thumbColor: Colors.white,
                      overlayColor:
                          const Color.fromRGBO(47, 255, 0, 0.15),
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 10),
                    ),
                    child: Slider(
                      value: state.totalLoanAmount.clamp(
                        state.limits.minAmmount.toDouble(),
                        state.limits.maxAmmount.toDouble(),
                      ),
                      min: state.limits.minAmmount.toDouble(),
                      max: state.limits.maxAmmount.toDouble(),
                      divisions: ((state.limits.maxAmmount -
                                  state.limits.minAmmount) /
                              10000)
                          .toInt(),
                      onChanged: (value) {
                        final snapped =
                            ((value / 10000).round() * 10000).toDouble();
                        widget.homeCubit.updateAmountDirectly(snapped);
                        _syncController(snapped);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          NumberFormat('#,##0', 'en_US')
                              .format(state.limits.minAmmount),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.35),
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          NumberFormat('#,##0', 'en_US')
                              .format(state.limits.maxAmmount),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.35),
                            fontSize: 11,
                          ),
                        ),
                      ],
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
                      children: List.generate(
                        maxInstallments - minInstallments + 1,
                        (index) {
                          int number = minInstallments + index;
                          return GestureDetector(
                            onTap: () {
                              widget.homeCubit.updateInstallments(number);
                            },
                            child: Container(
                              height: 70,
                              width: 40,
                              margin: const EdgeInsets.symmetric(horizontal: 5),
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
                        },
                      ),
                    ),
                  ),
                  const Spacer(),
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

class _AmountInputFormatter extends TextInputFormatter {
  final int max;
  _AmountInputFormatter({required this.max});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final raw = newValue.text.replaceAll(',', '');
    if (raw.isEmpty) return newValue.copyWith(text: '');
    final value = int.tryParse(raw);
    if (value == null) return oldValue;
    final clamped = value.clamp(0, max);
    final formatted = NumberFormat('#,##0', 'en_US').format(clamped);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
