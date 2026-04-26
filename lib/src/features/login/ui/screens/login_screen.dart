import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/routes.dart';
import '../../../../utils/images.dart';
import '../../../../utils/modalbottomsheet.dart';
import '../../../shared/widgets/floating_label_input.dart';
import '../../cubit/login_cubit.dart';
import '../widgets/otp_form.dart';
import 'terms_screen.dart';

const _green = Color.fromRGBO(47, 255, 0, 1);
const _bg = Color.fromARGB(255, 6, 16, 0);

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
  final PageController _pageController = PageController(initialPage: 0);
  bool obscurePassword = true;

  @override
  void initState() {
    super.initState();
    widget.loginCubit.phoneController.clear();
    widget.loginCubit.passwordController.clear();
    widget.loginCubit.clear();
    _pageController.addListener(() {
      setState(() {});
    });
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
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            extendBodyBehindAppBar: true,
            backgroundColor: _bg,
            body: Stack(
              children: [
                _body(context, state),
                if (_pageController.hasClients && _pageController.page! > 0.0)
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 8,
                    left: 16,
                    child: _backButton(),
                  ),
                if (state.isLoading) _loadingOverlay(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _backButton() {
    return GestureDetector(
      onTap: () => _pageController.jumpToPage(0),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _loadingOverlay() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withOpacity(0.6),
      child: const Center(
        child: SizedBox(
          width: 48,
          height: 48,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(_green),
            strokeWidth: 3,
          ),
        ),
      ),
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
    final isFullPage = _pageController.hasClients &&
        (_pageController.page! == 3.0 || _pageController.page! == 4.0);
    return Container(
      color: _bg,
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.zero,
        children: [
          if (!isFullPage) _buildImage(),
          if (isFullPage) SizedBox(height: MediaQuery.of(context).padding.top + 56),
          SizedBox(
            height: isFullPage
                ? MediaQuery.sizeOf(context).height * 0.85
                : MediaQuery.sizeOf(context).height * 0.4,
            child: PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _pageController,
              children: [
                _phoneForm(state),
                _passwordForm(state),
                _registerForm(state),
                _registerCompleteForm(state),
                _newPassword(state),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── HEADER HELPER ───
  Widget _header(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: "Unbounded",
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: Colors.white.withOpacity(0.5),
            height: 1.4,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════
  // PAGE 0 – Phone
  // ═══════════════════════════════════════════
  Widget _phoneForm(LoginState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header("Inicia sesión o regístrate", "Ingresa tu número de celular"),
          const SizedBox(height: 24),
          Row(
            children: [
              // Country code
              Container(
                width: 110,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: CountryCodePicker(
                  padding: EdgeInsets.zero,
                  boxDecoration: const BoxDecoration(color: Colors.transparent),
                  backgroundColor: Colors.transparent,
                  textStyle: const TextStyle(color: Colors.white, fontSize: 15),
                  onChanged: (country) {
                    if (country.dialCode != null) {
                      widget.loginCubit.updateCountryCode(country.dialCode!);
                    }
                  },
                  initialSelection: 'CO',
                  alignLeft: true,
                ),
              ),
              const SizedBox(width: 10),
              // Phone input
              Expanded(
                child: FloatingLabelInput(
                  label: "Celular",
                  icon: Icons.phone_outlined,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(10),
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: (value) => setState(() {}),
                  controller: widget.loginCubit.phoneController,
                  keyboardType: TextInputType.phone,
                ),
              ),
            ],
          ),
          const Spacer(),
          _actionButton(
            enabled: widget.loginCubit.phoneController.text.length >= 10,
            onTap: () async {
              FocusScope.of(context).unfocus();
              if (widget.loginCubit.phoneController.text.length >= 10) {
                await widget.loginCubit.validatePhone(
                  context: context,
                  pageController: _pageController,
                );
              }
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // PAGE 1 – Password
  // ═══════════════════════════════════════════
  Widget _passwordForm(LoginState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header("Inicio de sesión", "Ingresa tu contraseña"),
          const SizedBox(height: 24),
          FloatingLabelInput(
            label: "Contraseña",
            icon: Icons.lock_outline,
            inputFormatters: [
              LengthLimitingTextInputFormatter(20),
            ],
            onChanged: (value) => setState(() {}),
            controller: widget.loginCubit.passwordController,
            keyboardType: TextInputType.visiblePassword,
            obscureText: obscurePassword,
            onToggleObscure: () {
              setState(() => obscurePassword = !obscurePassword);
            },
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.06),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              onPressed: () => context.push(AppRoutes.recoveryPassword),
              child: const Text(
                'Olvidé mi contraseña',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ),
          ),
          const Spacer(),
          ValueListenableBuilder(
            valueListenable: widget.loginCubit.passwordController,
            builder: (context, value, _) {
              final enabled = value.text.length >= 8;
              return _actionButton(
                enabled: enabled,
                onTap: () async {
                  if (enabled) {
                    FocusScope.of(context).unfocus();
                    await widget.loginCubit.login(context: context);
                  }
                },
              );
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // PAGE 2 – OTP
  // ═══════════════════════════════════════════
  Widget _registerForm(LoginState state) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header("Regístrate", "Ingresa el código que enviamos a tu correo"),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OtpInputWidget(
                    onChanged: widget.loginCubit.updateOtp,
                  ),
                ),
              ],
            ),
            const Spacer(),
            _actionButton(
              enabled: state.otp.length == 6,
              onTap: () async {
                FocusScope.of(context).unfocus();
                if (state.otp.length == 6) {
                  bool validated = await widget.loginCubit.validateOtp(
                    context: context,
                  );
                  if (validated) {
                    _pageController.jumpToPage(4);
                  } else {
                    ModalbottomsheetUtils.invalidOtp(context);
                  }
                }
                setState(() {});
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // PAGE 3 – Registration form
  // ═══════════════════════════════════════════
  String name = "";
  String lastName = "";
  String email = "";
  String documentType = "CC";
  String documentNumber = "";
  bool checkboxValue = false;

  bool get _isFormValid =>
      checkboxValue &&
      name.isNotEmpty &&
      lastName.isNotEmpty &&
      email.isNotEmpty &&
      documentType.isNotEmpty &&
      documentNumber.isNotEmpty;

  Widget _registerCompleteForm(LoginState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _header("Regístrate", "Ingresa tus datos básicos"),
            const SizedBox(height: 16),
            FloatingLabelInput(
              label: "Nombre(s)",
              icon: Icons.person_outline,
              inputFormatters: const [],
              onChanged: (v) { name = v; setState(() {}); },
              keyboardType: TextInputType.name,
            ),
            const SizedBox(height: 12),
            FloatingLabelInput(
              label: "Apellido(s)",
              icon: Icons.person_outline,
              inputFormatters: const [],
              onChanged: (v) { lastName = v; setState(() {}); },
              keyboardType: TextInputType.name,
            ),
            const SizedBox(height: 12),
            FloatingLabelInput(
              label: "Correo electrónico",
              icon: Icons.email_outlined,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9@._+-]')),
              ],
              onChanged: (v) { email = v; setState(() {}); },
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            // Phone (read-only, verified)
            Container(
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.phone_outlined, color: Colors.white38, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    "${state.countryCode} ",
                    style: const TextStyle(color: Colors.white38, fontSize: 15),
                  ),
                  Text(
                    widget.loginCubit.phoneController.text,
                    style: const TextStyle(color: Colors.white54, fontSize: 15),
                  ),
                  const Spacer(),
                  const Icon(Icons.check_circle, color: _green, size: 18),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Document type + number
            Row(
              children: [
                Container(
                  width: 90,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(0.06)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: documentType,
                      isExpanded: true,
                      dropdownColor: const Color(0xFF0d1f0d),
                      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white30, size: 18),
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                      items: ["CC", "TI", "PP"].map((v) {
                        return DropdownMenuItem(value: v, child: Text(v));
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => documentType = v);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FloatingLabelInput(
                    label: "Nº documento",
                    icon: Icons.badge_outlined,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(10),
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: (v) { documentNumber = v; setState(() {}); },
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Terms
            Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => checkboxValue = !checkboxValue),
                  child: Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: checkboxValue ? _green : Colors.white30,
                            width: 2,
                          ),
                          color: checkboxValue ? _green : Colors.transparent,
                        ),
                        child: checkboxValue
                            ? const Icon(Icons.check, size: 14, color: Colors.black)
                            : null,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "Acepto los ",
                        style: TextStyle(color: Colors.white60, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TermsScreen(),
                    ),
                  ),
                  child: const Text(
                    "términos y condiciones",
                    style: TextStyle(
                      color: _green,
                      fontSize: 13,
                      decoration: TextDecoration.underline,
                      decorationColor: _green,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _actionButton(
              enabled: _isFormValid,
              onTap: () async {
                FocusScope.of(context).unfocus();
                if (_isFormValid) {
                  final sent = await widget.loginCubit.sendOtpVerification(
                    email: email,
                    context: context,
                  );
                  if (sent) {
                    _pageController.jumpToPage(2);
                  }
                }
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // PAGE 4 – Create password
  // ═══════════════════════════════════════════
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordConfirmController = TextEditingController();

  Widget _newPassword(LoginState state) {
    final pwd = passwordController.text;
    final hasMinLength = pwd.length >= 8;
    final hasLetter = pwd.contains(RegExp(r'[a-zA-Z]'));
    final hasNumber = pwd.contains(RegExp(r'[0-9]'));
    final passwordsMatch = pwd.isNotEmpty &&
        pwd == passwordConfirmController.text;
    final allValid = hasMinLength && hasLetter && hasNumber && passwordsMatch;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _header("Crea tu contraseña", "Establece una contraseña segura"),
            const SizedBox(height: 24),
            FloatingLabelInput(
              label: "Contraseña",
              icon: Icons.lock_outline,
              inputFormatters: [
                LengthLimitingTextInputFormatter(20),
              ],
              onChanged: (value) => setState(() {}),
              obscureText: obscurePassword,
              onToggleObscure: () {
                setState(() => obscurePassword = !obscurePassword);
              },
              controller: passwordController,
              keyboardType: TextInputType.visiblePassword,
            ),
            const SizedBox(height: 12),
            FloatingLabelInput(
              label: "Confirmar contraseña",
              icon: Icons.lock_outline,
              inputFormatters: [
                LengthLimitingTextInputFormatter(20),
              ],
              onChanged: (value) => setState(() {}),
              obscureText: obscurePassword,
              onToggleObscure: () {
                setState(() => obscurePassword = !obscurePassword);
              },
              controller: passwordConfirmController,
              keyboardType: TextInputType.visiblePassword,
            ),
            const SizedBox(height: 16),
            _passwordCheck("Mínimo 8 caracteres", hasMinLength),
            const SizedBox(height: 6),
            _passwordCheck("Contiene al menos una letra", hasLetter),
            const SizedBox(height: 6),
            _passwordCheck("Contiene al menos un número", hasNumber),
            const SizedBox(height: 6),
            _passwordCheck("Las contraseñas coinciden", passwordsMatch),
            const SizedBox(height: 24),
            _actionButton(
              enabled: allValid,
              onTap: () async {
                FocusScope.of(context).unfocus();
                if (allValid) {
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
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }


  // ═══════════════════════════════════════════
  // PASSWORD CHECK ITEM
  // ═══════════════════════════════════════════
  Widget _passwordCheck(String label, bool passed) {
    return Row(
      children: [
        Icon(
          passed ? Icons.check_circle : Icons.radio_button_unchecked,
          color: passed ? _green : Colors.white24,
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

  // ═══════════════════════════════════════════
  // ACTION BUTTON
  // ═══════════════════════════════════════════
  Widget _actionButton({
    required bool enabled,
    required VoidCallback onTap,
    String label = "Continuar",
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 58,
        decoration: BoxDecoration(
          color: enabled ? _green : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Text(
                label,
                style: TextStyle(
                  color: enabled ? Colors.black : Colors.white24,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: enabled
                      ? Colors.black.withOpacity(0.15)
                      : Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: enabled ? Colors.black : Colors.white24,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

