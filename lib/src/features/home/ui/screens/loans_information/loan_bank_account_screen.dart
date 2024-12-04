import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../utils/colors.dart';

import '../../../../../utils/modalbottomsheet.dart';
import '../../../../../utils/utils.dart';
import '../../../cubit/home_cubit.dart';
import '../../../data/entities/loan_information_entity.dart';
import '../../widgets/custom_textfield_widget.dart';

// ignore: must_be_immutable
class LoanBankAccountScreen extends StatefulWidget {
  final HomeCubit homeCubit;
  const LoanBankAccountScreen({
    super.key,
    required this.homeCubit,
  });

  @override
  State<LoanBankAccountScreen> createState() => _LoanBankAccountScreenState();
}

class _LoanBankAccountScreenState extends State<LoanBankAccountScreen> {
  String name = '';

  String lastName = '';

  String documentType = '';

  String documentNumber = '';

  String bank = '';

  String accountType = '';

  String accountNumber = '';

  bool get isFormValid =>
      name.isNotEmpty &&
      lastName.isNotEmpty &&
      documentType.isNotEmpty &&
      documentNumber.isNotEmpty &&
      bank.isNotEmpty &&
      accountType.isNotEmpty &&
      accountNumber.isNotEmpty;

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
          body: _body(context, state),
        );
      },
    );
  }

  Widget _body(BuildContext context, HomeState state) {
    return Container(
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 6, 16, 0),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 30,
        right: 30,
      ),
      height: MediaQuery.sizeOf(context).height,
      width: MediaQuery.sizeOf(context).width,
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.1,
            ),
            const Text(
              'Datos para finalizar',
              style: TextStyle(
                fontFamily: "Unbounded",
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.1,
            ),
            CustomTextfieldWidget(
              onlyNumber: false,
              title: 'Nombre (s)',
              hintText: 'Ingresa tu nombre',
              onChanged: (value) {
                if (value.isNotEmpty) {
                  name = value;
                }
              },
            ),
            const SizedBox(height: 15),
            CustomTextfieldWidget(
              onlyNumber: false,
              title: 'Apellido (s)',
              hintText: 'Ingresa tu apellido ',
              onChanged: (value) {
                if (value.isNotEmpty) {
                  lastName = value;
                }
              },
            ),
            const SizedBox(height: 15),
            CustomDropDowndWidget(
              hintText: "Tipo de documento",
              onChanged: (value) {
                if (value != null && value.isNotEmpty) {
                  documentType = value;
                }
              },
              options: const [
                'Cédula de ciudadanía',
                'Cédula de extranjería',
                'Pasaporte'
              ],
            ),
            const SizedBox(height: 15),
            CustomTextfieldWidget(
              title: 'Número de documento',
              hintText: 'Ingresa tu número de documento',
              onlyNumber: true,
              onChanged: (value) {
                if (value.isNotEmpty) {
                  documentNumber = value;
                }
              },
            ),
            const SizedBox(height: 15),
            CustomDropDowndWidget(
              hintText: "Selecciona tu banco",
              onChanged: (value) {
                if (value != null && value.isNotEmpty) {
                  bank = value;
                }
              },
              options: Utils.listOfBanks,
            ),
            const SizedBox(height: 15),
            CustomDropDowndWidget(
              hintText: "Tipo de cuenta",
              onChanged: (value) {
                if (value != null && value.isNotEmpty) {
                  accountType = value;
                }
              },
              options: const [
                'Corriente',
                'Ahorros',
              ],
            ),
            const SizedBox(height: 15),
            CustomTextfieldWidget(
              onlyNumber: true,
              title: 'Número de cuenta',
              hintText: 'Ingresa tu número de cuenta',
              onChanged: (value) {
                if (value.isNotEmpty) {
                  accountNumber = value;
                }
              },
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.1,
            ),
            GestureDetector(
              onTap: () {
                setState(() {});
                if (isFormValid) {
                  widget.homeCubit.setBankAccount(LoanBankAccountEntity(
                    bankName: bank,
                    accountType: accountType,
                    bankAccountNumber: accountNumber,
                    bankAccountName: name,
                    bankAccountLastName: lastName,
                    bankDocumentType: documentType,
                    bankDocumentNumber: documentNumber,
                  ));

                  ModalbottomsheetUtils.successBottomSheet(
                      context,
                      'Datos guardados correctamente',
                      "Los datos fueron actualizados",
                      "Aceptar", () {
                    context.pop();
                    context.pop();
                  });
                }
              },
              child: Container(
                height: 62,
                decoration: BoxDecoration(
                  color: isFormValid
                      ? const Color.fromRGBO(47, 255, 0, 1)
                      : const Color.fromRGBO(47, 255, 0, 0.5),
                  borderRadius: BorderRadius.circular(48),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 25),
                      child: Text(
                        'Actualizar',
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
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget step() {
    return Container();
  }
}
