import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/routes/routes.dart';
import '../../../../../utils/colors.dart';
import '../../../../../utils/images.dart';
import '../../../cubit/home_cubit.dart';
import '../../widgets/custom_tile_widget.dart';

class LoanDataCollectScreen extends StatelessWidget {
  final HomeCubit homeCubit;
  const LoanDataCollectScreen({
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
      child: Column(
        children: [
          const Spacer(),
          const Text(
            'Datos para finalizar',
            style: TextStyle(
              fontFamily: "Unbounded",
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          CustomListTile(
            isCompleted: state.loanInformation.direction.isNotEmpty,
            leadingIcon: AssetImages.locationDot,
            title: 'Dirección',
            subTitle: state.loanInformation.direction,
            trailingIcon: Icons.arrow_forward,
            onTap: () {
              context.push(AppRoutes.loanDirection);
            },
          ),
          const SizedBox(height: 10),
          CustomListTile(
            leadingIcon: AssetImages.empInvoice,
            title: 'Adjuntar Factura EPM',
            subTitle: "Factura Adjunta",
            trailingIcon: Icons.attach_file_outlined,
            isCompleted: state.loanInformation.empInvoiceFile.path.isNotEmpty,
            onTap: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles();
              if (result != null) {
                homeCubit.addEmpInvoiceFile(File(result.files.first.path!));
              }
            },
          ),
          const SizedBox(height: 10),
          CustomListTile(
            leadingIcon: AssetImages.ccPicture,
            title: 'Foto Cédula Frontal',
            subTitle: "Foto Realizada",
            trailingIcon: Icons.camera_alt_outlined,
            isCompleted: state.loanInformation.ccFrontalPicture.path.isNotEmpty,
            onTap: () async {
              await context.push(AppRoutes.loanCamera, extra: (File file) {
                homeCubit.addFrontIdFile(file);
              });
            },
          ),
          const SizedBox(height: 10),
          CustomListTile(
            leadingIcon: AssetImages.reverseCcPicture,
            title: 'Foto Cédula Posterior',
            subTitle: "Foto Realizada",
            trailingIcon: Icons.camera_alt_outlined,
            isCompleted: state.loanInformation.ccBackPicture.path.isNotEmpty,
            onTap: () async {
              await context.push(AppRoutes.loanCamera, extra: (File file) {
                homeCubit.addBackIdFile(file);
              });
            },
          ),
          const SizedBox(height: 10),
          CustomListTile(
            leadingIcon: AssetImages.selfie,
            title: 'Selfie',
            subTitle: "Selfie Realizada",
            trailingIcon: Icons.camera_alt_outlined,
            isCompleted: state.loanInformation.selfiePicture.path.isNotEmpty,
            onTap: () async {
              await context.push(AppRoutes.loanSelfie, extra: (File file) {
                homeCubit.addSelfieFile(file);
              });
            },
          ),
          const SizedBox(height: 10),
          CustomListTile(
            leadingIcon: AssetImages.references,
            title: 'Referencias',
            subTitle:
                "${state.loanInformation.firstReference.relationship} y ${state.loanInformation.secondReference.relationship}",
            trailingIcon: Icons.arrow_forward,
            isCompleted: state
                    .loanInformation.firstReference.relationship.isNotEmpty &&
                state.loanInformation.secondReference.relationship.isNotEmpty,
            onTap: () {
              context.push(AppRoutes.loanRefences);
            },
          ),
          const SizedBox(height: 10),
          CustomListTile(
            leadingIcon: AssetImages.bank,
            title: 'Cuenta Bancaria',
            subTitle: "TODO",
            isCompleted: state.loanInformation.bankInformation.isCompleted,
            trailingIcon: Icons.arrow_forward,
            onTap: () {},
          ),
          const SizedBox(height: 50),
          GestureDetector(
            onTap: () {},
            child: Container(
              height: 62,
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
                      'Hacer la solicitud',
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
    );
  }

  Widget step() {
    return Container();
  }
}
