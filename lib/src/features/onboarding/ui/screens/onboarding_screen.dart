import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../generated/l10n.dart';

import '../../../../config/routes/routes.dart';
import '../../../../core/preferences/shared_preference.dart';
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
        color: Colors.black,
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
              height: 72,
              margin: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(47, 255, 0, 1),
                borderRadius: BorderRadius.circular(48),
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
          padding: const EdgeInsets.only(left: 5),
          child: Text(
            title,
            textAlign: TextAlign.start,
            style: const TextStyle(
              fontFamily: "Unbounded",
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Text(
            description,
            textAlign: TextAlign.start,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
