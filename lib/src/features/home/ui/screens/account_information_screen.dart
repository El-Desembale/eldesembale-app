import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';

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
    final color = isSubscribed ? kPrimaryGreen : Colors.white70;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSubscribed
            ? kPrimaryGreen.withOpacity(0.15)
            : kSurfaceSoft,
        border: Border.all(color: color.withOpacity(0.6)),
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
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _body(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      padding: const EdgeInsets.symmetric(horizontal: kPadH),
      color: kBgScreen,
      child: Column(
        children: [
          const Spacer(),
          const Text(
            "Datos personales",
            style: TextStyle(
              fontSize: kFontTitleMd,
              fontWeight: FontWeight.bold,
              color: kTextPrimary,
            ),
          ),
          const SizedBox(height: 12),
          if (_loading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(kPrimaryGreen),
                ),
              ),
            )
          else
            _subscriptionChip(),
          const SizedBox(height: 24),
          CustomUneditableWidget(
            icon: Icons.person_outline,
            title: "Nombre (s)",
            initialValue: _user.name,
          ),
          const SizedBox(height: 20),
          CustomUneditableWidget(
            icon: Icons.person_outline,
            title: "Apellido (s)",
            initialValue: _user.lastName,
          ),
          const SizedBox(height: 20),
          CustomUneditableWidget(
            icon: Icons.email_outlined,
            title: "Correo electrónico",
            initialValue: _user.email,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: CountryCodePicker(
                  enabled: false,
                  boxDecoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  backgroundColor: Colors.white.withOpacity(0.16),
                  initialSelection: 'CO',
                  alignLeft: true,
                ),
              ),
              Expanded(
                flex: 5,
                child: CustomUneditableWidget(
                  icon: Icons.phone_outlined,
                  title: "Número de teléfono",
                  initialValue: _user.phone,
                ),
              ),
            ],
          ),
          const Spacer(),
          PrimaryActionButton(
            label: '¿Deseas editar tus datos?',
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
          const Spacer(),
        ],
      ),
    );
  }
}
