import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:desembale/src/config/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../config/auth/cubit/auth_cubit.dart';
import '../../../../core/di/injection_dependency.dart';
import '../../../../utils/design_tokens.dart';
import '../../cubit/home_cubit.dart';
import '../../data/entities/loan_request_entity.dart';
import '../../../shared/widgets/primary_action_button.dart';
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

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _amountController = TextEditingController();

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshData();
    _amountController.text = NumberFormat('#,##0', 'en_US')
        .format(widget.homeCubit.state.totalLoanAmount.toInt());
  }

  void _refreshData() {
    widget.homeCubit.getLimits();
    widget.homeCubit.getLoans();
    widget.homeCubit.loadReusableLoanInformation();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshData();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
              heroTag: 'home_fab',
              elevation: 0,
              shape: const CircleBorder(),
              backgroundColor: kSurfaceSoft,
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
              child: const Icon(
                Icons.menu,
                color: kTextPrimary,
                size: 30,
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
        color: kBgScreen,
      ),
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
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
                      color: kPrimaryGreen,
                      backgroundColor: kSurfaceSoft,
                    ),
                  ),
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                              height: MediaQuery.of(context).padding.top + 90),
                          const Text(
                            '¿Cuánto necesitas?',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: kDisplayFont,
                              color: kTextPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            decoration: BoxDecoration(
                              color: kSurfaceSoft,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: kBorderFaint,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  '\$',
                                  style: TextStyle(
                                    fontFamily: kDisplayFont,
                                    color: kTextSecondary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
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
                                      fontFamily: kDisplayFont,
                                      color: kTextPrimary,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
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
                                      widget.homeCubit
                                          .updateAmountDirectly(amount);
                                    },
                                  ),
                                ),
                                const Text(
                                  'COP',
                                  style: TextStyle(
                                    color: kTextSecondary,
                                    fontSize: 11,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          SliderTheme(
                            data: SliderThemeData(
                              activeTrackColor: kPrimaryGreen,
                              inactiveTrackColor: kSurfaceSoft,
                              thumbColor: kPrimaryGreen,
                              overlayColor: kPrimaryGreenSoft,
                              trackHeight: 5,
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
                                    ((value / 10000).round() * 10000)
                                        .toDouble();
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
                                  style: const TextStyle(
                                    color: kTextSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                                Text(
                                  NumberFormat('#,##0', 'en_US')
                                      .format(state.limits.maxAmmount),
                                  style: const TextStyle(
                                    color: kTextSecondary,
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
                              fontFamily: kDisplayFont,
                              color: kTextPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildPaymentOption(
                            label: 'Quincenal',
                            isSelected: state.paymentPeriod == 'Quincenal',
                            onTap: () {
                              widget.homeCubit.updatePaymentPeriod('Quincenal');
                            },
                          ),
                          const SizedBox(height: 20),
                          _buildPaymentOption(
                            label: 'Mensual',
                            isSelected: state.paymentPeriod == 'Mensual',
                            onTap: () {
                              widget.homeCubit.updatePaymentPeriod('Mensual');
                            },
                          ),
                          const SizedBox(height: 30),
                          const Text(
                            'Número de Cuotas',
                            style: TextStyle(
                              fontFamily: kDisplayFont,
                              color: kTextPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
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
                                      widget.homeCubit
                                          .updateInstallments(number);
                                    },
                                    child: Container(
                                      height: 62,
                                      width: 46,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 5),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color:
                                            state.selectedInstallments == number
                                                ? kPrimaryGreen
                                                : kSurfaceSoft,
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(
                                          color: state.selectedInstallments ==
                                                  number
                                              ? Colors.transparent
                                              : kBorderFaint,
                                        ),
                                      ),
                                      child: Text(
                                        '$number',
                                        style: TextStyle(
                                          color: state.selectedInstallments ==
                                                  number
                                              ? kPrimaryGreenDeep
                                              : kTextPrimary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                  _buildBottomAction(context, state),
                  const SizedBox(height: 20),
                ],
              ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: isSelected ? kPrimaryGreenSoft : kSurfaceSoft,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? kPrimaryGreen : kBorderFaint,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: kTextPrimary,
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ),
            Icon(
              isSelected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: isSelected ? kPrimaryGreen : kTextSecondary,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoanCard(BuildContext context, LoanRequestEntity loan) {
    final isPending = loan.status == 'pending';
    final statusLabel = isPending
        ? 'Pendiente'
        : loan.status == 'in_process'
            ? 'En revisión'
            : loan.status == 'in_disbursement_process'
                ? 'En desembolso'
                : loan.status == 'approved'
                    ? 'Activo'
                    : 'Rechazado';
    final statusColor = isPending ? kTextSecondary : kPrimaryGreen;
    return GestureDetector(
      onTap: () async {
        await context.push(AppRoutes.loansList);
        _refreshData();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: kSurfaceSoft,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: kBorderFaint),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    NumberFormat('\$#,##0', 'en_US')
                        .format(loan.amount.toInt()),
                    style: const TextStyle(
                      fontFamily: kDisplayFont,
                      color: kTextPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pagadas ${loan.installmentsPaid}/${loan.installments} · ${loan.paymentPeriod}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: kTextSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: kBgScreenAlt,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                color: kTextSecondary,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _goToLoanOrSubscription(BuildContext context) async {
    // Refresca isSubscribed desde Firestore antes de decidir
    final user = sl<AuthCubit>(instanceName: 'auth').state.user;
    bool isSubscribed = user.isSubscribed;
    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .where('phone', isEqualTo: user.phone)
          .limit(1)
          .get();
      if (snap.docs.isNotEmpty) {
        isSubscribed = snap.docs.first.data()['isSubscribed'] == true;
        if (isSubscribed != user.isSubscribed) {
          await sl<AuthCubit>(instanceName: 'auth').login(
            user: user.copyWith(isSubscribed: isSubscribed),
          );
        }
      }
    } catch (_) {}
    if (!context.mounted) return;
    if (isSubscribed) {
      await context.push(AppRoutes.loanInformation);
    } else {
      await context.push(
        AppRoutes.subscrption,
        extra: {
          'afterSuccessRoute': AppRoutes.loanInformation,
        },
      );
    }
    _refreshData();
  }

  Widget _buildNewRequestButton(BuildContext context) {
    return PrimaryActionButton(
      label: 'Continuar con solicitud',
      margin: EdgeInsets.zero,
      onTap: () => _goToLoanOrSubscription(context),
    );
  }

  Widget _buildBlockedButton() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.orange.withOpacity(0.25)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline,
                  color: Colors.orange.withOpacity(0.8), size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Tienes una solicitud en revisión. Espera la respuesta antes de hacer una nueva.',
                  style: const TextStyle(
                    color: kTextSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 62,
          decoration: BoxDecoration(
            color: kSurfaceSoft,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kBorderFaint),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 25),
                child: Text(
                  'Nueva solicitud',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Container(
                  width: 46,
                  height: 38,
                  decoration: BoxDecoration(
                    color: kBgScreenAlt,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.lock_outline_rounded,
                    color: Colors.white.withValues(alpha: 0.2),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetExhaustedBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.money_off_rounded,
              color: Colors.red.withOpacity(0.8), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'No hay presupuesto disponible en este momento. Intenta más tarde.',
              style: const TextStyle(
                color: kTextSecondary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction(BuildContext context, HomeState state) {
    final budgetAvailable = state.limits.budgetAvailable;
    final budgetExhausted = budgetAvailable != null && budgetAvailable <= 0;

    final pendingLoan =
        state.loans.where((l) => l.status == 'pending').firstOrNull;
    final approvedLoan =
        state.loans.where((l) => l.status == 'approved').firstOrNull;

    // Si hay una solicitud en revisión: mostrar tarjeta + bloquear botón
    if (pendingLoan != null) {
      return Column(
        children: [
          _buildLoanCard(context, pendingLoan),
          const SizedBox(height: 12),
          _buildBlockedButton(),
        ],
      );
    }

    // Si el presupuesto está agotado: mostrar banner + bloquear
    if (budgetExhausted) {
      return Column(
        children: [
          if (approvedLoan != null) ...[
            _buildLoanCard(context, approvedLoan),
            const SizedBox(height: 12),
          ],
          _buildBudgetExhaustedBanner(),
          Container(
            height: 62,
            decoration: BoxDecoration(
              color: kSurfaceSoft,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kBorderFaint),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: Text(
                    'Presupuesto agotado',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.3),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Container(
                    width: 46,
                    height: 38,
                    decoration: BoxDecoration(
                      color: kBgScreenAlt,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.lock_outline_rounded,
                      color: Colors.white.withValues(alpha: 0.2),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Si hay una aprobada (en proceso de pago): mostrar tarjeta + permitir nueva
    if (approvedLoan != null) {
      return Column(
        children: [
          _buildLoanCard(context, approvedLoan),
          const SizedBox(height: 12),
          _buildNewRequestButton(context),
        ],
      );
    }

    return PrimaryActionButton(
      label: 'Continuar con solicitud',
      margin: EdgeInsets.zero,
      onTap: () => _goToLoanOrSubscription(context),
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
