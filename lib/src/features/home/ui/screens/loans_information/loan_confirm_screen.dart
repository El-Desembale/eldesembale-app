import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../../config/auth/cubit/auth_cubit.dart';
import '../../../../../config/routes/routes.dart';
import '../../../../../core/di/injection_dependency.dart';
import '../../../../../utils/design_tokens.dart';
import '../../../../../utils/modalbottomsheet.dart';
import '../../../cubit/home_cubit.dart';

class LoanConfirmScreen extends StatelessWidget {
  final HomeCubit homeCubit;
  const LoanConfirmScreen({super.key, required this.homeCubit});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      bloc: homeCubit,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: kBgScreen,
          body: _body(context, state),
        );
      },
    );
  }

  Widget _body(BuildContext context, HomeState state) {
    final info = state.loanInformation;
    final fmt = NumberFormat('#,##0', 'en_US');
    final items = [
      _SummaryItem('Dirección', info.direction, Icons.location_on_outlined, true),
      _SummaryItem('Factura EPM', 'Adjuntada', Icons.receipt_long_outlined,
          info.empInvoiceFile.path.isNotEmpty || info.existingEmpInvoiceUrl.isNotEmpty),
      _SummaryItem('Cédula frontal', 'Foto lista', Icons.badge_outlined,
          info.ccFrontalPicture.path.isNotEmpty || info.existingCcFrontalPictureUrl.isNotEmpty),
      _SummaryItem('Cédula posterior', 'Foto lista', Icons.badge_outlined,
          info.ccBackPicture.path.isNotEmpty || info.existingCcBackPictureUrl.isNotEmpty),
      _SummaryItem('Selfie', 'Foto lista', Icons.face_outlined,
          info.selfiePicture.path.isNotEmpty || info.existingSelfiePictureUrl.isNotEmpty),
      _SummaryItem(
        'Referencias',
        '${info.firstReference.relationship} · ${info.secondReference.relationship}',
        Icons.people_outline,
        info.firstReference.relationship.isNotEmpty && info.secondReference.relationship.isNotEmpty,
      ),
      _SummaryItem(
        'Cuenta bancaria',
        info.bankInformation.bankName,
        Icons.account_balance_outlined,
        info.bankInformation.isCompleted,
      ),
    ];

    return SafeArea(
      child: Column(
        children: [
          // Header con botón atrás
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: kSurfaceSoft,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back, color: kTextPrimary, size: 22),
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Resumen de solicitud',
                  style: TextStyle(color: kTextPrimary, fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tarjeta de monto
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: kPrimaryGreenDeep,
                      borderRadius: BorderRadius.circular(kRadiusCard),
                      border: Border.all(color: kPrimaryGreenSoft),
                    ),
                    child: Column(
                      children: [
                        const Text('Monto solicitado', style: TextStyle(color: kTextSecondary, fontSize: 13)),
                        const SizedBox(height: 8),
                        Text(
                          '\$${fmt.format(state.totalLoanAmount)}',
                          style: const TextStyle(color: kTextPrimary, fontSize: 38, fontWeight: FontWeight.w800, letterSpacing: -1),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: kBgScreen,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _miniStat('Período', state.paymentPeriod),
                              Container(width: 1, height: 28, color: kBorderFaint),
                              _miniStat('Cuotas', '${state.selectedInstallments}'),
                              Container(width: 1, height: 28, color: kBorderFaint),
                              _miniStat('Interés', _fmtInterest(state.limits.interest)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    'Documentos adjuntos',
                    style: TextStyle(color: kTextSecondary, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 12),

                  // Lista de ítems
                  Container(
                    decoration: BoxDecoration(
                      color: kBgScreenAlt,
                      borderRadius: BorderRadius.circular(kRadiusCard),
                      border: Border.all(color: kBorderFaint),
                    ),
                    child: Column(
                      children: items.asMap().entries.map((e) {
                        final i = e.key;
                        final item = e.value;
                        return Column(
                          children: [
                            if (i > 0) Divider(height: 1, color: kBorderFaint),
                            _buildItem(context, item),
                          ],
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Aviso
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: kPrimaryGreenSoft,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, color: kPrimaryGreen, size: 18),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Al enviar la solicitud, un asesor revisará tu información y te notificará el resultado en menos de 24 horas.',
                            style: TextStyle(color: kTextSecondary, fontSize: 12, height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Botones fijos abajo
          Container(
            padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 16),
            decoration: BoxDecoration(
              color: kBgScreen,
              border: Border(top: BorderSide(color: kBorderFaint)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Botón enviar
                GestureDetector(
                  onTap: state.isLoading
                      ? null
                      : () async => _submit(context, state),
                  child: Container(
                    height: 62,
                    decoration: BoxDecoration(
                      color: state.isLoading ? kSurfaceSoft : kPrimaryGreen,
                      borderRadius: BorderRadius.circular(kRadiusButton),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 24),
                          child: Text(
                            state.isLoading ? 'Enviando...' : 'Enviar solicitud',
                            style: TextStyle(
                              color: state.isLoading ? kTextSecondary : Colors.black,
                              fontSize: 16, fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(
                              color: state.isLoading
                                  ? kBorderFaint
                                  : const Color.fromRGBO(0, 0, 0, 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              state.isLoading ? Icons.hourglass_empty : Icons.send_rounded,
                              color: state.isLoading ? kTextSecondary : Colors.black,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Botón volver a editar
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: kSurfaceSoft,
                      borderRadius: BorderRadius.circular(kRadiusButton),
                      border: Border.all(color: kBorderFaint),
                    ),
                    child: const Center(
                      child: Text(
                        'Volver y modificar algo',
                        style: TextStyle(color: kTextSecondary, fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _fmtInterest(double multiplier) {
    // interest se guarda como multiplicador (1.1 = 10% de interés)
    final pct = (multiplier - 1) * 100;
    return pct % 1 == 0 ? '${pct.toInt()}%' : '${pct.toStringAsFixed(1)}%';
  }

  Widget _miniStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: kTextSecondary, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: kTextPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildItem(BuildContext context, _SummaryItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: item.done ? kPrimaryGreenSoft : kSurfaceSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: item.done ? kPrimaryGreen : kTextSecondary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: const TextStyle(color: kTextPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
                if (item.subtitle.isNotEmpty)
                  Text(item.subtitle,
                      style: const TextStyle(color: kTextSecondary, fontSize: 12),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Icon(
            item.done ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            color: item.done ? kPrimaryGreen : kBorderFaint,
            size: 22,
          ),
        ],
      ),
    );
  }

  Future<void> _submit(BuildContext context, HomeState state) async {
    final isSubscribed = sl<AuthCubit>(instanceName: 'auth').state.user.isSubscribed;
    if (isSubscribed) {
      await homeCubit.submitLoan(context);
    } else {
      final response = await context.push<bool>(
        AppRoutes.subscrption,
        extra: {'returnSuccessResult': true},
      );
      if (!context.mounted) return;
      if (response ?? false) {
        await homeCubit.submitLoan(context);
      }
    }
  }
}

class _SummaryItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool done;
  const _SummaryItem(this.title, this.subtitle, this.icon, this.done);
}
