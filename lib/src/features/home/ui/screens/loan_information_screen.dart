import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../config/auth/cubit/auth_cubit.dart';
import '../../../../config/routes/routes.dart';
import '../../../../core/di/injection_dependency.dart';
import '../../../../utils/design_tokens.dart';
import '../../cubit/home_cubit.dart';
import 'subscription_screen.dart';
import '../../../shared/widgets/back_circle_button.dart';
import '../../../shared/widgets/primary_action_button.dart';

class LoanInformationScreen extends StatefulWidget {
  final HomeCubit homeCubit;
  const LoanInformationScreen({
    super.key,
    required this.homeCubit,
  });

  @override
  State<LoanInformationScreen> createState() => _LoanInformationScreenState();
}

class _LoanInformationScreenState extends State<LoanInformationScreen> {
  bool _checkingSubscription = true;
  bool _isSubscribed = false;

  @override
  void initState() {
    super.initState();
    _ensureSubscribed();
  }

  Future<void> _ensureSubscribed() async {
    final auth = sl<AuthCubit>(instanceName: 'auth');
    final user = auth.state.user;
    final isSubscribed = await _fetchSubscriptionStatus(user.id, user.phone, user.email);
    if (!mounted) return;

    if (isSubscribed != user.isSubscribed) {
      await auth.login(user: user.copyWith(isSubscribed: isSubscribed));
    }
    if (!mounted) return;

    setState(() {
      _isSubscribed = isSubscribed;
      _checkingSubscription = false;
    });
  }

  Future<bool> _fetchSubscriptionStatus(
    String userId,
    String phone,
    String email,
  ) async {
    final matched = <String, Map<String, dynamic>>{};
    if (userId.isNotEmpty) {
      final directDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (directDoc.exists) {
        matched[directDoc.id] = directDoc.data()!;
      }
    }

    final normalizedPhone = phone.replaceAll(' ', '');
    final fullPhone = '+57$normalizedPhone';
    final normalizedEmail = email.trim().toLowerCase();

    Future<void> collect(String field, String value) async {
      if (value.isEmpty) return;
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .where(field, isEqualTo: value)
          .get();
      for (final doc in snap.docs) {
        matched[doc.id] = doc.data();
      }
    }

    await collect('phone', phone);
    await collect('phone', normalizedPhone);
    await collect('phone', fullPhone);
    await collect('email', email);
    if (normalizedEmail != email) {
      await collect('email', normalizedEmail);
    }

    return matched.values.any((data) => data['isSubscribed'] == true);
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingSubscription) {
      return const Scaffold(
        backgroundColor: kBgScreen,
        body: Center(
          child: CircularProgressIndicator(color: kPrimaryGreen),
        ),
      );
    }

    if (!_isSubscribed) {
      return SubscriptionScreen(
        homeCubit: widget.homeCubit,
        afterSuccessRoute: AppRoutes.loanInformation,
      );
    }

    return BlocBuilder<HomeCubit, HomeState>(
      bloc: widget.homeCubit,
      builder: (BuildContext context, HomeState state) {
        return Scaffold(
          drawerEnableOpenDragGesture: false,
          extendBodyBehindAppBar: true,
          resizeToAvoidBottomInset: false,
          floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
          floatingActionButton: BackCircleButton(
            heroTag: 'loan_information_back',
            onPressed: () {
              context.go(AppRoutes.home);
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
      widget.homeCubit.useReusableLoanInformation();
      context.push(AppRoutes.loanConfirm);
    } else if (useSameData == false) {
      widget.homeCubit.resetLoanInformation();
      context.push(AppRoutes.loanDataCollect);
    }
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top + 24),
            const Text(
              'Detalles del Préstamo',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: kTextPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                color: kSurfaceSoft,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: kBorderFaint),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tu préstamo',
                    style: TextStyle(
                      color: kTextSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${NumberFormat('#,##0', 'en_US').format(state.totalLoanAmount.toInt())}',
                    style: const TextStyle(
                      color: kTextPrimary,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _InfoChip(
                        label: '${state.selectedInstallments} cuotas',
                        icon: Icons.calendar_month_outlined,
                      ),
                      const SizedBox(width: 10),
                      _InfoChip(
                        label: state.paymentPeriod,
                        icon: Icons.schedule_outlined,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: kSurfaceSoft,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: kBorderFaint),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Antes de continuar',
                    style: TextStyle(
                      color: kTextPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ChecklistRow(
                    title: 'Documentos al día',
                    subtitle: 'Cédula, selfie y comprobante de ingresos',
                    done: state.loanInformation.ccFrontalPicture.path.isNotEmpty ||
                        state.loanInformation.existingCcFrontalPictureUrl.isNotEmpty,
                  ),
                  const SizedBox(height: 10),
                  _ChecklistRow(
                    title: 'Referencias personales',
                    subtitle: 'Dos contactos que te conozcan bien',
                    done: state.loanInformation.firstReference.name.isNotEmpty &&
                        state.loanInformation.secondReference.name.isNotEmpty,
                  ),
                  const SizedBox(height: 10),
                  _ChecklistRow(
                    title: 'Cuenta bancaria',
                    subtitle: 'Para recibir el desembolso si se aprueba',
                    done: state.loanInformation.bankInformation.bankName.isNotEmpty,
                  ),
                ],
              ),
            ),
            const Spacer(),
            PrimaryActionButton(
              label: 'Continuar',
              margin: EdgeInsets.zero,
              onTap: () => _handleContinue(context, state),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _InfoChip({
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: kBgScreenAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorderFaint),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: kPrimaryGreen, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: kTextPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool done;

  const _ChecklistRow({
    required this.title,
    required this.subtitle,
    required this.done,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: done ? kPrimaryGreenSoft : kBgScreenAlt,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            done ? Icons.check_circle_outline : Icons.radio_button_unchecked,
            color: done ? kPrimaryGreen : kTextSecondary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: kTextPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: kTextSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
