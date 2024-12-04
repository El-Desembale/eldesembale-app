import 'package:country_code_picker/country_code_picker.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/auth/cubit/auth_cubit.dart';
import '../../../../config/auth/data/models/user_model.dart';
import '../../../../core/di/injection_dependency.dart';
import '../../../../utils/colors.dart';
import '../../../../utils/modalbottomsheet.dart';
import '../widgets/custon_uneditable_textfield_widget.dart';

class AccountInformationScreen extends StatelessWidget {
  const AccountInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            context.pop();
          },
          child: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 35,
          ),
        ),
      ),
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    UserModel user = sl<AuthCubit>(instanceName: 'auth').state.user;
    return Container(
      height: MediaQuery.of(context).size.height,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: const Color.fromARGB(255, 6, 16, 0),
      child: Column(
        children: [
          const Spacer(),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(left: 5),
            child: const Text(
              "Datos personales",
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 30),
          CustomUneditableWidget(
            icon: Icons.person_outline,
            title: "Nombre (s)",
            initialValue: user.name,
          ),
          const SizedBox(height: 20),
          CustomUneditableWidget(
            icon: Icons.person_outline,
            title: "Apellido (s)",
            initialValue: user.lastName,
          ),
          const SizedBox(height: 20),
          CustomUneditableWidget(
            icon: Icons.email_outlined,
            title: "Correo electrónico",
            initialValue: user.email,
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
                  initialValue: user.phone,
                ),
              ),
            ],
          ),
          const Spacer(),
          InkWell(
            onTap: () async {
              ModalbottomsheetUtils.successBottomSheet(
                context,
                '¿Deseas editar tus datos?',
                "Para modifar tus datos envía un correo a soporte@eldesembaleapp.com",
                "Entendido",
                null,
              );
            },
            child: Container(
              height: 72,
              margin: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
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
                      '¿Deseas editar tus datos?',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Container(
                      width: 72,
                      height: 55,
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
          const Spacer(),
        ],
      ),
    );
  }
}
