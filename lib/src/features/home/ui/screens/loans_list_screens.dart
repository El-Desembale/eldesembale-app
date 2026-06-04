import 'package:desembale/src/config/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../data/entities/loan_request_entity.dart';
import '../../../../utils/design_tokens.dart';
import '../../../../utils/images.dart';
import '../../../../utils/utils.dart';
import '../../../shared/widgets/back_circle_button.dart';
import '../../cubit/home_cubit.dart';
import 'loan_info_detail_screen.dart';

class LoansListScreen extends StatefulWidget {
  final HomeCubit homeCubit;
  const LoansListScreen({
    super.key,
    required this.homeCubit,
  });

  @override
  State<LoansListScreen> createState() => _LoansListScreenState();
}

class _LoansListScreenState extends State<LoansListScreen> {
  DateTime? _selectedDate;

  @override
  void initState() {
    widget.homeCubit.getLoans();
    super.initState();
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
            heroTag: 'loans_list_fab',
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.home);
              }
            },
          ),
          body: Stack(
            children: [
              _body(context, state),
            ],
          ),
        );
      },
    );
  }

  List<LoanRequestEntity> get _filteredLoans {
    final loans = widget.homeCubit.state.loans;
    if (_selectedDate == null) return loans;
    return loans.where((loan) {
      final createdAt = loan.createdAt.toDate();
      return createdAt.year == _selectedDate!.year &&
          createdAt.month == _selectedDate!.month &&
          createdAt.day == _selectedDate!.day;
    }).toList();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
      locale: const Locale('es', 'CO'),
    );

    if (pickedDate != null) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  Widget _body(BuildContext context, HomeState state) {
    final filteredLoans = _filteredLoans;

    return Container(
      color: kBgScreen,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 92, 24, 24),
          child: state.isLoading
              ? const Center(
                  child: SizedBox(
                    height: 40,
                    width: 40,
                    child: CircularProgressIndicator(
                      color: kPrimaryGreen,
                      strokeWidth: 2.4,
                    ),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Solicitudes',
                      style: TextStyle(
                        color: kTextPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Consulta tu historial y filtra por fecha cuando necesites revisar una solicitud específica.',
                      style: TextStyle(
                        color: kTextSecondary,
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        InkWell(
                          onTap: _pickDate,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: kSurfaceSoft,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: kBorderFaint),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.calendar_today_rounded,
                                  color: kPrimaryGreen,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedDate == null
                                      ? 'Buscar por fecha'
                                      : DateFormat('d MMM y', 'es_CO')
                                          .format(_selectedDate!),
                                  style: const TextStyle(
                                    color: kTextPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_selectedDate != null)
                          InkWell(
                            onTap: () => setState(() => _selectedDate = null),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: kSurfaceFaint,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: kBorderFaint),
                              ),
                              child: const Text(
                                'Limpiar filtro',
                                style: TextStyle(
                                  color: kTextSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Expanded(
                      child: _loansList(context, state, filteredLoans),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _loansList(
    BuildContext context,
    HomeState state,
    List<LoanRequestEntity> filteredLoans,
  ) {
    if (state.loans.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 100,
              width: 100,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: kSurfaceSoft,
                borderRadius: BorderRadius.circular(18),
              ),
              child: SvgPicture.asset(
                AssetImages.request,
                colorFilter: const ColorFilter.mode(
                  kPrimaryGreen,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Sin solicitudes aún',
              style: TextStyle(
                color: kTextPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Aquí verás el historial\nde tus préstamos.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: kTextSecondary,
                fontSize: 14,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 36),
            InkWell(
              onTap: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(AppRoutes.home);
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                decoration: BoxDecoration(
                  color: kPrimaryGreen,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Solicitar préstamo',
                  style: TextStyle(
                    color: kPrimaryGreenDeep,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (filteredLoans.isEmpty) {
      return Center(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: kSurfaceSoft,
            borderRadius: BorderRadius.circular(kRadiusCard),
            border: Border.all(color: kBorderFaint),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.event_busy_outlined,
                color: kTextSecondary,
                size: 34,
              ),
              SizedBox(height: 12),
              Text(
                'No hay solicitudes para esa fecha',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: kTextPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Prueba con otro día o limpia el filtro.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: kTextSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: filteredLoans.length,
      itemBuilder: (BuildContext context, int index) {
        final loan = filteredLoans[index];
        final actualIndex = state.loans.indexOf(loan);
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LoanInfoDetailScreen(
                  loanIndex: actualIndex,
                  homeCubit: widget.homeCubit,
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(18),
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(kRadiusCard),
              color: kInputSurface,
              border: Border.all(color: kBorderFaint),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    status(loan.status),
                    const SizedBox(height: 16),
                    Text(
                      '\$${NumberFormat("#,##0", "es_CO").format(loan.amount)}',
                      style: const TextStyle(
                        color: kTextPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.6,
                      ),
                    ),
                  ],
                ),
                Builder(builder: (context) {
                  final bool isApproved = loan.isActive;
                  final bool hasPending = isApproved && loan.canPay;
                  String? nextDateStr;
                  String? nextAmountStr;
                  if (hasPending) {
                    // Modelo nuevo: fecha y monto de la próxima cuota desde el desglose.
                    final nextCuota = (loan.pricing != null &&
                            loan.installmentsPaid <
                                loan.pricing!.installments.length)
                        ? loan.pricing!.installments[loan.installmentsPaid]
                        : null;
                    final nextDate = nextCuota?.fechaVencimiento ??
                        Utils.calculateInstallmentDate(
                          installmentIndex: loan.installmentsPaid,
                          paymentPeriod: loan.paymentPeriod,
                          baseDate: loan.createdAt.toDate(),
                        );
                    final nextAmount = loan.cuotaAmount(loan.installmentsPaid);
                    nextDateStr = DateFormat('d/M/y').format(nextDate);
                    nextAmountStr =
                        NumberFormat("#,##0", "en_US").format(nextAmount);
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        loan.status == "pending" ||
                                loan.status == "reviewing" ||
                                loan.status == "rejected"
                            ? "Solicitado ${DateFormat('d/M/y').format(loan.createdAt.toDate())}"
                            : "Desembolso: ${DateFormat('d/M/y').format(loan.createdAt.toDate())}",
                        style: const TextStyle(
                          color: kTextPrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Pago ${loan.paymentPeriod}",
                        style: const TextStyle(
                          color: kTextSecondary,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        "Pagadas ${loan.installmentsPaid}/${loan.installments}",
                        style: const TextStyle(
                          color: kTextSecondary,
                          fontSize: 11,
                        ),
                      ),
                      if (hasPending && nextDateStr != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: kPrimaryGreenSoft,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: kPrimaryGreen.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'Próxima cuota',
                                style: TextStyle(
                                  color: kPrimaryGreen,
                                  fontSize: 9,
                                ),
                              ),
                              Text(
                                nextDateStr,
                                style: const TextStyle(
                                  color: kTextPrimary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                '\$$nextAmountStr',
                                style: const TextStyle(
                                  color: kPrimaryGreen,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else if (isApproved && !loan.canPay) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: kSurfaceSoft,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Pagado ✓',
                            style: TextStyle(
                              color: kPrimaryGreen,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                }),
              ],
            ),
                if (loan.status == 'rejected' &&
                    loan.rejectionReason.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: kDangerSoft.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
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
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          loan.rejectionReason,
                          style: const TextStyle(
                            color: kTextPrimary,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget status(String status) {
    Map<String, String> statusMap = {
      "pending": "Pendiente",
      "reviewing": "En revisión",
      "approved": "Activo",
      "rejected": "Rechazado",
      "disbursed": "Desembolsado",
    };
    Map<String, Color> statusColorMap = {
      "pending": kWarningSoft,
      "reviewing": const Color(0xFFA78BFA),
      "approved": kPrimaryGreen,
      "rejected": kDangerSoft,
      "disbursed": const Color(0xFF8CC5FF),
    };

    Map<String, String> statusIconMap = {
      "pending": AssetImages.loanClock,
      "reviewing": AssetImages.loanWaitting,
      "approved": AssetImages.loanCheck,
      "rejected": AssetImages.loanCancel,
      "disbursed": AssetImages.loanCash,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: (statusColorMap[status] ?? Colors.white).withValues(alpha: 0.12),
        border: Border.all(color: statusColorMap[status] ?? Colors.white),
      ),
      child: Row(
        children: [
          SvgPicture.asset(statusIconMap[status] ?? AssetImages.loanWaitting),
          const SizedBox(width: 10),
          Text(
            statusMap[status] ?? "",
            style: TextStyle(
              color: statusColorMap[status] ?? kTextPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
