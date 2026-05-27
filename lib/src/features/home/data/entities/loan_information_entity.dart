import 'dart:io';

class LoanInformationEntity {
  final String direction;
  final String directionWayType;
  final String directionWayNumber;
  final String directionWayNumber2;
  final String directionWayNumber3;
  final String directionInterior;
  final String directionAdditionalInfo;
  final String directionCity;
  final File empInvoiceFile;
  final File ccFrontalPicture;
  final File ccBackPicture;
  final File selfiePicture;
  final String existingEmpInvoiceUrl;
  final String existingCcFrontalPictureUrl;
  final String existingCcBackPictureUrl;
  final String existingSelfiePictureUrl;
  final LoanReferenceEntity firstReference;
  final LoanReferenceEntity secondReference;
  final LoanBankAccountEntity bankInformation;
  LoanInformationEntity({
    required this.direction,
    this.directionWayType = 'Avenida',
    this.directionWayNumber = '',
    this.directionWayNumber2 = '',
    this.directionWayNumber3 = '',
    this.directionInterior = '',
    this.directionAdditionalInfo = '',
    this.directionCity = 'Medellín',
    required this.empInvoiceFile,
    required this.ccFrontalPicture,
    required this.ccBackPicture,
    required this.selfiePicture,
    this.existingEmpInvoiceUrl = '',
    this.existingCcFrontalPictureUrl = '',
    this.existingCcBackPictureUrl = '',
    this.existingSelfiePictureUrl = '',
    required this.firstReference,
    required this.secondReference,
    required this.bankInformation,
  });

  factory LoanInformationEntity.fromStoredMap(Map<String, dynamic> map) {
    final firstReferenceMap =
        (map['first_reference'] as Map<String, dynamic>?) ?? {};
    final secondReferenceMap =
        (map['second_reference'] as Map<String, dynamic>?) ?? {};
    final bankInformationMap =
        (map['bank_information'] as Map<String, dynamic>?) ?? {};

    return LoanInformationEntity(
      direction: (map['direction'] as String?) ?? '',
      directionWayType: 'Avenida',
      empInvoiceFile: File(''),
      ccFrontalPicture: File(''),
      ccBackPicture: File(''),
      selfiePicture: File(''),
      existingEmpInvoiceUrl: (map['emp_invoice_file'] as String?) ?? '',
      existingCcFrontalPictureUrl: (map['cc_frontal_picture'] as String?) ?? '',
      existingCcBackPictureUrl: (map['cc_back_picture'] as String?) ?? '',
      existingSelfiePictureUrl: (map['selfie_picture'] as String?) ?? '',
      firstReference: LoanReferenceEntity(
        phone: ((firstReferenceMap['phone'] as num?) ?? 0).toInt(),
        relationship: (firstReferenceMap['relationship'] as String?) ?? '',
      ),
      secondReference: LoanReferenceEntity(
        phone: ((secondReferenceMap['phone'] as num?) ?? 0).toInt(),
        relationship: (secondReferenceMap['relationship'] as String?) ?? '',
      ),
      bankInformation: LoanBankAccountEntity(
        bankName: (bankInformationMap['bank_name'] as String?) ?? '',
        accountType: (bankInformationMap['account_type'] as String?) ?? '',
        bankAccountNumber:
            (bankInformationMap['bank_account_number'] as String?) ?? '',
        bankAccountName:
            (bankInformationMap['bank_account_name'] as String?) ?? '',
        bankAccountLastName:
            (bankInformationMap['bank_account_last_name'] as String?) ?? '',
        bankDocumentType:
            (bankInformationMap['bank_document_type'] as String?) ?? '',
        bankDocumentNumber:
            (bankInformationMap['bank_document_number'] as String?) ?? '',
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'direction': direction,
      'first_reference': {
        'relationship': firstReference.relationship,
        'phone': firstReference.phone,
      },
      'second_reference': {
        'relationship': secondReference.relationship,
        'phone': secondReference.phone,
      },
      'bank_information': {
        'bank_name': bankInformation.bankName,
        'account_type': bankInformation.accountType,
        'bank_account_number': bankInformation.bankAccountNumber,
        'bank_account_name': bankInformation.bankAccountName,
        'bank_account_last_name': bankInformation.bankAccountLastName,
        'bank_document_type': bankInformation.bankDocumentType,
        'bank_document_number': bankInformation.bankDocumentNumber,
      },
    };
  }

  LoanInformationEntity copyWith({
    String? direction,
    String? directionWayType,
    String? directionWayNumber,
    String? directionWayNumber2,
    String? directionWayNumber3,
    String? directionInterior,
    String? directionAdditionalInfo,
    String? directionCity,
    File? empInvoiceFile,
    File? ccFrontalPicture,
    File? ccBackPicture,
    File? selfiePicture,
    String? existingEmpInvoiceUrl,
    String? existingCcFrontalPictureUrl,
    String? existingCcBackPictureUrl,
    String? existingSelfiePictureUrl,
    LoanReferenceEntity? firstReference,
    LoanReferenceEntity? secondReference,
    LoanBankAccountEntity? bankInformation,
  }) {
    return LoanInformationEntity(
      direction: direction ?? this.direction,
      directionWayType: directionWayType ?? this.directionWayType,
      directionWayNumber: directionWayNumber ?? this.directionWayNumber,
      directionWayNumber2: directionWayNumber2 ?? this.directionWayNumber2,
      directionWayNumber3: directionWayNumber3 ?? this.directionWayNumber3,
      directionInterior: directionInterior ?? this.directionInterior,
      directionAdditionalInfo:
          directionAdditionalInfo ?? this.directionAdditionalInfo,
      directionCity: directionCity ?? this.directionCity,
      empInvoiceFile: empInvoiceFile ?? this.empInvoiceFile,
      ccFrontalPicture: ccFrontalPicture ?? this.ccFrontalPicture,
      ccBackPicture: ccBackPicture ?? this.ccBackPicture,
      selfiePicture: selfiePicture ?? this.selfiePicture,
      existingEmpInvoiceUrl:
          existingEmpInvoiceUrl ?? this.existingEmpInvoiceUrl,
      existingCcFrontalPictureUrl:
          existingCcFrontalPictureUrl ?? this.existingCcFrontalPictureUrl,
      existingCcBackPictureUrl:
          existingCcBackPictureUrl ?? this.existingCcBackPictureUrl,
      existingSelfiePictureUrl:
          existingSelfiePictureUrl ?? this.existingSelfiePictureUrl,
      firstReference: firstReference ?? this.firstReference,
      secondReference: secondReference ?? this.secondReference,
      bankInformation: bankInformation ?? this.bankInformation,
    );
  }

  static LoanInformationEntity initial() => LoanInformationEntity(
        direction: '',
        empInvoiceFile: File(''),
        ccBackPicture: File(''),
        selfiePicture: File(''),
        ccFrontalPicture: File(''),
        firstReference: LoanReferenceEntity(
          phone: 0,
          relationship: "",
        ),
        secondReference: LoanReferenceEntity(
          phone: 0,
          relationship: "",
        ),
        bankInformation: LoanBankAccountEntity(
          bankName: "",
          accountType: "",
          bankAccountNumber: '',
          bankAccountName: '',
          bankAccountLastName: '',
          bankDocumentType: '',
          bankDocumentNumber: '',
        ),
      );

  bool get hasStoredDocuments =>
      existingEmpInvoiceUrl.isNotEmpty &&
      existingCcFrontalPictureUrl.isNotEmpty &&
      existingCcBackPictureUrl.isNotEmpty &&
      existingSelfiePictureUrl.isNotEmpty;

  bool get hasCapturedDocuments =>
      empInvoiceFile.path.isNotEmpty &&
      ccFrontalPicture.path.isNotEmpty &&
      ccBackPicture.path.isNotEmpty &&
      selfiePicture.path.isNotEmpty;

  bool get hasReusableProfile =>
      direction.isNotEmpty &&
      firstReference.relationship.isNotEmpty &&
      secondReference.relationship.isNotEmpty &&
      bankInformation.isCompleted &&
      (hasCapturedDocuments || hasStoredDocuments);

  bool get isLoanInformationCompleted =>
      direction.isNotEmpty &&
      (empInvoiceFile.path.isNotEmpty || existingEmpInvoiceUrl.isNotEmpty) &&
      (ccFrontalPicture.path.isNotEmpty ||
          existingCcFrontalPictureUrl.isNotEmpty) &&
      (ccBackPicture.path.isNotEmpty || existingCcBackPictureUrl.isNotEmpty) &&
      (selfiePicture.path.isNotEmpty || existingSelfiePictureUrl.isNotEmpty) &&
      firstReference.relationship.isNotEmpty &&
      secondReference.relationship.isNotEmpty &&
      bankInformation.isCompleted;
}

class LoanReferenceEntity {
  final String relationship;
  final int phone;
  LoanReferenceEntity({
    required this.relationship,
    required this.phone,
  });
  LoanReferenceEntity copyWith({
    String? name,
    String? relationship,
    int? phone,
  }) {
    return LoanReferenceEntity(
      relationship: relationship ?? this.relationship,
      phone: phone ?? this.phone,
    );
  }
}

class LoanBankAccountEntity {
  final String bankAccountName;
  final String bankAccountLastName;
  final String bankDocumentType;
  final String bankDocumentNumber;
  final String bankName;
  final String accountType;
  final String bankAccountNumber;

  bool get isCompleted =>
      bankAccountName.isNotEmpty &&
      bankAccountLastName.isNotEmpty &&
      bankDocumentType.isNotEmpty &&
      bankDocumentNumber.isNotEmpty &&
      bankName.isNotEmpty &&
      accountType.isNotEmpty &&
      bankAccountNumber.isNotEmpty;

  LoanBankAccountEntity({
    required this.bankName,
    required this.accountType,
    required this.bankAccountNumber,
    required this.bankAccountName,
    required this.bankAccountLastName,
    required this.bankDocumentType,
    required this.bankDocumentNumber,
  });
  LoanBankAccountEntity copyWith({
    String? bankAccountName,
    String? bankAccountLastName,
    String? bankDocumentType,
    String? bankDocumentNumber,
    String? bankName,
    String? accountType,
    String? bankAccountNumber,
  }) {
    return LoanBankAccountEntity(
      bankAccountName: bankAccountName ?? this.bankAccountName,
      bankAccountLastName: bankAccountLastName ?? this.bankAccountLastName,
      bankDocumentType: bankDocumentType ?? this.bankDocumentType,
      bankDocumentNumber: bankDocumentNumber ?? this.bankDocumentNumber,
      bankName: bankName ?? this.bankName,
      accountType: accountType ?? this.accountType,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
    );
  }
}
