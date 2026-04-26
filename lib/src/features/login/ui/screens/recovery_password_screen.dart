import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../utils/colors.dart';
import '../../../../utils/images.dart';
import '../../../../utils/modalbottomsheet.dart';
import '../../../shared/widgets/floating_label_input.dart';
import '../../../shared/widgets/primary_action_button.dart';
import '../../cubit/login_cubit.dart';
import '../widgets/otp_form.dart';

class RecoveryPasswordScreen extends StatefulWidget {
  const RecoveryPasswordScreen({
    super.key,
    required this.loginCubit,
  });
  final LoginCubit loginCubit;
  @override
  State<RecoveryPasswordScreen> createState() => _RecoveryPasswordScreenState();
}

class _RecoveryPasswordScreenState extends State<RecoveryPasswordScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  bool obscurePassword = true;
  bool _otpSent = false;
  String? _userEmail;

  String get _maskedEmail {
    if (_userEmail == null || !_userEmail!.contains('@')) return '';
    final parts = _userEmail!.split('@');
    final name = parts[0];
    final domain = parts[1];
    if (name.length <= 2) return '${name[0]}***@$domain';
    return '${name[0]}${'*' * (name.length - 2)}${name[name.length - 1]}@$domain';
  }

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {});
    });
  }

  Future<void> _sendOtp() async {
    // First get the email associated with this phone
    final email = await widget.loginCubit.getEmailByPhone(
      phone: widget.loginCubit.phoneController.text,
    );
    if (email == null || email.isEmpty) {
      if (mounted) {
        ModalbottomsheetUtils.customError(
          context,
          'Correo no encontrado',
          'No se encontró un correo asociado a este número.',
        );
      }
      return;
    }
    _userEmail = email;
    final sent = await widget.loginCubit.sendOtpVerification(
      email: email,
      context: context,
    );
    if (mounted) {
      setState(() {
        _otpSent = sent;
      });
    }
  }

  @override
  void dispose() {
    if (_pageController.hasClients && _pageController.page != 0) {
      _pageController.jumpTo(0);
    }

    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginCubit, LoginState>(
      bloc: widget.loginCubit,
      listener: (BuildContext context, LoginState state) {},
      builder: (BuildContext context, LoginState state) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          floatingActionButton: IconButton(
            onPressed: () {
              if (_pageController.hasClients && _pageController.page != 0) {
                _pageController.jumpTo(0);
              } else {
                context.pop();
              }
            },
            icon: Container(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.16),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
          body: Stack(
            children: [
              _body(context, state),
              if (state.isLoading)
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  color: Colors.white.withOpacity(0.5),
                  child: const Center(
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          UIColors.primaryYellow,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _body(BuildContext context, LoginState state) {
    return GestureDetector(
      onTap: () {
        // Quita el foco cuando se toca fuera del OtpInputWidget
        FocusScope.of(context).unfocus();
      },
      child: Container(
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 6, 16, 0),
        ),
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.zero,
          children: [
            Image.asset(AssetImages.login),
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.5,
              child: PageView(
                physics: const NeverScrollableScrollPhysics(),
                controller: _pageController,
                children: [
                  _validateOtp(state),
                  _newPassword(state),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordConfirmController = TextEditingController();
  Widget _newPassword(LoginState state) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.45,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 5),
            child: const Text(
              "Recupera tu contraseña",
              textAlign: TextAlign.start,
              maxLines: 1,
              style: TextStyle(
                fontFamily: "Unbounded",
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 5),
            child: const Text(
              "Establece tu contraseña",
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(200, 243, 248, 241),
              ),
            ),
          ),
          const Spacer(),
          FloatingLabelInput(
            label: "Contraseña",
            inputFormatters: [
              LengthLimitingTextInputFormatter(20),
            ],
            icon: Icons.lock_outline,
            onChanged: (value) {
              setState(() {});
            },
            controller: passwordController,
            keyboardType: TextInputType.visiblePassword,
            obscureText: obscurePassword,
            onPressedHint: () {
              setState(() {
                obscurePassword = !obscurePassword;
              });
            },
          ),
          const SizedBox(height: 8),
          FloatingLabelInput(
            label: "Confirmar contraseña",
            inputFormatters: [
              LengthLimitingTextInputFormatter(20),
            ],
            icon: Icons.lock_outline,
            onChanged: (value) {
              setState(() {});
            },
            controller: passwordConfirmController,
            keyboardType: TextInputType.visiblePassword,
            obscureText: obscurePassword,
            onPressedHint: () {
              setState(() {
                obscurePassword = !obscurePassword;
              });
            },
          ),
          const SizedBox(height: 12),
          _buildPasswordCheck("Mínimo 8 caracteres", passwordController.text.length >= 8),
          const SizedBox(height: 4),
          _buildPasswordCheck("Contiene al menos una letra", passwordController.text.contains(RegExp(r'[a-zA-Z]'))),
          const SizedBox(height: 4),
          _buildPasswordCheck("Contiene al menos un número", passwordController.text.contains(RegExp(r'[0-9]'))),
          const SizedBox(height: 4),
          _buildPasswordCheck("Las contraseñas coinciden", passwordController.text.isNotEmpty && passwordController.text == passwordConfirmController.text),
          const Spacer(),
          Builder(
            builder: (context) {
              final pwd = passwordController.text;
              final valid = pwd.length >= 8 &&
                  pwd.contains(RegExp(r'[a-zA-Z]')) &&
                  pwd.contains(RegExp(r'[0-9]')) &&
                  pwd == passwordConfirmController.text;
              return PrimaryActionButton(
                label: 'Continuar',
                enabled: valid,
                onTap: () async {
                  if (!valid) return;
                  FocusScope.of(context).unfocus();
                  await widget.loginCubit.changePassword(
                    context: context,
                    password: pwd,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _validateOtp(LoginState state) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 5),
            child: const Text(
              "Recupera tu contraseña",
              textAlign: TextAlign.start,
              maxLines: 1,
              style: TextStyle(
                fontFamily: "Unbounded",
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 5),
            child: Text(
              _otpSent
                  ? "Ingresa el código que enviamos a $_maskedEmail"
                  : "Te enviaremos un código a tu correo electrónico registrado",
              textAlign: TextAlign.start,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(200, 243, 248, 241),
              ),
            ),
          ),
          const Spacer(),
          if (_otpSent)
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: OtpInputWidget(
                    onChanged: widget.loginCubit.updateOtp,
                  ),
                ),
              ],
            ),
          const Spacer(),
          PrimaryActionButton(
            label: _otpSent ? 'Continuar' : 'Enviar código',
            icon: _otpSent ? Icons.arrow_forward : Icons.send_outlined,
            enabled: !_otpSent || state.otp.length == 6,
            onTap: () async {
              FocusScope.of(context).unfocus();
              if (!_otpSent) {
                await _sendOtp();
              } else if (state.otp.length == 6) {
                bool validated = await widget.loginCubit.validateOtp(
                  context: context,
                );
                if (validated) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeIn,
                  );
                } else {
                  ModalbottomsheetUtils.invalidOtp(context);
                }
              }
              setState(() {});
            },
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildPasswordCheck(String label, bool passed) {
    return Row(
      children: [
        Icon(
          passed ? Icons.check_circle : Icons.radio_button_unchecked,
          color: passed ? const Color.fromRGBO(47, 255, 0, 1) : Colors.white24,
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: passed ? Colors.white70 : Colors.white30,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
