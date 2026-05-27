import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../utils/design_tokens.dart';
import '../../../shared/widgets/back_circle_button.dart';
import '../../../shared/widgets/primary_action_button.dart';
import '../../cubit/home_cubit.dart';
import '../widgets/web_payment_view.dart';

class SubscriptionScreen extends StatefulWidget {
  final HomeCubit homeCubit;
  final String? afterSuccessRoute;
  final bool returnSuccessResult;
  const SubscriptionScreen({
    super.key,
    required this.homeCubit,
    this.afterSuccessRoute,
    this.returnSuccessResult = false,
  });

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  @override
  void initState() {
    super.initState();
    widget.homeCubit.loadWompiConfig();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      bloc: widget.homeCubit,
      builder: (BuildContext context, HomeState state) {
        return Scaffold(
          drawerEnableOpenDragGesture: false,
          extendBodyBehindAppBar: true,
          floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
          floatingActionButton: BackCircleButton(
            heroTag: 'subscription_back',
            onPressed: () => context.pop(),
          ),
          body: _body(context, state),
        );
      },
    );
  }

  Widget _body(BuildContext context, HomeState state) {
    final amountLabel =
        NumberFormat.decimalPattern('es_CO').format(state.subscriptionAmount);
    const benefits = [
      'Préstamos fáciles de obtener',
      'Sin requisitos complejos',
      'Aprobación rápida y sencilla',
      'Transparencia total',
      'Soporte disponible',
    ];

    return Container(
      color: kBgScreen,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 92, 24, 28),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.sizeOf(context).height - 140,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Suscríbete',
                  style: TextStyle(
                    color: kTextPrimary,
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1.2,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Activa tu membresía y mantén acceso ágil a las solicitudes, pagos y soporte de la plataforma.',
                  style: TextStyle(
                    color: kTextSecondary,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: kSurfaceSoft,
                    borderRadius: BorderRadius.circular(kRadiusCard),
                    border: Border.all(color: kBorderFaint),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tu suscripción incluye',
                        style: TextStyle(
                          color: kTextPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...benefits.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 3),
                                width: 18,
                                height: 18,
                                decoration: const BoxDecoration(
                                  color: kPrimaryGreenSoft,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  size: 12,
                                  color: kPrimaryGreen,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  item,
                                  style: const TextStyle(
                                    color: kTextPrimary,
                                    fontSize: 15,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: kSurfaceFaint,
                    borderRadius: BorderRadius.circular(kRadiusCard),
                    border: Border.all(color: kBorderFaint),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: kPrimaryGreenSoft,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.info_outline_rounded,
                          color: kPrimaryGreen,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              '¿Por qué existe esta suscripción?',
                              style: TextStyle(
                                color: kTextPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Nos ayuda a sostener la operación de la plataforma y seguir ofreciéndote un servicio confiable y rápido.',
                              style: TextStyle(
                                color: kTextSecondary,
                                fontSize: 14,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: kPrimaryGreenSoft,
                    borderRadius: BorderRadius.circular(kRadiusCard),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Valor actual de la suscripción',
                        style: TextStyle(
                          color: kTextSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$$amountLabel COP',
                        style: const TextStyle(
                          color: kTextPrimary,
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                PrimaryActionButton(
                  margin: EdgeInsets.zero,
                  label: 'Continuar con el pago',
                  onTap: () async {
                    final payment = await widget.homeCubit
                        .generateSubscriptionPayment(context);
                    if (!context.mounted) return;

                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WebPaymentView(
                          paymentUrl: payment.url,
                          homeCubit: widget.homeCubit,
                          reference: payment.reference,
                          amountInCents: payment.amountInCents,
                          onSuccessfulPayment: () async {
                            await widget.homeCubit.updateUserSubscription();
                            if (!context.mounted) return;

                            context.pop();
                            context.pop(true);

                            if (widget.returnSuccessResult) {
                              context.pop(true);
                              return;
                            }

                            if (widget.afterSuccessRoute != null) {
                              context.go(widget.afterSuccessRoute!);
                              return;
                            }

                            context.pop(true);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
