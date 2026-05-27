import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../config/routes/routes.dart';
import '../../../../utils/design_tokens.dart';
import '../../../../utils/utils.dart';
import '../../cubit/home_cubit.dart';
import '../../../shared/widgets/back_circle_button.dart';
import '../../../shared/widgets/primary_action_button.dart';

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
          floatingActionButton: BackCircleButton(
            heroTag: 'loan_information_back',
            onPressed: () {
              context.pop();
            },
          ),
          body: _body(context, state),
        );
      },
    );
  }

  Future<void> _handleContinue(BuildContext context, HomeState state) async {
    final reusable = state.reusableLoanInformation;
    if (reusable == null || !reusable.hasReusableProfile) {
      context.push(AppRoutes.loanDataCollect);
      return;
    }

    final useSameData = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: kBgScreenAlt,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: kBorderFaint),
          ),
          title: const Text(
            '¿Tus datos cambiaron?',
            style: TextStyle(
              color: kTextPrimary,
              fontWeight: FontWeight.bold,
              fontFamily: kDisplayFont,
              fontSize: 18,
            ),
          ),
          content: const Text(
            'Podemos reutilizar la dirección, referencias, documentos y cuenta bancaria de tu última solicitud para que no tengas que llenarlo todo otra vez.',
            style: TextStyle(
              color: kTextSecondary,
              height: 1.45,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text(
                'Sí, cambiaron',
                style: TextStyle(color: kTextSecondary),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: kPrimaryGreen,
                foregroundColor: kPrimaryGreenDeep,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Tengo los mismos datos'),
            ),
          ],
        );
      },
    );

    if (!context.mounted) return;

    if (useSameData == true) {
      homeCubit.useReusableLoanInformation();
    } else if (useSameData == false) {
      homeCubit.resetLoanInformation();
    } else {
      return;
    }

    context.push(AppRoutes.loanDataCollect);
  }

  Widget _body(BuildContext context, HomeState state) {
    return Container(
      decoration: const BoxDecoration(color: kBgScreen),
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
        ),
        height: MediaQuery.sizeOf(context).height,
        width: MediaQuery.sizeOf(context).width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            const Text(
              'Detalles del Préstamo',
              maxLines: 2,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: kDisplayFont,
                color: kTextPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
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
                      NumberFormat("#,##0", "en_US")
                          .format(state.totalLoanAmount),
                      style: const TextStyle(
                        fontFamily: kDisplayFont,
                        color: kTextPrimary,
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
                            color: kTextSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          state.paymentPeriod,
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
                          "Número Cuotas",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: kTextSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "${state.selectedInstallments}",
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
            const Text(
              'Fechas de Pago',
              style: TextStyle(
                fontFamily: kDisplayFont,
                color: kTextPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: kSurfaceSoft,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: kBorderFaint),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children:
                        List.generate(state.selectedInstallments, (index) {
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: index == state.selectedInstallments - 1
                                  ? Colors.transparent
                                  : kBorderFaint,
                            ),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                DateFormat('d MMMM, yyyy', 'es')
                                    .format(Utils.calculateInstallmentDate(
                                  installmentIndex: index,
                                  paymentPeriod: state.paymentPeriod,
                                )),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: kTextPrimary,
                                  fontSize: 14,
                                  height: 1.35,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                NumberFormat("#,##0", "en_US").format(
                                  Utils.getTotalAmount(
                                    state.totalLoanAmount,
                                    state.selectedInstallments,
                                    state.limits.interest,
                                    state.paymentPeriod,
                                  ),
                                ),
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  color: kPrimaryGreen,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            PrimaryActionButton(
              label: 'Hacer la solicitud',
              margin: EdgeInsets.zero,
              onTap: () => _handleContinue(context, state),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
