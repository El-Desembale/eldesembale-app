import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../config/auth/cubit/auth_cubit.dart';
import '../../../../../config/routes/routes.dart';
import '../../../../../core/di/injection_dependency.dart';
import '../../../../../utils/colors.dart';
import '../../../../../utils/design_tokens.dart';
import '../../../../../utils/images.dart';
import '../../../../../utils/modalbottomsheet.dart';
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
              backgroundColor: kSurfaceSoft,
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
          body: Stack(
            children: [
              _body(context, state),
              state.isLoading
                  ? Container(
                      color: Colors.black.withOpacity(0.5),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        );
      },
    );
  }

  Widget _body(BuildContext context, HomeState state) {
    return Container(
      decoration: const BoxDecoration(
        color: kBgScreen,
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
          SizedBox(height: MediaQuery.of(context).padding.top + 70),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Datos para finalizar',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 24),
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
            onTap: () => _showInvoiceOptions(context),
          ),
          const SizedBox(height: 10),
          CustomListTile(
            leadingIcon: AssetImages.ccPicture,
            title: 'Foto Cédula Frontal',
            subTitle: "Foto Realizada",
            trailingIcon: Icons.camera_alt_outlined,
            isCompleted: state.loanInformation.ccFrontalPicture.path.isNotEmpty,
            onTap: () => _showIdPhotoOptions(
              context,
              title: 'Foto Cédula Frontal',
              onFileSaved: (file) => homeCubit.addFrontIdFile(file),
            ),
          ),
          const SizedBox(height: 10),
          CustomListTile(
            leadingIcon: AssetImages.reverseCcPicture,
            title: 'Foto Cédula Posterior',
            subTitle: "Foto Realizada",
            trailingIcon: Icons.camera_alt_outlined,
            isCompleted: state.loanInformation.ccBackPicture.path.isNotEmpty,
            onTap: () => _showIdPhotoOptions(
              context,
              title: 'Foto Cédula Posterior',
              onFileSaved: (file) => homeCubit.addBackIdFile(file),
            ),
          ),
          const SizedBox(height: 10),
          CustomListTile(
            leadingIcon: AssetImages.selfie,
            title: 'Selfie',
            subTitle: "Selfie Realizada",
            trailingIcon: Icons.camera_alt_outlined,
            isCompleted: state.loanInformation.selfiePicture.path.isNotEmpty,
            onTap: () => _showSelfieOptions(context),
          ),
          const SizedBox(height: 10),
          CustomListTile(
            leadingIcon: AssetImages.references,
            title: 'Referencias',
            subTitle:
                '${state.loanInformation.firstReference.relationship}  ·  ${state.loanInformation.secondReference.relationship}',
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
            onTap: () {
              context.push(AppRoutes.loanBankAccount);
            },
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              if (state.loanInformation.isLoanInformationCompleted) {
                context.push(AppRoutes.loanConfirm);
              } else {
                ModalbottomsheetUtils.customError(
                  context,
                  "Faltan datos",
                  "Por favor completa todos los campos antes de continuar",
                );
              }
            },
            child: Container(
              height: 62,
              decoration: BoxDecoration(
                color: state.loanInformation.isLoanInformationCompleted
                    ? kPrimaryGreen
                    : kSurfaceSoft,
                borderRadius: BorderRadius.circular(12),
                border: state.loanInformation.isLoanInformationCompleted
                    ? null
                    : Border.all(color: kBorderFaint),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 25),
                    child: Text(
                      'Revisar y enviar',
                      style: TextStyle(
                        color: state.loanInformation.isLoanInformationCompleted
                            ? Colors.black
                            : kTextSecondary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: state.loanInformation.isLoanInformationCompleted
                            ? const Color.fromRGBO(0, 0, 0, 0.15)
                            : kBgScreen,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: state.loanInformation.isLoanInformationCompleted
                            ? Colors.black
                            : kTextSecondary,
                        size: 22,
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

  void _showSelfieOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color.fromARGB(255, 12, 28, 5),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Selfie',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Elige cómo deseas adjuntar la selfie',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 24),
                _OptionButton(
                  icon: Icons.camera_front_outlined,
                  label: 'Tomar selfie',
                  description: 'Usa la cámara frontal para tomarte una foto',
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    await context.push(
                      AppRoutes.loanCamera,
                      extra: {
                        'onFileSelected': (File file) {
                          homeCubit.addSelfieFile(file);
                        },
                        'isSelfie': true,
                      },
                    );
                  },
                ),
                const SizedBox(height: 12),
                _OptionButton(
                  icon: Icons.upload_file_outlined,
                  label: 'Subir imagen',
                  description: 'Selecciona una foto desde tu galería',
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    final picked = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 85,
                    );
                    if (picked != null) homeCubit.addSelfieFile(File(picked.path));
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showIdPhotoOptions(
    BuildContext context, {
    required String title,
    required void Function(File) onFileSaved,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color.fromARGB(255, 12, 28, 5),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Elige cómo deseas adjuntar la foto',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 24),
                _OptionButton(
                  icon: Icons.camera_alt_outlined,
                  label: 'Tomar foto',
                  description: 'Usa la cámara para fotografiar el documento',
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    await context.push(
                      AppRoutes.loanCamera,
                      extra: {
                        'onFileSelected': onFileSaved,
                        'isSelfie': false,
                      },
                    );
                  },
                ),
                const SizedBox(height: 12),
                _OptionButton(
                  icon: Icons.upload_file_outlined,
                  label: 'Subir imagen',
                  description: 'Selecciona una foto desde tu galería',
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    final picked = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 85,
                    );
                    if (picked != null) onFileSaved(File(picked.path));
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showInvoiceOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color.fromARGB(255, 12, 28, 5),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Adjuntar Factura EPM',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Elige cómo deseas adjuntar la factura',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 24),
                _OptionButton(
                  icon: Icons.camera_alt_outlined,
                  label: 'Tomar foto',
                  description: 'Usa la cámara para fotografiar la factura',
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    await context.push(
                      AppRoutes.loanCamera,
                      extra: {
                        'onFileSelected': (File file) {
                          homeCubit.addEmpInvoiceFile(file);
                        },
                        'isSelfie': false,
                      },
                    );
                  },
                ),
                const SizedBox(height: 12),
                _OptionButton(
                  icon: Icons.upload_file_outlined,
                  label: 'Subir archivo',
                  description:
                      'Selecciona un PDF o imagen desde tu dispositivo',
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
                      withData: true,
                    );
                    if (result != null) {
                      final file = await LoanDataCollectScreen._platformFileToFile(result.files.first);
                      if (file != null) homeCubit.addEmpInvoiceFile(file);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Convierte un PlatformFile a File, usando bytes si path es null (dispositivos físicos / cloud)
  static Future<File?> _platformFileToFile(PlatformFile pf) async {
    if (pf.path != null) return File(pf.path!);
    if (pf.bytes != null) {
      final dir = await getTemporaryDirectory();
      final tmp = File('${dir.path}/${pf.name}');
      await tmp.writeAsBytes(pf.bytes!);
      return tmp;
    }
    return null;
  }
}

class _OptionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onTap;

  const _OptionButton({
    required this.icon,
    required this.label,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: kPrimaryGreenSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon,
                  color: kPrimaryGreen, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.45),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                color: Colors.white.withOpacity(0.3), size: 16),
          ],
        ),
      ),
    );
  }
}
