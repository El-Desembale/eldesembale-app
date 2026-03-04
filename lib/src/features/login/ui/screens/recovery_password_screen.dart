import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../utils/colors.dart';
import '../../../../utils/modalbottomsheet.dart';
import '../../cubit/login_cubit.dart';
import '../widgets/otp_form.dart';
import 'login_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {});
    });
  }

  Future<void> _sendOtp() async {
    final sent = await widget.loginCubit.sendOtpVerification(context: context);
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
          children: [
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.45,
              child: const Column(
                children: [],
              ),
            ),
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
              "Recupera tu\ncontraseña",
              textAlign: TextAlign.start,
              style: TextStyle(
                fontFamily: "Unbounded",
                fontSize: 40,
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
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(200, 243, 248, 241),
              ),
            ),
          ),
          const Spacer(),
          FloatingLabelInput(
            label: "Contraseña",
            inputFormatters: [
              LengthLimitingTextInputFormatter(10),
              FilteringTextInputFormatter.digitsOnly,
            ],
            icon: Icons.lock_outline,
            onChanged: (value) {
              setState(() {});
            },
            controller: passwordController,
            keyboardType: TextInputType.phone,
            obscureText: obscurePassword,
            onPressedHint: () {
              setState(() {
                obscurePassword = !obscurePassword;
              });
            },
          ),
          FloatingLabelInput(
            label: "Confirmar contraseña",
            inputFormatters: [
              LengthLimitingTextInputFormatter(10),
              FilteringTextInputFormatter.digitsOnly,
            ],
            icon: Icons.lock_outline,
            onChanged: (value) {
              setState(() {});
            },
            controller: passwordConfirmController,
            keyboardType: TextInputType.phone,
            obscureText: obscurePassword,
            onPressedHint: () {
              setState(() {
                obscurePassword = !obscurePassword;
              });
            },
          ),
          const Spacer(),
          InkWell(
            onTap: () async {
              FocusScope.of(context).unfocus();
              if (passwordController.text == passwordConfirmController.text) {
                await widget.loginCubit.changePassword(
                  context: context,
                  password: passwordController.text,
                );
              }
            },
            child: Container(
              height: 72,
              margin: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              decoration: BoxDecoration(
                color: passwordController.text != passwordConfirmController.text
                    ? Colors.white.withOpacity(0.08)
                    : const Color.fromRGBO(47, 255, 0, 1),
                borderRadius: BorderRadius.circular(48),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 25),
                    child: Text(
                      'Continuar',
                      style: TextStyle(
                        color: passwordController.text !=
                                passwordConfirmController.text
                            ? Colors.white.withOpacity(0.16)
                            : Colors.black,
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
                        color: passwordController.text !=
                                passwordConfirmController.text
                            ? Colors.white.withOpacity(0.16)
                            : const Color.fromRGBO(255, 255, 255, 0.5),
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
              "Recupera tu\ncontraseña",
              textAlign: TextAlign.start,
              style: TextStyle(
                fontFamily: "Unbounded",
                fontSize: 40,
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
                  ? "Ingresa el código que te enviamos al ${state.countryCode} ${widget.loginCubit.phoneController.text}"
                  : "Te enviaremos un código al ${state.countryCode} ${widget.loginCubit.phoneController.text}",
              textAlign: TextAlign.start,
              style: const TextStyle(
                fontSize: 16,
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
          InkWell(
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
            child: Container(
              height: 72,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: _otpSent && state.otp.length != 6
                    ? Colors.white.withOpacity(0.08)
                    : const Color.fromRGBO(47, 255, 0, 1),
                borderRadius: BorderRadius.circular(48),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 25),
                    child: Text(
                      _otpSent ? 'Continuar' : 'Enviar código',
                      style: TextStyle(
                        color: _otpSent && state.otp.length != 6
                            ? Colors.white.withOpacity(0.16)
                            : Colors.black,
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
                        color: _otpSent && state.otp.length != 6
                            ? Colors.white.withOpacity(0.16)
                            : const Color.fromRGBO(255, 255, 255, 0.5),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Icon(
                        _otpSent ? Icons.arrow_forward : Icons.send_outlined,
                        color: Colors.black,
                        size: 26,
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
