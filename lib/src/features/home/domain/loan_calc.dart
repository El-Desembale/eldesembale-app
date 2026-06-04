// Motor de cálculo de créditos y cuotas (espejo de loan-calc.ts de web/admin).
//
// El costo del crédito es 10% mensual sobre el capital inicial (no sobre saldo) por los meses
// de plazo, dividido en interés / plataforma / administrativo. Sobre cada cuota se aplica el
// gross-up de Wompi para que la empresa reciba la cuota completa; el cliente no ve Wompi como
// concepto: queda absorbido dentro de "Plataforma". Se calcula una sola vez al crear el crédito.

class PricingSplit {
  final double interes;
  final double plataforma;
  final double administrativo;
  const PricingSplit({
    required this.interes,
    required this.plataforma,
    required this.administrativo,
  });
}

class WompiFees {
  final double porcentaje;
  final double fijo;
  final double iva;
  const WompiFees({
    required this.porcentaje,
    required this.fijo,
    required this.iva,
  });
}

class LoanPricingConfig {
  final double interesMensual;
  final PricingSplit split;
  final WompiFees wompi;
  const LoanPricingConfig({
    required this.interesMensual,
    required this.split,
    required this.wompi,
  });
}

const LoanPricingConfig kDefaultPricingConfig = LoanPricingConfig(
  interesMensual: 0.10,
  split: PricingSplit(interes: 0.5, plataforma: 0.3, administrativo: 0.2),
  wompi: WompiFees(porcentaje: 0.0265, fijo: 700, iva: 0.19),
);

class InstallmentBreakdown {
  final int numeroCuota;
  final DateTime fechaVencimiento;
  final int capital;
  final int interes;
  final int plataforma;
  final int administrativo;
  final int costosCredito;
  final int cuotaCredito;
  final int comisionWompi;
  final int totalCliente;
  final int plataformaCliente;
  const InstallmentBreakdown({
    required this.numeroCuota,
    required this.fechaVencimiento,
    required this.capital,
    required this.interes,
    required this.plataforma,
    required this.administrativo,
    required this.costosCredito,
    required this.cuotaCredito,
    required this.comisionWompi,
    required this.totalCliente,
    required this.plataformaCliente,
  });

  Map<String, dynamic> toMap() => {
        'numero_cuota': numeroCuota,
        'fecha_vencimiento': fechaVencimiento.toIso8601String(),
        'capital': capital,
        'interes': interes,
        'plataforma': plataforma,
        'administrativo': administrativo,
        'costos_credito': costosCredito,
        'cuota_credito': cuotaCredito,
        'comision_wompi': comisionWompi,
        'total_cliente': totalCliente,
        'plataforma_cliente': plataformaCliente,
      };

  static int _int(dynamic v) => (v is num) ? v.round() : 0;
  static DateTime _date(dynamic v) {
    if (v is DateTime) return v;
    if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
    // Firestore Timestamp
    try {
      return (v as dynamic).toDate() as DateTime;
    } catch (_) {
      return DateTime.now();
    }
  }

  factory InstallmentBreakdown.fromMap(Map<String, dynamic> m) =>
      InstallmentBreakdown(
        numeroCuota: _int(m['numero_cuota']),
        fechaVencimiento: _date(m['fecha_vencimiento']),
        capital: _int(m['capital']),
        interes: _int(m['interes']),
        plataforma: _int(m['plataforma']),
        administrativo: _int(m['administrativo']),
        costosCredito: _int(m['costos_credito']),
        cuotaCredito: _int(m['cuota_credito']),
        comisionWompi: _int(m['comision_wompi']),
        totalCliente: _int(m['total_cliente']),
        plataformaCliente: _int(m['plataforma_cliente']),
      );
}

class LoanPricing {
  final int version;
  final int capital;
  final int numeroCuotas;
  final double mesesPlazo;
  final String paymentPeriod;
  final double interesMensual;
  final PricingSplit split;
  final WompiFees wompi;
  final int costoTotalCredito;
  final int interesTotal;
  final int plataformaTotal;
  final int administrativoTotal;
  final int wompiTotal;
  final int totalCreditoSinWompi;
  final int totalCliente;
  final List<InstallmentBreakdown> installments;
  const LoanPricing({
    required this.version,
    required this.capital,
    required this.numeroCuotas,
    required this.mesesPlazo,
    required this.paymentPeriod,
    required this.interesMensual,
    required this.split,
    required this.wompi,
    required this.costoTotalCredito,
    required this.interesTotal,
    required this.plataformaTotal,
    required this.administrativoTotal,
    required this.wompiTotal,
    required this.totalCreditoSinWompi,
    required this.totalCliente,
    required this.installments,
  });

  Map<String, dynamic> toMap() => {
        'version': version,
        'capital': capital,
        'numero_cuotas': numeroCuotas,
        'meses_plazo': mesesPlazo,
        'payment_period': paymentPeriod,
        'interes_mensual': interesMensual,
        'split': {
          'interes': split.interes,
          'plataforma': split.plataforma,
          'administrativo': split.administrativo,
        },
        'wompi': {
          'porcentaje': wompi.porcentaje,
          'fijo': wompi.fijo,
          'iva': wompi.iva,
        },
        'costo_total_credito': costoTotalCredito,
        'interes_total': interesTotal,
        'plataforma_total': plataformaTotal,
        'administrativo_total': administrativoTotal,
        'wompi_total': wompiTotal,
        'total_credito_sin_wompi': totalCreditoSinWompi,
        'total_cliente': totalCliente,
        'installments': installments.map((c) => c.toMap()).toList(),
      };

  static int _int(dynamic v) => (v is num) ? v.round() : 0;
  static double _dbl(dynamic v, double fallback) =>
      (v is num) ? v.toDouble() : fallback;

  /// Reconstruye el desglose desde el doc de Firestore. Devuelve null si no hay datos.
  static LoanPricing? fromMap(Map<String, dynamic>? m) {
    if (m == null) return null;
    final split = (m['split'] as Map<String, dynamic>?) ?? const {};
    final wompi = (m['wompi'] as Map<String, dynamic>?) ?? const {};
    final rawList = (m['installments'] as List<dynamic>?) ?? const [];
    return LoanPricing(
      version: _int(m['version']),
      capital: _int(m['capital']),
      numeroCuotas: _int(m['numero_cuotas']),
      mesesPlazo: _dbl(m['meses_plazo'], 0),
      paymentPeriod: (m['payment_period'] as String?) ?? 'Mensual',
      interesMensual: _dbl(m['interes_mensual'], 0.10),
      split: PricingSplit(
        interes: _dbl(split['interes'], 0.5),
        plataforma: _dbl(split['plataforma'], 0.3),
        administrativo: _dbl(split['administrativo'], 0.2),
      ),
      wompi: WompiFees(
        porcentaje: _dbl(wompi['porcentaje'], 0.0265),
        fijo: _dbl(wompi['fijo'], 700),
        iva: _dbl(wompi['iva'], 0.19),
      ),
      costoTotalCredito: _int(m['costo_total_credito']),
      interesTotal: _int(m['interes_total']),
      plataformaTotal: _int(m['plataforma_total']),
      administrativoTotal: _int(m['administrativo_total']),
      wompiTotal: _int(m['wompi_total']),
      totalCreditoSinWompi: _int(m['total_credito_sin_wompi']),
      totalCliente: _int(m['total_cliente']),
      installments: rawList
          .map((e) => InstallmentBreakdown.fromMap(
              Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

/// Meses de plazo cobrados: Quincenal cobra medio mes por cuota; Mensual un mes por cuota.
double mesesPlazo(int numeroCuotas, String paymentPeriod) {
  return paymentPeriod == 'Quincenal' ? numeroCuotas / 2 : numeroCuotas.toDouble();
}

/// Fecha de vencimiento de la cuota [index] (0-based). La primera vence ~30 días después
/// (mes siguiente, mismo día); las siguientes son mensuales o quincenales (+15 días).
DateTime installmentDueDate(DateTime base, int index, String paymentPeriod) {
  final first = DateTime(base.year, base.month + 1, base.day);
  if (paymentPeriod == 'Mensual') {
    return DateTime(first.year, first.month + index, first.day);
  }
  return first.add(Duration(days: 15 * index));
}

/// Gross-up de Wompi: total a cobrar al cliente para que la empresa reciba [cuotaCredito].
double grossUpWompi(double cuotaCredito, WompiFees wompi) {
  final ivaFactor = 1 + wompi.iva;
  return (cuotaCredito + wompi.fijo * ivaFactor) /
      (1 - wompi.porcentaje * ivaFactor);
}

/// Calcula el desglose completo. Redondea a pesos enteros y ajusta las diferencias por
/// redondeo en la última cuota para que la suma de las cuotas coincida con los totales.
LoanPricing computeLoanPricing({
  required double capital,
  required int numeroCuotas,
  required String paymentPeriod,
  required DateTime fechaDesembolso,
  LoanPricingConfig config = kDefaultPricingConfig,
}) {
  final n = numeroCuotas;
  final meses = mesesPlazo(n, paymentPeriod);

  final costoTotalCredito = (capital * config.interesMensual * meses).round();
  final interesTotal = costoTotalCredito * config.split.interes;
  final plataformaTotal = costoTotalCredito * config.split.plataforma;
  final administrativoTotal = costoTotalCredito * config.split.administrativo;

  final capitalCuota = capital / n;
  final interesCuota = interesTotal / n;
  final plataformaCuota = plataformaTotal / n;
  final administrativoCuota = administrativoTotal / n;
  final cuotaCreditoPreciso =
      capitalCuota + interesCuota + plataformaCuota + administrativoCuota;
  final totalClientePreciso = grossUpWompi(cuotaCreditoPreciso, config.wompi);

  final capitalRedondeado = capital.round();
  final interesRedondeado = interesTotal.round();
  final plataformaRedondeado = plataformaTotal.round();
  final administrativoRedondeado = administrativoTotal.round();
  final totalClienteRedondeado = (totalClientePreciso * n).round();
  final costosRedondeado =
      interesRedondeado + plataformaRedondeado + administrativoRedondeado;

  var accCapital = 0;
  var accInteres = 0;
  var accPlataforma = 0;
  var accAdministrativo = 0;
  var accComisionWompi = 0;
  var accTotalCliente = 0;

  final installments = <InstallmentBreakdown>[];

  for (var i = 0; i < n; i++) {
    final isLast = i == n - 1;

    final capitalI =
        isLast ? capitalRedondeado - accCapital : capitalCuota.round();
    final interesI =
        isLast ? interesRedondeado - accInteres : interesCuota.round();
    final plataformaI = isLast
        ? plataformaRedondeado - accPlataforma
        : plataformaCuota.round();
    final administrativoI = isLast
        ? administrativoRedondeado - accAdministrativo
        : administrativoCuota.round();
    final costosCreditoI = interesI + plataformaI + administrativoI;
    final cuotaCreditoI = capitalI + costosCreditoI;
    final totalClienteI = isLast
        ? totalClienteRedondeado - accTotalCliente
        : totalClientePreciso.round();
    final comisionWompiI = totalClienteI - cuotaCreditoI;
    final plataformaClienteI = plataformaI + comisionWompiI;

    accCapital += capitalI;
    accInteres += interesI;
    accPlataforma += plataformaI;
    accAdministrativo += administrativoI;
    accComisionWompi += comisionWompiI;
    accTotalCliente += totalClienteI;

    installments.add(InstallmentBreakdown(
      numeroCuota: i + 1,
      fechaVencimiento: installmentDueDate(fechaDesembolso, i, paymentPeriod),
      capital: capitalI,
      interes: interesI,
      plataforma: plataformaI,
      administrativo: administrativoI,
      costosCredito: costosCreditoI,
      cuotaCredito: cuotaCreditoI,
      comisionWompi: comisionWompiI,
      totalCliente: totalClienteI,
      plataformaCliente: plataformaClienteI,
    ));
  }

  return LoanPricing(
    version: 1,
    capital: capitalRedondeado,
    numeroCuotas: n,
    mesesPlazo: meses,
    paymentPeriod: paymentPeriod,
    interesMensual: config.interesMensual,
    split: config.split,
    wompi: config.wompi,
    costoTotalCredito: costoTotalCredito,
    interesTotal: interesRedondeado,
    plataformaTotal: plataformaRedondeado,
    administrativoTotal: administrativoRedondeado,
    wompiTotal: accComisionWompi,
    totalCreditoSinWompi: capitalRedondeado + costosRedondeado,
    totalCliente: accTotalCliente,
    installments: installments,
  );
}
