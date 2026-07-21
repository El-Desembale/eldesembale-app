import 'package:flutter_test/flutter_test.dart';
import 'package:desembale/src/features/home/domain/loan_calc.dart';

void main() {
  group('loan_calc', () {
    // Ejemplo del spec: capital 1.000.000, 4 cuotas quincenales -> 2 meses de plazo.
    final p = computeLoanPricing(
      capital: 1000000,
      numeroCuotas: 4,
      paymentPeriod: 'Quincenal',
      fechaDesembolso: DateTime(2026, 1, 1),
    );

    test('meses_plazo según período', () {
      expect(mesesPlazo(4, 'Quincenal'), 2);
      expect(mesesPlazo(4, 'Mensual'), 4);
      expect(mesesPlazo(2, 'Mensual'), 2);
    });

    test('costo total = 200.000 y split 100k/60k/40k', () {
      expect(p.costoTotalCredito, 200000);
      expect(p.interesTotal, 100000);
      expect(p.plataformaTotal, 60000);
      expect(p.administrativoTotal, 40000);
      expect(p.totalCreditoSinWompi, 1200000);
    });

    test('4 cuotas, cada cuotaCredito = 300.000', () {
      expect(p.installments.length, 4);
      for (final c in p.installments) {
        expect(c.capital, 250000);
        expect(c.interes, 25000);
        expect(c.plataforma, 15000);
        expect(c.administrativo, 10000);
        expect(c.costosCredito, 50000);
        expect(c.cuotaCredito, 300000);
      }
    });

    test('Wompi gross-up por cuota según fórmula', () {
      final esperado = grossUpWompi(300000, kDefaultPricingConfig.wompi).round();
      expect(p.installments[0].totalCliente, esperado);
      expect(p.installments[0].comisionWompi, esperado - 300000);
    });

    test('plataformaCliente = plataforma + comisionWompi (Wompi absorbido)', () {
      for (final c in p.installments) {
        expect(c.plataformaCliente, c.plataforma + c.comisionWompi);
      }
    });

    test('identidad: suma de cuotas == totales', () {
      int sum(int Function(InstallmentBreakdown) f) =>
          p.installments.fold(0, (a, c) => a + f(c));
      expect(sum((c) => c.capital), p.capital);
      expect(sum((c) => c.interes), p.interesTotal);
      expect(sum((c) => c.plataforma), p.plataformaTotal);
      expect(sum((c) => c.administrativo), p.administrativoTotal);
      expect(sum((c) => c.comisionWompi), p.wompiTotal);
      expect(sum((c) => c.totalCliente), p.totalCliente);
      expect(p.totalCliente, p.capital + 200000 + p.wompiTotal);
    });

    test('redondeo con capital no divisible: cuadra al peso', () {
      final q = computeLoanPricing(
        capital: 333333,
        numeroCuotas: 3,
        paymentPeriod: 'Mensual',
        fechaDesembolso: DateTime(2026, 1, 1),
      );
      int sum(int Function(InstallmentBreakdown) f) =>
          q.installments.fold(0, (a, c) => a + f(c));
      expect(sum((c) => c.capital), q.capital);
      expect(sum((c) => c.totalCliente), q.totalCliente);
      expect(q.totalCliente, q.capital + q.costoTotalCredito + q.wompiTotal);
    });

    test('fechas: primera quincenal a 15 días', () {
      expect(p.installments[0].fechaVencimiento, DateTime(2026, 1, 16));
      final d0 = p.installments[0].fechaVencimiento;
      final d1 = p.installments[1].fechaVencimiento;
      expect(d1.difference(d0).inDays, 15);
    });
  });
}
