import 'dart:io';

class LoanInformationEntity {
  final String direction;
  final File empInvoiceFile;
  final File ccFrontalPicture;
  final File ccBackPicture;
  final File selfiePicture;
  final LoanReferenceEntity firstReference;
  final LoanReferenceEntity secondReference;
  final LoanBankAccountEntity bankInformation;
  LoanInformationEntity({
    required this.direction,
    required this.empInvoiceFile,
    required this.ccFrontalPicture,
    required this.ccBackPicture,
    required this.selfiePicture,
    required this.firstReference,
    required this.secondReference,
    required this.bankInformation,
  });
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
    File? empInvoiceFile,
    File? ccFrontalPicture,
    File? ccBackPicture,
    File? selfiePicture,
    LoanReferenceEntity? firstReference,
    LoanReferenceEntity? secondReference,
    LoanBankAccountEntity? bankInformation,
  }) {
    return LoanInformationEntity(
      direction: direction ?? this.direction,
      empInvoiceFile: empInvoiceFile ?? this.empInvoiceFile,
      ccFrontalPicture: ccFrontalPicture ?? this.ccFrontalPicture,
      ccBackPicture: ccBackPicture ?? this.ccBackPicture,
      selfiePicture: selfiePicture ?? this.selfiePicture,
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
  bool get isLoanInformationCompleted =>
      direction.isNotEmpty &&
      empInvoiceFile.path.isNotEmpty &&
      ccFrontalPicture.path.isNotEmpty &&
      ccBackPicture.path.isNotEmpty &&
      selfiePicture.path.isNotEmpty &&
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
