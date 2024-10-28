// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `With Taxi Seguro`
  String get onboardingTitle {
    return Intl.message(
      'With Taxi Seguro',
      name: 'onboardingTitle',
      desc: '',
      args: [],
    );
  }

  /// `Travel`
  String get onboardingTravel {
    return Intl.message(
      'Travel',
      name: 'onboardingTravel',
      desc: '',
      args: [],
    );
  }

  /// `Let us trust in you.`
  String get onboardingTitleStepOne {
    return Intl.message(
      'Let us trust in you.',
      name: 'onboardingTitleStepOne',
      desc: '',
      args: [],
    );
  }

  /// `We are a secure platform.`
  String get onboardingTitleStepTwo {
    return Intl.message(
      'We are a secure platform.',
      name: 'onboardingTitleStepTwo',
      desc: '',
      args: [],
    );
  }

  /// `We grow with you.`
  String get onboardingTitleStepThree {
    return Intl.message(
      'We grow with you.',
      name: 'onboardingTitleStepThree',
      desc: '',
      args: [],
    );
  }

  /// `We lend to you easily and quickly.`
  String get onboardingsubitleStepOne {
    return Intl.message(
      'We lend to you easily and quickly.',
      name: 'onboardingsubitleStepOne',
      desc: '',
      args: [],
    );
  }

  /// `Your personal data is protected`
  String get onboardingsubitleStepTwo {
    return Intl.message(
      'Your personal data is protected',
      name: 'onboardingsubitleStepTwo',
      desc: '',
      args: [],
    );
  }

  /// `We increase your credit limit based on your payment habits`
  String get onboardingsubitleStepThree {
    return Intl.message(
      'We increase your credit limit based on your payment habits',
      name: 'onboardingsubitleStepThree',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'es'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
