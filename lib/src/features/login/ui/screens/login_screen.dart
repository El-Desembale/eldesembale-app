import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/routes.dart';
import '../../../../utils/colors.dart';
import '../../../../utils/images.dart';
import '../../../../utils/modalbottomsheet.dart';
import '../../cubit/login_cubit.dart';
import '../widgets/otp_form.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.loginCubit,
  });
  final LoginCubit loginCubit;
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final PageController _pageController = PageController(
    initialPage: 0,
  );
  bool obscurePassword = true;

  @override
  void initState() {
    _pageController.addListener(() {
      // Llama a setState cuando la página cambia para actualizar el botón
      setState(() {});
    });
    super.initState();
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
          floatingActionButton: _pageController.hasClients &&
                  _pageController.page! > 0.0
              ? IconButton(
                  onPressed: () {
                    _pageController.jumpToPage(
                      0,
                    );
                  },
                  icon: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
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
                )
              : null,
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

  Widget _buildImage() {
    if (_pageController.hasClients) {
      final currentPage = _pageController.page!;

      if (currentPage < 2.0) {
        return Image.asset(AssetImages.login);
      } else if (currentPage == 3.0 || currentPage == 4.0) {
        return Container();
      } else {
        return Image.asset(AssetImages.register);
      }
    }

    return Image.asset(AssetImages.login);
  }

  Widget _body(BuildContext context, LoginState state) {
    return Container(
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 6, 16, 0),
      ),
      child: ListView(
        children: [
          _buildImage(),
          SizedBox(
            height: _pageController.hasClients &&
                    (_pageController.page! == 3.0 ||
                        _pageController.page! == 4.0)
                ? MediaQuery.sizeOf(context).height * 0.95
                : MediaQuery.sizeOf(context).height * 0.5,
            child: PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _pageController,
              children: [
                _phoneForm(state),
                _passwordForm(state),
                _registerForm(state),
                _registerCompliteForm(state),
                _newPassword(state)
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _phoneForm(LoginState state) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 5),
            child: const Text(
              "Inicio\nde sesión",
              textAlign: TextAlign.start,
              style: TextStyle(
                fontFamily: "Unbounded",
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: CountryCodePicker(
                  boxDecoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  backgroundColor: Colors.white.withOpacity(0.16),
                  onChanged: (country) {
                    if (country.dialCode != null) {
                      widget.loginCubit.updateCountryCode(country.dialCode!);
                    }
                  },
                  initialSelection: 'CO',
                  alignLeft: true,
                ),
              ),
              Expanded(
                flex: 5,
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
                        Icons.phone_outlined,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Celular",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            TextFormField(
                              onChanged: (value) {
                                setState(() {});
                              },
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(10),
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              controller: widget.loginCubit.phoneController,
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
              if (widget.loginCubit.phoneController.text.length >= 10) {
                await widget.loginCubit.validatePhone(
                  context: context,
                  pageController: _pageController,
                );
              }
            },
            child: Container(
              height: 72,
              margin: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              decoration: BoxDecoration(
                color: widget.loginCubit.phoneController.text.length < 10
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
                        color:
                            widget.loginCubit.phoneController.text.length < 10
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
                        color:
                            widget.loginCubit.phoneController.text.length < 10
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

  Widget _passwordForm(LoginState state) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 5),
            child: const Text(
              "Inicio\nde sesión",
              textAlign: TextAlign.start,
              style: TextStyle(
                fontFamily: "Unbounded",
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
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
                              style: const TextStyle(
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
                              controller: widget.loginCubit.passwordController,
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
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                  ),
                ),
                onPressed: () {
                  context.push(AppRoutes.recoveryPassword);
                },
                child: const Text(
                  'Olvidé mi contraseña',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: () async {
              setState(() {});
              if (widget.loginCubit.passwordController.text.length >= 6) {
                FocusScope.of(context).unfocus();
                await widget.loginCubit.login(context: context);
              }
            },
            child: Container(
              height: 72,
              margin: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              decoration: BoxDecoration(
                color: widget.loginCubit.passwordController.text.length < 6
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
                        color:
                            widget.loginCubit.passwordController.text.length < 6
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
                        color:
                            widget.loginCubit.passwordController.text.length <
                                    10
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

  Widget _registerForm(LoginState state) {
    return GestureDetector(
      onTap: () {
        print("out");
        FocusScope.of(context).unfocus();
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.4,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 5),
              child: const Text(
                "Regístrate",
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
                "Ingresa el código que te enviamos",
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 20,
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
      ),
    );
  }

  String name = "";
  String lastName = "";
  String email = "";
  String documentType = "";
  String documentNumber = "";
  bool checkboxValue = false;
  get isValid =>
      !checkboxValue ||
      name.isEmpty ||
      lastName.isEmpty ||
      email.isEmpty ||
      documentType.isEmpty ||
      documentNumber.isEmpty;
  Widget _registerCompliteForm(LoginState state) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const Spacer(),
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 5),
            child: const Text(
              "Regístrate",
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
              "Ingresa tus datos basicos",
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(200, 243, 248, 241),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 5,
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
                        Icons.person_outline,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Nombre (s)",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            TextFormField(
                              onChanged: (value) {
                                name = value;
                                setState(() {});
                              },
                              keyboardType: TextInputType.name,
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
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 5,
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
                        Icons.person_outline,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Apellido (s)",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            TextFormField(
                              onChanged: (value) {
                                lastName = value;
                                setState(() {});
                              },
                              keyboardType: TextInputType.name,
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
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 5,
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
                        Icons.email_outlined,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Correo electrónico",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            TextFormField(
                              onChanged: (value) {
                                email = value;
                                setState(() {});
                              },
                              keyboardType: TextInputType.name,
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
                    ],
                  ),
                ),
              ),
            ],
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
                  onChanged: (country) {
                    if (country.dialCode != null) {
                      widget.loginCubit.updateCountryCode(country.dialCode!);
                    }
                  },
                  initialSelection: 'CO',
                  alignLeft: true,
                ),
              ),
              Expanded(
                flex: 5,
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
                        Icons.phone_outlined,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Celular",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            TextFormField(
                              enabled: false,
                              onChanged: (value) {
                                setState(() {});
                              },
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(10),
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              controller: widget.loginCubit.phoneController,
                              keyboardType: TextInputType.phone,
                              style: const TextStyle(
                                color: Colors.grey,
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
                      const Icon(
                        Icons.check_circle_outline,
                        size: 30,
                        color: Color.fromRGBO(47, 255, 0, 1),
                      ),
                      const SizedBox(width: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: DropdownButtonFormField(
                    items: ["CC", "TI", "PP"].map((String value) {
                      return DropdownMenuItem(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 20,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        documentType = value;
                      }
                    },
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 20),
                      filled: true,
                      fillColor: Colors.transparent,
                      errorBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                    ),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 20,
                    ),
                    dropdownColor:
                        Colors.white.withOpacity(0.16), // Color del dropdown
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 5,
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
                        Icons.person_pin_outlined,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Número de documento",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            TextFormField(
                              onChanged: (value) {
                                documentNumber = value;
                                setState(() {});
                              },
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(10),
                                FilteringTextInputFormatter.digitsOnly,
                              ],
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
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Checkbox.adaptive(
                shape: const CircleBorder(),
                value: checkboxValue,
                activeColor: const Color.fromRGBO(47, 255, 0, 1),
                onChanged: (value) {
                  setState(() {
                    checkboxValue = value!;
                  });
                },
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                checkColor: Colors.transparent,
                visualDensity: VisualDensity.adaptivePlatformDensity,
              ),
              const Text(
                "Acepto ",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              const Text(
                "Terminos y condiciones",
                style: TextStyle(
                  color: Colors.white,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.white,
                ),
              )
            ],
          ),
          const SizedBox(height: 20),
          InkWell(
            onTap: () async {
              FocusScope.of(context).unfocus();
              if (!isValid) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeIn,
                );
              }
            },
            child: Container(
              height: 72,
              margin: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              decoration: BoxDecoration(
                color: isValid
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
                        color: isValid
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
                        color: isValid
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

  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordConfirmController = TextEditingController();
  Widget _newPassword(LoginState state) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.45,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const Spacer(),
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 5),
            child: const Text(
              "Regístrate",
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
          SizedBox(height: 30),
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
                              style: const TextStyle(
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
          SizedBox(height: 30),
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
                              style: const TextStyle(
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
          SizedBox(height: 30),
          InkWell(
            onTap: () async {
              FocusScope.of(context).unfocus();
              if (passwordController.text == passwordConfirmController.text) {
                await widget.loginCubit.register(
                  context: context,
                  name: name,
                  lastName: lastName,
                  email: email,
                  documentType: documentType,
                  documentNumberm: documentNumber,
                  password: passwordController.text,
                  countryCode: state.countryCode,
                  user: widget.loginCubit.phoneController.text,
                );
              }
            },
            child: Container(
              height: 72,
              margin: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              decoration: BoxDecoration(
                color:
                    passwordController.text != passwordConfirmController.text &&
                            passwordController.text.isEmpty
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
                                    passwordConfirmController.text &&
                                passwordController.text.isEmpty
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
                                    passwordConfirmController.text &&
                                passwordController.text.isEmpty
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
}
