import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/auth/cubit/auth_cubit.dart';
import '../../../../config/auth/data/models/user_model.dart';
import '../../../../core/di/injection_dependency.dart';
import '../../../../utils/design_tokens.dart';
import '../../../../utils/modalbottomsheet.dart';
import '../../../shared/widgets/back_circle_button.dart';
import '../../../shared/widgets/primary_action_button.dart';
import '../widgets/custon_uneditable_textfield_widget.dart';

class AccountInformationScreen extends StatefulWidget {
  const AccountInformationScreen({super.key});

  @override
  State<AccountInformationScreen> createState() =>
      _AccountInformationScreenState();
}

class _AccountInformationScreenState extends State<AccountInformationScreen> {
  late UserModel _user;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _user = sl<AuthCubit>(instanceName: 'auth').state.user;
    _refreshFromFirestore();
  }

  Future<void> _refreshFromFirestore() async {
    final phone = _user.phone;
    if (phone.isEmpty) {
      setState(() => _loading = false);
      return;
    }
    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();
      if (snap.docs.isNotEmpty) {
        final data = snap.docs.first.data();
        final fresh = UserModel(
          id: snap.docs.first.id,
          email: data['email'] ?? _user.email,
          phone: phone,
          name: data['name'] ?? _user.name,
          lastName: data['lastName'] ?? _user.lastName,
          isSubscribed: data['isSubscribed'] ?? false,
        );
        await sl<AuthCubit>(instanceName: 'auth').login(user: fresh);
        if (mounted) {
          setState(() {
            _user = fresh;
            _loading = false;
          });
        }
        return;
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawerEnableOpenDragGesture: false,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      floatingActionButton: BackCircleButton(
        heroTag: 'account_back',
        onPressed: () => context.pop(),
      ),
      body: _body(context),
    );
  }

  Widget _subscriptionChip() {
    final isSubscribed = _user.isSubscribed;
    final color = isSubscribed ? kPrimaryGreen : kTextSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isSubscribed ? kPrimaryGreenSoft : kSurfaceSoft,
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(kRadiusChip),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSubscribed ? Icons.verified : Icons.cancel_outlined,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            isSubscribed ? 'Suscrito' : 'No suscrito',
            style: TextStyle(
              color: color,
              fontSize: kFontSmall,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _phonePrefix() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: kPrimaryGreenSoft,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        '🇨🇴 +57',
        style: TextStyle(
          color: kTextPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    return Container(
      color: kBgScreen,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(kPadH, 92, kPadH, 28),
          children: [
            const Text(
              "Datos personales",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: kTextPrimary,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.center,
              child: _subscriptionChip(),
            ),
            const SizedBox(height: 28),
            if (_loading) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(kPrimaryGreen),
                    ),
                  ),
                ),
              ),
            ] else ...[
              CustomUneditableWidget(
                icon: Icons.person_outline,
                title: "Nombre (s)",
                initialValue: _user.name,
              ),
              const SizedBox(height: 14),
              CustomUneditableWidget(
                icon: Icons.badge_outlined,
                title: "Apellido (s)",
                initialValue: _user.lastName,
              ),
              const SizedBox(height: 14),
              CustomUneditableWidget(
                icon: Icons.mail_outline_rounded,
                title: "Correo electrónico",
                initialValue: _user.email,
                singleLineValue: true,
              ),
              const SizedBox(height: 14),
              CustomUneditableWidget(
                icon: Icons.phone_outlined,
                title: "Número de teléfono",
                initialValue: _user.phone,
                leading: _phonePrefix(),
                singleLineValue: true,
              ),
            ],
            const SizedBox(height: 28),
            PrimaryActionButton(
              margin: EdgeInsets.zero,
              label: 'Solicitar cambio de datos',
              onTap: () {
                ModalbottomsheetUtils.successBottomSheet(
                  context,
                  '¿Deseas editar tus datos?',
                  "Para modifar tus datos envía un correo a soporte@eldesembaleapp.com",
                  "Entendido",
                  null,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
