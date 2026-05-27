import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../generated/l10n.dart';

import '../../../../config/routes/routes.dart';
import '../../../../core/preferences/shared_preference.dart';
import '../../../../utils/design_tokens.dart';
import '../../../../utils/images.dart';

class OnboardingScreen extends StatefulWidget {
  final LocalSharedPreferences prefs;
  const OnboardingScreen({
    super.key,
    required this.prefs,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController(initialPage: 0);

  int page = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: kBgScreen,
      ),
      child: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildOnboardingStep(
                  context,
                  S.of(context).onboardingTitleStepOne,
                  S.of(context).onboardingsubitleStepOne,
                  Image.asset(
                    AssetImages.onboarding1,
                  ),
                ),
                _buildOnboardingStep(
                  context,
                  S.of(context).onboardingTitleStepTwo,
                  S.of(context).onboardingsubitleStepTwo,
                  Image.asset(
                    AssetImages.onboarding2,
                  ),
                ),
                _buildOnboardingStep(
                  context,
                  S.of(context).onboardingTitleStepThree,
                  S.of(context).onboardingsubitleStepThree,
                  Image.asset(
                    AssetImages.onboarding3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 50),
          InkWell(
            onTap: () async {
              if (_pageController.hasClients && _pageController.page != 2.0) {
                await _pageController.nextPage(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              } else {
                widget.prefs.isFirstTime = false;
                context.go(AppRoutes.login);
              }

              setState(() {});
            },
            child: Container(
              height: 64,
              margin: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: kPrimaryGreen,
                borderRadius: BorderRadius.circular(kRadiusButton),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 25),
                    child: Text(
                      _pageController.hasClients && _pageController.page == 2.0
                          ? 'Empezar'
                          : 'Continuar',
                      style: const TextStyle(
                        color: kPrimaryGreenDeep,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Container(
                      width: 56,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.28),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.arrow_forward,
                        color: kPrimaryGreenDeep,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildOnboardingStep(
    BuildContext context,
    String title,
    String description,
    Widget? widget,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.45,
            child: Center(
              child: widget ?? Container(),
            ),
          ),
        ),
        Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 8, right: 8),
          child: Text(
            title,
            textAlign: TextAlign.start,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: kDisplayFont,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: kTextPrimary,
              height: 1.15,
            ),
          ),
        ),
        Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            description,
            textAlign: TextAlign.start,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              color: kTextSecondary,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}
