import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../utils/colors.dart';
import '../../../../utils/modalbottomsheet.dart';
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

  @override
  void initState() {
    super.initState();
    // Escuchar los cambios de página
    _pageController.addListener(() {
      // Llama a setState cuando la página cambia para actualizar el botón
      setState(() {});
    });
    widget.loginCubit.sendOtpVerification(context: context);
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
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      const SizedBox(width: 20),
                      const Icon(
                        Icons.lock_outline,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Contraseña",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            TextFormField(
                              onChanged: (value) {
                                setState(() {});
                              },
                              obscureText: obscurePassword,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(10),
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              controller: passwordController,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                              decoration: const InputDecoration(
                                alignLabelWithHint: true,
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.auto,
                                labelStyle: TextStyle(
                                  color: Colors.white,
                                ),
                                fillColor: Colors.transparent,
                                errorBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                focusedErrorBorder: InputBorder.none,
                                border: InputBorder.none,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                        icon: Icon(
                          obscurePassword
                              ? Icons.remove_red_eye_sharp
                              : Icons.remove_red_eye_outlined,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      const SizedBox(width: 20),
                      const Icon(
                        Icons.lock_outline,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Contraseña",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            TextFormField(
                              onChanged: (value) {
                                setState(() {});
                              },
                              obscureText: obscurePassword,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(10),
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              controller: passwordConfirmController,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                              decoration: const InputDecoration(
                                alignLabelWithHint: true,
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.auto,
                                labelStyle: TextStyle(
                                  color: Colors.white,
                                ),
                                fillColor: Colors.transparent,
                                errorBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                focusedErrorBorder: InputBorder.none,
                                border: InputBorder.none,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                        icon: Icon(
                          obscurePassword
                              ? Icons.remove_red_eye_sharp
                              : Icons.remove_red_eye_outlined,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 20),
                    ],
                  ),
                ),
              ),
            ],
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
              "Ingresa el código que te enviamos al ${state.countryCode} ${widget.loginCubit.phoneController.text}",
              textAlign: TextAlign.start,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(200, 243, 248, 241),
              ),
            ),
          ),
          const Spacer(),
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
              if (state.otp.length == 6) {
                bool validated = await widget.loginCubit.validateOtp(
                  context: context,
                );
                if (validated) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeIn,
                  );
                } else {
                  ModalbottomsheetUtils.invalidOtp(
                    context,
                  );
                }
              }
              setState(() {});
            },
            child: Container(
              height: 72,
              margin: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              decoration: BoxDecoration(
                color: state.otp.length != 6
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
                        color: state.otp.length != 6
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
                        color: state.otp.length != 6
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
          const Spacer(),
        ],
      ),
    );
  }
}
